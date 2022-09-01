# Creating Elasticcache : A Managed service for Redis
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "roboshop-${var.ENV}"
  engine               = "redis"
  node_type            = "cache.t3.small"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.default.name
  engine_version       = "6.2"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.subnet-group.name
}


# Creating the patameter group
resource "aws_elasticache_parameter_group" "default" {
  name   = "cache-params"
  family = "redis6.2"
}


# Creating Subnet Grouo 
resource "aws_elasticache_subnet_group" "subnet-group" {
  name       = "roboshop-${var.ENV}"
  subnet_ids = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS

  tags = {
    Name = "roboshop-${var.ENV}"
  }
}

# Created instances and adds to the mongodb cluster
resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "roboshop-${var.ENV}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.medium"
}


resource "aws_security_group" "allow_mongodb" {
  name        = "roboshop-mongodb-${var.ENV}"
  description = "roboshop-monogdb-${var.ENV}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description = "TLS from VPC"
    from_port   = 27017
    to_port     = 27017
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
    Name = "roboshop-mongodb-${var.ENV}"
  }
}