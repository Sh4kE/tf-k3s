resource "cloudflare_record" "openstack-wildcard-subdomain" {
  zone_id = data.cloudflare_zone.sh4ke-rocks.id
  name    = "*.${var.subdomain}"
  value   = var.lb_external_ip
  type    = "A"
  ttl     = 300
}
