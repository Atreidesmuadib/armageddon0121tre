# Explanation: EC2 SG is bos’s bodyguard—only let in what you mean to.
resource "aws_security_group" "bos_ec2_sg01" {
  name        = "${local.name_prefix}-ec2-sg01"
  description = "EC2 app security group"
  vpc_id      = aws_vpc.bos_vpc01.id

  # TODO: student adds inbound rules (HTTP 80, SSH 22 from their IP)
  # TODO: student ensures outbound allows DB port to RDS SG (or allow all outbound)

  tags = {
    Name = "${local.name_prefix}-ec2-sg01"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bos_ec2_http" {
  security_group_id = aws_security_group.bos_ec2_sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_vpc_security_group_ingress_rule" "bos_ssh" {
  security_group_id = aws_security_group.bos_ec2_sg01.id
  cidr_ipv4         = "${chomp(data.http.myip.response_body)}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "ec2_all_traffic_ipv4" {
  security_group_id = aws_security_group.bos_ec2_sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Explanation: RDS SG is the Rebel vault—only the app server gets a keycard.
resource "aws_security_group" "bos_rds_sg01" {
  name        = "${local.name_prefix}-rds-sg01"
  description = "RDS security group"
  vpc_id      = aws_vpc.bos_vpc01.id

  # TODO: student adds inbound MySQL 3306 from aws_security_group.bos_ec2_sg01.id

  tags = {
    Name = "${local.name_prefix}-rds-sg01"
  }
}

# Ingress: Allow MySQL only from the EC2 app server's security group
resource "aws_vpc_security_group_ingress_rule" "bos_rds_mysql" {
  security_group_id            = aws_security_group.bos_rds_sg01.id
  referenced_security_group_id = aws_security_group.bos_ec2_sg01.id # ← This points to your EC2 SG

  from_port   = 3306
  to_port     = 3306
  ip_protocol = "tcp"
  description = "Allow MySQL access only from app tier EC2 instances"
}

# Egress: Remains unchanged (allow all outbound)
resource "aws_vpc_security_group_egress_rule" "rds_all_traffic_ipv4" {
  security_group_id = aws_security_group.bos_rds_sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # All protocols and ports
  description       = "Allow all outbound traffic"
}
