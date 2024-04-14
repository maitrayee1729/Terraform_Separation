# Data source to get hosted zone information
data "aws_route53_zone" "unicommerce_private_hosted_zones" {
  name         = "unicommerce.infra"
  private_zone = "true"
}

#Global Variables
locals {
  ssh_key        = var.launch_region == "Singapore" ? "devops" : "Devops_Mumbai"
  app_diskname   = element(split(".", var.instance_type), 0) == "t2" ? "/dev/xvdf" : "/dev/nvme1n1"
  mysql_diskname = element(split(".", var.instance_type), 0) == "t2" ? "/dev/xvdg" : "/dev/nvme2n1"
  vol_type       = "gp3"
  vol_size       = "5" #Applicable for ebs devices
  throughput     = "125"
  iops           = "3000"
  app1_hostname  = var.launch_region == "Singapore" ? "app1.${lower(var.tenant_shortname)}.unicommerce.infra" : "app1.${lower(var.tenant_shortname)}-in.unicommerce.infra"
  task_hostname  = var.launch_region == "Singapore" ? "app2.${lower(var.tenant_shortname)}.unicommerce.infra" : "app2.${lower(var.tenant_shortname)}-in.unicommerce.infra"
  app3_hostname  = var.launch_region == "Singapore" ? "app3.${lower(var.tenant_shortname)}.unicommerce.infra" : "app3.${lower(var.tenant_shortname)}-in.unicommerce.infra"
  db_hostname    = var.launch_region == "Singapore" ? "db.${lower(var.tenant_shortname)}.unicommerce.infra" : "db.${lower(var.tenant_shortname)}-in.unicommerce.infra"
  #db_server_id         = var.setup_type == "Standalone" ? aws_instance.Uniware_App1_Instance.id : aws_instance.Uniware_DB_Instance[0].id
  #db_server_private_ip = var.setup_type == "Standalone" ? aws_instance.Uniware_App1_Instance.private_ip : aws_instance.Uniware_DB_Instance[0].private_ip
  subnet_app          = var.launch_region == "Singapore" ? var.SUBNETS_SINGAPORE["app_server"] : var.SUBNETS_MUMBAI["app_server"]
  subnet_task         = var.launch_region == "Singapore" ? var.SUBNETS_SINGAPORE["task_server"] : var.SUBNETS_MUMBAI["task_server"]
  subnet_db           = var.launch_region == "Singapore" ? var.SUBNETS_SINGAPORE["database_server"] : var.SUBNETS_MUMBAI["database_server"]
  security_group_app  = var.launch_region == "Singapore" ? var.SG_SINGAPORE["app_server"] : var.MUMBAI_SG_MAP[var.setup_type]["app_server"]
  security_group_task = var.launch_region == "Singapore" ? var.SG_SINGAPORE["task_server"] : var.MUMBAI_SG_MAP[var.setup_type]["task_server"]
  security_group_db   = var.launch_region == "Singapore" ? var.SG_SINGAPORE["database_server"] : var.MUMBAI_SG_MAP[var.setup_type]["database_server"]
}

resource "aws_instance" "Uniware_Task_Instance" {

  count                       = var.setup_type == "Enterprise" ? 0 : 1
  ami                         = lookup(var.AMI_ID, var.launch_region)
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_task
  vpc_security_group_ids      = local.security_group_task
  key_name                    = local.ssh_key
  associate_public_ip_address = "true"
  iam_instance_profile        = "UniwareS3"

  tags = {
    Name        = local.task_hostname
    ENVIRONMENT = "Production"
    SYSTEM      = "Uniware"
    CLOUD       = "TRUE"
  }

  root_block_device {
    volume_type           = local.vol_type
    throughput            = local.throughput
    iops                  = local.iops
    delete_on_termination = "false"

    tags = {
      Name = local.task_hostname
    }
  }

  #Disk for app directory
  ebs_block_device {
    device_name           = local.app_diskname
    volume_size           = local.vol_size
    volume_type           = local.vol_type
    throughput            = local.throughput
    iops                  = local.iops
    delete_on_termination = "false"

    tags = {
      Name = local.task_hostname
    }
  }

  #Default connection settings
  connection {
    host        = self.private_ip
    type        = "ssh"
    user        = "build"
    private_key = file(var.private_key)
    timeout     = "120s"
  }

  #Move docker installation file to remote
  provisioner "file" {
    source      = join("/", [var.workspace, "remote_exec_files/docker_setup.sh"])
    destination = "/home/build/docker_setup.sh"
  }

  #Setup docker service
  provisioner "remote-exec" {
    inline = [
      "sh -x /home/build/docker_setup.sh ${var.docker_version} ${var.scm_hostname} ${var.scm_user} ${var.scm_pwd} > /tmp/docker_setup.log",
    ]
  }

}


#Route53 entry for task instance
resource "aws_route53_record" "Task_Instance_dns_entry" {
  count   = var.setup_type == "Standalone" ? 0 : 1
  zone_id = data.aws_route53_zone.unicommerce_private_hosted_zones.zone_id
  name    = local.task_hostname
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Uniware_Task_Instance[0].private_ip]
}

resource "null_resource" "run_ansible_playbook_uniware" {
  depends_on = [aws_route53_record.Task_Instance_dns_entry]
  provisioner "local-exec" {
    command = "ansible-playbook -i hosts -v ${var.workspace}/setup_scripts/Uniware_Setup.yml --extra-vars @vars.json"
  }
}

