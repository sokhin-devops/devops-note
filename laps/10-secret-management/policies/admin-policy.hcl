# For comparison against app-policy.hcl — full access, the way the root
# token every earlier script uses behaves in practice. Not used by any
# script; read it side by side with app-policy.hcl.
path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "database/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
