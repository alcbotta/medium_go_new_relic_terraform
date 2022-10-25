terraform {
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
    }
  }
}

provider "newrelic" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  api_key    = var.NEW_RELIC_API_KEY 
  region     = var.NEW_RELIC_REGION                               
}

resource "newrelic_one_dashboard" "dashboard" {
  name = "Medium Article Dashboard"

  # Only I can see this dashboard
  permissions = "private"

  page {
    name = "Medium Article Dashboard"

    widget_table {
      title  = "max duration per user"
      row    = 1
      column = 1
      width = 12
      height = 3

      nrql_query {
        query = "SELECT max(duration) from Transaction facet capture(request.uri, r'.*/users/(?P<userId>\\w+).*') where appName='${var.APP_NAME}' since 30 minutes ago"
      }
    }

    widget_pie {
      title  = "count by http response"
      row    = 2
      column = 1
      width = 6
      height = 6

      nrql_query {
        query = "SELECT count(*) from Transaction FACET httpResponseCode where appName='${var.APP_NAME}' since 30 minutes ago limit 10 "
      }
    }
  }
}