# Creating Elasticcache : A Managed service for Redis
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "roboshop-${var.ENV}"
  engine               = "redis"
  node_type            = var.ELASTICCCACHE_NODE_TYPE
  num_cache_nodes      = var.ELASTICCCACHE_NODE_COUNT
  parameter_group_name = aws_elasticache_parameter_group.default.name
  engine_version       = var.ELASTICCCACHE_PORT_ENGINE_VERSION
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.ec-subnet-group.name
  security_group_ids   = [aws_security_group.allow_redis.id]
}


# Creating the patameter group
resource "aws_elasticache_parameter_group" "default" {
  name   = "roboshop-${var.ENV}"
  family = "redis${var.ELASTICCCACHE_PORT_ENGINE_VERSION}"

}

# Creating Subnet Grouo 
resource "aws_elasticache_subnet_group" "ec-subnet-group" {
  name       = "roboshop-ec-${var.ENV}"
  subnet_ids = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS

  tags = {
    Name = "roboshop-ec-${var.ENV}"
  }
}


# SG for redis

resource "aws_security_group" "allow_redis" {
  name        = "roboshop-redis-${var.ENV}"
  description = "roboshop-redis-${var.ENV}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description = "TLS from VPC"
    from_port   = var.ELASTICCCACHE_PORT
    to_port     = var.ELASTICCCACHE_PORT
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.VPC_CIDR]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "roboshop-redis-${var.ENV}"
  }
}