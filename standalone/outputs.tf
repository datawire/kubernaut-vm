output "ssh_user" {
  description = "SSH user to download kubeconfig file"
  value = "ubuntu"
}

output "public_ip" {
  description = "Public IP address"
  value = "${aws_spot_instance_request.kubernaut.public_ip}"
}

output "kubeconfig_ip" {
  description = "Path to the kubeconfig file using IP address"
  value = "/home/ubuntu/kubeconfig_ip"
}
