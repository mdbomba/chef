#!/bin/bash +x
# Version 20240406
#
#############
# PARAMETERS
#############
CHEF_ADMIN_ID='chef'
CHEF_ADMIN_FIRST='Chef'
CHEF_ADMIN_LAST='Admin'
CHEF_ADMIN_EMAIL='chef.admin@kemptech.biz'
CHEF_ADMIN_PASS='devsecops'
CHEF_ORG='progress'
CHEF_ORG_LONG="Progress Software"

#######################
# ASK IF VALUES ARE OK
#######################
echo ''
echo 'THIS SCRIPT WILL INSTALL CHEF AUTOMATE WITH CHEF INFRA SERVER'
echo 'THIS SCRIPT IS INTENDED TO BE EDITED TO SET PARAMETERS BEFORE BEING RUN'
echo 'PARAMETER LIST FOR THIS SCRIPT IS LISTED BELOW'
echo "    CHEF_ADMIN_ID = $CHEF_ADMIN_ID"
echo "    CHEF_ADMIN_FIRST = $CHEF_ADMIN_FIRST"
echo "    CHEF_ADMIN_LAST = $CHEF_ADMIN_LAST"
echo "    CHEF_ADMIN_EMAIL = $CHEF_ADMIN_EMAIL"
echo "    CHEF_ADMIN_PASS = $CHEF_ADMIN_PASS"
echo "    CHEF_ORG = $CHEF_ORG"
echo "    CHEF_ORG_LONG = $CHEF_ORG_LONG"
read -p "Press any key to continue, CTRL-C to terminate and edit values" YN
	
########################
# UPDATE sysctl.conf
########################
if ! test -f /etc/sysctl.conf_orig; then sudo cp -f /etc/sysctl.conf /etc/sysctl.conf_orig; fi
if test -f /etc/sysctl.conf_orig; then sudo cp -f /etc/sysctl.conf_orig /etc/sysctl.conf; fi
echo "vm.max_map_count=262144"         | sudo tee -a /etc/sysctl.conf
echo "vm.dirty_expire_centisecs=20000" | sudo tee -a /etc/sysctl.conf

########################
# UPDATE RUNNING CONFIG
########################
sudo  sysctl -w vm.max_map_count=262144
sudo  sysctl -w vm.dirty_expire_centisecs=20000

#######################################################################
# DOWNLOAD AND INSTALL CHEF SERVER (AUTOMATE + INFRA_SERVER + BUILDER)
#######################################################################
if [ `command -v chef-server-ctl` ]; then
  echo 'Chef Automate already installed, Proceeding to create user/org'
else
  curl https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip | gunzip - > chef-automate && chmod +x chef-automate
  sudo ./chef-automate deploy --product automate --product infra-server
  sudo chef-automate init-config
fi
sudo chef-server-ctl user-create "$CHEF_ADMIN_ID" "$CHEF_ADMIN_FIRST" "$CHEF_ADMIN_LAST" "$CHEF_ADMIN_EMAIL" "$CHEF_ADMIN_PASS" --filename "$CHEF_ADMIN_ID"".pem"
sudo chef-server-ctl org-create "$CHEF_ORG" "$CHEF_ORG_LONG" --association_user "$CHEF_ADMIN_ID" --filename "$CHEF_ORG""-validator.pem"


