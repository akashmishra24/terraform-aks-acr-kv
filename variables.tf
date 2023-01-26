variable "enable_oms_agent" {
  type    = bool
  default = false
}

variable "private_zone_id" {}

variable "tenant_id" {
  default = "72f988bf-86f1-41af-91ab-2d7cd011db47"
}

variable "admin_group_object_ids" {
  default = null
}

variable "virtual_network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "aks_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "sku_tier" {
  type    = string
  default = "Free"
}

variable "private_cluster_enabled" {
  type    = bool
  default = true
}

# variable "default_node_pool" {
#   type = map(any)
# }

variable "default_node_pool_vm_size" {
  description = "Specifies the vm size of the default node pool"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "default_node_pool_os_disk_size_gb" {
  type    = number
  default = 30
}

variable "default_node_pool_node_count" {
  type    = number
  default = 1
}

variable "default_node_pool_availability_zones" {
  description = "Specifies the availability zones of the default node pool" # ["1", "2", "3", "None"]
  default     = ["None"]
  type        = list(string)
}

variable "default_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type        = bool
  default     = true
}

variable "default_node_pool_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "default_node_pool_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "default_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 50
}

variable "default_node_pool_node_labels" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = map(any)
  default     = {}
}

variable "default_node_pool_node_taints" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type        = list(string)
  default     = []
}

variable "default_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type        = string
  default     = "Ephemeral"
}

variable "default_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type        = number
  default     = 3
}

variable "default_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type        = number
  default     = 1
}

variable "linux_profile" {
  type    = map(any)
  default = {}
}

variable "service_principal" {
  type    = object({ client_id = string, client_secret = string })
  default = { client_id = "", client_secret = "" }
}

# variable "network_profile" {
#   type    = map(any)
#   default = {}
# }

variable "network_plugin" {
  type    = string
  default = "azure"
}

variable "network_policy" {
  type    = string
  default = "azure"
}

variable "dns_service_ip" {

}

variable "docker_bridge_cidr" {

}

variable "outbound_type" {
  default = null
}

variable "pod_cidr" {
  default = null
}

variable "service_cidr" {
  default = null
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "ingress_application_gateway" {
  type    = map(any)
  default = {}
}

variable "auto_scaler_profile" {
  type    = map(any)
  default = {}
}

variable "api_server_access_profile" {
  type    = map(any)
  default = {}
}

variable "aks_http_proxy_settings" {
  type    = map(any)
  default = {}
}

variable "user_assigned_mi" {
  type    = set(string)
  default = null
}

variable "linux_admin_username" {
  type    = string
  default = "aksadmin"
}

variable "linux_ssh_key" {
  default = "C:/Users/2000087814/tf-module-vm-test/ssh-public-key.pub"
}

variable "key_vault_secrets_provider" {
  type    = map(any)
  default = {}
}

# variable "oms_agent" {
#   type    = map(any)
#   default = {}
# }

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "log_workspace_id" {
  default = null
}

variable "key_vault_name" {
  type = string
}

variable "key_vault_rg_name" {
  type = string
}

variable "acr_rg_name" {
  type = string
}

variable "acr_name" {
  type = string
}
