output "connection_name" {
  value = google_sql_database_instance.instance.connection_name
}

output "ip_addresses" {
  value = {
    for addr in google_sql_database_instance.instance.ip_address : addr.type => addr.ip_address
  }
}

output "passwords" {
  sensitive = true
  value     = { for user, pwd in random_password.sql_user : user => pwd.result }
}
