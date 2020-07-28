view: ga_sessions_base {
  extension: required
  dimension: partition_date {
    view_label: "Date and Time"
    type: date_time
    sql: TIMESTAMP(PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'^\d\d\d\d\d\d\d\d')))  ;;
  }



  dimension: id {
    view_label: "User Attributes"
    primary_key: yes
    sql: CONCAT(CAST(${fullVisitorId} AS STRING), '|', COALESCE(CAST(${visitId} AS STRING),''), CAST(PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'^\d\d\d\d\d\d\d\d'))   AS STRING)) ;;
  }
  dimension: visitorId {
    view_label: "User Attributes"
    label: "Visitor ID"
    }

  dimension: visitnumber {
    view_label: "User Attributes"
    label: "Visit Number"
    type: number
    description: "The session number for this user. If this is the first session, then this is set to 1."
  }

  dimension:  first_time_visitor {
    view_label: "User Attributes"
    type: yesno
    sql: ${visitnumber} = 1 ;;
  }

  dimension: visitnumbertier {
    view_label: "User Attributes"
    label: "Visit Number Tier"
    type: tier
    tiers: [1,2,5,10,15,20,50,100]
    style: integer
    sql: ${visitnumber} ;;
  }
  dimension: visitId {
    label: "Visit ID"
    view_label: "User Attributes"
  }
  dimension: fullVisitorId {
    label: "Full Visitor ID"
    view_label: "User Attributes"
  }

  dimension: visitStartSeconds {
    view_label: "Date and Time"
    label: "Visit Start Seconds"
    type: date_time
    sql: TIMESTAMP_SECONDS(${TABLE}.visitStarttime) ;;
    hidden: yes
  }

  ## referencing partition_date for demo purposes only. Switch this dimension to reference visistStartSeconds
  dimension_group: visitStart {
    timeframes: [date,day_of_week,fiscal_quarter,week,month,year,month_name,month_num,week_of_year]
    label: "Visit Start"
    view_label: "Date and Time"
    type: time
    sql: (TIMESTAMP(${visitStartSeconds})) ;;
  }
  ## use visit or hit start time instead
  dimension: date {
    view_label: "Date and Time"
    hidden: yes
  }

  dimension: socialEngagementType {
    label: "Social Engagement Type"
    view_label: "User Engagement"
  }
  dimension: userid {
    label: "User ID"
    hidden: yes
    view_label: "User Attributes"
  }

  measure: session_count {
    view_label: "Measures"
    type: count
    filters: {
      field: hits.isInteraction
      value: "yes"
    }
    drill_fields: [fullVisitorId, visitnumber, session_count, totals.transactions_count, totals.transactionRevenue_total]
  }
  measure: unique_visitors {
    view_label: "Measures"
    type: count_distinct
    sql: ${fullVisitorId} ;;
    drill_fields: [fullVisitorId, visitnumber, session_count, totals.hits, totals.page_views, totals.timeonsite]
  }

  measure: average_sessions_ver_visitor {
    view_label: "Measures"
    type: number
    sql: 1.0 * (${session_count}/NULLIF(${unique_visitors},0))  ;;
    value_format_name: decimal_2
    drill_fields: [fullVisitorId, visitnumber, session_count, totals.hits, totals.page_views, totals.timeonsite]
  }

  measure: total_visitors {
    view_label: "Measures"
    type: count
    drill_fields: [fullVisitorId, visitnumber, session_count, totals.hits, totals.page_views, totals.timeonsite]
  }

  measure: first_time_visitors {
    view_label: "Measures"
    label: "First Time Visitors"
    type: count
    filters: {
      field: visitnumber
      value: "1"
    }
  }

  measure: second_time_visitors {
    view_label: "Measures"
    label: "Second Time Visitors"
    type: count
    filters: {
      field: visitnumber
      value: "2"
    }
  }


  measure: returning_visitors {
    view_label: "Measures"
    label: "Returning Visitors"
    type: count
    filters: {
      field: visitnumber
      value: "<> 1"
    }
  }

  dimension: channelGrouping {
    label: "Channel Grouping"
    view_label: "Traffic Source"
  }

  # subrecords
  dimension: geoNetwork {hidden: yes}
  dimension: totals {hidden:yes}
  dimension: trafficSource {hidden:yes}
  dimension: device {hidden:yes}
  dimension: customDimensions {hidden:yes}
  dimension: hits {hidden:yes}
  dimension: hits_eventInfo {hidden:yes}

}


