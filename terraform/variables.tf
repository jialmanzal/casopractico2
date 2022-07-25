# Variable para definir la ubicación del grupo de recursos
variable "resource_group_location" {
  default     = "WestUS3"
  description = "Location of the resource group."
}

# Variable para definición de VMs
variable "vms" {
  type = map(any)
  default = {
    vm1 = {
      name   = "MasterKubernetes"
      size   = "Standard_D2_v2"
      indice = 1
    }
    vm2 = {
      name   = "WorkerKubernetes"
      size   = "Standard_B2s"
      indice = 2
    }
    vm3 = {
      name   = "NFS"
      size   = "Standard_B2s"
      indice = 3
    }
  }
}

### Variable para definir el nombre
variable "resource_group_name" {
  default     = "rg_laboratorio_ja"
  description = "Nombre del RG"
}