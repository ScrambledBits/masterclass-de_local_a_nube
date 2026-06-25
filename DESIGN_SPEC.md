# DESIGN SPECIFICATION: Masterclass "De Código Local a la Nube"
**Target Audience:** Potential Students (Mixed Background)
**Goal:** Demystify deployment and sell the DevOps Bootcamp.
**Format:** 1 Hour (Demo + Presentation)
**Language:** Spanish (Neutro). No regionalisms, no slang, no \"AI-isms\".

---

## 0. Editorial & Operational Rigor (MANDATORY)
This section overrides all other behaviors. Claude Code must adhere to these rules strictly:

### A. The "Professor Emilio" Voice
- **Language:** Pure Spanish Neutro.
- **Tone:** Professional, technical, and direct. Avoid fluff. Focus on the \"Reasoning\" over \"Execution\".
- **Code Documentation:** All code MUST be documented with detailed, pedagogical comments. Do not just say *what* the code does; explain *why* it's done this way and how it relates to a real-world professional scenario.
- **Analogies:** Use physical analogies to simplify complex concepts (e.g., \"The Pipeline is a conveyor belt\", \"The Backend is the crown jewel in a vault\") but do not overuse them, only when it's necessary to explain a complex concept.
- **Technical Truth:** Be blunt about pitfalls (e.g., why local state is dangerous, why a public backend is a security disaster).

### B. Execution Guardrails
- **ZERO ASSUMPTIONS:** Do not assume file paths, variable names, or environment settings. If a detail is not explicitly defined in this document, it is an ambiguity.
- **AMBIGUITY PROTOCOL:** In case of any ambiguity, contradiction, or missing information, **STOP and ASK the user** before proceeding. Do not guess.
- **VERIFICATION:** Every generated file must be verified against this spec before being declared "done".

---

## 1. Project Architecture & Directory Tree
The project will be hosted in a **public Git repository**. Therefore, strict hygiene is required. Only final deliverables and source code are checked in. Intermediate files, secrets, and temporary artifacts must be ignored.

```text
.
├── .github/
│   └── workflows/
│       └── pipeline.yml           # El \"Robot\": Coordina Infra -> Config
├── app/
│   ├── main.py                    # App simple FastAPI/Flask (Backend)
│   └── requirements.txt           # Dependencias de la app
├── ansible/
│   ├── group_vars/
│   │   └── all.yml                # Variables globales (puerto_app, etc.)
│   ├── roles/
│   │   ├── common/                # Setup base (apt update, python3-pip)
│   │   ├── frontend/              # Instalación Nginx & Config Proxy Inverso
│   │   │   ├── templates/
│   │   │   │   └── nginx.conf.j2  # Plantilla Jinja2 para el proxy inverso
│   │   │   └── tasks/
│   │       └── main.yml
│   │   └── backend/              # Despliegue App & servicio systemd
│   │       ├── templates/
│   │       │   └── flask_app.service.j2
│   │       └── tasks/
│   │           └── main.yml
│   └── playbook.yml               # Orquestación principal
├── terraform/
│   ├── backend.tf                 # Configuración S3 Backend (Estado remoto)
│   ├── main.tf                    # VPC, Subnets, IGW, NAT Gateway
│   ├── security.tf                # SGs (Público: 80/22, Privado: 5000 desde Público)
│   ├── compute.tf                 # Instancias EC2 (Frontend & Backend)
│   ├── outputs.tf                  # IP Pública, Comandos SSH
│   └── variables.tf               # Región, AMI, tipos de instancia
├── presentation/
│   └── final_presentation.pptx    # Único archivo entregable en esta carpeta
├── .gitignore                     # Debe excluir secretos y archivos temporales
└── README.md                      # Documentación del proyecto
```

### Git Hygiene & Secret Management
- **`.gitignore` MUST include:**
    - `*.pem` (Private keys)
    - `terraform.tfstate*` (Local state files)
    - `.env` (Environment variables)
    - `presentation/tmp/` (Directory for intermediate files like `slides_outline.md`)
- **NO SECRETS:** No AWS keys, SSH keys, or passwords must ever be committed. All secrets must be handled via GitHub Secrets in the pipeline.
- **INTERMEDIATE FILES:** The `slides_outline.md` is a temporary artifact. It must be created in `presentation/tmp/`, used to generate the `.pptx`, and then not committed to the repository.

---

## 2. Technical Requirements (The \"No-Fail\" Implementation)

### A. Terraform (La Infraestructura)
- **S3 State:** Mandatory remote backend.
- **Network Isolation:** 
    - **Frontend:** Public Subnet. SG allows Port 80 from `0.0.0.0/0`.
    - **Backend:** Private Subnet. SG allows Port 5000 **ONLY** from the Frontend SG. No Public IP.
- **Connectivity:** The Frontend must act as a bastion for Ansible.

### B. Ansible (La Configuración)
- **Templates:** 
    - `nginx.conf.j2`: Use `backend_private_ip` for `proxy_pass`.
    - `flask_app.service.j2`: Use systemd for persistence.
- **Execution:** `Common Role` $\rightarrow$ `Backend Role` $\rightarrow$ `Frontend Role`.

### C. GitHub Actions (CI/CD)
- **Job 1: Infra:** Checkout $\rightarrow$ Setup Terraform $\rightarrow$ `apply`. Output `frontend_ip` and `backend_private_ip`.
- **Job 2: Config:** Run `ansible-playbook` using `ProxyJump` through the frontend.

---

## 3. Presentation Blueprint (PPTX)
**IMPORTANT:** Claude Code must use the dedicated `bootcamperu-deliverable` skill to generate the final `.pptx` file following the corporate style. 

**Workflow:** 
1. Create a temporary `presentation/tmp/slides_outline.md` (NOT to be committed).
2. Use the `bootcamperu-deliverable` skill to transform that outline into the `presentation/final_presentation.pptx`.

**Slide Deck Structure (Spanish Neutro):**
1. **Portada:** \"De Código Local a la Nube: El Camino Profesional\".
2. **El Dolor (El \"Antes\"):** FileZilla, SSH manual, \"En mi máquina sí funciona\".
3. **La Promesa:** \"De un caos manual a un robot de despliegue\".
4. **El Estado Local:** App en `localhost:8000`. La brecha entre \"Terminar\" y \"Estar Vivo\".
5. **La Receta (IaC):** Terraform como \"Código que construye computadoras\". El S3 State como la \"Fuente de Verdad\".
6. **El Robot (CI/CD):** GitHub Actions. Los \"Círculos Verdes\" del éxito.
7. **La Arquitectura (Diagramas):** Visualización de VPC $\rightarrow$ Subred Pública $\rightarrow$ Subred Privada.
8. **El Triunfo:** Acceso real vía IP Pública.
9. **El Puente al Bootcamp:** De una \"Casita\" (EC2) a \"Rascacielos\" (K8s, Service Mesh).
10. **Q&A y Cierre.**

---

## 4. Diagram Specifications (Comparison Challenge)
Claude Code must implement these. Reference versions are in `/diagrams`.

### Diagram 1: El Flujo del Pipeline (Alto Nivel)
- **Lógica:** Flujo secuencial: Desarrollador $\rightarrow$ Git Push $\rightarrow$ GitHub Action (El Robot) $\rightarrow$ Terraform $\rightarrow$ AWS.

### Diagram 2: El Interior de la Nube (Arquitectura de Red)
- **Lógica:** Aislamiento y Seguridad.
- **Boundary:** VPC de AWS.
- **Zonas:** Subred Pública (Nginx) $\rightarrow$ Subred Privada (App Python).
- **Flujo:** Usuario $\rightarrow$ Puerto 80 $\rightarrow$ Nginx $\rightarrow$ Puerto 5000 $\rightarrow$ App.

---

## 5. Demo Narrative (The "Professor Emilio" Touch)
- **Step 1:** Run app locally. "Here is the code, but it's a secret. No one can see it."
- **Step 2:** `git push`. "We just gave the order to the robot."
- **Step 3:** Open GitHub Actions. "While the robot builds the data center, let's talk about why we don't do this by hand." $\rightarrow$ *Switch to PPTX*.
- **Step 4:** Return to GitHub. "Green lights. The factory is ready."
- **Step 5:** Load URL. "Boom. Professional grade."
- **Step 6:** The "Aha!" moment: "If I change the code and push, the robot does it again. That is the power of DevOps."
