variable "domain_name" {
  description = "The domain name for the ACM certificate."
  type        = string
}

variable "subject_alternative_names" {
  description = "A list of subject alternative names for the ACM certificate."
  type        = list(string)
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare zone ID for the domain."
  type        = string
}