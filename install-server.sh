#!/bin/bash -xe
# Version 20240311
#
##################
# SET PARAMETERS
#################
CHEF_ADMIN_ID='chef'
CHEF_ADMIN_FIRT='Chef'
CHEF_ADMIN_LAST='Admin'
CHEF_ADMIN_EMAIL='chef.admin@kemptech.biz'
CHEF_ADMIN_PASS='devsecops'
CHEF_ORG='progress'
CHEF_ORG_LONG="Progress Software"

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
curl https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip | gunzip - > chef-automate && chmod +x chef-automate
sudo ./chef-automate deploy --product automate --product infra-server
sudo chef-automate init-config
sudo chef-server-ctl user-create "$CHEF_ADMIN_ID" "$CHEF_ADMIN_FIRST" "$CHEF_ADMIN_LAST" "$CHEF_ADMIN_EMAIL" "$CHEF_ADMIN_PASS" --filename "$CHEF_ADMIN_ID.pem"
sudo chef-server-ctl org-create "$CHEF_ORG" "$CHEF_ORG_LONG" --association_user "$CHEF_ADMIN_ID" --filename "$CHEF_ORG-validator.pem"

###########################
# CREATE SSL KEY
###########################
ssh-keygen -b 4092 -f ~/.ssh/id_rsa -N '' >> /dev/null

