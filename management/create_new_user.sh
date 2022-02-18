#!/bin/bash

function help {
  echo "Usage: create_new_user.sh <username> [pubkey]"
  echo "  <username> Typical unix username"
  echo "  <pubkey>   Public key to add to authorized_keys file (optional)"
  echo
  echo "Requirements: for each machine, you must have an associated ssh configuration using a public key authentication mechanism with a root account."
  echo
  echo "Usage example:"
  echo "./create_new_user.sh test \"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwxO5Du2KvS/OcZ97qiN2bhSLhocQ3JIprLM8m+zrDa3F2DdxlVtndpwm/uHgbDSfw8swIpZA5Y05Q6miArzjP//iAQdsXOKkNSCV7FNn/CZ9dKRxYHiLeg92+gOOQF741yDs4QAbteCloa8TYMpA1Oe55Mjq0w7yVq61YFfRMo9Sxqwe7HthOhYDvXa8VI8knK5PIZR0Wym8vlmVmY4RdZu1OXJCfcQMo+KYHcOWOpOYIGofAzpCQGiFkbxmDjqjTAFuk1ZGyt1jFxlISGXvSM0vo36t0ENnY1oVC7nMi183dhRDhxkFULBsXPGd3HJnSCXFFkuGQO493jtZizPzTiRtFnpyEydcjJzKYTfj9SFIrHY+9tODbF710m8k3Vc4rfArbfQTURcbELEV4gL+4Sdst3KvAFVs3gkw0GxQMUbn1agDyehSLIi00k6Jn2LgNJ1YEUG3vdDQXgxSdrNzKs7xR8A77SNfkK/CpxHRe8XZBsHDMeaPweKhxhR9OgQ0=\""
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  help
  exit 0
fi

username=$1
pubkey=$2

machines=("gsd+e291427x1300274" "gsd+e291427x1300275")

# Testing configuration and connections first
for machine in ${machines[*]}; do
  if ! grep -q $machine ~/.ssh/config; then
    echo "Unable to find ssh configuration for machine $machine. Make sure you have an entry for this machine on ~/.ssh/config."
  fi

  ip=`sed -e "/$machine/,/Hostname/I!d" ~/.ssh/config | grep -i hostname | awk -F ' ' '{print $2}'`
  echo "Testing connection on machine $machine ($ip)..."
  
  if ! ping -q -c 1 -W 1 $ip >/dev/null; then
    echo "Machine $machine is down. Aborting."
    exit 0
  fi
  
  echo "Ok!"
done

echo
echo "*****************************************************************"
echo " Creating new user:"
echo "   username $username"
echo "   pubkey   $pubkey"
for machine in ${machines[*]}; do
echo "   machine  $machine"
done
echo "*****************************************************************"
echo

read -p "Are you sure? [y/N] " -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

# Now creating the new user
echo "Creating user..."

password=`dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev`

for machine in ${machines[*]}; do
  ssh -t $machine "sudo useradd -s /bin/bash -m -G sudo,docker $username && \
    echo '$username:$password' | sudo chpasswd"
  ret=$?

  if [ $ret -ne 0 ]; then
    echo "Something went wrong. Aborting."
    exit 1
  fi
  
  if [ -n "$pubkey" ]; then
    ssh -t $machine "sudo mkdir /home/$username/.ssh && \
        echo \"$pubkey\" | sudo tee /home/$username/.ssh/authorized_keys > /dev/null && \
        sudo chmod 600 /home/$username/.ssh/authorized_keys && \
        sudo chown -R $username:$username /home/$username/.ssh"
  fi
done

echo "Done!"
echo ""
echo "username $username"
echo "password $password"
echo "pubkey   $pubkey"
