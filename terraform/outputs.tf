# App
output "app_ec2_public_dns" {
  value = aws_instance.microblog.public_dns
}

output "app_ec2_id" {
  value = aws_instance.microblog.id
}

output "app_ecr_repository_url" {
  value = aws_ecr_repository.microblog.repository_url
}

# Monitoring
output "mon_ec2_public_dns" {
  value = aws_instance.monitoring.public_dns
}

output "mon_ec2_id" {
  value = aws_instance.monitoring.id
}

# Ansible-relevant outputs
resource "local_file" "ansible_inventory" {
  content = templatefile("templates/ansible/hosts.ini.tmpl",
    {
      app_ec2_public_dns = aws_instance.microblog.public_dns,
      app_ec2_id = aws_instance.microblog.id,
      mon_ec2_public_dns = aws_instance.monitoring.public_dns,
      mon_ec2_id = aws_instance.monitoring.id,
      key = "private.pem"
    }
  )
  filename = "output/ansible/hosts.ini"
}

resource "local_file" "tls_private_key" {
  content = tls_private_key.key.private_key_pem
  filename = "output/ansible/private.pem"
  file_permission = "0600"
}

resource "local_file" "ansible_host_vars" {
  content = templatefile("templates/ansible/group_vars/all.yml.tmpl",
    {
      app_ecr_repository_url = aws_ecr_repository.microblog.repository_url,
      app_ec2_public_dns = aws_instance.microblog.public_dns
    }
  )
  filename = "output/ansible/group_vars/all.yml"
}

resource "local_file" "docker_config" {
  content = templatefile("templates/ansible/files/microblog/docker_config.json.tmpl",
    {
      app_ecr_repository_url = replace(aws_ecr_repository.microblog.repository_url, "//.*$/", "")
      app_ecr_repository_creds = data.aws_ecr_authorization_token.token.authorization_token
    }
  )
  filename = "output/ansible/files/microblog/docker_config.json"
}
