# Construye la imagen a partir del Dockerfile del proyecto backend/, en
# lugar de descargarla de un registro. Terraform reconstruye la imagen
# automáticamente si el contenido de esa carpeta cambia.
resource "docker_image" "backend" {
  name = "iac-workshop-backend:local"

  build {
    context    = abspath("${path.module}/../backend")
    dockerfile = "Dockerfile"
  }

  # Fuerza a Terraform a detectar cambios en el código fuente del backend
  # y reconstruir la imagen, aunque el nombre/tag no cambie.
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset("${path.module}/../backend", "**") : filesha1("${path.module}/../backend/${f}")]))
  }
}

# "count" crea tantos contenedores idénticos como indique
# var.backend_replica_count. Cada uno es un recurso independiente en el
# grafo y en el archivo de estado: docker_container.backend[0],
# docker_container.backend[1], etc.
resource "docker_container" "backend" {
  count    = var.backend_replica_count
  name     = "workshop-backend-${count.index + 1}"
  image    = docker_image.backend.image_id
  hostname = local.backend_aliases[count.index]

  networks_advanced {
    name    = docker_network.workshop_net.name
    aliases = [local.backend_aliases[count.index]]
  }

  env = [
    "PORT=3000",
    "DB_HOST=mysql",
    "DB_PORT=3306",
    "DB_USER=${var.mysql_user}",
    "DB_PASSWORD=${var.mysql_password}",
    "DB_NAME=${var.mysql_database}",
  ]

  # No arranca hasta que MySQL esté "healthy" (ver wait/healthcheck en
  # mysql.tf). Terraform respeta este orden al construir el grafo de
  # dependencias, igual que se explicó en la clase de arquitectura de IaC.
  depends_on = [docker_container.mysql]

  restart  = "unless-stopped"
  must_run = true
}
