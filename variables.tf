variable "project_name" {
  type = string
  default = "POS"
}

variable "order_processor_lambda_name" {
  type = string
  default = "OrderProcessor"
}

variable "order_creator_lambda_name" {
  type = string
  default = "PlaceOrder"
}

variable "order_getter_lambda_name" {
  type = string
  default = "GetOrders"
}

variable "sqs_name" {
  type = string
  default = "Orders"
}

variable "db_table_name" {
  type = string
  default = "Orders"
}

