output "dns_name" {
  value = aws_lb.alb.dns_name
}

output "listener" {
  value = try(aws_lb_listener.backend_app_listeners.*.arn[0], null)
}
output "alb_arn" {
  value = aws_lb.alb.arn
}