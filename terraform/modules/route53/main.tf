resource "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_route53_record" "primary" {
  zone_id         = aws_route53_zone.main.zone_id
  name            = "app.${var.domain_name}"
  type            = "A"
  ttl             = 300
  records         = [var.primary_ec2_public_ip]
  set_identifier  = "${var.project}-primary"
  health_check_id = aws_route53_health_check.primary.id
  failover_routing_policy {
    type = "PRIMARY"
  }
}

resource "aws_route53_record" "secondary" {
  zone_id         = aws_route53_zone.main.zone_id
  name            = "app.${var.domain_name}"
  type            = "A"
  ttl             = 300
  records         = var.secondary_ec2_public_ip != "0.0.0.0" ? [var.secondary_ec2_public_ip] : []
  set_identifier  = "${var.project}-secondary"
  health_check_id = var.secondary_ec2_public_ip != "0.0.0.0" ? aws_route53_health_check.secondary.id : null
  failover_routing_policy {
    type = "SECONDARY"
  }
}

resource "aws_route53_health_check" "primary" {
  ip_address        = var.primary_ec2_public_ip
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"
  tags = {
    Name    = "${var.project}-primary-health-check"
    Project = var.project
  }
}

resource "aws_route53_health_check" "secondary" {
  ip_address        = var.secondary_ec2_public_ip != "0.0.0.0" ? var.secondary_ec2_public_ip : null
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"
  tags = {
    Name    = "${var.project}-secondary-health-check"
    Project = var.project
  }
}