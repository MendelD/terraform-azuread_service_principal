variable "service_principals" {
  description = "A nested list of Service Principals and their configuration"
  type = list(object({                                    # List of Service Principals, one object for each SP.
    display_name       = string                           # Name of the Service Principal.
    description = optional(string)                        # Description of the service principal provided for internal end-users.
    account_enabled = optional(bool, true)                # Whether or not the service principal account is enabled. Defaults to true.
    app_role_assignment_required = optional(bool, false)  # Whether this service principal requires an app role assignment to a user or group before Azure AD will issue a user or access token to the application. Defaults to false.
    owners        = optional(list(string))                          # Owners of the Service Principal.

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
    for sp in var.service_principals : sp                 # Iterates through all Service Principals and creates a list of them.
  ])
}