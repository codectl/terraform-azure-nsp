module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "westeurope"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "storage" {
  source  = "codectl/sa/azure"
  version = "~> 1.0"

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "network_security_perimeter" {
  source  = "codectl/nsp/azure"
  version = "~> 1.0"

  network_security_perimeter = {
    name                = "nsp-demo-dev"
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    profiles = {
      default-profile = {
        access_rules = {
          allow-inbound-cidrs = {
            direction        = "Inbound"
            address_prefixes = ["203.0.113.0/24"]
          }
          allow-outbound-fqdns = {
            direction = "Outbound"
            fqdns     = ["example.com"]
          }
        }
        associations = {
          storage-assoc = {
            access_mode = "Learning"
            resource_id = module.storage.account.id
          }
        }
      }
    }
  }
}
