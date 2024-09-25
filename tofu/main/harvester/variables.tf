# Frequently changed variables
variable "namespace" {
  description = "The namespace where the VM should be created"
  default     = "default"
}

variable "kubeconfig" {
  description = "Path to the Harvester kubeconfig file. Uses KUBECONFIG by default. See https://docs.harvesterhci.io/v1.3/faq/#how-can-i-access-the-kubeconfig-file-of-the-harvester-cluster"
  type        = string
  default     = null
}

# Upstream cluster specifics
variable "upstream_cluster" {
  type = object({
    name_prefix    = string // Prefix to append to objects created for this cluster
    server_count   = number // Number of server nodes in the upstream cluster
    agent_count    = number // Number of agent nodes in the upstream cluster
    distro_version = string // Version of the Kubernetes distro in the upstream cluster

    # public_ip = bool // Whether the upstream cluster should have a public IP assigned
    reserve_node_for_monitoring = bool // Set a 'monitoring' label and taint on one node of the upstream cluster to reserve it for monitoring

    // harvester-specific
    cpu             = number      // Number of CPUs to allocate for the VM(s)
    memory          = number      // Number of GB of Memory to allocate for the VM(s)
    tags            = map(string) // Harvester tags to apply to the VM
    image_name      = string      // AMI for downstream cluster nodes
    image_namespace = string      // Namespace to search for OR upload image, if it does not exist
  })
  default = {
    name_prefix    = "upstream"
    server_count   = 1
    agent_count    = 0
    distro_version = "v1.26.9+k3s1"
    # public_ip = true
    reserve_node_for_monitoring = false

    // harvester-specific
    cpu    = 2
    memory = 16
    tags = {
      "Owner" : "st",
      "DoNotDelete" : "true"
    }
    image_name      = "opensuse-leap-15.5-minimal" // https://download.opensuse.org/distribution/leap/15.5/appliances/openSUSE-Leap-15.5-Minimal-VM.x86_64-Cloud.qcow2
    image_namespace = "default"
  }
}

# Downstream cluster specifics
variable "downstream_cluster_templates" {
  type = list(object({
    cluster_count  = number // Number of downstream clusters that should be created using this configuration
    name_prefix    = string // Prefix to append to objects created for this cluster
    server_count   = number // Number of server nodes in the downstream cluster
    agent_count    = number // Number of agent nodes in the downstream cluster
    distro_version = string // Version of the Kubernetes distro in the downstream cluster

    # public_ip = bool // Whether the downstream cluster should have a public IP assigned
    reserve_node_for_monitoring = bool // Set a 'monitoring' label and taint on one node of the downstream cluster to reserve it for monitoring

    // harvester-specific
    cpu             = number      // Number of CPUs to allocate for the VM(s)
    memory          = number      // Number of GB of Memory to allocate for the VM(s)
    tags            = map(string) // Harvester tags to apply to the VM
    image_name      = string      // AMI for downstream cluster nodes
    image_namespace = string      // Namespace to search for OR upload image, if it does not exist
  }))
  default = [{
    cluster_count  = 0 // defaults to 0 to keep in-line with previous behavior
    name_prefix    = "downstream"
    server_count   = 1
    agent_count    = 0
    distro_version = "v1.26.9+k3s1"
    # public_ip = false
    reserve_node_for_monitoring = false

    // harvester-specific
    cpu    = 2
    memory = 8
    tags = {
      "Owner" : "st",
      "DoNotDelete" : "true"
    }
    image_name      = "opensuse-leap-15.5-minimal" // https://download.opensuse.org/distribution/leap/15.5/appliances/openSUSE-Leap-15.5-Minimal-VM.x86_64-Cloud.qcow2
    image_namespace = "default"
  }]
}

# Tester cluster specifics
variable "tester_cluster" {
  type = object({
    name_prefix    = string // Prefix to append to objects created for this cluster
    server_count   = number // Number of server nodes in the downstream cluster
    agent_count    = number // Number of agent nodes in the downstream cluster
    distro_version = string // Version of the Kubernetes distro in the downstream cluster

    # public_ip = bool // Whether the downstream cluster should have a public IP assigned
    reserve_node_for_monitoring = bool // Set a 'monitoring' label and taint on one node of the downstream cluster to reserve it for monitoring

    // harvester-specific
    cpu             = number      // Number of CPUs to allocate for the VM(s)
    memory          = number      // Number of GB of Memory to allocate for the VM(s)
    tags            = map(string) // Harvester tags to apply to the VM
    image_name      = string      // AMI for downstream cluster nodes
    image_namespace = string      // Namespace to search for OR upload image, if it does not exist
  })
  default = {
    name_prefix    = "tester"
    server_count   = 1
    agent_count    = 0
    distro_version = "v1.26.9+k3s1"
    # public_ip = true
    reserve_node_for_monitoring = false

    // harvester-specific
    cpu    = 2
    memory = 8
    tags = {
      "Owner" : "st",
      "DoNotDelete" : "true"
    }
    image_name      = "opensuse-leap-15.5-minimal" // https://download.opensuse.org/distribution/leap/15.5/appliances/openSUSE-Leap-15.5-Minimal-VM.x86_64-Cloud.qcow2
    image_namespace = "default"
  }
}

