resource "boundary_host_catalog_static" "aws_compute" {
  name        = "Demo Static Host Catalogue"
  description = "Demo Static Host Catalogue"
  scope_id    = boundary_scope.project.id
}

/* Create a static host set for AWS Linux Machines. The hosts to be placed
within this host set are the public and private hosts, defined within the
host-catalog.tf configuration.
*/
resource "boundary_host_set_static" "ubuntu_linux_machines" {
  name            = "ubuntu-linux-machines"
  description     = "Host set for Ubuntu Linux Machines"
  host_catalog_id = boundary_host_catalog_static.aws_compute.id
  host_ids = [
    boundary_host_static.ubuntu_private_linux.id,
  ]
}

# Creates a static private Boundary host and assigns it to the static host catalog
resource "boundary_host_static" "ubuntu_private_linux" {
  name            = "ubuntu-private-linux"
  description     = "Ubuntu Linux host"
  address         = aws_instance.web_instance.private_ip
  host_catalog_id = boundary_host_catalog_static.aws_compute.id
}

resource "boundary_target" "ubuntu_linux_private" {
  type                     = "tcp"
  name                     = "ubuntu-private-linux"
  description              = "Ubuntu Linux Private Target"
  egress_worker_filter     = " \"sm-egress-downstream-worker1\" in \"/tags/type\" "
  ingress_worker_filter    = " \"sm-ingress-upstream-worker1\" in \"/tags/type\" "
  scope_id                 = boundary_scope.project.id
  session_connection_limit = -1
  default_port             = 443
  host_source_ids = [
    boundary_host_set_static.ubuntu_linux_machines.id
  ]
}

resource "boundary_alias_target" "ts_alias_target" {
  name                      = "transparent_sessions_alias_target"
  description               = "Alias to target using test.transparentsessions.com"
  scope_id                  = "global"
  value                     = "test.transparentsessions.com"
  destination_id            = boundary_target.ubuntu_linux_private.id
  authorize_session_host_id = boundary_host_static.ubuntu_private_linux.id
}

