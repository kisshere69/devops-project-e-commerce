# Project Troubleshooting & Incident Log

This document records the main technical problems encountered during development and deployment.

---

# 1. Application Configuration (Python, Flask)

## 1.1 `psycopg` rejected the `postgresql+psycopg://` URL

### Symptom

The Flask application failed when connecting to PostgreSQL from Amazon EKS. The error indicated that the PostgreSQL connection string was not valid for `psycopg`.

### Root cause

The application received a SQLAlchemy-style URL:

```text
postgresql+psycopg://...
```

but `psycopg.connect()` expected a PostgreSQL connection string such as:

```text
postgresql://...
```

### Resolution

Normalize the URL before connecting:

```python
database_url = DATABASE_URL.replace(
    "postgresql+psycopg://",
    "postgresql://",
)

return psycopg.connect(database_url)
```

### Lesson

Different libraries can use different database URL dialects. A connection string that is valid for SQLAlchemy is not necessarily accepted directly by the underlying PostgreSQL driver.

---

## 1.2 Application used `localhost:5432` inside Kubernetes

### Symptom

`/health/db` returned HTTP 500.

The application attempted to connect to:

```text
127.0.0.1:5432
```

instead of the Amazon RDS endpoint.

### Root cause

The original Python configuration had a local fallback:

```text
postgresql://coffee:coffee@localhost:5432/coffee_shop
```

This works with Docker Compose, but inside a Kubernetes Pod `localhost` means the application container itself.

The production database was Amazon RDS, not a PostgreSQL container inside the same Pod.

### Resolution

The application was changed to prefer the CSI-mounted secret:

```text
/mnt/secrets-store/DATABASE_URL
```

and only use the local environment/fallback when that file does not exist.

### Lesson

A local-development database configuration must not silently become the production Kubernetes configuration.

---

## 1.3 Local and AWS database credentials were different

### Symptom

The application worked locally but the RDS connection could not use the local `coffee` credentials.

### Root cause

Local containerized PostgreSQL used:

```text
user: coffee
password: coffee
database: coffee_shop
host: localhost
```

Amazon RDS used a Terraform-generated master password and:

```text
user: roast_admin
database: coffee_shop
```

### Resolution

AWS credentials were stored in Secrets Manager and exposed to Kubernetes through the CSI driver.

### Lesson

Local and cloud environments can legitimately have different credentials. Configuration should be injected rather than hardcoded into application code.

---

# 2. PostgreSQL / Alembic

## 2.1 Migration Job failed because the seed was not idempotent

### Symptom

The Kubernetes migration Job initially failed when the seed was executed against a database where the products already existed.

### Root cause

The seed inserted explicit product IDs and was not safe to execute more than once.

### Resolution

The seed was changed to use:

```sql
ON CONFLICT (id) DO UPDATE
```

and the PostgreSQL sequence was synchronized:

```sql
SELECT setval(
    pg_get_serial_sequence('products', 'id'),
    COALESCE((SELECT MAX(id) FROM products), 1)
);
```

### Lesson

A bootstrap process that may be retried should be idempotent.

---

# 3. Docker / Docker Compose

## 3.1 PostgreSQL data persisted after `docker compose down`

### Symptom

The PostgreSQL container was recreated but previous database data was still present.

### Root cause

A named Docker volume was used:

```yaml
volumes:
  postgres_data:
```

### Resolution

Normal shutdown:

```bash
docker compose down
```

removes containers but keeps the volume.

To intentionally remove the database data:

```bash
docker compose down -v
```

### Lesson

Persistent volumes are independent of containers. This is desirable for normal local development, but can surprise you when testing a completely clean database `:)`.

---

## 3.2 Docker build dependency caching confusion

### Symptom

I noticed that:

```dockerfile
RUN pip install --no-cache-dir -r requirements.txt
```

appeared to download dependencies during builds.

`--no-cache-dir` disables pip's package download cache. It does **not** disable Docker layer caching.

