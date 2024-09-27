resource "boundary_auth_method" "password" {
  scope_id = "global"
  type     = "password"
  name     = "ts-userpass"
}

//Boundary configuration for the unauthorised user
resource "boundary_account_password" "unauthorised_user" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "unauthorised"
  password       = "unauthorised"
}

resource "boundary_user" "unauthorised_user" {
  name        = "unauthorised_user"
  description = "Unauthorised user"
  account_ids = [boundary_account_password.unauthorised_user.id]
  scope_id    = "global"
}

resource "boundary_role" "unauthorised" {
  description = "read-auth-token"
  grant_strings = [
    "type=auth-token;ids=*;actions=read:self",
    "type=user;actions=list-resolvable-aliases;ids=*",
  ]
  name          = "read-auth-token"
  principal_ids = [boundary_user.unauthorised_user.id]
  scope_id      = "global"
}

//Boundary configuration for the authorised user
resource "boundary_account_password" "authorised_user" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "authorised"
  password       = "authorised"
}

resource "boundary_user" "authorised_user" {
  name        = "authorised_user"
  description = "Authorised user"
  account_ids = [boundary_account_password.authorised_user.id]
  scope_id    = "global"
}

resource "boundary_role" "authorised_global_role" {
  name          = "authorised_global_role"
  description   = "Authorised Global Role"
  scope_id      = "global"
  principal_ids = [boundary_user.authorised_user.id]
  grant_strings = [
    "ids=*;type=*;actions=read",
    "type=auth-token;ids=*;actions=read:self",
    "type=user;actions=list-resolvable-aliases;ids=*",
  ]
}

resource "boundary_role" "authorised_org_role" {
  name          = "authorised_org_role"
  description   = "Authorised Org Role"
  scope_id      = boundary_scope.org.id
  principal_ids = [boundary_user.authorised_user.id]
  grant_strings = ["ids=*;type=*;actions=*", ]
}

resource "boundary_role" "authorised_project_role" {
  name          = "authorised_project_role"
  description   = "Authorised Project Role"
  scope_id      = boundary_scope.project.id
  principal_ids = [boundary_user.authorised_user.id]
  grant_strings = ["ids=*;type=*;actions=*", ]
}