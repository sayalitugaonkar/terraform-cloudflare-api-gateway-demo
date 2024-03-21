### Here we are creating Cloudflare related components to go to API gateway we just created in api-gateway.tf


#### We are also adding domain names for api.example.com as domain
resource "aws_api_gateway_domain_name" "gateway_domain_name" {
  domain_name     = "api.example.com"
  certificate_arn = data.aws_acm_certificate.gateway_domain_name.arn
}

### With www
resource "aws_api_gateway_domain_name" "gateway_domain_name" {
  domain_name     = "www.api.example.com"
  certificate_arn = data.aws_acm_certificate.gateway_domain_name.arn
}

### Finally we add the record which allows us to access api.example.com
resource "cloudflare_record" "cf_record_api" {
  name    = "api"
  value   = aws_api_gateway_domain_name.gateway_domain_name.cloudfront_domain_name
  type    = "CNAME"
  proxied = "true"
  zone_id = "zone id we get from cloudflare"
}


### With www

resource "cloudflare_record" "gateway_record_with_www" {
  name    = "www"
  value   = aws_api_gateway_domain_name.gateway_domain_name.cloudfront_domain_name
  type    = "CNAME"
  proxied = "true"
  zone_id = "zone-id we get from cloudflare"
}

##### We similarly create one more record which points to ALB instead of the API gateway. 

#### Important: for non-api related endpoints, we just need to replace the value for cloudflare_record to Loadbalancer ARN ####