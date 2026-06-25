# Los outputs son el contrato entre Terraform y Ansible.
# El job 'infra' del pipeline los captura y los pasa al job 'config'.

output "frontend_ip" {
  description = "IP pública del servidor frontend (Nginx). Usada para: acceso HTTP y bastión SSH."
  value       = aws_instance.frontend.public_ip
}

output "backend_private_ip" {
  description = "IP privada del servidor backend (FastAPI). Solo accesible desde la red interna."
  value       = aws_instance.backend.private_ip
}

output "comando_ssh_frontend" {
  description = "Comando SSH directo al frontend (para debugging manual)"
  value       = "ssh -i masterclass-keypair.pem ubuntu@${aws_instance.frontend.public_ip}"
}

output "comando_ssh_backend" {
  description = "Comando SSH al backend via ProxyJump por el frontend (para debugging manual)"
  value       = "ssh -i masterclass-keypair.pem -J ubuntu@${aws_instance.frontend.public_ip} ubuntu@${aws_instance.backend.private_ip}"
}

output "url_app" {
  description = "URL final de la aplicación"
  value       = "http://${aws_instance.frontend.public_ip}/"
}
