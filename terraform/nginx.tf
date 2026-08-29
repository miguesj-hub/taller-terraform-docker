resource "docker_image" "nginx" {
  name         = "nginx:1.27-alpine"
  keep_locally = true
}

resource "docker_container" "nginx" {
  name  = "workshop-nginx"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.workshop_net.name
  }

  # Único puerto expuesto al host: el resto de la arquitectura solo es
  # accesible dentro de la red interna de Docker que creó Terraform.
  ports {
    internal = 80
    external = var.nginx_host_port
  }

  # "upload" sube contenido generado por Terraform directamente al sistema
  # de archivos del contenedor ANTES de arrancarlo. templatefile() procesa
  # nginx.conf.tpl inyectando el alias de cada réplica del backend.
  # Nota pedagógica: si esta plantilla cambia (por ejemplo, al escalar el
  # backend), Terraform DESTRUYE y RECREA este contenedor -- no lo "edita"
  # en caliente. Es el mismo principio de infraestructura inmutable visto
  # en la clase de conceptos de IaC.
  upload {
    content = templatefile("${path.module}/../nginx/nginx.conf.tpl", {
      backend_hosts = local.backend_aliases
    })
    file = "/etc/nginx/nginx.conf"
  }

  depends_on = [docker_container.backend, docker_container.frontend]

  restart  = "unless-stopped"
  must_run = true
}
