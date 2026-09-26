data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
  
  keepers = {
    vpc_cidr = var.vpc_cidr
  }
}

locals {
  base_name = "${var.environment}-${var.purpose}-${data.aws_region.current.region}"
  unique    = random_string.suffix.result

  vpc_name = "${local.base_name}-${var.vpc_name}-${local.unique}"
}


resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = local.vpc_name
  }
}



resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.base_name}-igw"
  }
}


resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id                  = aws_vpc.this.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index + 1)
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.base_name}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
 count = var.az_count

  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 10)

  tags = {
    Name = "${local.base_name}-private-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.base_name}-public-rt"
  }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
   domain = "vpc"
 }

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
 }

resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.base_name}-private-rt-${count.index + 1}"
  }
}

resource "aws_route" "nat_route" {
   count                  = length(aws_route_table.private)
   route_table_id         = aws_route_table.private[count.index].id
   destination_cidr_block = "0.0.0.0/0"
   nat_gateway_id         = aws_nat_gateway.nat.id
 }

resource "aws_route_table_association" "private_assoc" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}



resource "aws_security_group" "lambda" {
  name   = "${local.base_name}-lambda-sg-${local.unique}"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group" "rds" {
  name   = "${local.base_name}-rds-sg-${local.unique}"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group" "ec2" {
  name   = "${local.base_name}-ec2-sg-${local.unique}"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group" "embeddings" {
  name   = "${local.base_name}-embeddings-sg-${local.unique}"
  vpc_id = aws_vpc.this.id
}

# VPC ENDPOINT SECURITY GROUP
# -----------------------------
resource "aws_security_group" "vpce" {
  name   = "${local.base_name}-vpce-sg-${local.unique}"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "vpce_https_from_lambda" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpce.id
  source_security_group_id = aws_security_group.lambda.id
}

resource "aws_security_group_rule" "vpce_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.vpce.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lambda_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lambda.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "rds_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ec2_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ec2.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "embeddings_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.embeddings.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lambda_to_rds_ingress" {
  type                     = "ingress"
  from_port                = var.rds_port
  to_port                  = var.rds_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.lambda.id
}

resource "aws_security_group_rule" "lambda_to_rds_egress" {
  type                     = "egress"
  from_port                = var.rds_port
  to_port                  = var.rds_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda.id
  source_security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "ec2_to_rds_ingress" {
  type                     = "ingress"
  from_port                = var.rds_port
  to_port                  = var.rds_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "ec2_to_rds_egress" {
  type                     = "egress"
  from_port                = var.rds_port
  to_port                  = var.rds_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2.id
  source_security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "ec2_ssh" {
  type              = "ingress"
  from_port         = var.ssh_port
  to_port           = var.ssh_port
  protocol          = "tcp"
  security_group_id = aws_security_group.ec2.id
  cidr_blocks       = ["103.93.107.18/32"]
}

resource "aws_security_group_rule" "embeddings_access" {
  type              = "ingress"
  from_port         = var.aurora_port
  to_port           = var.aurora_port
  protocol          = "tcp"
  security_group_id = aws_security_group.embeddings.id
  cidr_blocks       = ["103.93.107.18/32"]
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "vpce-ssm"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
  vpc_endpoint_type = "Interface"

  # attach to both private subnets (multi-AZ)
  subnet_ids = aws_subnet.private[*].id

  # reuse common VPCE security group
  security_group_ids = [
    aws_security_group.vpce.id
  ]

  # enable private DNS (IMPORTANT)
  private_dns_enabled = true

  tags = {
    Name = "vpce-secretsmanager"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "vpce-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.sqs"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "vpce-sqs"
  }
}

resource "aws_vpc_endpoint" "appsync" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.appsync"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "vpce-appsync"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"

  # Attach to PRIVATE route tables (important)
  route_table_ids = aws_route_table.private[*].id

  tags = {
    Name = "vpce-s3"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  # Attach to private route tables (for Lambda)
  route_table_ids = aws_route_table.private[*].id

  tags = {
    Name = "vpce-dynamodb"
  }
}