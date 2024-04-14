# Data source to get hosted zone information
data "aws_route53_zone" "unicommerce_private_hosted_zones" {
  name         = "unicommerce.infra"
  private_zone = "true"
}

#Global Variables
locals {
  ssh_key              = var.launch_region == "Singapore" ? "devops" : "Devops_Mumbai"
  app_diskname         = element(split(".", var.instance_type), 0) == "t2" ? "/dev/xvdf" : "/dev/nvme1n1"
  mysql_diskname       = element(split(".", var.instance_type), 0) == "t2" ? "/dev/xvdg" : "/dev/nvme2n1"
  vol_type             = "gp3"
  vol_size             = "5" #Applicable for ebs devices
  throughput           = "125"
  iops                 = "3000"
  app1_hostname        = var.launch_region == "Singapore" ? "app1.${lower(var.tenant_shortname)}.unicommerce.infra" : "app1.${lower(var.tenant_shortname)}-in.unicommerce.infra"
  task_hostname        = var.launch_region == "Singapore" ? "app2.${lower(var.tenant_shortname)}.unicommerce.infra" : "app2.${lower(var.tenant_shortname)}-in.unicommerce.infra"
  app3_hostname        = var.launch_region == "Singapore" ? "app3.${lower(var.tenant_shortname)}.unicommerce.infra" : "app3.${lower(var.tenant_shortname)}-in.unicommerce.infra"
  db_hostname          = var.launch_region == "Singapore" ? "db.${lower(var.tenant_shortname)}.unicommerce.infra" : "db.${lower(var.tenant_shortname)}-in.unicommerce.infra"
  db_server_id         = aws_instance.Uniware_DB_Instance[0].id
  db_server_private_ip = aws_instance.Uniware_DB_Instance[0].private_ip
  subnet_app           = var.launch_region == "Singapore" ? var.SUBNETS_SINGAPORE["app_server"] : var.SUBNETS_MUMBAI["app_server"]
  subnet_task          = var.launch_region == "Singapore" ? var.SUBNETS_SINGAPORE["task_server"] : var.SUBNETS_MUMBAI["task_server"]
  subnet_db            = var.launch_region == "Singapore" ? var.SUBNETS_SINGAPORE["database_server"] : var.SUBNETS_MUMBAI["database_server"]
  security_group_app   = var.launch_region == "Singapore" ? var.SG_SINGAPORE["app_server"] : var.MUMBAI_SG_MAP[var.setup_type]["app_server"]
  security_group_task  = var.launch_region == "Singapore" ? var.SG_SINGAPORE["task_server"] : var.MUMBAI_SG_MAP[var.setup_type]["task_server"]
  security_group_db    = var.launch_region == "Singapore" ? var.SG_SINGAPORE["database_server"] : var.MUMBAI_SG_MAP[var.setup_type]["database_server"]
}



#Database Instance Creation
resource "aws_instance" "Uniware_DB_Instance" {
  count                       = var.setup_type == "Standalone" ? 0 : 1
  ami                         = lookup(var.AMI_ID, var.launch_region)
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_db
  vpc_security_group_ids      = local.security_group_db
  key_name                    = local.ssh_key
  associate_public_ip_address = "false"

  tags = {
    Name        = local.db_hostname
    ENVIRONMENT = "Production"
    SYSTEM      = "Uniware"
    MYSQL       = "TRUE"
  }

  root_block_device {
    volume_type           = local.vol_type
    throughput            = local.throughput
    iops                  = local.iops
    delete_on_termination = "false"

    tags = {
      Name = local.db_hostname
    }
  }

  connection {
    host        = self.private_ip
    type        = "ssh"
    user        = "build"
    private_key = file(var.private_key)
    timeout     = "120s"
  }


  
}


#Route53 entry for DB instance
resource "aws_route53_record" "Database_dns_entry" {
  zone_id = data.aws_route53_zone.unicommerce_private_hosted_zones.zone_id
  name    = local.db_hostname
  type    = "A"
  ttl     = "300"
  records = [local.db_server_private_ip]
}


resource "null_resource" "wait_for_ssh" {
  depends_on = [aws_instance.Uniware_DB_Instance]

  # Use remote-exec provisioner to check SSH reachability
  provisioner "remote-exec" {
    inline = [
      "echo 'SSH is ready'",
    ]

    # Specify connection information
    connection {
      type        = "ssh"
      user        = "build"
      private_key = file(var.private_key)
      host        = aws_instance.Uniware_DB_Instance[0].private_ip
    }
  }
}

resource "null_resource" "ansible_setup" {
  depends_on = [null_resource.wait_for_ssh]

  provisioner "local-exec" {
    command = "ansible-playbook -i hosts -v ${var.workspace}/setup_scripts/Mysql_Setup.yml --extra-vars @vars.json"
  }
}

#resource "null_resource" "wait_before_creation" {
#  depends_on = [aws_route53_record.Database_dns_entry]
#  provisioner "local-exec" {
#    command = "sleep 120"
#  }
#}

#resource "null_resource" "ansible_setup" {
#  depends_on = [null_resource.wait_before_creation]
#  provisioner "local-exec" {
#    command = "ansible-playbook -i hosts -v ${var.workspace}/setup_scripts/Mysql_Setup.yml --extra-vars @vars.json"
#  }
#}
