provider "aws" {
  region = "${var.region}"
}

data "aws_route53_zone" "kubernaut_io" {
  name = "kubernaut.io"
}

resource "aws_route53_record" "kubernaut_cluster" {
  zone_id = "${data.aws_route53_zone.kubernaut_io.zone_id}"
  name    = "${var.cluster_name}.${data.aws_route53_zone.kubernaut_io.name}"
  type    = "CNAME"
  ttl     = 60
  records = ["${aws_spot_instance_request.kubernaut.public_dns}"]
}

resource "aws_key_pair" "kubernaut" {
  key_name_prefix = "kubernaut-${var.cluster_name}-"
  public_key      = "${file(pathexpand(var.ssh_public_key))}"
}

data "template_file" "bootstrap_script" {
  template = "${file("${path.module}/templates/bootstrap.sh")}"

  vars {
    kubeadm_token = "${data.template_file.kubeadm_token.rendered}"
    dns_name      = "${var.cluster_name}.${replace(data.aws_route53_zone.kubernaut_io.name, "/[.]$/", "")}"
    cluster_name  = "${var.cluster_name}"
  }
}

data "template_file" "cloudinit_config" {
  template = "${file("${path.module}/templates/cloud-init-config.yaml")}"

  vars {
    calico_yaml = "${base64gzip("${file("${path.module}/templates/calico.yaml")}")}"
  }
}

data "template_cloudinit_config" "kubernaut_cloudinit" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-init-config.yaml"
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudinit_config.rendered}"
  }

  part {
    filename     = "kubernaut-bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.bootstrap_script.rendered}"
  }
}

resource "aws_spot_instance_request" "kubernaut" {
  ami                         = "${var.image_id}"
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.kubernaut_profile.name}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${aws_subnet.kubernaut.id}"
  user_data                   = "${data.template_cloudinit_config.kubernaut_cloudinit.rendered}"
  key_name                    = "${aws_key_pair.kubernaut.id}"
  monitoring                  = false
  spot_price                  = "${lookup(var.instance_spot_price, var.instance_type, "0.10")}"
  vpc_security_group_ids      = ["${aws_security_group.kubernaut.id}"]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = true
  }

  tags = "${merge(map("Name", var.cluster_name, "kubernaut.io/cluster/name", var.cluster_name, format("kubernetes.io/cluster/%v", var.cluster_name), "owned"), var.tags)}"
}