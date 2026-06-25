# ============================================================
# COMPUTE: Instancias EC2
# ============================================================

resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.ubuntu_22_04.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.publica.id
  vpc_security_group_ids      = [aws_security_group.frontend.id]
  key_name                    = var.ssh_key_name

  # associate_public_ip_address es true por defecto en subnet pública,
  # pero lo explicamos explícitamente: esta instancia DEBE tener IP pública
  # para que Nginx sea accesible y para que Ansible pueda conectarse via SSH.
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8  # GB (suficiente para Ubuntu + Nginx)
    volume_type = "gp3"
  }

  tags = {
    Name     = "${var.proyecto}-frontend"
    Rol      = "frontend"
    Proyecto = var.proyecto
  }
}

resource "aws_instance" "backend" {
  ami                         = data.aws_ami.ubuntu_22_04.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.privada.id
  vpc_security_group_ids      = [aws_security_group.backend.id]
  key_name                    = var.ssh_key_name

  # Sin IP pública. No hay camino desde internet a esta instancia.
  # La única entrada es via ProxyJump desde el frontend (puerto 22, SG-restringido).
  associate_public_ip_address = false

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name     = "${var.proyecto}-backend"
    Rol      = "backend"
    Proyecto = var.proyecto
  }
}