Docker can still reuse the entire `RUN pip install...` layer when previous Dockerfile layers have not changed.

### Lesson

Docker layer caching and pip package caching are two different mechanisms.

---

# 4. Kubernetes

## 4.1 Application Pods used the default ServiceAccount

### Symptom

The Secrets Store CSI integration could not obtain the expected AWS permissions for the application.

### Root cause

The Deployment initially did not explicitly specify:

```yaml
serviceAccountName: roast-co-app
```

Therefore the Pod used the default ServiceAccount.

### Resolution

The Deployment was changed to:

```yaml
spec:
  template:
    spec:
      serviceAccountName: roast-co-app
```

Terraform then associated that ServiceAccount with the application's IAM role through EKS Pod Identity.

### Lesson

Kubernetes ServiceAccounts are part of the application's AWS identity configuration. If the wrong ServiceAccount is used, IAM permissions may appear to be missing even when the IAM role itself is correct.

---

## 4.2 Secrets Store CSI reported missing ServiceAccount role association

### Symptom

The CSI provider produced an error similar to:

```text
The token included in the request has no service account role association for it.
```

### Root cause

The Pod's Kubernetes ServiceAccount did not have the expected EKS Pod Identity association.

### Resolution

Separate ServiceAccounts were created:

```text
roast-co-app
db-migration
```

and Terraform created corresponding Pod Identity associations.

### Lesson

For AWS Pod Identity, verify the entire chain:

- Pod
- ServiceAccount
- Pod Identity association
- IAM role
- IAM permissions
- AWS resource

---

# 5. AWS EKS

## 5.1 EKS Node Group `NodeCreationFailure`

### Symptom

The EKS managed node group failed to create worker nodes.

### Resolution

The infrastructure was fully destroyed and recreated.

The subsequent deployment successfully created the node group.

### Lesson

Some managed AWS provisioning failures can be transient. Before changing architecture, inspect:

```bash
kubectl get nodes
```

and AWS/EKS node group events and determine whether the failure is persistent.

A clean rebuild can also distinguish infrastructure configuration problems from transient AWS provisioning problems.

---

# 6. AWS IAM / EKS Pod Identity

## 6.1 Application needed its own IAM role

### Symptom

The migration workload could access the database secret, but the application needed the same capability independently.

### Root cause

The migration Job and application had different responsibilities and should not share one workload identity.

### Resolution

A separate application IAM role and policy were created.

The application policy allows:

```text
secretsmanager:GetSecretValue
secretsmanager:DescribeSecret
```

only for the RDS credentials secret.

The application ServiceAccount:

```text
roast-co-app
```

was associated with this IAM role.

### Lesson

As a result, I spent time digging into code. Separation of workload identities makes troubleshooting and permissions much clearer.

---

## 6.2 Duplicate / conflicting OIDC provider concern

### Context

During GitHub Actions OIDC setup, an existing AWS OIDC provider for:

```text
token.actions.githubusercontent.com
```

was already present. This was associated with the previous project configuration.

### Risk

A Terraform module could attempt to create another provider instead of reusing the existing one.

### Resolution

The old development OIDC module was reviewed so Terraform would not attempt to create a second provider.

### Lesson

AWS account-level identity resources should be treated carefully when modules are destroyed/recreated.

---

# 7. AWS ECR

## 7.1 Application image had to be rebuilt and pushed after code changes

### Symptom

Kubernetes continued running the previous application code even after the source code changed.

### Root cause

The EKS Deployment runs a Docker image, not the local source tree.

Changing Python code alone does not change the running container.

### Resolution

Build and push a new image with a commit-SHA tag, then update:

```yaml
image: .../roast-co-app:<COMMIT_SHA>
```

and apply the Deployment.

### Lesson

The immutable image is the deployment artifact.

---

# 8. AWS ALB / Kubernetes Ingress

## 8.1 Ingress failed because of an old ACM certificate ARN

### Symptom

The AWS Load Balancer Controller reported certificate-related reconciliation errors.

