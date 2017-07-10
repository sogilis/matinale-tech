########################################################################
################### application load balancer ##########################
########################################################################

resource "aws_security_group" "public_alb" {
  name = "alb-security-group"
  description = "allow 80 and 443 tcp port for incoming traffic"
  vpc_id = "${aws_vpc.mat_tech.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_cluster" {
  name = "ecs-cluster-security-group"
  description = "allow all traffic inside the ecs cluster"
  vpc_id = "${aws_vpc.mat_tech.id}"

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "TCP"
    self = true
  }
}

resource "aws_alb_target_group" "ecs_cluster" {
  name     = "ecs-cluster-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.mat_tech.id}"
}

# because of its ability to deals with ecs dynamic port feature
resource "aws_alb" "public_alb" {
  name = "mat-tech-alb"
  internal = false
  security_groups = ["${aws_security_group.public_alb.id}","${aws_security_group.ecs_cluster.id}"]
  subnets = ["${aws_subnet.public_subnet_a.id}","${aws_subnet.public_subnet_b.id}","${aws_subnet.public_subnet_c.id}"]
}

resource "aws_alb_listener" "ecs_cluster" {
  load_balancer_arn = "${aws_alb.public_alb.arn}"
  port = 80
  default_action {
    target_group_arn = "${aws_alb_target_group.ecs_cluster.arn}"
    type = "forward"
  }
}





