# Module using database.
module "source-us-east-2" {
  source        = "./source_db"
  region        = "us-east-2"

  access_key = var.access_key
  secret_key = var.secret_key
}

# Module using backend.
module "source-us-east-1" {
  source = "./source_server"
  region = "us-east-1"

  #Depends on creation of database.
  server_depends_on = [module.source-us-east-2.this_db_instance_address]

  #Outputs of database module.
  dbName = module.source-us-east-2.this_db_instance_name
  dbHost = module.source-us-east-2.this_db_instance_address
  dbUser = module.source-us-east-2.this_db_instance_username
  dbPass = module.source-us-east-2.this_db_instance_password
  dbPort = module.source-us-east-2.this_db_instance_port

  #Passed input variables to source_server module.
  access_key = var.access_key
  secret_key = var.secret_key
  public_key = var.public_key
  key_name = var.key_name
  
}

#Set state to remote. Use "terraform login" to authenticate and use remote. You can give other config with parameter -backend-config="<file>"
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "cloud-computing-orchestration"

    workspaces {
      name = "orchestration-tf"
    }
  }
}