### Root cause

The infrastructure had previously been destroyed and recreated.

The old certificate ARN was no longer the certificate associated with the current environment.

Old:

```text
arn:aws:acm:eu-central-1:215229808174:certificate/660ba418-e41b-4db7-86c5-921ec324e841
```

Current:

```text
arn:aws:acm:eu-central-1:215229808174:certificate/25b7a1f9-5c77-493a-af48-5d1e9420a36f
```

### Resolution

Find the current certificate:

```bash
aws acm list-certificates \
  --region eu-central-1 \
  --query 'CertificateSummaryList[?DomainName==`roast-and-co.online`].[CertificateArn,DomainName]' \
  --output table
```

Update `k8s/ingress.yaml` and reapply it:

```bash
kubectl apply -f k8s/ingress.yaml
```

### Lesson

AWS ARNs are resource-specific and can become stale after resource replacement. Never assume an ARN remains valid after destroying/recreating infrastructure.

---

## 8.2 ALB was not immediately available

### Symptom

The Ingress initially did not have a usable ALB address.

### Diagnosis

Inspect:

```bash
kubectl get ingress -n dev
kubectl describe ingress roast-co-dev-ingress -n dev
```

and inspect AWS Load Balancer Controller logs.

### Resolution

After the controller and required AWS resources were healthy, the Ingress reconciled successfully.

### Lesson

For Kubernetes-managed AWS resources, `kubectl describe` events are often the fastest way to identify the reconciliation failure.

---

# 9. AWS Networking / Terraform Destroy

## 9.1 Internet Gateway could not be deleted

### Error

Terraform destroy reported:

```bash
Error: deleting EC2 Internet Gateway ...
DependencyViolation:
Network vpc-0b6085921712a6cdb has some mapped public address(es).
Please unmap those public address(es) before detaching the gateway.
```

### Root cause

The VPC still had public addresses associated with resources.

AWS therefore refused to detach the Internet Gateway.

### Meaning

This is a dependency-order problem during teardown.

The Internet Gateway cannot be detached while the VPC still has mapped public addresses.

### Troubleshooting

Inspect public IP/EIP resources and the dependent resources:

```bash
aws ec2 describe-addresses \
  --region eu-central-1
```

Also inspect remaining network interfaces/resources in the VPC.

### Lesson

`terraform destroy` is dependency-aware, but AWS can still reject deletion when a managed service or network resource has not completely released its dependencies.

---

## 9.2 Subnets could not be deleted

### Error

Terraform reported:

```text
Error: deleting EC2 Subnet ...
DependencyViolation:
The subnet 'subnet-...' has dependencies and cannot be deleted.
```

### Root cause

Resources were still attached to or dependent on the subnet.

Typical examples include:

- network interfaces
- load balancers
- NAT-related resources
- managed AWS services
- Kubernetes-created AWS resources

### Troubleshooting

First identify remaining resources associated with the subnet.

```bash
aws ec2 describe-network-interfaces \
  --region eu-central-1 \
  --filters Name=subnet-id,Values=<SUBNET_ID>
```

Also inspect:

```bash
kubectl get ingress -A
```

### Lesson

When a subnet refuses deletion, do not immediately delete the subnet manually. Find the dependency first.

---

# 10. AWS ACM Destroy

## 10.1 ACM certificate was still in use

### Error

Terraform reported:

```bash
Error: deleting ACM Certificate ...
ResourceInUseException:
Certificate ... is in use.
```

### Root cause

The ACM certificate was still attached to an AWS resource, most importantly the HTTPS ALB listener.

### Resolution

The resource using the certificate must be removed first.

For this project, inspect the Kubernetes Ingress and ALB:

```bash
kubectl get ingress -n dev
kubectl describe ingress roast-co-dev-ingress -n dev
```

Then verify the AWS ALB and listener before retrying deletion.

### Lesson

AWS resources created indirectly by Kubernetes can outlive the Kubernetes object for a short period during controller reconciliation.

