data "azuread_client_config" "client_config" {} # Data source to access the configuration of the AzureAD provider and adds it as owner of Service Principal

resource "azuread_application" "application" {
  for_each = { for sp in local.service-principals : sp.display_name => sp }
  display_name = each.key
  description = each.value.description
  owners       = concat(each.value.owners != null ? each.value.owners : [], [data.azuread_client_config.client_config.object_id])
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