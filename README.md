# Taller Terraform + Docker

Taller práctico que despliega, con Terraform y el proveedor
[`kreuzwerker/docker`](https://registry.terraform.io/providers/kreuzwerker/docker),
una arquitectura de cuatro capas sobre contenedores Docker locales:
**Nginx → React → Node.js (con réplicas) → MySQL**. Todo corre en local,
sin ningún proveedor de nube (AWS, GCP, Azure).

El taller se usa como banco de pruebas para practicar el archivo de estado
de Terraform: inspección, detección de *drift*, `state mv`, `-replace`,
`import` y escalado.

Repositorio: https://github.com/miguesj-hub/taller-terraform-docker

## Arquitectura

| Componente       | Función                                                        | Puerto        |
|------------------|-----------------------------------------------------------------|---------------|
| Nginx            | Balanceador y *reverse proxy*; único punto de entrada           | 8080 (host)   |
| React (frontend) | Interfaz servida como estáticos desde su propio Nginx interno  | 80 (interno)  |
| Node.js/Express  | API con `/api/health` y `/api/visits`; N réplicas               | 3000 (interno)|
| MySQL 8.0        | Base de datos con volumen nombrado para persistencia            | 3306 (interno)|

## Requisitos

- Docker Desktop / Engine 24.x
- Terraform CLI 1.5.0+
- Node.js 20.x (opcional, solo para desarrollo fuera de contenedores)

## Estructura del proyecto

```
workshop/
  backend/            API Express (health + visits)
  frontend/           UI React que consume la API
  nginx/              plantilla nginx.conf.tpl que Terraform renderiza
  mysql/               esquema inicial de la base de datos
  terraform/
    versions.tf       provider + version de Terraform
    variables.tf      replicas, puerto, credenciales
    locals.tf         lista de alias backend-1, backend-2, ...
    network.tf        red privada iac-workshop-net
    mysql.tf          imagen + volumen + contenedor
    backend.tf        usa "count" para las réplicas
    frontend.tf       una sola réplica
    nginx.tf          usa templatefile() + upload
    outputs.tf        URLs y nombres de contenedores
  informe/            informe LaTeX del taller (PDF compilado incluido)
```

## Uso rápido

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # ajustar si hace falta
terraform init
terraform plan
terraform apply
```

Una vez aplicado:

```bash
docker ps
curl http://localhost:8080/api/health
curl http://localhost:8080/api/visits
```

Abrir `http://localhost:8080` en el navegador para ver la interfaz React.

Para escalar el backend, cambiar `backend_replica_count` en
`terraform.tfvars` y volver a ejecutar `terraform plan` / `terraform apply`.

Para destruir todo el entorno (incluye el volumen de MySQL):

```bash
terraform destroy
```

## Informe

El informe detallado del taller, con capturas de cada paso, está en
[`informe/main.tex`](informe/main.tex) (PDF compilado:
[`Taller_Terraform_Docker.pdf`](Taller_Terraform_Docker.pdf)).
