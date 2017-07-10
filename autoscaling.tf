

resource "aws_autoscaling_group" "ecs_cluster" {
  name = "ecs-cluster-autoscaling-group"
  vpc_zone_identifier = ["${aws_subnet.public_subnet_a.id}","${aws_subnet.public_subnet_b.id}","${aws_subnet.public_subnet_c.id}"]
  max_size = 6
  min_size = 0
  desired_capacity = 0
  health_check_type = "EC2"
  target_group_arns = ["${aws_alb_target_group.ecs_cluster.arn}"]
  launch_configuration = "${aws_launch_configuration.ecs_instance.id}"
}
