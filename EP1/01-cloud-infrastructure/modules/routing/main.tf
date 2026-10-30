# Un solo NAT Gateway (AZ preferente) para controlar costos del Learner Lab.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_ids[0]

  tags = merge(var.tags, {
    Name = "${var.project_name}-nat"
  })
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-rtb-public"
  })
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_ids)

  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_app" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-rtb-private-app"
  })
}

resource "aws_route_table_association" "private_app" {
  count = length(var.private_app_subnet_ids)

  subnet_id      = var.private_app_subnet_ids[count.index]
  route_table_id = aws_route_table.private_app.id
}

resource "aws_route_table" "private_data" {
  vpc_id = var.vpc_id

  # Salida via NAT solo para bootstrap/parches (yum, imagen MySQL).
  # El aislamiento real lo imponen los Security Groups (solo 3306 desde App).
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-rtb-private-data"
  })
}

resource "aws_route_table_association" "private_data" {
  count = length(var.private_data_subnet_ids)

  subnet_id      = var.private_data_subnet_ids[count.index]
  route_table_id = aws_route_table.private_data.id
}
