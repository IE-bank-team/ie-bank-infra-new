param diagnosticsLogAnalyticsWorkspaceId string
param location string = 'global'


resource appServicePlanProd 'Microsoft.Web/serverfarms@2021-02-01' existing = {
  name: 'group1-asp-prod'
}

resource appServiceAppProd 'Microsoft.Web/sites@2021-02-01' existing = {
  name: 'group1-be-prod'
}

resource postgreSQLServerProd 'Microsoft.DBforPostgreSQL/flexibleservers@2021-06-01' existing = {
  name: 'group1-dbsrv-prod'
}

resource diagnosticSettingAppServicePlanPROD 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'group1-asp-prod-diagnostics'
  scope: appServicePlanProd
  properties: {
    workspaceId: diagnosticsLogAnalyticsWorkspaceId
    metrics: [{
      category: 'AllMetrics'
      enabled: true
    }]
  }
}

resource appServicePlanCpuAlertPROD 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-group1-asp-prod'
  location: location
  properties: {
    description: 'Alert when CPU utilization is over 80%'
    severity: 3
    enabled: true
    scopes: [
      appServicePlanProd.id
    ]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'alert-group1-asp-prod'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'CpuPercentage'
          metricNamespace: 'Microsoft.Web/serverfarms'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
        }
      ]
    }
    windowSize: 'PT5M'
    evaluationFrequency: 'PT1M'
  }
}

// Function to create diagnostic settings for Backend App Service PROD (BE)
resource diagnosticSettingAppServiceAppPROD 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' =  {
  name: 'group1-be-prod-diagnostics'
  scope: appServiceAppProd
  properties: {
    workspaceId: diagnosticsLogAnalyticsWorkspaceId
    logs: [{
      category: 'AppServiceHTTPLogs'
      enabled: true
    }]
    metrics: [{
      category: 'AllMetrics'
      enabled: true
    }]
  }
}

resource appServiceResponseTimeAlertPROD 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-group1-be-prod'
  location: location
  properties: {
    description: 'Alert when average response time is over 200ms'
    severity: 3
    enabled: true
    scopes: [
      appServiceAppProd.id
    ]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'alert-group1-be-prod'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'AverageResponseTime'
          metricNamespace: 'Microsoft.Web/sites'
          operator: 'GreaterThan'
          threshold: 200
          timeAggregation: 'Average'
        }
      ]
    }
    windowSize: 'PT5M'
    evaluationFrequency: 'PT1M'
  }
}

// Azure Database for PostgreSQL PROD
resource diagnosticSettingPostgreSQLServerPROD 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'group1-dbsrv-prod-diagnostics'
  scope: postgreSQLServerProd
  properties: {
    workspaceId: diagnosticsLogAnalyticsWorkspaceId
    logs: [{
      category: 'PostgreSQLLogs'
      enabled: true
    }]
    metrics: [{
      category: 'AllMetrics'
      enabled: true
    }]
  }
}

resource postgreSQLCpuUtilizationAlertPROD 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-group1-dbsrv-prod'
  location: location
  properties: {
    description: 'Alert when CPU utilization is over 70%'
    severity: 3
    enabled: true
    scopes: [
      postgreSQLServerProd.id
    ]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'alert-group1-dbsrv-prod'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'cpu_percent'
          metricNamespace: 'Microsoft.DBforPostgreSQL/flexibleservers'
          operator: 'GreaterThan'
          threshold: 70
          timeAggregation: 'Average'
        }
      ]
    }
    windowSize: 'PT5M'
    evaluationFrequency: 'PT1M'
  }
}