view: geoNetwork_base {
  extension: required
  dimension: continent {
    view_label: "Location"
    drill_fields: [subcontinent,country,region,city,metro,approximate_networkLocation,networkLocation]
  }
  dimension: subcontinent {
    view_label: "Location"
    drill_fields: [country,region,city,metro,approximate_networkLocation,networkLocation]

  }
  dimension: country {
    view_label: "Location"
    map_layer_name: countries
    drill_fields: [region,metro,city,approximate_networkLocation,networkLocation]
  }
  dimension: region {
    view_label: "Location"
    drill_fields: [metro,city,approximate_networkLocation,networkLocation]
  }
  dimension: metro {
    view_label: "Location"
    drill_fields: [city,approximate_networkLocation,networkLocation]
  }
  dimension: city {
    view_label: "Location"
    drill_fields: [metro,approximate_networkLocation,networkLocation]
  }
  dimension: cityid {
    hidden: yes
    label: "City ID"
    view_label: "Location"
  }
  dimension: networkDomain {
    hidden: yes
    label: "Network Domain"
    view_label: "Location"
  }
  dimension: latitude {
    type: number
    hidden: yes
    sql: CAST(${TABLE}.latitude as FLOAT64);;
    view_label: "Location"
  }
  dimension: longitude {
    type: number
    hidden: yes
    sql: CAST(${TABLE}.longitude as FLOAT64);;
    view_label: "Location"
  }
  dimension: networkLocation {
    label: "Network Location"
    view_label: "Location"
    hidden: yes
  }
  dimension: location {
    label: "Coordinates"
    view_label: "Location"
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }
  dimension: approximate_networkLocation {
    hidden: yes
    view_label: "Location"
    type: location
    sql_latitude: ROUND(${latitude},1) ;;
    sql_longitude: ROUND(${longitude},1) ;;
    drill_fields: [networkLocation]
  }
}


view: totals_base {
  extension: required
  dimension: id {
    primary_key: yes
    hidden: yes
    sql: ${ga_sessions.id} ;;
  }
  measure: visits_total {
    view_label: "Measures"
    type: sum
    sql: ${TABLE}.visits ;;
  }
  measure: hits_total {
    view_label: "Measures"
    type: sum
    sql: ${TABLE}.hits ;;
    drill_fields: [hits.detail*]
  }
  measure: hits_average_per_session {
    view_label: "Measures"
    type: number
    sql: 1.0 * ${hits_total} / NULLIF(${ga_sessions.session_count},0) ;;
    value_format_name: decimal_2
  }
  measure: pageviews_total {
    view_label: "Measures"
    label: "Page Views"
    type: sum
    sql: ${TABLE}.pageviews ;;
  }
  measure: timeonsite_total {
    view_label: "Measures"
    label: "Time On Site"
    type: sum
    sql: ${TABLE}.timeonsite ;;
  }
  dimension: timeonsite_tier {
    view_label: "User Engagement"
    label: "Time On Site Tier"
    type: tier
    sql: ${TABLE}.timeonsite ;;
    tiers: [0,15,30,60,120,180,240,300,600]
    style: integer
  }
  measure: timeonsite_average_per_session {
    view_label: "Measures"
    label: "Time On Site Average Per Session"
    type: number
    sql: 1.0 * ${timeonsite_total} / NULLIF(${ga_sessions.session_count},0) ;;
    value_format_name: decimal_2
  }

  measure: page_views_session {
    label: "PageViews Per Session"
    view_label: "Measures"
    type: number
    sql: 1.0 * ${pageviews_total} / NULLIF(${ga_sessions.session_count},0) ;;
    value_format_name: decimal_2
  }

  measure: bounces_total {
    view_label: "Measures"
    type: sum
    sql: ${TABLE}.bounces ;;
  }
  measure: bounce_rate {
    view_label: "Measures"
    type:  number
    sql: 1.0 * ${bounces_total} / NULLIF(${ga_sessions.session_count},0) ;;
    value_format_name: percent_2
  }
  measure: transactions_count {
    view_label: "Measures"
    type: sum
    sql: ${TABLE}.transactions ;;
  }
  measure: transactionRevenue_total {
    view_label: "Measures"
    label: "Transaction Revenue Total"
    type: sum
    sql: (${TABLE}.transactionRevenue/1000000) ;;
    value_format_name: usd_0
    drill_fields: [transactions_count, transactionRevenue_total]
  }
  measure: newVisits_total {
    view_label: "Measures"
    label: "New Visits Total"
    type: sum
    sql: ${TABLE}.newVisits ;;
  }
  measure: screenViews_total {
    view_label: "Measures"
    label: "Screen Views Total"
    type: sum
    sql: ${TABLE}.screenViews ;;
  }
  measure: timeOnScreen_total{
    view_label: "Measures"
    label: "Time On Screen Total"
    type: sum
    sql: ${TABLE}.timeOnScreen ;;
  }
  measure: uniqueScreenViews_total {
    view_label: "Measures"
    label: "Unique Screen Views Total"
    type: sum
    sql: ${TABLE}.uniqueScreenViews ;;
  }
  dimension: timeOnScreen_total_unique{
    view_label: "User Engagement"
    label: "Time On Screen Total"
    type: number
    sql: ${TABLE}.timeOnScreen ;;
  }
}


