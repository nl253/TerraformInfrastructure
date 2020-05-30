variable "runtime" {
  type    = string
  default = "python3.8"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "app_name" {
  type = string
  default = "test-api-rest-app-123551"
}

variable "binary_mimes" {
  type = list(string)
  default = [
    "application/octet-stream",
    "application/pdf",
    "application/x-7z-compressed",
    "application/zip",
    "application/gzip",
    "audio/mpeg",
    "audio/ogg",
    "audio/wav",
    "audio/webm",
    "font/otf",
    "font/ttf",
    "font/woff",
    "font/woff2",
    "image/gif",
    "image/jpeg",
    "image/png",
    "video/mpeg",
    "video/webm",
  ]
}
