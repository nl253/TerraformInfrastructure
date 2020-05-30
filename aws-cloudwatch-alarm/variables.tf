variable "app_name" {
  type    = string
}

variable "threshold" {
  type    = number
  default = 10
//  validation {
//    condition = var.threshold > 0
//    error_message = "Must be > 0."
//  }
}

variable "period_seconds" {
  type    = number
  default = 120
//  validation {
//    condition = ((var.period_seconds / 15) - floor((var.period_seconds / 15))) == 0
//    error_message = "Must be multiple of 15."
//  }
}

variable "unit" {
  type    = string
  default = "Count"
//  validation {
//    condition = contains([
//      "Seconds",
//      "Microseconds",
//      "Milliseconds",
//      "Bytes",
//      "Kilobytes",
//      "Megabytes",
//      "Gigabytes",
//      "Terabytes",
//      "Bits",
//      "Kilobits",
//      "Megabits",
//      "Gigabits",
//      "Terabits",
//      "Percent",
//      "Count",
//      "Bytes/Second",
//      "Kilobytes/Second",
//      "Megabytes/Second",
//      "Gigabytes/Second",
//      "Terabytes/Second",
//      "Bits/Second",
//      "Kilobits/Second",
//      "Megabits/Second",
//      "Gigabits/Second",
//      "Terabits/Second",
//      "Count/Second",
//      "None",
//    ], var.unit)
//    error_message = "invalid unit"
//  }
}

variable "statistic" {
  type    = string
//  validation {
//    condition = contains([
//      'Average',
//      'Maximum',
//      'Minimum',
//      'Data Samples',
//      'Sum',
//      'p99',
//      'p95',
//      'p90',
//      'p50',
//      'p10',
//    ], var.statistic)
//    error_message = "invalid statistic"
//  }
}

variable "metric" {
  type    = string
}

variable "service" {
  type    = string
//  validation {
//    condition = contains([
//      "AWS/ApiGateway",
//      "AWS/AppStream",
//      "AWS/AppSync",
//      "AWS/Athena",
//      "AWS/Billing",
//      "AWS/ACMPrivateCA",
//      "AWS/Chatbot",
//      "AWS/CloudFront",
//      "AWS/CloudHSM",
//      "AWS/CloudSearch",
//      "AWS/Logs",
//      "AWS/CodeBuild",
//      "AWS/Cognito",
//      "AWS/Connect",
//      "AWS/DataSync",
//      "AWS/DMS",
//      "AWS/DX",
//      "AWS/DocDB",
//      "AWS/DynamoDB",
//      "AWS/EC2",
//      "AWS/ElasticGPUs",
//      "AWS/EC2Spot",
//      "AWS/AutoScaling",
//      "AWS/ElasticBeanstalk",
//      "AWS/EBS",
//      "AWS/ECS",
//      "AWS/EFS",
//      "AWS/ElasticInference",
//      "AWS/ApplicationELB",
//      "AWS/ELB",
//      "AWS/NetworkELB",
//      "AWS/ElasticTranscoder",
//      "AWS/ElastiCache",
//      "AWS/ElastiCache",
//      "AWS/ES",
//      "AWS/ElasticMapReduce",
//      "AWS/MediaConnect",
//      "AWS/MediaConvert",
//      "AWS/MediaPackage",
//      "AWS/MediaStore",
//      "AWS/MediaTailor",
//      "AWS/Events",
//      "AWS/FSx",
//      "AWS/FSx",
//      "AWS/GameLift",
//      "AWS/Glue",
//      "AWS/GroundStation",
//      "AWS/Inspector",
//      "AWS/IoT",
//      "AWS/IoTAnalytics",
//      "AWS/IoTSiteWise",
//      "AWS/ThingsGraph",
//      "Metrics",
//      "AWS/KMS",
//      "AWS/Cassandra",
//      "AWS/KinesisAnalytics",
//      "AWS/Firehose",
//      "AWS/Kinesis",
//      "AWS/KinesisVideo",
//      "AWS/Lambda",
//      "AWS/Lex",
//      "AWS/ML",
//      "AWS/Kafka",
//      "AWS/AmazonMQ",
//      "AWS/Neptune",
//      "AWS/OpsWorks",
//      "AWS/Polly",
//      "AWS/QLDB",
//      "AWS/Redshift",
//      "AWS/RDS",
//      "AWS/Robomaker",
//      "AWS/Route53",
//      "AWS/SageMaker",
//      "AWS/SDKMetrics",
//      "AWS/ServiceCatalog",
//      "AWS/DDoSProtection",
//      "AWS/SES",
//      "AWS/SNS",
//      "AWS/SQS",
//      "AWS/S3",
//      "AWS/SWF",
//      "AWS/States",
//      "AWS/StorageGateway",
//      "AWS/SSM-RunCommand",
//      "AWS/Textract",
//      "AWS/Transfer",
//      "AWS/Translate",
//      "AWS/TrustedAdvisor",
//      "AWS/NATGateway",
//      "AWS/TransitGateway",
//      "AWS/VPN",
//      "WAF",
//      "AWS/WorkMail",
//      "AWS/WorkSpaces",
//    ], var.service)
//    error_message = "invalid service"
//  }
}

variable "env" {
  type    = string
//  validation {
//    condition = length(var.env) > 0
//    error_message = "Must be non-empty."
//  }
}

variable "dimensions" {
  default = null
  type = map(any)
}

variable "evaluation_periods" {
  default = 3
  type = number
//  validation {
//    condition = var.evaluation_periods > 0
//    error_message = "Must be > 0."
//  }
}

variable "sns_arns" {
  default = ["arn:aws:sns:eu-west-2:660847692645:failure"]
  type = list(string)
}
