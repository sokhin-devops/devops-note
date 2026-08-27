# Deliberately narrow — read one exact path, nothing else. See
# ./03-policies.sh for what this actually blocks, proven against a real
# token, not just read here as a description of intent.
path "kv/data/blog/database" {
  capabilities = ["read"]
}
