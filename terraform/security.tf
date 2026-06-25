# ============================================================
# SECURITY GROUPS: El firewall de cada instancia
# ============================================================
# Regla de oro: principio de mínimo privilegio.
# Abre solo los puertos que NECESITAS, desde las IPs que DEBES permitir.

# Security Group del Frontend (Nginx)
resource "aws_security_group" "frontend" {
  name        = "${var.proyecto}-sg-frontend"
  description = "SG para Nginx: permite trafico web publico y SSH desde runners de CI/CD"
  vpc_id      = aws_vpc.principal.id

  # Puerto 80: tráfico HTTP público (aqui llegan los usuarios)
  ingress {
    description = "HTTP publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Puerto 22: acceso SSH para Ansible desde GitHub Actions runners
  # En producción real, restringirías esto a los rangos de IP de GitHub.
  # Para la masterclass, cualquier IP simplifica el demo sin afectar el concepto.
  ingress {
    description = "SSH para Ansible (GitHub Actions runners)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress irrestricto: la instancia puede iniciar conexiones hacia afuera
  # (necesario para apt update, descargar paquetes, conectarse al backend)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "${var.proyecto}-sg-frontend"
    Proyecto = var.proyecto
  }
}

# Security Group del Backend (FastAPI)
resource "aws_security_group" "backend" {
  name        = "${var.proyecto}-sg-backend"
  description = "SG para FastAPI: solo acepta trafico desde el SG del frontend"
  vpc_id      = aws_vpc.principal.id

  # Puerto 5000: SOLO desde el SG del frontend.
  # Esto es aislamiento real: ni siquiera con la IP correcta puedes entrar
  # si no pasas por el security group del frontend primero.
  ingress {
    description     = "FastAPI solo desde Nginx (frontend SG)"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

  # Puerto 22: solo desde el frontend (bastión SSH para Ansible via ProxyJump)
  ingress {
    description     = "SSH via ProxyJump desde frontend (bastion Ansible)"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "${var.proyecto}-sg-backend"
    Proyecto = var.proyecto
  }
}