view: trafficSource_base {
  extension: required

# dimension: adwords {}
  dimension: referralPath {label: "Referral Path"}
  dimension: campaign {}
  dimension: source {}
  dimension: medium {}
  dimension: keyword {}
  dimension: adContent {label: "Ad Content"}
  measure: source_list {
    type: list
    list_field: source
  }
  measure: source_count {
    type: count_distinct
    sql: ${source} ;;
    drill_fields: [source, totals.hits, totals.pageviews]
  }
  measure: keyword_count {
    type: count_distinct
    sql: ${keyword} ;;
    drill_fields: [keyword, totals.hits, totals.pageviews]
  }
  # Subrecords
#   dimension: adwordsClickInfo {}
}

view: adwordsClickInfo_base {
  extension: required
  dimension: campaignId {label: "Campaign ID"}
  dimension: adGroupId {label: "Ad Group ID"}
  dimension: creativeId {label: "Creative ID"}
  dimension: criteriaId {label: "Criteria ID"}
  dimension: page {type: number}
  dimension: slot {}
  dimension: criteriaParameters {label: "Criteria Parameters"}
  dimension: gclId {}
  dimension: customerId {label: "Customer ID"}
  dimension: adNetworkType {label: "Ad Network Type"}
  dimension: targetingCriteria {label: "Targeting Criteria"}
  dimension: isVideoAd {
    label: "Is Video Ad"
    type: yesno
  }
}

view: device_base {
  extension: required
  #label: "TEST"

  dimension: browser {}
  dimension: browserVersion {label:"Browser Version"}
  dimension: operatingSystem {label: "Operating System"}
  dimension: operatingSystemVersion {label: "Operating System Version"}
  dimension: deviceCategory { label:"Device Category" description:"mobile,tablet,desktop"}
  dimension: isMobile {type: yesno label: "Is Mobile" sql: ${deviceCategory} in ('mobile','tablet') ;; }
  dimension: isDesktop {type: yesno label: "Is Desktop" sql: ${deviceCategory} = 'desktop' ;; }
  dimension: flashVersion {label: "Flash Version"}
  dimension: javaEnabled {
    label: "Java Enabled"
    type: yesno
  }
  dimension: language {}
  dimension: screenColors {label: "Screen Colors"}
  dimension: screenResolution {label: "Screen Resolution"}
  dimension: mobileDeviceBranding {label: "Mobile Device Branding"}
  dimension: mobileDeviceInfo {label: "Mobile Device Info"}
  dimension: mobileDeviceMarketingName {label: "Mobile Device Marketing Name"}
  dimension: mobileDeviceModel {label: "Mobile Device Model"}
  dimension: mobileDeviceInputSelector {label: "Mobile Device Input Selector"}
}

