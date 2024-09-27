resource "hcp_hvn" "ts_hvn" {
  hvn_id         = "ts-hvn"
  cloud_provider = "aws"
  region         = "eu-west-2"
  cidr_block     = "172.25.16.0/20"
}

resource "hcp_aws_network_peering" "ts_peering" {
  hvn_id          = hcp_hvn.ts_hvn.hvn_id
  peer_account_id = aws_vpc.boundary_ingress_worker_vpc.owner_id
  peer_vpc_id     = aws_vpc.boundary_ingress_worker_vpc.id
  peer_vpc_region = var.aws_region
  peering_id      = "HCP"
}

resource "aws_vpc_peering_connection_accepter" "ts_peering" {
  vpc_peering_connection_id = hcp_aws_network_peering.ts_peering.provider_peering_id
  auto_accept               = true
}

resource "hcp_vault_cluster" "pki_vault" {
  cluster_id      = "pki-vault-cluster"
  public_endpoint = true
  hvn_id          = hcp_hvn.ts_hvn.hvn_id
  tier            = "dev"
}

resource "hcp_vault_cluster_admin_token" "root_token" {
  cluster_id = hcp_vault_cluster.pki_vault.cluster_id
}

