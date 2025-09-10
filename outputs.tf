output "master_public_ips" {
  value = [aws_instance.jenkins_master.public_ip]
}

output "agent_private_ips" {
  value = [for a in aws_instance.jenkins_agent : a.private_ip]
}
