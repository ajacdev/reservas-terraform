variable "resource_group_name" {
  description = "El nombre del grupo de recursos."
  default     = "my-resource-group"
}

variable "location" {
  description = "Ubicación del recurso en Azure."
  default     = "East US"
}

variable "nginx_vm_size" {
  description = "Tamaño de la máquina virtual para NGINX."
  default     = "Standard_B1s"  # Tamaño de VM gratuito
}

variable "admin_username" {
  description = "Nombre de usuario administrador para la VM."
  default     = "adminuser"
}

variable "admin_password" {
  description = "Contraseña para el administrador de la VM."
}
