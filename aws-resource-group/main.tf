resource "aws_resourcegroups_group" "rg" {
  name = "${var.app_name}-resource-group"
  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "Application"
          Values = [var.app_name]
        }
      ]
    })
  }
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}
