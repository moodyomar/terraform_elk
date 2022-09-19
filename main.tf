# Providers
provider "aws" {
  region = var.region
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
      "sudo chown $USER /var/run/docker.sock",
      "git clone https://github.com/moodyomar/docker-elk.git",
      "cd docker-elk",
      "echo ELASTIC_VERSION=8.4.1 > .env",
      "echo ELASTIC_PASSWORD=${var.ELK_PASSWORD} >> .env ",
      "echo LOGSTASH_INTERNAL_PASSWORD=${var.ELK_PASSWORD} >> .env ",
      "echo KIBANA_SYSTEM_PASSWORD=${var.ELK_PASSWORD} >> .env ",
      "sudo docker-compose up -d",
      "sudo docker ps",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key)
      host        = self.public_ip
    }
  }

   provisioner "local-exec" {
    command = "echo lunching Kibana Dashboard... && sleep 45 && open http://${self.public_ip}:5601 || xdg-open http://${self.public_ip}:5601"
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
      "curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.4.1-linux-x86_64.tar.gz",
      "tar xzvf elastic-agent-8.4.1-linux-x86_64.tar.gz",
      "sed -i 's/changeme/${var.ELK_PASSWORD}/' elastic-agent-8.4.1-linux-x86_64/elastic-agent.yml",
      "sed -i 's/127.0.0.1/${self.public_ip}/' elastic-agent-8.4.1-linux-x86_64/elastic-agent.yml",
      "sed -i 's/# username/ username/' elastic-agent-8.4.1-linux-x86_64/elastic-agent.yml",
      "sed -i 's/# password/ password/' elastic-agent-8.4.1-linux-x86_64/elastic-agent.yml",
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
