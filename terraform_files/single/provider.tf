provider "aws" {
  region = lookup(var.REGION_ID, var.launch_region)
}

