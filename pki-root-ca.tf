resource "vault_mount" "pki_root" {
  path                      = "pki"
  type                      = "pki"
  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 315360000
}

resource "vault_pki_secret_backend_root_cert" "pki_root_cert" {
  backend     = vault_mount.pki_root.path
  common_name = "transparentsessions.com"
  type        = "internal"
  ttl         = 315360000
  issuer_name = "pki_root"
}

resource "vault_pki_secret_backend_issuer" "pki_root" {
  backend                        = vault_mount.pki_root.path
  issuer_ref                     = vault_pki_secret_backend_root_cert.pki_root_cert.issuer_id
  issuer_name                    = vault_pki_secret_backend_root_cert.pki_root_cert.issuer_name
  revocation_signature_algorithm = "SHA256WithRSA"
}

output "vault_pki_secret_backend_root_cert_pki_root" {
  value = vault_pki_secret_backend_root_cert.pki_root_cert.certificate
}

resource "local_file" "djk_pki_root_cert" {
  content  = vault_pki_secret_backend_root_cert.pki_root_cert.certificate
  filename = "pki_root.crt"
}

resource "vault_pki_secret_backend_role" "pki_role" {
  backend        = vault_mount.pki_root.path
  name           = "web-servers"
  allow_any_name = true
}

resource "vault_pki_secret_backend_config_urls" "pki_urls" {
  backend                 = vault_mount.pki_root.path
  issuing_certificates    = ["${var.vault_addr}/v1/pki/ca"]
  crl_distribution_points = ["${var.vault_addr}/v1/pki/crl"]
}