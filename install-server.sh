#!/bin/bash +x
# Version 20240406
#
#############
# PARAMETERS
#############
ADMIN='chef'
ADMIN_FIRST='Chef'
ADMIN_LAST='Chef'
ADMIN_EMAIL='chef@kemptech.biz'
ADMIN_PASS='devsecops'
ORG='demoLab'
ORG_LONG="Progress Software Demo Lab"

#######################
# ASK IF VALUES ARE OK
#######################
echo ''
echo 'THIS SCRIPT WILL INSTALL CHEF AUTOMATE WITH CHEF INFRA SERVER'
echo 'THIS SCRIPT IS INTENDED TO BE EDITED TO SET PARAMETERS BEFORE BEING RUN'
echo 'PARAMETER LIST FOR THIS SCRIPT IS LISTED BELOW'
echo "    ADMIN = $ADMIN"
echo "    ADMIN_FIRST = $ADMIN_FIRST"
echo "    ADMIN_LAST = $ADMIN_LAST"
echo "    ADMIN_EMAIL = $ADMIN_EMAIL"
echo "    ADMIN_PASS = $ADMIN_PASS"
echo "    ORG_ = $ORG_"
echo "    ORG__LONG = $ORG__LONG"
read -p "Press any key to continue, CTRL-C to terminate and edit values" YN
	
########################
# UPDATE sysctl.conf
########################
sudo grep -v "vm.max_map_count" /etc/sysctl.conf           | sudo tee ./temp1.tmp >/dev/null
sudo grep -v "vm.dirty_expire_centisecs=" /etc/sysctl.conf | sudo tee -a ./temp1.tmp >/dev/null
echo "vm.max_map_count=262144"         | sudo tee -a ./temp1.tmp
echo "vm.dirty_expire_centisecs=20000" | sudo tee -a ./temp1.tmp
sudo cp -f ./temp1.tmp /etc/sysctl.conf 

########################
# UPDATE RUNNING CONFIG
########################
sudo  sysctl -w vm.max_map_count=262144
sudo  sysctl -w vm.dirty_expire_centisecs=20000

##########################
# CHECK FOR PREREQUISITES
##########################
sudo apt install -y curl >/dev/null 2>&1 ; fi
sudo apt install -y gzip >/dev/null 2>&1 ; fi
sudo apt install -y openssh-server >/dev/null 2>&1 ; fi

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

###############################################
# CREATE ACCOUNTS FOR USER ADMIN AND ORG ADMIN
###############################################
sudo chef-server-ctl user-create "$ADMIN" "$ADMIN_FIRST" "$ADMIN_LAST" "$ADMIN_EMAIL" "$ADMIN_PASS" --filename "$ADMIN"".pem"
sudo chef-server-ctl org-create "$ORG" "$ORG_LONG" --association_user "$ADMIN" --filename "$ORG""-validator.pem"


