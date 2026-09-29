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

module "network_security_perimeter" {
  source  = "codectl/nsp/azure"
  version = "~> 1.0"

  network_security_perimeter = {
    name                = "nsp-demo-dev"
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}
