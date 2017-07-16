# the IAM profile of ec2 instances
# this resource is used to affect a role
# to the future instances.
resource "aws_iam_instance_profile" "ecs_instance" {
  name = "ecs-instance"
  role = "${aws_iam_role.ecs_instance.name}"
}

# the configuration used by the auto scaling group to
# launch new ecs instances
resource "aws_launch_configuration" "ecs_instance" {
  name_prefix = "ecs_instance-"
  image_id = "ami-809f84e6"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_instance.id}"
  security_groups = ["${aws_security_group.ecs_cluster.id}"]
  associate_public_ip_address = true
  lifecycle = {
    create_before_destroy = true
  }
  user_data = <<EOF
  #!/bin/bash
  echo ECS_CLUSTER=ecs-cluster-for-matinale-tech >> /etc/ecs/ecs.config
EOF
}

# this is the autoscaling group configuration. An autoscaling group is
# a logical group of ec2 instance with same configuration. We can scale
# up or scale down the number of instance, depending on the needs.
# We choose to use an auto scaling group for this capacity, making
# easier to run the ec2 instances only when needed, just by changing the
# desired_capacity and then run 'terraform apply'.
# In production, you can perform dynamic cluster resizing through
# cloud watch or custom tools and aws api.

resource "aws_autoscaling_group" "ecs_cluster" {
  name = "ecs-cluster-autoscaling-group"
  vpc_zone_identifier = ["${aws_subnet.public_subnet_a.id}","${aws_subnet.public_subnet_b.id}","${aws_subnet.public_subnet_c.id}"]
  max_size = 6
  min_size = 0
  desired_capacity = "${var.desired_capacity}"
  health_check_type = "EC2"
  launch_configuration = "${aws_launch_configuration.ecs_instance.id}"
}