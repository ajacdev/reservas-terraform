output "nginx_public_ip" {
  description = "La dirección IP pública de la VM de NGINX."
  value       = azurerm_public_ip.example.ip_address
}

output "postgresql_fqdn" {
  description = "El nombre de dominio completo del servidor PostgreSQL."
  value       = azurerm_postgresql_server.example.fully_qualified_domain_name
}