view: hits_base {
  extension: required
  dimension: id {
    primary_key: yes
    sql: CONCAT(${ga_sessions.id},'|',FORMAT('%05d',${hitNumber})) ;;
  }
  dimension: hitNumber {}
  dimension: time {}
  dimension_group: hit {
    timeframes: [date,day_of_week,fiscal_quarter,week,month,year,month_name,month_num,week_of_year]
    type: time
    sql: TIMESTAMP_MILLIS(${ga_sessions.visitStartSeconds}*1000 + ${TABLE}.time) ;;
  }
  dimension: hour {}
  dimension: minute {}
  dimension: isSecure {
    label: "Is Secure"
    type: yesno
  }
  dimension: isInteraction {
    label: "Is Interaction"
    type: yesno
    description: "If this hit was an interaction, this is set to true. If this was a non-interaction hit (i.e., an event with interaction set to false), this is false."
  }
  dimension: referer {}

  measure: count {
    type: count
    drill_fields: [hits.detail*]
  }

  # subrecords
  dimension: page {hidden:yes}
  dimension: transaction {hidden:yes}
  dimension: item {hidden:yes}
  dimension: contentinfo {hidden:yes}
  dimension: social {hidden: yes}
  dimension: publisher {hidden: yes}
  dimension: appInfo {hidden: yes}
  dimension: contentInfo {hidden: yes}
  dimension: customDimensions {hidden: yes}
  dimension: customMetrics {hidden: yes}
  dimension: customVariables {hidden: yes}
  dimension: ecommerceAction {hidden: yes}
  dimension: eventInfo {hidden:yes}
  dimension: exceptionInfo {hidden: yes}
  dimension: experiment {hidden: yes}


  set: detail {
    fields: [ga_sessions.id, ga_sessions.visitnumber, ga_sessions.session_count, hits_page.pagePath, hits.pageTitle]
  }
}

view: hits_page_base {
  extension: required
  dimension: pagePath {
    label: "Page Path"
    link: {
      label: "Link"
      url: "{{ value }}"
    }
    link: {
      label: "Page Info Dashboard"
      url: "/dashboards/101?Page%20Path={{ value | encode_uri}}"
      icon_url: "http://www.looker.com/favicon.ico"
    }
  }
  dimension: hostName {label: "Host Name"}
  dimension: pageTitle {label: "Page Title"}
  dimension: searchKeyword {label: "Search Keyword"}
  dimension: searchCategory{label: "Search Category"}
}

view: hits_transaction_base {
  extension: required

  dimension: id {
    primary_key: yes
    sql: ${hits.id} ;;
  }
  dimension: transactionShipping {label: "Transaction Shipping"}
  dimension: affiliation {}
  dimension: currencyCode {label: "Curency Code"}
  dimension: localTransactionRevenue {label: "Local Transaction Revenue"}
  dimension: localTransactionTax {label: "Local Transaction Tax"}
  dimension: localTransactionShipping {label: "Local Transaction Shipping"}
}

view: hits_item_base {
  extension: required

  dimension: id {
    primary_key: yes
    sql: ${hits.id} ;;
  }
  dimension: transactionId {label: "Transaction ID"}
  dimension: productName {
    label: "Product Name"
    }

  dimension: productCategory {label: "Product Catetory"}
  dimension: productSku {label: "Product Sku"}

  dimension: itemQuantity {
    description: "Should only be used as a dimension"
    label: "Item Quantity"
    hidden: yes
    }
  dimension: itemRevenue {
    description: "Should only be used as a dimension"
    label: "Item Revenue"
    hidden: yes
    }
  dimension: curencyCode {label: "Curency Code"}
  dimension: localItemRevenue {
    label:"Local Item Revenue"
    description: "Should only be used as a dimension"
    }

  measure: product_count {
    type: count_distinct
    sql: ${productSku} ;;
    drill_fields: [productName, productCategory, productSku, total_item_revenue]
  }
}

view: hits_social_base {
  extension: required   ## THESE FIELDS WILL ONLY BE AVAILABLE IF VIEW "hits_social" IN GA CUSTOMIZE HAS THE "extends" parameter declared

  dimension: socialInteractionNetwork {label: "Social Interaction Network"}
  dimension: socialInteractionAction {label: "Social Interaction Action"}
  dimension: socialInteractions {label: "Social Interactions"}
  dimension: socialInteractionTarget {label: "Social Interaction Target"}
  dimension: socialNetwork {label: "Social Network"}
  dimension: uniqueSocialInteractions {
    label: "Unique Social Interactions"
    type: number
  }
  dimension: hasSocialSourceReferral {label: "Has Social Source Referral"}
  dimension: socialInteractionNetworkAction {label: "Social Interaction Network Action"}
}

