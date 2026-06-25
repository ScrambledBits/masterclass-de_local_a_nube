# ============================================================
# RED: VPC, Subnets, Internet Gateway, Route Tables
# ============================================================
# Analogía: La VPC es el edificio. Las subnets son los pisos.
# La pública tiene ventanas (IGW). La privada no tiene salida directa.

# Buscamos la AMI más reciente de Ubuntu 22.04 LTS de forma dinámica.
# Hardcodear un AMI ID es un error común: cambia por región y se deprecan.
data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  owners      = ["099720109477"] # ID canónico de Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "principal" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true # Necesario para que las instancias tengan nombres DNS
  enable_dns_support   = true

  tags = {
    Name     = "${var.proyecto}-vpc"
    Proyecto = var.proyecto
  }
}

# Subred pública: aquí vive Nginx. Tiene ruta al internet.
resource "aws_subnet" "publica" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true # Las instancias aquí reciben IP pública automáticamente

  tags = {
    Name     = "${var.proyecto}-subnet-publica"
    Proyecto = var.proyecto
  }
}

# Subred privada: aquí vive la app Python. Sin salida directa al internet.
resource "aws_subnet" "privada" {
  vpc_id            = aws_vpc.principal.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"
  # map_public_ip_on_launch = false es el default — explícito aquí con propósito pedagógico

  tags = {
    Name     = "${var.proyecto}-subnet-privada"
    Proyecto = var.proyecto
  }
}

# Internet Gateway: la "puerta" entre la VPC y el internet público
resource "aws_internet_gateway" "principal" {
  vpc_id = aws_vpc.principal.id

  tags = {
    Name     = "${var.proyecto}-igw"
    Proyecto = var.proyecto
  }
}

# Route Table para la subred pública: todo el tráfico que no es local va al IGW
resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.principal.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.principal.id
  }

  tags = {
    Name     = "${var.proyecto}-rt-publica"
    Proyecto = var.proyecto
  }
}

resource "aws_route_table_association" "publica" {
  subnet_id      = aws_subnet.publica.id
  route_table_id = aws_route_table.publica.id
}

# La subred privada NO tiene route table propia aquí.
# Usa el route table principal de la VPC, que no tiene ruta al IGW.
# Esto es lo que la hace "privada": simplemente no hay camino al internet.
