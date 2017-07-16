# here is the load balancer stuff we need for ecs.
# we do had the choice : old classic load balancer (ELB)
# or the new one (ALB). We finally choose the ALB, because of its
# ability to deals with docker dynamic host port feature and
# the possibility to route the traffic with rules based on
# path matching.
# this means that we can launch many instance of one service on the same host,
# exposing different port for the same service. The instances of the same kind
# are grouped in 'target group', and the routing for an incoming request
# to one of this group is based on path and no more on port.

# this target group is for the service instances that
# are available in production.
# please note the health check path 'status'. All
# target registered on this target group must answer
# on /status request with a 2XX answer.
resource "aws_alb_target_group" "prod_ecs_cluster" {
  name     = "prod-ecs-cluster-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.mat_tech.id}"
  depends_on = ["aws_alb.public_alb"]

  health_check {
    path = "/status"
  }
}

# this target group is for the service instances that
# are available in test.
# please note the health check path 'status'. All
# target registered on this target group must answer
# on /status request with a 2XX answer.
resource "aws_alb_target_group" "test_ecs_cluster" {
  name     = "test-ecs-cluster-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.mat_tech.id}"
  depends_on = ["aws_alb.public_alb"]

  health_check {
    path = "/status"
  }
}

# this is the definition of the load balancer itself.
resource "aws_alb" "public_alb" {
  name = "mat-tech-alb"
  internal = false
  security_groups = ["${aws_security_group.public_alb.id}","${aws_security_group.ecs_cluster.id}"]
  subnets = ["${aws_subnet.public_subnet_a.id}","${aws_subnet.public_subnet_b.id}","${aws_subnet.public_subnet_c.id}"]
}

# The listener is the 'external' interface of the load balancer.
# here is defined the exposed port (here 80), and the redirection rules
# to the target group will be attached on it.
resource "aws_alb_listener" "ecs_cluster" {
  load_balancer_arn = "${aws_alb.public_alb.arn}"
  port = 80
  default_action {
    target_group_arn = "${aws_alb_target_group.prod_ecs_cluster.arn}"
    type = "forward"
  }
}

# redirection rule to production target group
resource "aws_alb_listener_rule" "prod" {
  listener_arn = "${aws_alb_listener.ecs_cluster.arn}"
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.prod_ecs_cluster.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/production/*"]
  }
}

# redirection rule to test target group
resource "aws_alb_listener_rule" "test" {
  listener_arn = "${aws_alb_listener.ecs_cluster.arn}"
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.test_ecs_cluster.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/test/*"]
  }
}





