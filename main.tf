resource "aws_security_group" "rabbitmq" {
  name        = "${var.env}-rabbitmq_segrp"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.main_vpc

  ingress {
    description      = "rabbitmq"
    from_port        = 5672
    to_port          = 5672
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags       = merge(
    local.common_tags,
    { Name = "${var.env}-rabbitmq-segrp" }
  )
}

resource "aws_mq_broker" "rabbitmq" {
  broker_name = "${var.env}-rabbitmq"
  deployment_mode = var.deployment_mode
  subnet_ids = var.deployment_mode == "SINGLE_INSTANCE" ? var.subnet_ids[0] : var.subnet_ids

#  configuration {
#    id       = aws_mq_configuration.test.id
#    revision = aws_mq_configuration.test.latest_revision
#  }

  engine_type        = var.engine_type
  engine_version     = var.engine_version
  host_instance_type = var.host_instance_type
  security_groups    = [aws_security_group.rabbitmq.id]

  encryption_options {
    use_aws_owned_key = false
    kms_key_id = data.aws_kms_key.key.arn
  }

  user {
    username = "dimpul"
    password = "dimpul123"
  }
}


