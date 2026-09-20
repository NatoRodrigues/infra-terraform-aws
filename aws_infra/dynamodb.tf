resource "aws_dynamodb_table" "webapp_table" {
  name            = "webapp-table"
  billing_mode    = "PAY_PER_REQUEST"
  hash_key        = "id"

  attribute {
    name = "id"
    type = "S"
  }
}