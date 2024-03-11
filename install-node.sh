#!/bin/bash -xe
# Version 20240311
#
############
# PARAMETERS
############
CHEF_ADMIN_ID='chef'
CHEF_SERVER_NAME='chef-server'
CHEF_ORG='progress'

# Do some chef pre-work
if [ ! -d /etc/chef ];     then `sudo mkdir /etc/chef`; fi
if [ ! -d /var/lib/chef ]; then 'sudo mkdir /var/lib/chef'; fi
if [ ! -d /var/log/chef ]; then `sudo mkdir /var/log/chef`; fi
if [ ! -d ~/temp ];        then `mkdir ~/temp`; fi

###########################################
# CREATE CHEF CLIENT (first-boot.json) FILE
###########################################
cd ~/temp
cat > "./first-boot.json" << EOF
{
   "policy_group": "dev",
   "policy_name": "base"
}
EOF
sudo cp -f first-boot.json /etc/chef/first-boot.json

#####################################
# CREATE CHEF CLIENT (client.rb) FILE
#####################################
cd ~/temp
cat > ./client.rb << EOF
log_location     STDOUT
ssl_verify_mode     :verify_none
verify_api_cert     false
chef_server_url  "https://$CHEF_SERVER_NAME/organizations/$CHEF_ORG"
validation_client_name "$CHEF_ORG-validator"
validation_key "/etc/chef/$CHEF_ORG-validator.pem"
node_name  "${HOSTNAME}"
chef_license "accept"
EOF
sudo cp -f client.rb /etc/chef/client.rb


#################################
# DOWNLOAD CHEF ORG VALIDATOR KEY
#################################
sudo scp $CHEF_ADMIN_ID@$CHEF_SERVER_NAME:/user/$CHEF_ADMIN_ID/$CHEF_ORG-validator.pem /etc/chef/$CHEF_ORG-validator.pem

#########################
# DOWNLOAD INSTALL SCRIPT
#########################
cd /etc/chef
wget -O /etc/chef/install.sh 'https://omnitruck.chef.io/install.sh'
sudo chmod +x *.sh

#####################
# INSTALL CHEF CLIENT
#####################
sudo ./install.sh -v 'latest'

#######################
# CONFIGURE CHEF CLIENT
#######################
sudo chef-client -j /etc/chef/first-boot.json | sudo tee chef-client-output.txt

echo "Node name is $HOSTNAME" 