A destroy operation may therefore need to be retried after dependent resources are fully removed.

---

# 11. Kubernetes / AWS Resource Lifecycle

## 11.1 Terraform destroy encountered resources created by Kubernetes

### Context

The project contains two infrastructure management layers:

### Terraform-managed

Examples:

- VPC
- subnets
- NAT Gateway
- EKS
- node group
- RDS
- ECR
- IAM
- Secrets Manager
- EKS Pod Identity
- Helm releases

### Kubernetes-managed

Examples:

- Namespace
- Deployment
- Service
- Ingress
- migration Job
- ServiceAccounts
- SecretProviderClass

The AWS ALB Controller creates AWS resources from Kubernetes objects.

### Problem

If Kubernetes-created AWS resources still exist when Terraform tries to destroy the underlying networking infrastructure, AWS can reject deletion with `DependencyViolation` or `ResourceInUseException`.

### Lesson

When destroying an environment, Kubernetes resources can create AWS resources.

Therefore Kubernetes cleanup can be part of AWS infrastructure teardown.

---

# 12. Cloudflare / DNS

## 12.1 Root domain initially needed to point to the current ALB

### Context

The AWS ALB hostname changes when the ALB is recreated.

Current architecture:

```text
roast-and-co.online → Cloudflare → AWS ALB → Amazon EKS
```

### Problem

After infrastructure recreation, the previous ALB hostname may no longer be valid.

### Resolution

Find the current Ingress address:

```bash
kubectl get ingress -n dev
```

and update the Cloudflare root-domain CNAME target to the current ALB hostname.

### Lesson

A Kubernetes-created ALB is not a stable endpoint across infrastructure recreation. DNS must point to the current ALB hostname.

---

# 13. Temporary `pg-client` Debug Pod

## Purpose

A temporary Pod was used during troubleshooting:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pg-client
  namespace: dev
spec:
  serviceAccountName: db-migration
  restartPolicy: Never
  containers:
    - name: pg-client
      image: postgres:16.15-alpine
      command: ["sleep", "300"]
```

It mounted:

```text
/mnt/secrets-store
```

through the same CSI SecretProviderClass.

### Why it was useful

It allowed independent testing of:

- ServiceAccount
- EKS Pod Identity
- Secrets Store CSI
- `DATABASE_URL`
- PostgreSQL client connectivity
- RDS network access

without involving Flask.

### Current status

The real migration Job now tests the same integration as part of the deployment.

### Lesson

Debug Pods can be useful as troubleshooting tools.

---

# 14. Important Diagnostic Commands Used

## Kubernetes

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl get pods -n dev
kubectl describe pod <POD> -n dev
kubectl describe ingress <INGRESS> -n dev
kubectl logs <POD> -n dev
kubectl logs deployment/roast-co -n dev
kubectl get events -n dev --sort-by=.lastTimestamp
```

## AWS

```bash
aws sts get-caller-identity

aws ec2 describe-network-interfaces \
  --region eu-central-1

aws ec2 describe-addresses \
  --region eu-central-1

aws acm list-certificates \
  --region eu-central-1

aws ecr describe-repositories \
  --region eu-central-1
```

## Terraform

```bash
terraform plan
terraform apply
terraform destroy
terraform state list
terraform output
```

---

# 15. General Troubleshooting Method Learned From the Project

When something fails, do not immediately modify configuration.

Use this order:

## 1. Identify the exact symptom

Example:

```text
HTTP 500
```

is not a root cause.

Determine whether the failure is:

- application
- Kubernetes
- network
- IAM
- secret
- database
- AWS resource
- DNS

## 2. Check the closest component

For an application failure:

```bash
kubectl logs deployment/roast-co -n dev
```

For an Ingress failure:

```bash
kubectl describe ingress -n dev
```

For a Pod failure:

```bash
kubectl describe pod <POD> -n dev
```

## 3. Follow the dependency chain

For the application database:

