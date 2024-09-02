
variable "service_principal" {
  description = "A nested list of Service Principals and their configuration"
  type = list(object({                                    # List of Service Principals, one object for each SP.
    display_name       = string                           # Name of the Service Principal.
    description = optional(string)                        # Description of the service principal provided for internal end-users.
    account_enabled = optional(bool, true)                # Whether or not the service principal account is enabled. Defaults to true.
    app_role_assignment_required = optional(bool, false)  # Whether this service principal requires an app role assignment to a user or group before Azure AD will issue a user or access token to the application. Defaults to false.
    owners        = optional(list(string))                          # Owners of the Service Principal.
    sign_in_audience = optional(string, "AzureADMyOrg")   # The Microsoft account types that are supported for the current application. Must be one of "AzureADMyOrg", "AzureADMultipleOrgs", "AzureADandPersonalMicrosoftAccount" or "PersonalMicrosoftAccount". Defaults to "AzureADMyOrg".
    fallback_public_client_enabled = optional(bool, false) # Specifies whether the application is a public client. Appropriate for apps using token grant flows that don't use a redirect URI. Defaults to false.

    required_resource_access = optional(object({
      resource_app_id = optional (string, "00000003-0000-0000-c000-000000000000") # "00000003-0000-0000-c000-000000000000" which is Microsoft Graph
      resource_access = list(object({
        id   = string                                     # The unique identifier for an app role or OAuth2 permission scope published by the resource application.
        type = string                                     # Specifies whether the id property references an app role or an OAuth2 permission scope. Possible values are "Role" or "Scope".
        }))
  }))

    client_secret  = optional(list(object({               # Block to create multiple client secrets
      display_name = string                               # Display name of the client secret
      end_date = optional(number, 4380)                   # Number of hours for client secret to last, default is 4380 hours or 6 months. 8760 is 1 year. Maximum 17520 hours or 2 years.
      store_in_keyvault = optional (bool, false)
      key_vault_id = optional (string) 
        keyvault = optional(object({                      # Block to store the client secret in key vault, secret name = client_secret display_name
          key_vault_id = string                           # key vault id to store the secret in
        }))
    })))

    client_id  = optional(object({                        # Block to store client id in keyvault as a secret.
      name = string                                       # Secret name
      key_vault_id = string                               # Key vault ID to store the secret in
    }))

    preferred_single_sign_on_mode = optional(string)      # The single sign-on mode configured for this application. Supported values are oidc, password, saml or notSupported.
    
    saml_single_sign_on  = optional(object({              # Use with SAML-based single sign-on.
      relay_state = optional(string)                      # The relative URI the service provider would redirect to after completion of the single sign-on flow.
    }))
    
    login_url = optional(string)                          # The URL where the service provider redirects the user to Entra ID to authenticate. When blank, Azure AD performs IdP-initiated sign-on for applications configured with SAML-based single sign-on.
    notes = optional(string)                              # A free text field to capture information about the service principal, typically used for operational purposes.
    notification_email_addresses = optional(list(string)) # A set of email addresses where Azure AD sends a notification when the active certificate is near the expiration date. This is only for the certificates used to sign the SAML token issued for Azure AD Gallery applications.

    feature_tags = optional(object({                      # Features are configured for a service principal using tags, and are provided as a shortcut to set the corresponding magic tag value for each feature.
      custom_single_sign_on = optional(bool, false)       # Whether this service principal represents a custom SAML application. Defaults to false.
      enterprise = optional(bool, false)                  # Whether this service principal represents an Enterprise Application. Defaults to false.
      gallery = optional(bool, false)                     # Whether this service principal represents a gallery application. Defaults to false.
      hide = optional(bool, false)                        # Whether this app is invisible to users in My Apps and Office 365 Launcher. Defaults to false.
    }))
  }))
}

locals {
  service-principals = flatten([                          # Flattens the nested lists to a list with a depth of 1.
    for sp in var.service_principal : sp                  # Iterates through all Service Principals and creates a list of them.
  ])

  client_secret = flatten([                               # Flattens the nested lists to a list with a depth of 1.
    for sp in var.service_principal : [                   # Iterates through all service principals
      for secret in (sp.client_secret != null ? sp.client_secret : []) : [
        merge(secret, {                                   # Iterates through all client secrets within each service principal
          application = sp.display_name                   #  Creates a reference key to each service principal display name
          display_name = secret.display_name              #  Creates a reference key to each secret display name
          end_date = secret.end_date                      #  Creates a reference key to each secret end date
        })
      ]
    ]
  ])

  keyvault = flatten([                                    # Flattens the nested lists to a list with a depth of 1.
    for sp in var.service_principal : [                   # Iterates through all service principals
      for secret in (sp.client_secret != null ? sp.client_secret : []) :  [                 # Iterates through all client secrets within each service principal
        for kv in (secret.keyvault != null ? [secret.keyvault] : []) : [
          merge(kv, {                                     # Iterates through all keyvaults within each client secrets within each service principal
            name = secret.display_name                    #  Creates a reference key to each secret display name
            application = sp.display_name                 #  Creates a reference key to each service principal display name
            key_vault_id = kv.key_vault_id                #  Creates a reference key to each key vault id
          })
        ]
      ]
    ]
  ])
}