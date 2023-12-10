param diagnosticsLogAnalyticsWorkspaceId string
param location string = 'global'


resource appServicePlanUat 'Microsoft.Web/serverfarms@2021-02-01' existing = {
  name: 'group1-asp-uat'
}

resource appServiceAppUat 'Microsoft.Web/sites@2021-02-01' existing = {
  name: 'group1-be-uat'
}

resource postgreSQLServerUat 'Microsoft.DBforPostgreSQL/flexibleservers@2021-06-01' existing = {
  name: 'group1-dbsrv-uat'
}


resource diagnosticSettingAppServicePlanUAT 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'group1-asp-uat-diagnostics'
  scope: appServicePlanUat
  properties: {
    workspaceId: diagnosticsLogAnalyticsWorkspaceId
    metrics: [{
      category: 'AllMetrics'
      enabled: true
    }]
  }
}

resource appServicePlanCpuAlertUAT 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-group1-asp-uat'
  location: location
  properties: {
    description: 'Alert when CPU utilization is over 80%'
    severity: 3
    enabled: true
    scopes: [
      appServicePlanUat.id
    ]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'alert-group1-asp-uat'
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


// Function to create diagnostic settings for Backend App Service UAT (BE)
resource diagnosticSettingAppServiceAppUAT 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' =  {
  name: 'group1-be-uat-diagnostics'
  scope: appServiceAppUat
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

resource appServiceResponseTimeAlertUAT 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-group1-be-uat'
  location: location
  properties: {
    description: 'Alert when average response time is over 200ms'
    severity: 3
    enabled: true
    scopes: [
      appServiceAppUat.id
    ]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'alert-group1-be-uat'
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

// Azure Database for PostgreSQL UAT
resource diagnosticSettingPostgreSQLServerUAT 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'group1-dbsrv-uat-diagnostics'
  scope: postgreSQLServerUat
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

resource postgreSQLCpuUtilizationAlertUAT 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-group1-dbsrv-uat'
  location: location
  properties: {
    description: 'Alert when CPU utilization is over 70%'
    severity: 3
    enabled: true
    scopes: [
      postgreSQLServerUat.id
    ]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'alert-group1-dbsrv-uat'
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
