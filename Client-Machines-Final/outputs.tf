output "Guacamole-Server-HTTPS-Address" {
  description = "Contains the HTTPS URL Address for the Guacamole Server"
  value       = "https://${aws_eip.guacamole-server-eip.public_ip}/guacamole/"
}

output "Guacamole-Server-HTTP-Tomcat-Address" {
  description = "Contains the HTTPS URL Address for the Guacamole Server"
  value       = "http://${aws_eip.guacamole-server-eip.public_ip}:8080/guacamole/"
}

output "Dev-Server-Public-IP-Address" {
  description = "Contains the Public IP for ARTO Windows Dev Server"
  value       = "${aws_instance.windows-dev-box.public_ip}"
}

#output "Dev-Server-Public-IP-Address" {
#  description = "Contains the Public IP for ARTO Attacker Kali"
#  value       = "${aws_instance.attacker-kali-box.public_ip}"
#}

output "Guacamole-Login-Password" {
  description = "Creds for Guacamole"
  value       = "Rusted60striker01Promotes"
}

output "Guacamole-Login-Username" {
  description = "Creds for Guacamole"
  value       = "admin"
}