```text
Pod
→ ServiceAccount
→ Pod Identity
→ IAM role
→ Secrets Manager
→ CSI
→ DATABASE_URL
→ RDS network
→ PostgreSQL
```

A failure anywhere in the chain can appear to the application as simply "database unavailable".

## 4. Separate control-plane problems from application problems

For example:

- "Ingress has no ALB" is an infrastructure problem.

- "ALB returns 502" can be a target, application or service problem.

- "Application returns 500" is likely inside the application or its dependencies.

---

# 16. Most Important Lessons From the Project

1. **Kubernetes resources can create AWS resources.** Destroy dependencies in the correct lifecycle order.

2. **AWS ARNs are not necessarily stable.** Recreated resources can receive completely different ARNs.

3. **ServiceAccount identity matters.** A correct IAM policy is meaningless if the Pod uses the wrong ServiceAccount.

4. **Secrets Manager, Pod Identity and CSI form a chain.** Troubleshoot each layer independently.

5. **Database seeds should be idempotent.** Kubernetes Jobs may be retried.

6. **Immutable image tags make debugging easier.** A commit SHA tells you the exact application version currently running.

7.  **Logs and events are primary diagnostic tools.** `kubectl describe`, `kubectl logs`, Terraform errors, and AWS API errors often provide enough information to identify the failing layer.

8.  **A symptom is not a root cause.** `HTTP 500`, `Pending`, `DependencyViolation`, or `database unreachable` are only starting points for investigation.

---

# 17. Terraform Destroy Blocked by Orphaned Kubernetes AWS Resources

## Incident Summary

During a full `terraform destroy`, the VPC could not initially be removed because AWS resources created indirectly by Kubernetes were still present.

Initial errors included:

```bash
DependencyViolation:
Network vpc-0b6085921712a6cdb has some mapped public address(es).
Please unmap those public address(es) before detaching the gateway.
```

```bash
ResourceInUseException:
Certificate ... is in use.
```

```bash
DependencyViolation:
The subnet 'subnet-...' has dependencies and cannot be deleted.
```

The EKS API was already unavailable:

```bash
kubectl get ingress -A
Unable to connect to the server:
dial tcp: lookup ...eks.amazonaws.com: no such host
```

Therefore the Kubernetes Ingress could no longer be deleted with `kubectl`.

## Investigation

### 1. Identify the public addresses

```bash
aws ec2 describe-addresses \
  --region eu-central-1 \
  --output table
```

Two public IPs were found:

```text
3.64.93.68
63.188.128.87
```

Both were marked:

```text
ServiceManaged: alb
```

### 2. Identify the network interfaces

```bash
aws ec2 describe-network-interfaces \
  --region eu-central-1 \
  --filters Name=vpc-id,Values=vpc-0b6085921712a6cdb \
  --query 'NetworkInterfaces[*].[NetworkInterfaceId,SubnetId,Description,Association.PublicIp,Status]' \
  --output table
```

The ENIs belonged to:

```text
ELB app/k8s-dev-roastcod-874ea519b1/e147c50a53f954e6
```

with:

```text
RequesterId: amazon-elb
RequesterManaged: True
```

This proved that the remaining networking resources were associated with the Kubernetes-created ALB.

### 3. Find the ALB

```bash
aws elbv2 describe-load-balancers \
  --region eu-central-1 \
  --query 'LoadBalancers[?LoadBalancerName==`k8s-dev-roastcod-874ea519b1`].[LoadBalancerArn,DNSName,State.Code]' \
  --output table
```

The ALB was:

```text
k8s-dev-roastcod-874ea519b1-1846492264.eu-central-1.elb.amazonaws.com
```

and its state was:

```text
active
```

### 4. Kubernetes could not remove the Ingress

Because the EKS endpoint was already unavailable:

```bash
kubectl get ingress -A

Unable to connect to the server
```

the Ingress could not be deleted through Kubernetes.

The ALB therefore had to be removed through the AWS API.

## Resolution

The ALB was deleted using:

