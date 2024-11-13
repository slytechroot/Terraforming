output "ARTO-Client-Application-Server-IP" {
  value       = "${aws_instance.arto-client-application.public_ip}"
}
output "ARTO-Domain-Controller-Server-IP" {
  value       = "${aws_instance.arto-domain-controller.public_ip}"
}
output "ARTO-ADCS-Server-IP" {
  value       = "${aws_instance.arto-adcs.public_ip}"
}
output "ARTO-SQL-Server-Server-IP" {
  value       = "${aws_instance.arto-sql.public_ip}"
}



