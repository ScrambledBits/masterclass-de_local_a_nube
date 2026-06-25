# Changelog

## [1.1.0] - 2026-06-25

### Added
- NAT Gateway en subred publica para que el backend (subred privada) pueda
  ejecutar `apt update` y `pip install` sin quedar expuesto a internet
- Job `destruir` en el pipeline con activacion manual (`workflow_dispatch`):
  escribe "destruir" en GitHub Actions → Run workflow para eliminar toda la
  infraestructura AWS sin necesidad de acceso local
- Docker Compose para demo local: `docker compose up --build` levanta Nginx +
  FastAPI en `http://localhost/` replicando la arquitectura de produccion

### Fixed
- Caracteres con tilde en `description` de ingress rules de Security Groups:
  AWS solo acepta ASCII en ese campo (`bastion Ansible`, no `bastión Ansible`)
- Expresion Jinja2 vacia `{{ }}` en comentario de `flask_app.service.j2`
  causaba error de sintaxis al renderizar el template con Ansible
- Variable `$GITHUB_OUTPUT` sin comillas en el step de captura de outputs
  (shellcheck SC2086)
- Guiones em (—) en comentarios y textos de varios archivos (regla editorial
  Bootcamperu: usar comas, parentesis o puntos en su lugar)

## [1.0.0] - 2026-06-25

### Added
- Implementacion inicial del proyecto Masterclass CI/CD
- App FastAPI demo con endpoints `/` y `/health`
- Infraestructura Terraform: VPC, subnets, IGW, SGs, EC2 (x2), S3 backend
- Ansible: roles common, backend y frontend con templates Jinja2
- Pipeline GitHub Actions: job infra (Terraform) + job config (Ansible)
- Presentacion PPTX 10 slides para la sesion de masterclass
