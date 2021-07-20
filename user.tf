resource "random_password" "sql_user" {
  for_each = merge(
    local.mysql_users,
    local.postgres_admins,
    local.postgres_users,
  )

  length  = 48
  special = false # special chars tend to wreak havoc with certain client libs :-(
}

resource "google_sql_user" "mysql_user" {
  for_each = local.mysql_users

  instance = google_sql_database_instance.instance.name
  name     = each.value.name
  host     = each.value.host
  password = random_password.sql_user[each.key].result
}

resource "google_sql_user" "postgres_user" {
  for_each = local.postgres_admins

  instance = google_sql_database_instance.instance.name
  name     = each.value.name
  password = random_password.sql_user[each.key].result
}

resource "postgresql_role" "postgres_users" {
  for_each = local.postgres_users

  name     = each.value.name
  login    = true
  password = random_password.sql_user[each.key].result
}

resource "postgresql_grant" "postgres_readers" {
  for_each = {
    for x in local.postgres_db_readers : "${x.db}/${x.user}" => x
  }

  database    = each.value.db
  role        = each.value.user
  schema      = "public"
  object_type = "table"
  privileges = [
    "SELECT",
  ]
}

resource "postgresql_grant" "postgres_writers" {
  for_each = {
    for x in local.postgres_db_writers : "${x.db}/${x.user}" => x
  }

  database    = each.value.db
  role        = each.value.user
  schema      = "public"
  object_type = "table"
  privileges = [
    "SELECT",
    "INSERT",
    "UPDATE",
  ]
}
