output "entry_point_production" {
  value = "${aws_alb.public_alb.dns_name}/production"
}

output "entry_point_test" {
  value = "${aws_alb.public_alb.dns_name}/test"
}