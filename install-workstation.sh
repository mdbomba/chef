#!/bin/bash +x
# Version 20240406
#
#############
# PARAMETERS
#############
DISTRO='ubuntu'
CHEF_ADMIN_ID='chef'
CHEF_ORG='progress'
CHEF_SERVER_NAME='server'
CHEF_REPO='chef_repo'

#######################
# ASK IF VALUES ARE OK
#######################
echo ''
echo 'THIS SCRIPT WILL INSTALL CHEF WORKSTATION'
echo 'THIS SCRIPT IS INTENDED TO BE EDITED TO SET PARAMETERS BEFORE BEING RUN'
echo 'PARAMETER LIST FOR THIS SCRIPT IS LISTED BELOW'
echo "    DISTRO = $DISTRO"
echo "    CHEF_ADMIN_ID = $CHEF_ADMIN_ID"
echo "    CHEF_ORG = $CHEF_ORG"
echo "    CHEF_SERVER_NAME = $CHEF_SERVER_NAME"
echo "    CHEF_REPO = $CHEF_REPO"
read -p "Press any key to continue, CTRL-C to terminate and edit parameter values" YN

##########################
# DETERMINE DOWNLOAD INFO
##########################
if [ "x$DISTRO" = "xubuntu" ] || [ "x$DISTRO" = "xlinuxmint" ] || [ "x$DISTRO" = "xdebian" ]; then 
  URL='https://packages.chef.io/files/stable/chef-workstation/21.10.640/ubuntu/20.04/chef-workstation_21.10.640-1_amd64.deb'
  PKG="chef-workstation_21.10.640-1_amd64.deb"
  INST='dpkg'
else 
  URL='https://packages.chef.io/files/stable/chef-workstation/21.10.640/el/8/chef-workstation-21.10.640-1.el8.x86_64.rpm'
  PKG='chef-workstation-21.10.640-1.el8.x86_64.rpm'
  INST='yum'
fi

########################################
# DOWNLOAD AND INSTALL CHEF WORKSTATION
########################################
REBOOT='no'; DOIT='yes'
if [ `command -v chef` ]; then echo "Chef Workstation is already installed"; DOIT=no; fi
if [ "$INST" = "dpkg" ] && [ "$DOIT" = "yes" ]; then sudo dpkg -i "$PKG"; REBOOT='yes'; fi
if [ "$INST" = "yum"  ] && [ "$DOIT" = "yes" ]; then sudo yum localinstall "$PKG"; REBOOT='yes'; fi

#########################
# CREATE CREDENTIALS FILE
#########################
if ! test -d ~/.chef; then mkdir ~/.chef; fi
if test -f ~/.chef/credentials; then
  echo "Credentials file for knife already exists"
else
  echo "Creating credentials file for knife commands in ~/.chef/"
  echo "[default]"                                                                      > ~/.chef/credentials
  echo "client_name     = '$CHEF_ADMIN_ID'"                                            >> ~/.chef/credentials
  echo "client_key      = '/home/$CHEF_ADMIN_ID/.chef/$CHEF_ADMIN_ID.pem'"             >> ~/.chef/credentials
  echo "validation_client_name = '$CHEF_ORG'"                                          >> ~/.chef/credentials
  echo "validation_client_key = '/home/$CHEF_ADMIN_ID/.chef/$CHEF_ORG-validator.pem'"  >> ~/.chef/credentials
  echo "chef_server_url = 'https://$CHEF_SERVER_NAME/organizations/$CHEF_ORG'"         >> ~/.chef/credentials
  echo "cookbook_path  =  'home/$CHEF_ADMIN_ID/$CHEF_REPO/cookbooks'"                  >> ~/.chef/credentials
fi

#############
# UPDATE PATH
#############
if `grep -i "chef shell-init" ~/.bashrc > /dev/null`; then
  echo "Path already added to .bashrc"
else
  echo "Adding path info to .bashrc for chef"
  PATH=/opt/chef-workstation/bin:$PATH
  chef shell-init bash
  echo 'eval "$(chef shell-init bash)"' | tee -a ~/.bashrc >> /dev/null
  REBOOT="yes"
fi

############################
# GENERATE DEFAULT CHEF REPO
############################
if test -d "$CHEF_REPO"; then 
  echo "Chef Repo named $CHEF_REPO already exsts"
else
  echo "Generating repo named $CHEF_REPO"
  chef generate repo "$CHEF_REPO" --chef-license 'accept'
fi

###############################
# PULL CREDENTIALS FROM SERVER
###############################
if `ping -c 1 $CHEF_SERVER_NAME > /dev/null`; then 
  echo "Pulling .pem files from chef server $CHEF_SERVER_NAME"
  rcp $CHEF_ADMIN_ID@$CHEF_SERVER_NAME:/home/$CHEF_ADMIN_ID/*.pem ~/.chef/
else
  echo ""
  echo "###################################################################################"
  echo "AFTER INSTALL, COPY .pem FILES FROM CHEF SERVER TO CHEF WORKSTATION FOLDER ~/.chef/"
  echo "###################################################################################"
  echo ""
fi

echo "###########################"
echo "# CHEF WORKSTATION REBOOT #"
echo '###########################'
if [ "x$REBOOT" = "xyes" ]; then
  echo "Script will automatically reboot server now"
  echo 'Please run "knife ssl fetch" after reboot and when chef automate server is running to cache ssl certs'
  read -p "Press Enter to reboot, CTRL-C to abort reboot" REBOOT
  shutdown -r now
fi



