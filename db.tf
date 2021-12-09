resource "aws_dynamodb_table" "orders_table" {
    name           = "${var.project_name}-${var.db_table_name}-Dev-DYNAMODB"
    hash_key       = "id"
    billing_mode   = "PROVISIONED"
    read_capacity  = 4
    write_capacity = 4

    attribute {
        name = "id"
        type = "N"
    }

    attribute {
        name = "status"
        type = "S"
    }

    global_secondary_index {
      name               = "status-index"
      hash_key           = "status"
      write_capacity     = 1
      read_capacity      = 1
      projection_type    = "ALL"
      non_key_attributes = []
  }
}
