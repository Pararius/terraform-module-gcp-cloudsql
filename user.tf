resource "random_password" "sql_user" {
  for_each = merge(
    local.mysql_users,
    local.postgres_users,
  )

  length = 48
}

resource "google_sql_user" "mysql_user" {
  for_each = local.mysql_users

  instance = google_sql_database_instance.instance.name
  name     = each.value.name
  host     = each.value.host
  password = random_password.sql_user[each.key].result
}

resource "google_sql_user" "postgres_user" {
  for_each = local.postgres_users

  instance = google_sql_database_instance.instance.name
  name     = each.value.name
  password = random_password.sql_user[each.key].result
}
