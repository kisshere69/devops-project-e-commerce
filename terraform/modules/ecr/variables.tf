variable "project" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "Dev environment"
  type        = string
}

variable "repository" {
  description = "The name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability settings"
  type        = string

  default = "MUTABLE"

  validation {
    condition = contains(
      ["MUTABLE", "IMMUTABLE"],
      var.image_tag_mutability
    )

    error_message = "Image tag mutability must be either 'MUTABLE' or 'IMMUTABLE'."
  }
}

variable "managed_by" {
  description = "Terraform managed"
}

# Scanning image on push for vulnerabilities

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}