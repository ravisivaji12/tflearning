resource_groups = {
  cc-prod-rg = {
    location = "canadacentral"
    tags = {
      env   = "prod"
      owner = "cloudteam"
    }
    lock = {
      level = "CanNotDelete"
      notes = "Production lock"
    }
  }

  cc-dev-rg = {
    location = "canadaeast"
    tags = {
      env   = "dev"
      owner = "devteam"
    }
    lock = null
  }
}
