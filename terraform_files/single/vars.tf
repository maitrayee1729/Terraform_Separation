variable "launch_region" {
  default = "Mumbai"
}

variable "REGION_ID" {
  type = any
  default = {
    "Singapore" = "ap-southeast-1",
    "Mumbai"    = "ap-south-1"
  }
}

variable "AVAILABILITY_ZONE" {
  type = any
  default = {
    "Singapore" = "ap-southeast-1a",
    "Mumbai"    = "ap-south-1a"
  }
}

variable "AMI_ID" {
  type = any
  default = {
    "Singapore" = "ami-004c3ef4d58675a30",
    "Mumbai"    = "ami-0b01a9099d98e8c02"
  }
}

variable "SG_SINGAPORE" {
  type = any
  default = {
    "app_server"      = ["sg-4a31ff2f", "sg-3431ff51"],
    "database_server" = ["sg-3431ff51"],
    "task_server"     = ["sg-4a31ff2f"]
  }
}

variable "MUMBAI_SG_MAP" {
  type = any
  default = {
    Standalone = {
      "app_server"      = ["sg-0e9fb02d3c2d065ce"],
      "database_server" = ["sg-0765ba5a71fbb9395"],
      "task_server"     = ["sg-0e9fb02d3c2d065ce"]
    }
    Dedicated_Setup = {
      "app_server"      = ["sg-0901b87dd0813941a"],
      "database_server" = ["sg-0765ba5a71fbb9395"],
      "task_server"     = ["sg-0901b87dd0813941a"]
    }
  }
}


variable "SUBNETS_SINGAPORE" {
  type = any
  default = {
    #Current Default subnet for app and database: "UC-Production-Public - 1a"
    "app_server"      = "subnet-f9b47d9c",
    "database_server" = "subnet-f9b47d9c",
    #Default subnet same as app server 
    "task_server" = "subnet-f9b47d9c"
  }
}

#SUBNET
#10.0.4.0/24 - MAIN
#subnet-002f616c381fea245

#10.0.7.0/24 - AZ 1b
#subnet-098b99a4466336c1b

variable "SUBNETS_MUMBAI" {
  type = any
  default = {
    # UC_Private_3_AP_South_1A_Internet_Enabled - 10.4.8.0/23
    "app_server" = "subnet-0d704cb764b98199d",
    # UC_Private_AP_South_1A_Internet_Disabled - 10.0.6.0/24
    "database_server" = "subnet-0c006e4bb221c3498",
    # UC_Private_3_AP_South_1A_Internet_Enabled - 10.4.8.0/23
    "task_server" = "subnet-0d704cb764b98199d"
  }
}

variable "tenant_shortname" {
}

variable "setup_type" {
  default = "Standalone"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "docker_version" {
  default = "23.0.5"
}

variable "scm_hostname" {
}

variable "scm_user" {
}

variable "scm_pwd" {
  sensitive = "true"
}

variable "private_key" {
  sensitive = "true"
}

variable "workspace" {
}




