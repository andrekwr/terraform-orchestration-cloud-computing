# Template file to load script with variables of choice.
data "template_file" "django_server_setup" {
  template = file("${path.module}/scripts/setup-server.sh")
  vars = { 
    dbName = var.dbName
    dbUser = var.dbUser
    dbPass = var.dbPass
    dbHost = var.dbHost
    dbPort = var.dbPort
  }
}