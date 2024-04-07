#!/bin/bash +x
# Version 20240406
#
#############
# PARAMETERS
#############
CHEF_ADMIN_ID='chef'
CHEF_SERVER_NAME='chef-server'
CHEF_ORG='progress'
POLICY_GROUP='dev'
POLICY_NAME='base'

###################
# CHECK PARAMETERS
###################
echo ''
echo 'THIS SCRIPT INSTALLS CHEF CLIENT ON A CHEF MANAGED NODE'
echo 'YOU SHOULD EDIT THE PARAMETERS IN THIS SCRIPT BEFORE RUNNING IT'
echo 'EXISTING PARAMETERS ARE:'
echo "    CHEF_ADMIN_ID = $CHEF_ADMIN_ID"
echo "    CHEF_SERVER_NAME = "$CHEF_SERVER_NAME"
echo "    CHEF_ORG = $CHEF_ORG"
echo "    POLICY_GROUP = $POLICY_GROUP"
echo "    POLICY_NAME = $POLICY_NAME"
read -p "Press Enter to continue, CTRL-C to abort and edit values" YN

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
   "policy_group": "$POLICY_GROUP",
   "policy_name": "$POLICY_NAME"
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

