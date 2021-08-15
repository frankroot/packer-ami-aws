packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name        = "crashell-ami-ubuntu-{{timestamp}}"
  ami_description = "Crashell Web Server"
  instance_type   = "t2.micro"
  region          = "us-east-2"
  subnet_id       = "subnet-0bf9bf5ffdaa3fc63"
  source_ami      = "ami-00399ec92321828f5"
  ssh_username    = "ubuntu"
  tags = {
    Name = "Crashell"
    Os   = "Ubuntu 20.04"
  }
}

build {
  name = "crashell-ami"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source      = "config/webapp.conf"
    destination = "/tmp/webapp.conf"
  }

  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get install -y apache2 php7.4",
      "sudo git clone https://github.com/frankroot/WebApp.git /var/www/WebApp",
      "sudo cp /tmp/webapp.conf /etc/apache2/sites-available/webapp.conf",
      "sudo a2ensite webapp.conf",
      "sudo a2dissite 000-default.conf"
    ]
  }
}