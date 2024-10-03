output "nginx_public_ip" {
  description = "La dirección IP pública de la VM de NGINX y PostgreSQL."
  value       = azurerm_public_ip.example.ip_address
}