resource "docker_image" "frontend" {
  name = "iac-workshop-frontend:local"

  build {
    context    = abspath("${path.module}/../frontend")
    dockerfile = "Dockerfile"
  }

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset("${path.module}/../frontend", "**") : filesha1("${path.module}/../frontend/${f}")]))
  }
}

resource "docker_container" "frontend" {
  name     = "workshop-frontend"
  image    = docker_image.frontend.image_id
  hostname = "frontend"

  networks_advanced {
    name    = docker_network.workshop_net.name
    aliases = ["frontend"]
  }

  restart  = "unless-stopped"
  must_run = true
}
