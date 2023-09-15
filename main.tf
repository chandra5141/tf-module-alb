
resource "aws_security_group" "alb_security_group" {
  name        = "${var.env}-alb_${var.subnets_name}-security_group"
  description = "${var.env}-alb_${var.subnets_name}_subnet_group"
  vpc_id      = var.vpc_id


  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr

  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge (local.common_tags, { Name = "${var.env}-alb_${var.subnets_name}_security_group" } )

}

resource "aws_lb" "alb" {
  name               = "${var.env}-${var.subnets_name}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = var.subnet_ids

  tags = merge (local.common_tags, { Name = "${var.env}-alb_${var.subnets_name}" } )

}


resource "aws_lb_listener" "backend_app_listeners" {
  count = var.internal ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "NO_RULE"
      status_code  = "503"
    }
  }
}

resource "aws_route53_record" "public_alb_dns" {
  count = var.internal  ? 0 : 1
  zone_id = "Z0388000D98EZSBQJXAU"
  name    = var.dns_domain
  type    = "CNAME"
  ttl     = 30
  records = [aws_lb.alb.dns_name]
}