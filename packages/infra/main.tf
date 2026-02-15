provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {}
}

locals {
  data_lake_bucket   = "${var.app_name}-data-lake-${var.env}"
  dbt_staging_bucket = "${var.app_name}-dbt-${var.env}"
  athena_workgroup   = "${var.app_name}-athena-${var.env}"
  glue_raw_db        = "${var.app_name}_raw"
  glue_staging_db    = "${var.app_name}_staging"
  glue_mart_db       = "${var.app_name}_mart"
}

module "data_lake" {
  source      = "./modules/s3_data_lake"
  bucket_name = local.data_lake_bucket
}

module "dbt_staging" {
  source      = "./modules/s3_data_lake"
  bucket_name = local.dbt_staging_bucket
}

resource "aws_athena_workgroup" "primary" {
  name = local.athena_workgroup

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      output_location = "s3://${local.dbt_staging_bucket}/dbt/"
    }
  }
}

resource "aws_glue_catalog_database" "raw" {
  name = local.glue_raw_db
}

resource "aws_glue_catalog_database" "staging" {
  name = local.glue_staging_db
}

resource "aws_glue_catalog_database" "mart" {
  name = local.glue_mart_db
}
