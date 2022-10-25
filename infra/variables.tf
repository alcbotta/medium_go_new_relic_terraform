variable "NEW_RELIC_ACCOUNT_ID" {
  type = string
}

variable "NEW_RELIC_API_KEY" {
  type = string
}

variable "NEW_RELIC_REGION" {
  type = string
  default = "us"
}

variable "APP_NAME" {
  type = string
  default = "test-newrelic-go"
}