connection: "bigquery-connectors-ga360"

# include all the views
include: "ga_block.view"
include: "ga_customize.view"
# include all the dashboards
include: "bounce_rates.dashboard"
include: "traffic_engagement_overview.dashboard"
include: "transactions_conversions_revenue.dashboard"

explore: ga_sessions {
  label: "GA 360 Sessions"
  extends: [ga_sessions_block]
}
