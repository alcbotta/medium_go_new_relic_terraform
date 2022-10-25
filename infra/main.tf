terraform {
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
    }
  }
}

provider "newrelic" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  api_key    = var.NEW_RELIC_API_KEY # usually prefixed with 'NRAK'
  region     = var.NEW_RELIC_REGION                               # Valid regions are US and EU
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
# https://newrelic.com/blog/best-practices/advanced-nrql
# https://discuss.newrelic.com/t/relic-solution-extending-the-functionality-of-nrql-alert-conditions-beyond-a-single-minute/75441
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/alert_policy
resource "newrelic_alert_policy" "special_alert_policy" {
  name = "special_alert_policy"
}

resource "newrelic_nrql_alert_condition" "special_alert_condition" {
  policy_id                      = newrelic_alert_policy.special_alert_policy.id
  type                           = "static"
  name                           = "special_alert_policy"
  enabled                        = true
  

  nrql {
    query = "SELECT count(*) from TransactionError where appName='${var.APP_NAME}' and error.class='SpecialError'"
  }

  critical {
    threshold_duration = 60
    operator              = "above_or_equals"
    threshold             = 1
    threshold_occurrences = "AT_LEAST_ONCE"
  }
}
