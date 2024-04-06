#!/bin/bash +x
# Version 20240406
#
####################
# SCRIPT PARAMETERS
####################
CHEF_ADMIN_ID='chef'
CHEF_ORG='progress'
CHEF_SERVER_NAME='server'
CHEF_REPO='chef_repo'
DEB_URL='https://packages.chef.io/files/stable/chef-workstation/21.10.640/ubuntu/20.04/chef-workstation_21.10.640-1_amd64.deb'
RPM_URL='https://packages.chef.io/files/stable/chef-workstation/21.10.640/el/8/chef-workstation-21.10.640-1.el8.x86_64.rpm'

#######################
# ASK IF VALUES ARE OK
#######################
echo ''
echo 'THIS SCRIPT WILL INSTALL CHEF WORKSTATION'
echo 'THIS SCRIPT IS INTENDED TO BE EDITED TO SET PARAMETERS BEFORE BEING RUN'
echo 'PARAMETER LIST FOR THIS SCRIPT IS LISTED BELOW'
echo "    CHEF_ADMIN_ID = $CHEF_ADMIN_ID"
echo "    CHEF_ORG = $CHEF_ORG"
echo "    CHEF_SERVER_NAME = $CHEF_SERVER_NAME"
echo "    CHEF_REPO = $CHEF_REPO"
echo "    DEB_URL = $DEB_URL     ... INSTALL URL FOR chef-workstation_{version}.deb  "
echo "    RPM_URL = $DEB_URL     ... INSTALL URL FOR chef-workstation_{version}.rpm  "
read -p "Press any key to continue, CTRL-C to terminate and edit values" YN

##########################
# DETERMINE LINUX VARIENT
##########################
if test -f /etc/os-release; then . /etc/os-release; fi
if [ "x$ID" = "xubuntu" ] || [ "x$ID" = "xlinuxmint" ] || [ "x$ID" = "xdebian" ]; then URL="$DEB_URL"; else URL="$RPM_URL"; fi
if [ "x$ID" = "x" ]; then echo "Cannot determine OS variant. Terminating script"; exit; fi
PKG=`echo $URL | cut -d "/" -f 10`

########################################
# DOWNLOAD AND INSTALL CHEF WORKSTATION
########################################
REBOOT='no'
if [ `command -v chef` ]; then
  echo "Chef Workstation is already installed"
else
  wget -O "$PKG" "$URL"
  if [ "x$ID" = "xubuntu" ] || [ "x$ID" = "xlinuxmint" ] || [ "x$ID" = "xdebian" ]
    then sudo dpkg -i "$PKG; REBOOT='yes'"
    else sudo yum localinstall "$PKG"; REBOOT='yes'
  fi
fi

#########################
# CREATE CREDENTIALS FILE
#########################

if test -f ~.chef/credentials; then
  echo "Credentials file for knife already exists"
else
  if ! test -d ~/.chef; then mkdir ~/.chef; fi
echo "[default]
client_name     = '$CHEF_ADMIN_ID'
client_key      = '/home/$CHEF_ADMIN_ID/.chef/$CHEF_ADMIN_ID.pem'
validation_client_name = '$CHEF_ORG'
validation_client_key = '/home/$CHEF_ADMIN_ID/.chef/$CHEF_ORG-validator.pem'
chef_server_url = 'https://$CHEF_SERVER_NAME/organizations/$CHEF_ORG'
cookbook_path  =  'home/$CHEF_ADMIN_ID/$CHEF_REPO/cookbooks'
" > ~/.chef/credentials
fi

#############
# UPDATE PATH
#############
if `grep -i "chef shell-init" ~/.bashrc > /dev/null` ]; then
  echo "Path already added to .bashrc"
else
  PATH=/opt/chef-workstation/bin:$PATH
  chef shell-init bash
  echo 'eval "$(chef shell-init bash)"' | tee -a ~/.bashrc >> /dev/null
fi

############################
# GENERATE DEFAULT CHEF REPO
############################
if test -d "$CHEF_REPO"; then 
  echo "Chef Repo named $CHEF_REPO already exsts"
else
  chef generate repo "$CHEF_REPO" --chef-license 'accept'; fi
fi

echo "###########################"
echo "# CHEF WORKSTATION REBOOT #"
echo '###########################'
if [ "x$REBOOT" = "xyes" ]; then
  echo "Script will automatically reboot server now"
  read -p "Press Enter to reboot, CTRL-C to abort reboot" REBOOT
  shutdown -r now
fi


