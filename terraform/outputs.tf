output "app_url" {
  description = "URL de entrada de la aplicación completa (a través de Nginx)"
  value       = "http://localhost:${var.nginx_host_port}"
}

output "api_health_url" {
  description = "URL del endpoint de salud del backend, para probar el balanceo de carga"
  value       = "http://localhost:${var.nginx_host_port}/api/health"
}

output "backend_container_names" {
  description = "Nombres de todos los contenedores de backend actualmente desplegados"
  value       = docker_container.backend[*].name
}

output "mysql_container_name" {
  description = "Nombre del contenedor de MySQL"
  value       = docker_container.mysql.name
}

output "mysql_volume_name" {
  description = "Nombre del volumen Docker donde persisten los datos de MySQL"
  value       = docker_volume.mysql_data.name
}