```bash
aws elbv2 delete-load-balancer \
  --region eu-central-1 \
  --load-balancer-arn arn:aws:elasticloadbalancing:eu-central-1:215229808174:loadbalancer/app/k8s-dev-roastcod-874ea519b1/e147c50a53f954e6
```

After deletion, the ALB ENIs were checked again.

Initially one ENI became `available`, while another remained `in-use`. This demonstrated that AWS performs ALB cleanup asynchronously.

After waiting, both ALB ENIs disappeared. The associated EIPs were also no longer blocking the ALB cleanup.

## Remaining VPC Dependencies

The VPC still remained `available` even after:

- ALB deletion
- ENI cleanup
- NAT Gateway deletion
- Internet Gateway detachment
- subnet deletion

The remaining Security Groups were then inspected:

```bash
aws ec2 describe-security-groups \
  --region eu-central-1 \
  --filters Name=vpc-id,Values=vpc-0b6085921712a6cdb \
  --query 'SecurityGroups[*].[GroupId,GroupName]' \
  --output table
```

Two Kubernetes-created Security Groups remained:

```bash
default
sg-036d20a1e542e9845  k8s-dev-roastcod-28ed3b6c57
sg-0c2e9c0bcc351b27b  k8s-traffic-roastcodev-4032800fbf
```

The two Kubernetes Security Groups were not present in Terraform state.

Terraform state contained only:

```bash
module.acm-certificate.aws_acm_certificate.roast_co
module.vpc.aws_internet_gateway.this
module.vpc.aws_subnet.public_a
module.vpc.aws_subnet.public_b
module.vpc.aws_vpc.this
```

Therefore the two Kubernetes Security Groups were **orphaned AWS resources**.

## Final Cleanup

The two orphaned Kubernetes Security Groups were removed:

```bash
aws ec2 delete-security-group \
  --region eu-central-1 \
  --group-id sg-036d20a1e542e9845
```

```bash
aws ec2 delete-security-group \
  --region eu-central-1 \
  --group-id sg-0c2e9c0bcc351b27b
```

After cleanup, Terraform completed:

```bash
module.vpc.aws_vpc.this: Destruction complete after 19m15s

Destroy complete! Resources: 5 destroyed.
```

A final check:

```bash
$ aws ec2 describe-security-groups \
  --region eu-central-1 \
  --filters Name=vpc-id,Values=vpc-0b6085921712a6cdb \
  --query 'SecurityGroups[*].[GroupId,GroupName]' \
  --output table

$
```

returned no results, confirming that the VPC and its Security Groups had been removed.

## Root Cause

The AWS ALB Controller created AWS resources from a Kubernetes Ingress.

The Amazon EKS cluster was then destroyed, making the Kubernetes API unavailable before all controller-created AWS resources had finished cleaning up.

As a result, Kubernetes Ingress, AWS ALB Controller, ALB, ENIs/EIPs/Security Groups outlived the Kubernetes control plane.

Terraform subsequently attempted to destroy the underlying VPC infrastructure while AWS still had dependent resources.

## Lessons Learned

1. Kubernetes controllers can create AWS resources that are not directly represented in Terraform state.

2. Destroying Amazon EKS does not guarantee that every AWS resource created by Kubernetes has disappeared immediately.

3. AWS ALB cleanup is asynchronous.

4. An unavailable Kubernetes API changes the troubleshooting strategy: AWS APIs may be required to clean up orphaned controller-created resources.

5. `terraform state list` is valuable when determining whether an AWS resource is actually managed by Terraform.

6. Do not delete ENIs or EIPs blindly. First identify their owner using fields such as:

```text
RequesterId
RequesterManaged
Description
```

7. A `DependencyViolation` should be investigated as a dependency chain rather than solved by random manual deletion.

8. The safest operational sequence is to remove Kubernetes-created resources first, allowing AWS controllers to clean up their AWS resources, and then destroy the underlying Terraform-managed infrastructure.

9. Manual AWS cleanup should be a troubleshooting exception, not the normal deployment process.