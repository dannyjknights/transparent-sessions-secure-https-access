output "boundary_ingress_worker_public_ip" {
  value = aws_instance.boundary_ingress_worker.public_ip
}

output "issue_cert_endpoint" {
  value = vault_pki_secret_backend_config_urls.pki_urls.issuing_certificates
}

output "crl_dist_endpoint" {
  value = vault_pki_secret_backend_config_urls.pki_urls.crl_distribution_points
}