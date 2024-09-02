data "azuread_client_config" "client_config" {} # Data source to access the configuration of the AzureAD provider and adds it as owner of Service Principal

resource "azuread_application" "application" {
  for_each = { for sp in local.service-principals : sp.display_name => sp }
  display_name = each.key
  description = each.value.description
  owners       = concat(each.value.owners != null ? each.value.owners : [], [data.azuread_client_config.client_config.object_id])
  sign_in_audience = each.value.sign_in_audience
  fallback_public_client_enabled = each.value.fallback_public_client_enabled 

  dynamic "required_resource_access" {
    for_each = each.value.required_resource_access != null ? [each.value.required_resource_access] : []
    content {
      resource_app_id = required_resource_access.value.resource_app_id

      dynamic "resource_access" {
        for_each = required_resource_access.value.resource_access != null ? required_resource_access.value.resource_access : []
        content {
          id   = resource_access.value.id
          type = resource_access.value.type
        }
      }
    }
  }
}

resource "azuread_service_principal" "service_principal" {
  for_each = { for sp in local.service-principals : sp.display_name => sp }
  client_id                    = azuread_application.application[each.key].application_id
  description = each.value.description
  account_enabled = each.value.account_enabled
  app_role_assignment_required = each.value.app_role_assignment_required
  owners                       = concat(each.value.owners != null ? each.value.owners : [], [data.azuread_client_config.client_config.object_id])

  preferred_single_sign_on_mode = each.value.preferred_single_sign_on_mode

  dynamic "saml_single_sign_on" {
    for_each = toset(each.value.saml_single_sign_on != null ? [1] : [])
    content {
      relay_state = each.value.saml_single_sign_on.relay_state
    }
  }

  login_url = each.value.login_url
  notes = each.value.notes
  notification_email_addresses = each.value.notification_email_addresses != null ? each.value.notification_email_addresses : []

  dynamic "feature_tags" {
    for_each = toset(each.value.feature_tags != null ? [1] : [])
    content {
      custom_single_sign_on = each.value.feature_tags.custom_single_sign_on
      enterprise = each.value.feature_tags.enterprise
      gallery = each.value.feature_tags.gallery
      hide = each.value.feature_tags.hide
    }
  }
}

resource "azuread_application_password" "secret" {
  for_each = { for secret in local.client_secret : "${secret.application}:${secret.display_name}" => secret}

  application_id = "/applications/${azuread_application.application[each.value.application].object_id}"
  display_name = each.value.display_name

  # Calculate the end date based on the end_date in hours
  end_date = timeadd(timestamp(), "${each.value.end_date}h")

  lifecycle {
    ignore_changes = [
      end_date,
    ]
  }
}

resource "azurerm_key_vault_secret" "secret" {
  for_each = { for keyvault in local.keyvault : "${keyvault.application}:${keyvault.name}" => keyvault}
  name         = azuread_application_password.secret[each.key].display_name
  value        = azuread_application_password.secret[each.key].value
  expiration_date = azuread_application_password.secret[each.key].end_date
  key_vault_id = each.value.key_vault_id
}

resource "azurerm_key_vault_secret" "clientid" {
  for_each = { for sp in local.service-principals : sp.display_name => sp if sp.client_id != null }  # Only include service principals where client_id is present
  name         = each.value.client_id.name
  value        = azuread_application.application[each.key].application_id
  key_vault_id = each.value.client_id.key_vault_id
}