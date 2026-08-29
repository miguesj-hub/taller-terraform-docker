resource "docker_image" "mysql" {
  name         = "mysql:8.0"
  keep_locally = true
}

# Volumen nombrado: los datos de MySQL sobreviven a "terraform apply"
# repetidos y a recreaciones del contenedor. Solo se pierden si se destruye
# explícitamente este recurso (por ejemplo, con "terraform destroy").
resource "docker_volume" "mysql_data" {
  name = "iac-workshop-mysql-data"

  # Tip de producción (comentado a propósito): con lifecycle.prevent_destroy
  # activo, "terraform destroy" o cualquier plan que implique borrar este
  # volumen FALLARÁ hasta que se quite esta línea explícitamente en el
  # código. Es una red de seguridad real contra un "destroy" accidental
  # sobre datos productivos. Se deja comentado aquí para no bloquear el
  # "terraform destroy" final del taller.
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "docker_container" "mysql" {
  name     = "workshop-mysql"
  image    = docker_image.mysql.image_id
  hostname = "mysql"

  networks_advanced {
    name    = docker_network.workshop_net.name
    aliases = ["mysql"]
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}",
  ]

  volumes {
    volume_name    = docker_volume.mysql_data.name
    container_path = "/var/lib/mysql"
  }

  # Bind mount de solo lectura: monta el script de inicialización del
  # repositorio directamente dentro del contenedor.
  volumes {
    host_path      = abspath("${path.module}/../mysql/init.sql")
    container_path = "/docker-entrypoint-initdb.d/init.sql"
    read_only      = true
  }

  healthcheck {
    test     = ["CMD", "mysqladmin", "ping", "-h", "localhost"]
    interval = "5s"
    timeout  = "3s"
    retries  = 10
  }

  # "wait" hace que Terraform NO considere aplicado este recurso hasta que
  # el healthcheck reporte "healthy". Combinado con el depends_on del
  # backend (backend.tf), esto evita el clásico problema de "el backend
  # arrancó antes de que la base de datos estuviera lista".
  wait         = true
  wait_timeout = 120

  restart  = "unless-stopped"
  must_run = true
}
