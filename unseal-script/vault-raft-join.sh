#!/bin/sh

# Start the Vault server in the background
vault server -config=/vault/config/config.hcl &

# Wait for the server to start
sleep 15

# raft join vault-server1
# no need to decalre the address of the server bacause it is already in the config.hcl file by retry_join parameter
#vault operator raft join http://vault-server1:8200

echo "raft joined successfully"

# Unseal Vault (optional, depends on your setup)
if vault status | grep -q 'Sealed.*true'; then
  echo "Unsealing Vault"
  
  vault operator unseal $(grep 'Unseal Key 1' /unseal-script/unseal-output.txt | awk '{print $4}')
  sleep 1
  vault operator unseal $(grep 'Unseal Key 2' /unseal-script/unseal-output.txt | awk '{print $4}')
  sleep 1
  vault operator unseal $(grep 'Unseal Key 3' /unseal-script/unseal-output.txt | awk '{print $4}')
  sleep 1

  vault login $(grep 'Initial Root Token' /unseal-script/unseal-output.txt | awk '{print $4}')

  echo "Vault Unseal Successfully"

else
  echo "Vault is already unsealed."
fi

vault status
vault operator raft list-peers

# Keep container running & waiting process in the background to finish
wait
