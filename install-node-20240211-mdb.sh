version=20240211
# Version 20240211
#!/bin/bash -xe
#
# !!! Policy Name and Policy Group need to be preconfigured on the chef server !!!
#
# Run prep.sh script before running bootstrap.sh
#   -  prep.sh will update hosts file with chef components
#   -  prep.sh will create a series of environmental variables to support script automation
#   -  prep.sh will download and implement the demo ssh validator key
#   -  prep.sh will install various dependent applications
#
# bootstrap.sh script will do the following
#   -  create required working directories
#   -  download the organization pem file to /etc/chef
#   -  dowload the install.sh script
#   -  create a first-boot.json for initial chef-client execution
#   -  create a client.rb file
#   -  install the chef client and register the node with the chef server
# 

# Load chef parameters
if test -f ~/.chefparams ; then source ~/.chefparams 
  else echo "This script requires a ~/.chefparams file created by prep.sh. Please edit and run prep.sh. Exiting script."; exit
fi

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

