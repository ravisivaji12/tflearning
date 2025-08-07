terraform {
  cloud {
    organization = "Mccain_Foods"
    workspaces {
      name = "mf-core-platform"
    }
  }
}