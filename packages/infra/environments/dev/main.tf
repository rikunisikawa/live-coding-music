provider "aws" {
  region = "ap-northeast-1"
}

module "data_lake" {
  source      = "../../modules/s3_data_lake"
  bucket_name = "ai-native-data-lake-dev"
}
