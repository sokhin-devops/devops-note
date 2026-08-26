# The exact firewall design from the Vultr lab (../../5-cloud-providers),
# expressed as Terraform resources instead of curl+jq calls: 22, 80, 443
# allowed, everything else dropped before it reaches the instance.
resource "vultr_firewall_group" "this" {
  description = "${var.label} firewall"
}

resource "vultr_firewall_rule" "ssh" {
  firewall_group_id = vultr_firewall_group.this.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "22"
  notes             = "SSH"
}

resource "vultr_firewall_rule" "http" {
  firewall_group_id = vultr_firewall_group.this.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "80"
  notes             = "HTTP"
}

resource "vultr_firewall_rule" "https" {
  firewall_group_id = vultr_firewall_group.this.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "443"
  notes             = "HTTPS"
}
