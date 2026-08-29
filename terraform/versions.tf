terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.0"
    }
  }
}

# Sin bloque "host": el provider usa el socket local de Docker por defecto
# (unix:///var/run/docker.sock en Linux/Mac, npipe en Windows), detectado
# automáticamente a través del contexto activo de Docker Desktop/Engine.
# Por eso este taller NO necesita ninguna cuenta ni crédito de nube pública.
provider "docker" {}
