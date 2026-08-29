# Un solo lugar de verdad para los alias de red de cada réplica del
# backend (ej. "backend-1", "backend-2"...). Se usa tanto al crear los
# contenedores (backend.tf) como al generar la configuración de Nginx
# (nginx.tf), garantizando que ambos siempre coincidan aunque cambie
# var.backend_replica_count.
locals {
  backend_aliases = [for i in range(var.backend_replica_count) : "backend-${i + 1}"]
}
