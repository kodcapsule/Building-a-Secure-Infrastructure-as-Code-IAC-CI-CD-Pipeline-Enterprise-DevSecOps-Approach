package terraform.security

deny[msg] if {
  input.resource_changes[_].change.after.public == true
  msg := "Public resource is not allowed"
}