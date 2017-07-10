########################################################################
####### ec2 instances permissions specifics to the ECS cluster #########
########################################################################

# first of all the role is created
# On AWS, the role is an important part of IAM service (identity and access management).
# It is used to permit some actions (like access data an S3 bucket or update a docker image on ecr).
# This permissions are granted without additionnal identity informations, which is very convenient
# for application running on AWS that have to manipulate AWS resources => no need to share API key.
# This role can only be assumed by ec2 instance (assume_role_policy)
resource "aws_iam_role" "ecs" {
    name = "ecs"
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

# then some abilities are attached to the newly created role.
# this abilities are grouped in policies. Here we refere to an
# existing policy instead of creating a new one.
resource "aws_iam_policy_attachment" "ecs_for_ec2" {
  name = "ecs-for-ec2"
  roles = ["${aws_iam_role.ecs.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

########################################################################
################### EC2 instances description ##########################
########################################################################

# on this part is described the ec2 instances we want to have on the ecs cluster,
# the security group and, the scalling policy

# the IAM profile of ec2 instances
resource "aws_iam_instance_profile" "ecs" {
  name = "ecs-instance"
  role = "${aws_iam_role.ecs.name}"
}

# the configuration used by the auto scaling to
# launch new ecs instances
resource "aws_launch_configuration" "ecs_instance" {
  name_prefix = "ecs_instance-"
  image_id = "ami-809f84e6"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.ecs.id}"
  user_data = <<USER_DATA
  #!bin/bash
  echo ECS_CLUSTER=your_cluster_name >> /etc/ecs/ecs.config
USER_DATA
}

