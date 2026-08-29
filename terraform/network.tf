# Red privada tipo "bridge" en la que viven los cuatro servicios. Docker
# provee resolución DNS automática entre contenedores de la misma red
# usando su nombre o alias (por eso el backend puede conectarse a "mysql"
# y Nginx puede hablarle a "backend-1", "backend-2", "frontend").
resource "docker_network" "workshop_net" {
  name = "iac-workshop-net"
}
