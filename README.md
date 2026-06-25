# Masterclass CI/CD: De Código Local a la Nube

**Objetivo:** Demostrar el flujo completo de DevOps profesional:
`git push` → GitHub Actions → Terraform → Ansible → App en producción.

## Arquitectura

```
Internet → Nginx (EC2 Pública, Puerto 80) → FastAPI (EC2 Privada, Puerto 5000)
```

El backend **no tiene IP pública**. Solo Nginx puede hablarle, en el puerto 5000.
Este aislamiento es la diferencia entre "funciona en mi máquina" y "producción real".

## Prerequisitos Manuales

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
.github/workflows/pipeline.yml   # El "Robot": coordina Infra → Config
app/                             # FastAPI demo
ansible/                         # Roles: common, backend, frontend
terraform/                       # IaC: VPC, EC2, SG, S3 Backend
presentation/                    # Entregable PPTX de la clase
```

## Ejecutar el Pipeline

```bash
git add .
git commit -m "feat: implementación completa masterclass CI/CD"
git push origin main
```

El pipeline en GitHub Actions hará el resto.

## Acceder a la App (post-pipeline)

La URL aparecerá en los logs del job `config`. Formato:
```
http://<frontend_ip>/
```
