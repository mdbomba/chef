# Version 202140210
# Install Automate Package on dedicated server

echo '#######################################################################'
echo '# START OF CHEF SERVER INSTALL SCRIPT (AUTOMATE+INFRA+INSPEC+HABITAT) #'
echo '#######################################################################'

################
# SET PARAMETERS
################
STAMP=$(date +"_%Y%j%H%M%S")
if test -f ~/.chefparams; then 
  . ~/.chefparams
else
  GIT_USER='mdbomba'
  GIT_EMAIL='mbomba@kemptechnologies.com'
  CHEF_ADMIN_ID='mike'
  CHEF_ADMIN_FIRST='Mike'
  CHEF_ADMIN_LAST='Bomba'
  CHEF_ADMIN_EMAIL='mike.bomba@progress.com'
  CHEF_ORG_NAME='chef-demo'
  CHEF_WORKSTATION_IP='10.0.0.5'
  CHEF_WORKSTATION_NAME='chef-workstation'
  CHEF_SERVER_IP='10.0.0.6'
  CHEF_SERVER_NAME='chef-automate'
  CHEF_NODE1_IP='10.0.0.7'
  CHEF_NODE1_NAME='chef-node1'
  CHEF_NODE2_IP='10.0.0.8'
  CHEF_NODE2_NAME='chef-node2'
  URL_AUTOMATE='https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip'
fi
read -p "Enter the password for the Chef admin account ($CHEF_ADMIN_ID): " CHEF_ADMIN_PASSWORD

#############
# PREP SERVER
#############

sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w vm.dirty_expire_centisecs=20000
sudo cp /etc/sysctl.conf "/etc/sysctl.conf$STAMP"
echo 'sysctl -w vm.max_map_count=262144'         | sudo tee -a /etc/sysctl.conf
echo 'sysctl -w vm.dirty_expire_centisecs=20000' | sudo tee -a /etc/sysctl.conf

###############
# START INSTALL
###############

sudo curl "$URL_AUTOMATE" | sudo gunzip - > chef-automate && sudo chmod +x chef-automate
sudo ./chef-automate init-config 
sudo ./chef-automate deploy --product builder --product automate --product infra-server

# UPDATE .bashrc and .chefparams

echo 'eval "$(chef shell-init bash)"' >> ~/.bashrc
echo 'eval "$(chef shell-init bash)"' >> ~/.chefparams

. ~/.bashrc

#######################
# INITIAL CONFIGURATION
#######################
#
# CREATE FIRST USER
sudo chef-server-ctl create-user "$CHEF_ADMIN_ID" "$CHEF_ADMIN_FIRST" "$CHEF_ADMIN_LAST" "$CHEF_ADMIN_EMAIL" "$CHEF_ADMIN_PASSWORD" --filename "$CHEF_ADMIN_ID.pem"

# CREATE FIIRST ORGANIZATION
sudo chef-server-ctl org-create "$CHEF_ORG_NAME" "$CHEF_ORG_LONG" --association_user "$CHEF_ADMIN_ID" --filename "$CHEF_ORG-validator.pem"

###################################################################
# END OF CHEF SERVER INSTALL SCRIPT (AUTOMATE+INFRA+INSPEC+HABITAT)
###################################################################

