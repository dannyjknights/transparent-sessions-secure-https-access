resource "aws_route53_record" "a_record" {
  name    = "test.transparentsessions.com"
  type    = "A"
  zone_id = "Z06285722T9Q8KZ7ZLR2Y"
  records = [aws_instance.web_instance.private_ip]
  ttl     = 300
}

resource "aws_instance" "web_instance" {
  ami              = "ami-07c1b39b7b3d2525d"
  instance_type    = "t3.micro"
  key_name         = "boundary"
  user_data_base64 = data.cloudinit_config.install.rendered
  tags = {
    "Name" = "website-ec2"
  }
  network_interface {
    network_interface_id = aws_network_interface.boundary_target_ni.id
    device_index         = 0
  }
  lifecycle {
    ignore_changes = [
      user_data_base64,
    ]
  }
}

resource "aws_network_interface" "boundary_target_ni" {
  subnet_id               = aws_subnet.private_subnet.id
  security_groups         = [aws_security_group.static_target_sg.id]
  private_ip_list_enabled = false
}

data "cloudinit_config" "install" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y apache2
    sudo mkdir -p /etc/apache2/ssl
    sudo a2enmod ssl
    echo "<html><head><style>body { font-family: Arial, sans-serif; color: #E63946; text-align: center; margin-top: 20%; }</style></head><body><img src="https://d3g9o9u8re44ak.cloudfront.net/logo/cb927f0e-0e72-4eda-86ab-e6099a11a0d9/c6a290e6-d7be-4724-b48d-e980c2571e2b.png" alt="HashiCorp Boundary Logo" width="200"><h1>If you can see this, you have successfully reached this RFC1918 HTTPS website using Boundary's Transparent Sessions</h1></body></html>" | sudo tee /var/www/html/index.html
    curl \
    --header "X-Vault-Token:${hcp_vault_cluster_admin_token.root_token.token}" \
    --request POST --data '{"common_name": "test.transparentsessions.com", "ttl": "24h"}' ${hcp_vault_cluster.pki_vault.vault_public_endpoint_url}/v1/admin/pki_int/issue/transparentsessions-dot-com | jq -r | sudo tee ./pki.json
    jq -r '.data.private_key | sub("\\n"; "\n"; "g")' ./pki.json | tee /etc/apache2/ssl/test.transparentsessions.com.key
    jq -r '.data.certificate | sub("\\n"; "\n"; "g")' ./pki.json | tee /etc/apache2/ssl/test.transparentsessions.com.crt
    jq -r '.data.ca_chain[] | sub("\\n"; "\n"; "g")' ./pki.json | tee /etc/apache2/ssl/ca_chain.crt
    tee /etc/apache2/sites-available/test.transparentsessions.com.conf <<EOS
    <VirtualHost *:443>
      ServerName test.transparentsessions.com

      DocumentRoot /var/www/html

      SSLEngine on
      SSLCertificateFile /etc/apache2/ssl/test.transparentsessions.com.crt
      SSLCertificateKeyFile /etc/apache2/ssl/test.transparentsessions.com.key
      SSLCertificateChainFile /etc/apache2/ssl/ca_chain.crt

      <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
      </Directory>
    </VirtualHost>
    EOS
    sudo a2ensite test.transparentsessions.com.conf
    sudo systemctl restart apache2
    EOF
  }
}