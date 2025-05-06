#!/bin/sh

# Start the Vault server in the background
vault server -config=/vault/config/config.hcl &

sleep 0.5

# Initialize Vault
if vault status | grep -q 'Initialized.*false'; then
  echo "Vault is not initialized. Initializing..."
  vault operator init > /unseal-script/unseal-output.txt
else
  echo "Vault is already initialized."
fi

# Unseal Vault (optional, depends on your setup)
if vault status | grep -q 'Sealed.*true'; then
  echo "Unsealing Vault"

  vault operator unseal $(grep 'Unseal Key 1' /unseal-script/unseal-output.txt | awk '{print $4}')
  vault operator unseal $(grep 'Unseal Key 2' /unseal-script/unseal-output.txt | awk '{print $4}')
  vault operator unseal $(grep 'Unseal Key 3' /unseal-script/unseal-output.txt | awk '{print $4}')

  vault login $(grep 'Initial Root Token' /unseal-script/unseal-output.txt | awk '{print $4}')

  echo "Vault Unseal Successfully"

else
  echo "Vault is already unsealed."
fi

vault status
vault operator raft list-peers

# Keep container running & waiting process in the background to finish
wait

