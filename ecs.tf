resource "aws_ecs_cluster" "main" {
  name = "main-cluster"
}

# ECR repositories
resource "aws_ecr_repository" "apps" {
  count = 4  # 3 apps + 1 MQTT broker
  name  = "app-${count.index + 1}"
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "app" {
  count                    = 3
  family                   = "app-${count.index + 1}"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 256
  memory                  = 512

  container_definitions = jsonencode([
    {
      name  = "app-${count.index + 1}"
      image = "${aws_ecr_repository.apps[count.index].repository_url}:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# MQTT Broker Task Definition
resource "aws_ecs_task_definition" "mqtt" {
  family                   = "mqtt-broker"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 256
  memory                  = 512

  container_definitions = jsonencode([
    {
      name  = "mqtt-broker"
      image = "${aws_ecr_repository.apps[3].repository_url}:latest"
      portMappings = [
        {
          containerPort = 1883
          hostPort      = 1883
          protocol      = "tcp"
        }
      ]
    }
  ])
}