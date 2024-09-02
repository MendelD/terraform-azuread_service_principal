output "application" {
  description = "Outputs all Applications created through this module"
  value = azuread_application.application[*]
  }

output "secret" {
  description = "Outputs all Applications secrets created through this module"
  value = azuread_application_password.secret[*]
  }

output "service_principal" {
  description = "Outputs all Service Principals created through this module"
  value = azuread_service_principal.service_principal[*]
  }