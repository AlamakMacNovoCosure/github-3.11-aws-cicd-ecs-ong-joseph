resource "aws_ecr_repository" "ecrdemo" {
  name = "ecrdemo"
}

resource "aws_ecs_service" "ecstesting" {
  name = "ecstesting"
}

resource "aws_ecs_cluster" "joseph_cluster" {
  name = "joseph-app-cluster"
}

resource "aws_ecs_task_definition" "ecstesting" {
  family                   = "joseph-ecstesting" # Name your task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "ecs-sample",
      "image": "${aws_ecr_repository.ecrdemo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 512         # Specify the memory the container requires
  cpu                      = 256         # Specify the CPU the container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole1.arn}"
}

resource "aws_iam_role" "ecsTaskExecutionRole1" {
  name               = "ecsTaskExecutionRole1"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole1_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole1.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}