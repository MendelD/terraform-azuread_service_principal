<!-- BEGIN_TF_DOCS -->
# Terraform Module - AzureAD Service Principal

**By Tom Aril Virak**

---

This module allows you to simply deploy and manage Service Principals in Entra ID.

This module aims to simplify the definition of all the resources as much as possible, but all parameter values are identical to the actual azuread resource parameters. You will find that default values are applied as often as possible, this is in persuit of as simple of a deployment as possible.

All optional values are described in the input variable documentation, with it's default values.

## Resources deployed by this module

Which resources, and how many of each depends on your configuration
- Application
- Service Principal

*Complete list of all Terraform resources deployed is provided at the bottom of this page*

## Destroy resources


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.8.2 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >=2.48.0 |

## Example
```hcl
# This example contains a typical, basic deployment of an Service Principal with settings.
# Most of the parameters and inputs are left to their default values, as they are typically the correct values in a common deployment.

###   Entra ID Users
########################
locals {
  entra_users = [
    ###   Owners of Service Principals
    ########################
    "AdeleV@1abcde.onmicrosoft.com",
    "AlexW@1abcde.onmicrosoft.com"
  ]
}

data "azuread_user" "sp_owners" {
  for_each         = toset(local.entra_users)
  user_principal_name     = each.key
  }

module "sp" {
  source = "git@github.com:MendelD/terraform-azuread_service_principal"

  service_principal = [
    {
      display_name = "Salesforce"
      description = "CRM tool for all in sales department"
      owners       = [
        data.azuread_user.sp_owners["AdeleV@1abcde.onmicrosoft.com"].object_id,
        data.azuread_user.sp_owners["AlexW@1abcde.onmicrosoft.com"].object_id
        ]
      account_enabled = true
      app_role_assignment_required = false
      notes = "CRM platform, Owner Adele Vance and Alex Weber"
    }
  ]
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >=2.48.0 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="display_name"></a> [display_name](#input\_display\_name) | Name of the Service Principal | string | n/a | yes |
| <a name="description"></a> [description](#input\_description) | Description of the service principal provided for internal end-users | string | n/a | no |
| <a name="account_enabled"></a> [account_enabled](#input\_account\_enabled) | Whether or not the service principal account is enabled | bool | true | no |
| <a name="app_role_assignment_required"></a> [app_role_assignment_required](#input\_app\_role\_assignment\_required) | Whether this service principal requires an app role assignment to a user or group before Azure AD will issue a user or access token to the application | bool | false | no |
| <a name="owners"></a> [owners](#input\_owners) | Owners of the Service Principal | list(string) | n/a | no |
| <a name="preferred_single_sign_on_mode"></a> [preferred_single_sign_on_mode](#input\_preferred\_single\_sign\_on\_mode) | he single sign-on mode configured for this application. Supported values are oidc, password, saml or notSupported. | string | n/a | no |
| <a name="saml_single_sign_on"></a> [saml_single_sign_on](#input\_saml\_single\_sign\_on) | Use with SAML-based single sign-on | object | n/a | no |
| <a name="relay_state"></a> [relay_state](#input\_relay\_state) | The relative URI the service provider would redirect to after completion of the single sign-on flow | string | n/a | no |
| <a name="login_url"></a> [login_url](#input\_login\_url) | The URL where the service provider redirects the user to Entra ID to authenticate. When blank, Azure AD performs IdP-initiated sign-on for applications configured with SAML-based single sign-on. | string | n/a | no |
| <a name="notification_email_addresses"></a> [notification_email_addresses](#input\_notification\_email\_addresses) | A set of email addresses where Azure AD sends a notification when the active certificate is near the expiration date. This is only for the certificates used to sign the SAML token issued for Azure AD Gallery applications | list(string) | n/a | no |
| <a name="feature_tags"></a> [feature_tags](#input\_feature\_tags) | Features are configured for a service principal using tags, and are provided as a shortcut to set the corresponding magic tag value for each feature | object | n/a | no |
| <a name="custom_single_sign_on"></a> [custom_single_sign_on](#input\_custom\_single\_sign\_on) | Whether this service principal represents a custom SAML application | bool | false | no |
| <a name="enterprise"></a> [enterprise](#input\_enterprise) | Whether this service principal represents an Enterprise Application | bool | false | no |
| <a name="gallery"></a> [gallery](#input\_gallery) | Whether this service principal represents a gallery application | bool | false | no |
| <a name="hide"></a> [hide](#input\_hide) | Whether this app is invisible to users in My Apps and Office 365 Launcher | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application"></a> [application](#output\_application) | Outputs all Applications created through this module |
| <a name="output_service_principal"></a> [service\_principal](#output\_service\_principal) | Outputs all Service Principals created through this module |

## Resources

| Name | Type |
|------|------|
| [azuread_application](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_service_principal](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
<!-- END_TF_DOCS -->