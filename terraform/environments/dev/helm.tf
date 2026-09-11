resource "helm_release" "secrets_store_csi_driver" {
  name             = "secrets-store-csi-driver"
  namespace        = "kube-system"
  create_namespace = false

  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"

  set = [
    {
      name  = "tokenRequests[0].audience"
      value = "sts.amazonaws.com"
    },
    {
      name  = "tokenRequests[1].audience"
      value = "pods.eks.amazonaws.com"
    }
  ]
}

resource "helm_release" "secrets_store_csi_driver_aws" {
  name             = "secrets-store-csi-driver-provider-aws"
  namespace        = "kube-system"
  create_namespace = false

  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"

  set = [
    {
      name  = "secrets-store-csi-driver.install"
      value = "false"
    }
  ]

  depends_on = [
    helm_release.secrets_store_csi_driver
  ]
}

resource "helm_release" "aws_load_balancer_controller" {
  name      = "aws-load-balancer-controller"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set = [
    {
      name  = "clusterName"
      value = module.eks.cluster_name
    },
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "vpcId"
      value = module.vpc.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "alb-controller"
    }
  ]

  depends_on = [
    module.eks,
    module.alb-controller
  ]
}