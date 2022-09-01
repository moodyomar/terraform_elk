# Providers
provider "aws" {
  region = var.region
  secret_key = var.secret_key 
  access_key = var.access_key
}

resource "aws_instance" "master" {

ami = var.ami
instance_type = var.master_instance_type
key_name = var.key_name
vpc_security_group_ids = [var.security_group]

provisioner "remote-exec" {
    inline = [
      #!/bin/bash
      "sudo apt update -y && sudo apt install docker.io docker-compose -y",
      "wget https://gist.github.com/moodyomar/b95f9cc09d90581f19caa9295b874b53/raw/607573858498829b7489a53d594b91391047717e/.bash_aliases && source ~/.bash_aliases && source ~/.bashrc",
      "alias docker='sudo docker'",
      "sudo chown $USER /var/run/docker.sock",
      "git clone https://github.com/deviantony/docker-elk.git",
      "cd docker-elk && docker-compose up -d",
      "docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user elastic -i ${var.elastic_password}",
      "docker ps",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key)
      host        = self.public_ip
    }
  }

   provisioner "local-exec" {
    command = "sleep 3 && open http://${self.public_ip}:5601 || xdg-open http://${self.public_ip}:5601"
  } 

  tags = {
    Name = "terra_ELK_master"
  }
}

resource "aws_instance" "agent" {
ami = var.ami
instance_type = var.agent_instance_type
key_name = var.key_name
vpc_security_group_ids = [var.security_group]

provisioner "remote-exec" {
    inline = [
      #!/bin/bash
      "sudo apt update -y",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key)
      host        = self.public_ip
    }
  }
  tags = {
    Name = "terra_ELK_agent"
  }
}
