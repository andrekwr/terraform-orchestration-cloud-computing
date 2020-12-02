#Input variable to configure region used (pass it in main.tf file)
variable "region" {
}

#Input variables inherited from main (need to change values at secreft.auto.tfvars file at root).
variable "access_key" {
}
variable "secret_key" {
}