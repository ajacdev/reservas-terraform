variable "resource_group_name" {
  description = "El nombre del grupo de recursos."
  default     = "my-resource-group"
}

variable "location" {
  description = "Ubicación del recurso en Azure."
  default     = "East US"
}

variable "postgresql_admin_username" {
  description = "Nombre de usuario administrador para PostgreSQL."
  default     = "pgadmin"
}

variable "postgresql_admin_password" {
  description = "Contraseña de administrador para PostgreSQL."
}

variable "nginx_vm_size" {
  description = "Tamaño de la máquina virtual para NGINX."
  default     = "Standard_B1ms"
}