variable "envfile" {
  type    = string
  default = "../.env"
}

variable "db_name" {
  type    = string
  default = "retail_db"
}

locals {
  envfile = {
    for line in split("\n", file(var.envfile)) :
    split("=", line)[0] => trim(split("=", line)[1], "\t\r\n ")
    if !startswith(line, "#") && length(split("=", line)) > 1
  }
}

env "dev" {
  src = "file://dev_schema.sql"
  url = "${local.envfile["DEV_DB_URL"]}/${var.db_name}"
  migration {
    dir = "file://migrations/dev"
  }
  dev = "postgres://postgres:pass@atlas_local:5432/postgres?sslmode=disable"
}

env "uat" {
  src = "file://uat_schema.sql"
  url = "${local.envfile["UAT_DB_URL"]}/${var.db_name}"
  migration {
    dir = "file://migrations/uat"
  }
  dev = "postgres://postgres:pass@atlas_local:5432/postgres?sslmode=disable"
}

env "prod" {
  src = "file://prod_schema.sql"
  url = "${local.envfile["PROD_DB_URL"]}/${var.db_name}"
  migration {
    dir = "file://migrations/prod"
  }
  dev = "postgres://postgres:pass@atlas_local:5432/postgres?sslmode=disable"
}
