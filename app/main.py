"""
Backend de la Masterclass CI/CD

Esta app es intencionalmente simple. El objetivo de la clase no es
la complejidad de la aplicación, sino demostrar el proceso que la lleva
de localhost a producción de forma automática y reproducible.

Flujo de red en producción:
  Internet → Nginx (Puerto 80, subred pública)
           → Esta app (Puerto 5000, subred privada)
"""
from fastapi import FastAPI

app = FastAPI(
    title="Masterclass CI/CD Backend",
    description="API de demostración para el flujo CI/CD con Terraform y Ansible",
    version="1.0.0",
)


@app.get("/")
def raiz():
    """
    Endpoint principal.

    Si ves esta respuesta en el navegador después de un `git push`,
    el pipeline completo funcionó:
      1. Terraform construyó la infraestructura en AWS
      2. Ansible instaló uvicorn y configuró este servicio systemd
      3. Ansible instaló Nginx y lo configuró como proxy inverso
      4. Nginx recibió tu petición en el puerto 80 y la redirigió aquí
    """
    return {
        "mensaje": "¡Pipeline CI/CD exitoso!",
        "flujo": "Internet → Nginx (Puerto 80) → FastAPI (Puerto 5000)",
        "estado": "operativo",
    }


@app.get("/health")
def health_check():
    """
    Health check para Nginx y sistemas de monitoreo.

    Nginx y las plataformas cloud usan este endpoint para verificar
    que el proceso de la app está vivo antes de enviarle tráfico real.
    """
    return {"estado": "saludable"}
