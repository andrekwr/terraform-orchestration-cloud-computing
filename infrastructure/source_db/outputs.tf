# Outputs to export information to another module (source_db to source_server).

output "this_db_instance_address" {
  description = "The connection address"
  value       = module.database.this_db_instance_address
}

output "this_db_instance_name" {
  description = "The database name"
  value       = module.database.this_db_instance_name
}

output "this_db_instance_username" {
  description = "The master username for the database"
  value       = module.database.this_db_instance_username
}

output "this_db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = module.database.this_db_instance_password
}

output "this_db_instance_port" {
  description = "The database port"
  value       = module.database.this_db_instance_port
}