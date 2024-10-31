resource "boundary_host_set_static" "aws_linux_machines" {
  name            = "aws-linux_machines"
  description     = "Host set for AWS Linux Machines"
  host_catalog_id = boundary_host_catalog_static.aws_compute.id
  host_ids = [
    boundary_host_static.aws_private_linux.id,
  ]
}

resource "boundary_host_static" "aws_private_linux" {
  name            = "aws-private-linux"
  description     = "AWS Linux Host"
  address         = aws_instance.aws_private_linux.private_ip
  host_catalog_id = boundary_host_catalog_static.aws_compute.id

}

resource "boundary_credential_store_static" "static_cred_store" {
  name        = "static_credential_store"
  description = "Boundary Static Credential Store"
  scope_id    = boundary_scope.project.id
}

resource "boundary_credential_ssh_private_key" "static_ssh_key" {
  name                = "static-ssh-key"
  description         = "Boundary Static SSH credential"
  credential_store_id = boundary_credential_store_static.static_cred_store.id
  username            = "ec2-user"
  private_key         = file("../boundary.pem")
}

resource "boundary_target" "aws_linux_private" {
  type                                       = "ssh"
  name                                       = "aws-private-linux"
  description                                = "AWS Linux Private Target"
  egress_worker_filter                       = " \"sm-egress-downstream-worker1\" in \"/tags/type\" "
  ingress_worker_filter                      = " \"sm-ingress-upstream-worker1\" in \"/tags/type\" "
  scope_id                                   = boundary_scope.project.id
  session_connection_limit                   = -1
  default_port                               = 22
  host_source_ids                            = [boundary_host_set_static.aws_linux_machines.id]
  injected_application_credential_source_ids = [boundary_credential_ssh_private_key.static_ssh_key.id]
}

resource "boundary_alias_target" "ts_alias_target_aws_linux" {
  name                      = "aws_linux_alias_target"
  description               = "Alias to AWS Linux Target"
  scope_id                  = "global"
  value                     = "aws.ec2"
  destination_id            = boundary_target.aws_linux_private.id
  authorize_session_host_id = boundary_host_static.aws_private_linux.id
}