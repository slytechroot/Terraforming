resource "tls_private_key" "cs-server-key" {
  //algorithm = "ED25519" - Azure does not support ED25519 WTF..
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "CS-Server-Key-${random_string.resource_code.result}"       # Add Key to AWS
  public_key = tls_private_key.cs-server-key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.kp.key_name}.pem"
  content = tls_private_key.cs-server-key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "ssh_key_pub" {
  filename = "${aws_key_pair.kp.key_name}.pub"
  content = tls_private_key.cs-server-key.public_key_openssh
  file_permission = "0600"
}