view: hits_publisher_base {
  extension: required    ## THESE FIELDS WILL ONLY BE AVAILABLE IF VIEW "hits_publisher" IN GA CUSTOMIZE HAS THE "extends" parameter declared

  dimension: dfpClicks {}
  dimension: dfpImpressions {}
  dimension: dfpMatchedQueries {}
  dimension: dfpMeasurableImpressions {}
  dimension: dfpQueries {}
  dimension: dfpRevenueCpm {}
  dimension: dfpRevenueCpc {}
  dimension: dfpViewableImpressions {}
  dimension: dfpPagesViewed {}
  dimension: adsenseBackfillDfpClicks {}
  dimension: adsenseBackfillDfpImpressions {}
  dimension: adsenseBackfillDfpMatchedQueries {}
  dimension: adsenseBackfillDfpMeasurableImpressions {}
  dimension: adsenseBackfillDfpQueries {}
  dimension: adsenseBackfillDfpRevenueCpm {}
  dimension: adsenseBackfillDfpRevenueCpc {}
  dimension: adsenseBackfillDfpViewableImpressions {}
  dimension: adsenseBackfillDfpPagesViewed {}
  dimension: adxBackfillDfpClicks {}
  dimension: adxBackfillDfpImpressions {}
  dimension: adxBackfillDfpMatchedQueries {}
  dimension: adxBackfillDfpMeasurableImpressions {}
  dimension: adxBackfillDfpQueries {}
  dimension: adxBackfillDfpRevenueCpm {}
  dimension: adxBackfillDfpRevenueCpc {}
  dimension: adxBackfillDfpViewableImpressions {}
  dimension: adxBackfillDfpPagesViewed {}
  dimension: adxClicks {}
  dimension: adxImpressions {}
  dimension: adxMatchedQueries {}
  dimension: adxMeasurableImpressions {}
  dimension: adxQueries {}
  dimension: adxRevenue {}
  dimension: adxViewableImpressions {}
  dimension: adxPagesViewed {}
  dimension: adsViewed {}
  dimension: adsUnitsViewed {}
  dimension: adsUnitsMatched {}
  dimension: viewableAdsViewed {}
  dimension: measurableAdsViewed {}
  dimension: adsPagesViewed {}
  dimension: adsClicked {}
  dimension: adsRevenue {}
  dimension: dfpAdGroup {}
  dimension: dfpAdUnits {}
  dimension: dfpNetworkId {}
}

view: hits_appInfo_base {
  extension: required

  dimension: name {}
  dimension: version {}
  dimension: id {}
  dimension: installerId {}
  dimension: appInstallerId {}
  dimension: appName {}
  dimension: appVersion {}
  dimension: appId {}
  dimension: screenName {}
  dimension: landingScreenName {}
  dimension: exitScreenName {}
  dimension: screenDepth {}
}

view: contentInfo_base {
  extension: required
  dimension: contentDescription {}
}

view: hits_customDimensions_base {
  extension: required
  dimension: index {type:number}
  dimension: value {}
}

view: hits_customMetrics_base {
  extension: required

  dimension: index {type:number}
  dimension: value {}
}

view: hits_customVariables_base {
  extension: required
  dimension: customVarName {}
  dimension: customVarValue {}
  dimension: index {type:number}
}

view: hits_eCommerceAction_base {
  extension: required
  dimension: action_type {}
  dimension: option {}
  dimension: step {}
}

view: hits_eventInfo_base {
  extension: required
  dimension: eventCategory {label: "Event Category"}

  dimension: eventAction {label: "Event Action"}
  dimension: eventLabel {label: "Event Label"}
  dimension: eventValue {label: "Event Value"}

}

# view: hits_sourcePropertyInfo {
# #   extension: required
#   dimension: sourcePropertyDisplayName {label: "Property Display Name"}
# }
