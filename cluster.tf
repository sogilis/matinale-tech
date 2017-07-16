resource "aws_ecs_cluster" "matinale-tech" {
  name = "ecs-cluster-for-matinale-tech"
}


resource "aws_ecr_repository" "matinale-tech" {
  name = "matinale-tech"
}

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

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b, eu-west-1c]"
  }
}

resource "aws_ecs_task_definition" "matinale-tech-test" {
  family                = "matinale-tech-test"
  container_definitions = "${data.template_file.test-mat-tech.rendered}"
}


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