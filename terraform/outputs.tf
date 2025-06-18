output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.web.public_dns
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${aws_key_pair.main.key_name}.pem ubuntu@${aws_instance.web.public_ip}"
}

output "website_url" {
  description = "URL to access the deployed website"
  value       = "http://${aws_instance.web.public_ip}"
}