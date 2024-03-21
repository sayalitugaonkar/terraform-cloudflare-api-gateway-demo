#### This terraform file describes how to route API requests from API gateway to our ALB


### Example loadbalancer we will be using in API gateway

resource "aws_lb" "example" {
  name               = "example"
  internal           = true
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id = "12345"
  }
}

### First we need a VPC link to connect API Gateway to loadbalancer

resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = "gateway-to-lb"
  description = "connect_gateway_to_lb"
  target_arns = [aws_lb.example.arn]
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  service_name        = "com.amazonaws.ap-south-east1.execute-api"
  vpc_id              = "vpc-id from our vpc module"
  subnet_ids          = "subnet id from our subnets module"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = ["security groups from our vpc module"]
}

### We are adding the API endpoint to tell that the gateway will connect with the private vpc
resource "aws_api_gateway_rest_api" "api_endpoint" {
  name = "rest-api-endpoint"
  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [aws_vpc_endpoint.vpc_endpoint.id] #### Point to the VPC we have created in modules via outputs
  }
}

#### We are here describing the method i.e HTTP way for integration
resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api_endpoint.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = ["GET", "POST"]
  authorization = "NONE"
}

#### We are here pointing to the Loadbalancer for only api.example.com
resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api_endpoint.id
  parent_id   = aws_api_gateway_rest_api.api_endpoint.root_resource_id
  path_part   = ["api"]
}

#### Finally putting it altogether for integrating API gateway with our Loadbalancer for api.example.com
resource "aws_api_gateway_integration" "api_integration" {
  http_method             = aws_api_gateway_method.method.http_method
  resource_id             = aws_api_gateway_resource.resource.id
  rest_api_id             = aws_api_gateway_rest_api.api_endpoint.id
  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id
  uri                     = "https://api.${aws_lb.example.arn}/"
}
