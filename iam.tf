# first of all the role is created
# On AWS, the role is an important part of IAM service (identity and access management).
# It is used to permit some actions (like access data an S3 bucket or update a docker image on ecr).
# This permissions are granted without additionnal identity informations, which is very convenient
# for application running on AWS that have to manipulate AWS resources => no need to share API key.
# This role can only be assumed by ec2 instance (assume_role_policy)
resource "aws_iam_role" "ecs_instance" {
  name = "ecs_instance"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# This role can only be assumed by ecs service (assume_role_policy)
resource "aws_iam_role" "ecs_service" {
  name = "ecs_service"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# the AmazonEC2ContainerServiceRole goal is to permit to ecs
# to register or deregister services on the load balancer
# see : http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_managed_policies.html#AmazonEC2ContainerServiceRole
resource "aws_iam_policy_attachment" "ecs_services" {
  name = "ecs_service_policy_attachement"
  roles = ["${aws_iam_role.ecs_service.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

# the AmazonEC2ContainerServiceforEC2Role allow the ecs container to communicate with
# the cluster.
# see : http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_managed_policies.html#AmazonEC2ContainerServiceforEC2Role
resource "aws_iam_policy_attachment" "ecs_instances" {
  name = "ecs_instances_policy_attachement"
  roles = ["${aws_iam_role.ecs_instance.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}