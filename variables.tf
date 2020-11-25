#Input variables (need to change values at secreft.auto.tfvars file).
variable "access_key" {
  default=""
  description = "Access key of aws account"
}
variable "secret_key" {
  default=""
  description = "Secret key of aws account"
}
variable "public_key" {
  default=""
  description = "Public key ssh-rsa to generate key_pairs"
}
variable "key_name" {
  default=""
  description = "Access key of aws account"
}

