output master_public_ip {
  value       = aws_instance.master.public_ip
  sensitive   = false
  description = "description"
}

output agent_public_ip {
  value       = aws_instance.agent.public_ip
  sensitive   = false
  description = "description"
}

