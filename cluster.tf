# the ECS cluster. ECS is the cluster scheduler service provided by AWS.
# unlike some of its competitor, it could only work with docker based
# applications. However, it is easy to start, easy to run (thanks to managed service !)
# and integrate well with other AWS services.

resource "aws_ecs_cluster" "matinale-tech" {
  name = "ecs-cluster-for-matinale-tech"
}

# ECR is the container repository for AWS
resource "aws_ecr_repository" "matinale-tech" {
  name = "matinale-tech"
}

# Here are the task definition. Basically, a task is a programm that will run
# on the cluster. Could be run as deamon, as one shot or recurrent task ...
# It contains description of the container, of its configuration and of its
# resources requirement (cpu / ram)
# we can express placement restriction : for exemple, if your task need to have
# hightly performant CPU, GPU computation or optimized IO/ps you can choose the
# kind of ec2 instance your task should run on.
data "template_file" "production-mat-tech" {
  template = "${file("templates/mat_tech_container_definition.tpl")}"

  vars {
    version = "${var.production_version}"
    env = "production"
    account_id = "${data.aws_caller_identity.current.account_id}"
  }
}

data "template_file" "test-mat-tech" {
  template = "${file("templates/mat_tech_container_definition.tpl")}"

  vars {
    version = "${var.test_version}"
    env = "test"
    account_id = "${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_ecs_task_definition" "matinale-tech-production" {
  family                = "matinale-tech-prod"
  container_definitions = "${data.template_file.production-mat-tech.rendered}"
}

resource "aws_ecs_task_definition" "matinale-tech-test" {
  family                = "matinale-tech-test"
  container_definitions = "${data.template_file.test-mat-tech.rendered}"
}

# On ecs, a service is a way to schedule task as a service.
# here is defined the number of instance the service should have,
# the placement strategie of task on the cluster, the laod balancer where
# the ecs scheduler should register new service instance, etc ...
resource "aws_ecs_service" "production" {
  name            = "mat-tech-prod"
  cluster         = "${aws_ecs_cluster.matinale-tech.id}"
  task_definition = "${aws_ecs_task_definition.matinale-tech-production.arn}"
  desired_count   = "${var.nb_production_task}"
  iam_role        = "${aws_iam_role.ecs_service.arn}"
  depends_on      = ["aws_iam_policy_attachment.ecs_services"]

  placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.prod_ecs_cluster.arn}"
    container_name = "matinale-tech"
    container_port = 80
  }
}

resource "aws_ecs_service" "test" {
  name            = "mat-tech-test"
  cluster         = "${aws_ecs_cluster.matinale-tech.id}"
  task_definition = "${aws_ecs_task_definition.matinale-tech-test.arn}"
  desired_count   = "${var.nb_test_task}"
  iam_role        = "${aws_iam_role.ecs_service.arn}"
  depends_on      = ["aws_iam_policy_attachment.ecs_services"]

  placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.test_ecs_cluster.arn}"
    container_name = "matinale-tech"
    container_port = 80
  }
}