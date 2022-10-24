locals {
  default_labels = {
    env = var.environment
  }
  default_tier = var.environment == "production" ? "db-custom-2-8192" : "db-f1-micro"

  db_engine = split("_", var.database_version)[0]

  backup_config = {
    binary_log_enabled = coalesce(var.backup_config.binary_log_enabled, var.highly_available)
    enabled            = coalesce(var.backup_config.enabled, var.highly_available)
    location           = coalesce(var.backup_config.enabled, var.highly_available) ? var.backup_config.location : null
  }
  labels       = merge(local.default_labels, var.labels)
  storage_size = var.storage_autoresize == true ? null : var.storage_size
  tier         = coalesce(var.tier, local.default_tier)

  mysql_users = local.db_engine != "MYSQL" ? {} : {
    # For every user, create a distict key in the format [user]@[host]
    # If the host parameter was omitted, use '%' as default and set the
    # default host in the resulting user object as well
    for user in concat(var.users, [{ name = "root", host = "%" }]) :
    "${user.name}@${lookup(user, "host", "%")}" => {
      name = user.name
      host = lookup(user, "host", "%")
    }
  }
  postgres_users = local.db_engine != "POSTGRES" ? {} : { for user in concat(var.users, [{ name = "postgres" }]) : user.name => user }
}