variable "deploy_tester_cluster" {
  description = "Use false not to deploy a tester cluster"
  default     = true
}

# "Multi-tenancy" variables
variable "project_name" {
  description = "Name of this project, used as prefix for resources it creates"
  default     = "st"
}

variable "first_kubernetes_api_port" {
  description = "Port number where the Kubernetes API of the first cluster is published locally. Other clusters' ports are published in successive ports"
  default     = 7445
}

variable "first_app_http_port" {
  description = "Port number where the first server's port 80 is published locally. Other clusters' ports are published in successive ports"
  default     = 9080
}

variable "first_app_https_port" {
  description = "Port number where the first server's port 443 is published locally. Other clusters' ports are published in successive ports"
  default     = 9443
}

variable "networks" {
  description = <<-EOT
  List of objects combining fields that define pre-existing VM Networks as well as the VM's network_interface type and model.
  Each object includes a name, a "public" flag if the network will assign a public IP address, a "wait_for_lease" flag if the interface is expected to provision an IP address,
  and optionally a namespace, interface_type and interface_model to be assigned to the VM.
  If using a VM Network which will assign a public IP to the VM, ensure the "public" flag is set to true.
  EOT
  type = list(object({
    name            = string
    namespace       = optional(string)
    interface_type  = optional(string)
    interface_model = optional(string)
    public          = bool
    wait_for_lease  = bool
  }))
  default = []
}

variable "user" {
  description = "User name to use for VM access"
  type        = string
  default     = "opensuse"
}

variable "password" {
  description = "Password to use for VM access"
  type        = string
}

variable "ssh_keys" {
  description = "List of SSH key names and namespaces to be pulled from Harvester"
  type = list(object({
    name      = string
    namespace = string
  }))
  default = []
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file (can be generated with `ssh-keygen -t ed25519`)"
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key file (can be generated with `ssh-keygen -t ed25519`)"
  default     = "~/.ssh/id_ed25519"
}

variable "ssh_bastion_host" {
  description = "Public name of the SSH bastion host. Leave null for publicly accessible instances"
  type        = string
  default     = null
}

variable "ssh_bastion_key_path" {
  description = "Path of private ssh key used to access the bastion host"
  type        = string
  default     = null
}

variable "ssh_shared_public_key" {
  description = "The name and namespace of a shared public ssh key (which already exists in Harvester) to load onto the Harvester VMs"
  type = object({
    name      = string
    namespace = string
  })
  default = null
}

variable "bastion_host_image_name" {
  description = "Unique name of a harvester image which will be used if it exists"
  default     = "opensuse-leap-15.5-minimal"
  // https://download.opensuse.org/distribution/leap/15.5/appliances/openSUSE-Leap-15.5-Minimal-VM.x86_64-Cloud.qcow2
}

variable "ssh_bastion_user" {
  description = "User name for the SSH bastion host's OS"
  default     = "root"
}

variable "ssh_tunnels" {
  description = "Opens SSH tunnels to this host via the bastion"
  type        = list(list(number))
  default     = []
}

variable "disks" {
  description = "List of objects representing the disks to be provisioned for the VM. NOTE: boot_order will be set to the index of each disk in the list."
  type = list(object({
    name = string
    type = string
    size = number
    bus  = string
  }))
  default = []
}

variable "efi" {
  description = "Flag that determines if the VM will boot in EFI mode"
  type        = bool
  default     = false
}

variable "secure_boot" {
  description = "Flag that determines if the VM will be provisioned with secure_boot enabled. EFI must be enabled to use this"
  type        = bool
  default     = false
}

variable "cloudinit_secrets" {
  description = <<-EOT
  A map which includes the name, namespace and optionally, the userdata content of a cloudinit configuration to be passed to the VM.
  If user_data is provided, a new cloudinit configuration will be created.
  If user_data is NOT provided, we use a datasource to pull the cloudinit_secret from Harvester.
  EOT
  type = list(object({
    name      = string
    namespace = string
    user_data = optional(string, "") //Path to a file to be used for the cloudinit_secret' user_data
  }))
  default = []
}

variable "host_configuration_commands" {
  description = "Commands to run when the host is deployed"
  default     = ["cat /etc/os-release"]
}
