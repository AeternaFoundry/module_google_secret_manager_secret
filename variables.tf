variable "secret_manager_secrets" {
  description = <<EOT
Map of secret_manager_secrets, attributes below
Required:
    - secret_id
    - replication (block):
        - auto (optional, block):
            - customer_managed_encryption (optional, block):
                - kms_key_name (required)
        - user_managed (optional, block):
            - replicas (required, block):
                - customer_managed_encryption (optional, block):
                    - kms_key_name (required)
                - location (required)
Optional:
    - annotations
    - deletion_policy
    - deletion_protection
    - expire_time
    - labels
    - project
    - secret_type
    - tags
    - ttl
    - version_aliases
    - version_destroy_ttl
    - rotation (block):
        - next_rotation_time (optional)
        - rotation_period (optional)
    - timeouts (block):
        - create (optional)
        - delete (optional)
        - update (optional)
    - topics (block):
        - name (required)
EOT

  type = map(object({
    secret_id           = string
    annotations         = optional(map(string))
    deletion_policy     = optional(string)
    deletion_protection = optional(bool)
    expire_time         = optional(string)
    labels              = optional(map(string))
    project             = optional(string)
    secret_type         = optional(string)
    tags                = optional(map(string))
    ttl                 = optional(string)
    version_aliases     = optional(map(string))
    version_destroy_ttl = optional(string)
    replication = object({
      auto = optional(object({
        customer_managed_encryption = optional(object({
          kms_key_name = string
        }))
      }))
      user_managed = optional(object({
        replicas = list(object({
          customer_managed_encryption = optional(object({
            kms_key_name = string
          }))
          location = string
        }))
      }))
    })
    rotation = optional(object({
      next_rotation_time = optional(string)
      rotation_period    = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
    topics = optional(list(object({
      name = string
    })))
  }))
  validation {
    condition = alltrue([
      for k, v in var.secret_manager_secrets : (
        v.replication.user_managed == null || (length(v.replication.user_managed.replicas) >= 1)
      )
    ])
    error_message = "Each replicas list must contain at least 1 items"
  }
}

