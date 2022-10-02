resource "cloudflare_record" "wildcard" {
  zone_id = data.cloudflare_zone.sh4ke-rocks.id
  name    = "*.${var.subdomain}"
  value   = var.lb_external_ip
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "server1" {
  zone_id = data.cloudflare_zone.sh4ke-rocks.id
  name    = "server1.${var.subdomain}"
  value   = var.server1_floating_ip
  type    = "A"
  ttl     = 300
}
