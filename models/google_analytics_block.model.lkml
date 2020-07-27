connection: "bigquery-connectors-ga360"

# include all the views
include: "/views/ga_block.view"
include: "/views/ga_customize.view"
# include all the dashboards
include: "/lookml_dashboards/bounce_rates.dashboard"
include: "/lookml_dashboards/traffic_engagement_overview.dashboard"
include: "/lookml_dashboards/transactions_conversions_revenue.dashboard"

explore: ga_sessions {
  label: "GA 360 Sessions"
  extends: [ga_sessions_block]
}
