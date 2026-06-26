# Changelog

## [1.8.0] - 2026-06-25

### Fixed
- `.github/workflows/pipeline.yml`: step "Verificar que la app responde correctamente"
  ahora comprueba el frontend estatico en `/` (HTTP 200) y el JSON del backend en
  `/api/`; antes usaba `python3 -m json.tool` sobre `/` que devuelve HTML, causando
  `Expecting value: line 1 column 1 (char 0)` y exit code 1

## [1.7.0] - 2026-06-25

### Fixed
- `ansible/roles/frontend/templates/nginx.conf.j2`: agregados `root /var/www/html`,
  `try_files` para archivos estaticos, y `location /api/` con proxy al backend;
  antes solo habia un proxy inverso total que enviaba todo al backend
- `ansible/roles/frontend/tasks/main.yml`: nueva tarea copia `frontend/index.html`
  a `/var/www/html/index.html` en el servidor antes de recargar Nginx
- `.github/workflows/pipeline.yml`: heredocs con contenido sin indentar reemplazados
  por `printf`; las lineas `Host ...` e `[frontend]` al nivel 0 rompian el parse YAML
  del runner de GitHub Actions

## [1.6.0] - 2026-06-25

### Changed
- `ansible/roles/common/tasks/main.yml`: `python3-pip` y `python3-venv` removidos del rol
  comun; el frontend EC2 solo corre Nginx y no los necesita
- `ansible/roles/backend/tasks/main.yml`: nueva tarea apt instala `python3-pip` y
  `python3-venv` en el host backend antes del paso `pip install`
- `frontend/index.html`: reglas CSS `.logo-b`/`.logo-c` deduplicadas con selector compartido
- `terraform/compute.tf`: campo `associate_public_ip_address = true` eliminado del frontend
  EC2 (la subnet publica ya tiene `map_public_ip_on_launch = true`)

## [1.5.0] - 2026-06-25

### Removed
- `terraform/outputs.tf`: outputs de debug `comando_ssh_frontend`, `comando_ssh_backend`,
  `url_app` eliminados; el pipeline solo consume `frontend_ip` y `backend_private_ip`

### Changed
- `frontend/index.html`: `fetchRaiz` y `fetchHealth` unificados en `fetchEndpoint(url, chipId, responseId)`

## [1.4.0] - 2026-06-25

### Fixed
- `terraform/security.tf`: `to_port = 8080` en el SG del frontend corregido a `to_port = 80`
- `terraform/security.tf`: eliminado `cidr_blocks = ["0.0.0.0/0"]` del ingress SSH del backend;
  el puerto 22 del backend queda restringido SOLO al SG del frontend (workaround revertido)
- `.github/workflows/pipeline.yml`: reemplazado `ansible_ssh_common_args` con ProxyJump en
  `~/.ssh/config` — corrige el error "UNKNOWN port 65535" de OpenSSH con ControlMaster
  cuando ProxyJump se pasa via args en lugar de configuracion SSH
- `.github/workflows/pipeline.yml`: actualizados actions a ultimas versiones con soporte Node 24:
  `actions/checkout` v4→v7, `aws-actions/configure-aws-credentials` v4→v6,
  `hashicorp/setup-terraform` v3→v4

## [1.3.0] - 2026-06-25

### Added
- Frontend estatico (`frontend/index.html`) con sistema de diseno Bootcamperu:
  - Colores: teal-700 (#0F766E) y orange-700 (#C2410C)
  - Fuentes: Cambria (titulos) y Calibri (cuerpo)
  - Banner de flujo de red: Internet → Nginx :80 → FastAPI :5000
  - Dos tarjetas con estado en tiempo real via `fetch` JS:
    - `GET /api/` → Estado del Pipeline
    - `GET /api/health` → Health Check
  - Auto-carga al abrir la pagina; boton "Probar el Pipeline" y actualizacion individual

### Changed
- `docker/nginx.conf`: agrega `root` y `try_files` para servir archivos estaticos;
  nueva ruta `location /api/` que hace proxy al backend (sin prefijo `/api/`)
- `docker-compose.yml`: monta `./frontend` en `/usr/share/nginx/html` del contenedor nginx
- `README.md`: instrucciones de demo local actualizadas con la nueva URL y descripcion del frontend

## [1.2.0] - 2026-06-25

### Added
- Diagramas de arquitectura en formato tldraw (.tldr) y PNG:
  - `diagrams/pipeline_flow.png`: flujo CI/CD en layout horizontal (dos filas)
  - `diagrams/cloud_interior.png`: red interior AWS en layout horizontal
- Dos nuevos slides en la presentacion (ahora 11 slides):
  - Slide 7: "Flujo del Pipeline CI/CD" con diagrama de pipeline
  - Slide 8: "Red Interior AWS" con diagrama de red
- README.md actualizado con imagenes de los diagramas

### Removed
- Diagramas Excalidraw obsoletos (sustituidos por tldraw)

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
