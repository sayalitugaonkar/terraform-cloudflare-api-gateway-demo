data "aws_acm_certificate" "example_domain" {
  domain   = "*.example.com"
  statuses = ["ISSUED"]
  provider = "aws.ap-southeast-1"
}