variable "backend_replica_count" {
  description = "Número de réplicas del backend Node.js detrás del balanceador Nginx"
  type        = number
  default     = 2
}

variable "nginx_host_port" {
  description = "Puerto del host donde se expone Nginx (punto de entrada único del taller)"
  type        = number
  default     = 8080
}

variable "mysql_database" {
  description = "Nombre de la base de datos de la aplicación"
  type        = string
  default     = "workshop_db"
}

variable "mysql_user" {
  description = "Usuario de aplicación para MySQL"
  type        = string
  default     = "app_user"
}

# --- Variables sensibles ---
# IMPORTANTE: aquí se usan valores por defecto SOLO porque este taller corre
# 100% en local, en contenedores efímeros, sin datos reales. En un proyecto
# real, estas variables NUNCA deberían tener "default" ni escribirse en
# archivos versionados en Git: se inyectan en tiempo de ejecución desde un
# gestor de secretos. Ver la sección "Consejos para producción" de la guía.
variable "mysql_root_password" {
  description = "Contraseña root de MySQL (solo para uso local del taller)"
  type        = string
  default     = "workshop_root_pw"
  sensitive   = true
}

variable "mysql_password" {
  description = "Contraseña del usuario de aplicación de MySQL (solo para uso local del taller)"
  type        = string
  default     = "workshop_app_pw"
  sensitive   = true
}
