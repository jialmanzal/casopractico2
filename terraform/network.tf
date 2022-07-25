# Creación de red virtual
resource "azurerm_virtual_network" "myNet" {
  name                = "kubernetesnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "CP2"
  }
}


# Creación de subnet
resource "azurerm_subnet" "mySubnet" {
  name                 = "terraformsubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myNet.name
  address_prefixes     = ["10.0.1.0/24"]

}

# IP pública
resource "azurerm_public_ip" "myPublicIp1" {
  ### Se adiciona para generar las 3 necesarias para las vm (modificacion 2)
  for_each = var.vms
  name     = each.value.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  tags = {
    environment = "CP2"
  }

}

# Create NIC
resource "azurerm_network_interface" "myNic1" {
  for_each            = var.vms
  name                = each.value.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myipconfiguration1"
    subnet_id                     = azurerm_subnet.mySubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.${each.value.indice + 10}"
    public_ip_address_id = azurerm_public_ip.myPublicIp1[each.key].id
  }

  tags = {
    environment = "CP2"
  }

}

# Se adicionan las reglas para permitir acceso ssh
resource "azurerm_network_security_group" "mySecGroup" {
  name                = "sshtraffic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "CP2"
  }
}

# Vinculamos el security group al interface de red
resource "azurerm_network_interface_security_group_association" "mySecGroupAssociation1" {
  for_each = var.vms
  network_interface_id      = azurerm_network_interface.myNic1[each.key].id
  network_security_group_id = azurerm_network_security_group.mySecGroup.id

}




