#State variable.
variable "region" {
}

#Input variables inherited from main (need to change values at secreft.auto.tfvars file at root).
variable "access_key" {
}
variable "secret_key" {
}
variable "public_key" {
}
variable "key_name" {
}

#Inherited variables.
variable "dbName" {
}
variable "dbUser" {
}
variable "dbPass" {
}
variable "dbHost" {
}
variable "dbPort" {
}

#Variable to link the modules.
variable "server_depends_on" {
  type    = any
  default = null
}
