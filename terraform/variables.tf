variable "aws_region" {
  description = "Región AWS donde se desplegará toda la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo de instancia EC2. t2.micro es elegible para la capa gratuita de AWS"
  type        = string
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "Nombre del Key Pair EC2 pre-existente en AWS para acceso SSH"
  type        = string
  default     = "masterclass-keypair"
}

variable "proyecto" {
  description = "Etiqueta para identificar todos los recursos de esta masterclass en la consola AWS"
  type        = string
  default     = "masterclass-cicd"
}
