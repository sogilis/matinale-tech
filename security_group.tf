# the security group are the way to control the traffic on aws.
# when adding rules for incoming and outgoing traffic, you can specify the
# protocole, the port(s), the source(s) and so one...


# this security group describe rules for the public
# load balancer. It allow from every where incoming
# tcp connection on port 80 and 443.
# No limits to outgoing traffic. this security group
# is only used by the public load balancer. Thats means
# that it's the only resource to accept request from outside
# the vpc.
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

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

# here is the security group that describe
# the traffic into the vpc, between ec2 instances and le the load balancer.
# Ec2 instances do have all tcp port reachable,but only for other member of
# this security group (other ec2 instance and the load balancer).
# all tcp port are opened, because the ecs services will run task with
# docker dynamic port feature, meaning that container exposed ports
# are not guessable.
# No limits to outgoing traffic.
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

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}