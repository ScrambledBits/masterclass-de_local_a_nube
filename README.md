# Masterclass CI/CD: De Código Local a la Nube

**Objetivo:** Demostrar el flujo completo de DevOps profesional:
`git push` → GitHub Actions → Terraform → Ansible → App en producción.

## Arquitectura

```
Internet
    |  Puerto 80
Nginx (EC2 Subred Publica)        <-- IP publica, accesible desde internet
    |  proxy_pass :5000
FastAPI (EC2 Subred Privada)      <-- sin IP publica, invisible desde internet
    |  apt, pip
NAT Gateway (Subred Publica)      <-- salida a internet para la subred privada
    |
Internet Gateway --> Internet
```

El backend **no tiene IP publica**. Solo Nginx puede hablarle en el puerto 5000.
La subred privada accede a internet (para `apt`, `pip`) a traves del NAT Gateway,
sin quedar expuesta al trafico entrante.

## Demo Local (Docker)

Replica la arquitectura de produccion sin necesidad de AWS:

```bash
docker compose up --build
```

Abre `http://localhost/` en el navegador. Para apagar:

```bash
docker compose down
```

## Prerequisitos Manuales (solo para el pipeline en AWS)

Antes del primer `git push`, el instructor debe:

1. **Bucket S3** (`masterclass-cicd-tfstate` en `us-east-1`):
   ```bash
   aws s3api create-bucket --bucket masterclass-cicd-tfstate --region us-east-1
   aws s3api put-bucket-versioning --bucket masterclass-cicd-tfstate \
     --versioning-configuration Status=Enabled
   ```

2. **EC2 Key Pair** (`masterclass-keypair` en `us-east-1`):
   ```bash
   aws ec2 create-key-pair --key-name masterclass-keypair \
     --query 'KeyMaterial' --output text > masterclass-keypair.pem
   chmod 400 masterclass-keypair.pem
   ```

3. **GitHub Secrets** (Settings → Secrets and variables → Actions):
   - `AWS_ACCESS_KEY_ID`: ID de clave de acceso IAM
   - `AWS_SECRET_ACCESS_KEY`: Clave secreta IAM
   - `SSH_PRIVATE_KEY`: Contenido completo del archivo `.pem` (incluyendo headers)

## Estructura del Proyecto

```
.github/workflows/pipeline.yml   # El "Robot": Infra → Config → Destruir (manual)
app/
  main.py                        # FastAPI: endpoints / y /health
  requirements.txt               # fastapi==0.111.0, uvicorn[standard]==0.29.0
  Dockerfile                     # Imagen para demo local
ansible/
  group_vars/all.yml             # Variables globales (app_port, app_dir, app_user)
  playbook.yml                   # Orquesta: common → backend → frontend
  roles/
    common/                      # apt update + python3/pip/venv
    backend/                     # FastAPI + servicio systemd
    frontend/                    # Nginx como proxy inverso
docker/
  nginx.conf                     # Config Nginx para docker compose (usa nombre de servicio)
terraform/
  backend.tf                     # S3 remote state (masterclass-cicd-tfstate)
  variables.tf                   # Region, instance type, key name, proyecto
  main.tf                        # VPC, subnets, IGW, NAT Gateway, route tables
  security.tf                    # SGs: frontend (80/22 publico) + backend (5000/22 via SG)
  compute.tf                     # EC2 frontend (IP publica) + backend (IP privada)
  outputs.tf                     # frontend_ip, backend_private_ip, URLs
presentation/
  final_presentation.pptx        # 10 slides, identidad visual Bootcamperu
```

## Ejecutar el Pipeline en AWS

```bash
git push origin main
```

GitHub Actions ejecuta automaticamente:
1. **Job infra**: `terraform apply` crea VPC, subnets, NAT Gateway, SGs y EC2s (~2 min)
2. **Job config**: Ansible configura Nginx y FastAPI via ProxyJump (~3 min)

La URL de la app aparece en los logs del job `config`:
```
[OK] App respondiendo en http://<frontend_ip>/
```

## Destruir la Infraestructura

Para evitar costos cuando el demo termina, desde GitHub Actions:

1. Ir a **Actions → Pipeline CI/CD → Run workflow**
2. Escribir `destruir` en el campo de confirmacion
3. Click **Run workflow**

O localmente con acceso a AWS:
```bash
cd terraform && terraform destroy
```
