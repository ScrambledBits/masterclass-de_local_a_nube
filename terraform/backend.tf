# El backend remoto es la diferencia entre un proyecto profesional y un proyecto local.
# Sin esto, el estado de Terraform vive en tu laptop:
#   - Si muere tu laptop, pierdes el estado → Terraform no sabe qué existe en AWS
#   - Si trabajas en equipo, dos personas aplican cambios a la vez → corrupción
# S3 con versionado es la "fuente de verdad" del equipo.

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "masterclass-cicd-tfstate"
    key    = "masterclass/terraform.tfstate"
    region = "us-east-1"

    # encrypt = true es el estándar profesional.
    # Aunque el bucket sea privado, si alguien accede al bucket sin cifrado,
    # lee tu tfstate en texto plano (IPs, IDs, y a veces secretos de outputs).
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}
