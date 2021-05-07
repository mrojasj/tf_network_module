variable "vpc_cidr_block" {
  type = string
}

variable "snet_extra_bits" {
  type = number
  validation {
    condition = var.snet_extra_bits >= 4
    error_message = "The snet_extra_bits value must be equal or greater than 4."
  }
}