#!/bin/bash -xe
# Version 20240311
#
####################
# SCRIPT PARAMETERS
####################
CHEF_ADMIN_ID='chef'
CHEF_ORG='progress'
CHEF_SERVER_NAME='chef-server'
DEB_URL='https://packages.chef.io/files/stable/chef-workstation/21.10.640/ubuntu/20.04/chef-workstation_21.10.640-1_amd64.deb'
RPM_URL='https://packages.chef.io/files/stable/chef-workstation/21.10.640/el/8/chef-workstation-21.10.640-1.el8.x86_64.rpm'

##########################
# DETERMINE LINUX VARIENT
##########################
if test -f /etc/lsb-release; then . /etc/lsb-release; fi
if [ "x$DISTRIB_ID" = "xUbuntu" ] || [ "x$DISTRIB_ID" = "xLinuxMint" ]; then URL="$DEB_URL"; else URL="$RPM_URL"; fi
PKG=`echo $URL | cut -d "/" -f 10`

########################################
# DOWNLOAD AND INSTALL CHEF WORKSTATION
########################################
wget -O "$PKG" "$URL"
if test "x$DISTRIB_ID" = "xUbuntu"
  then sudo dpkg -i "$PKG"
  else sudo yum localinstall "$PKG"
fi

#########################
# CREATE CREDENTIALS FILE
#########################
if ! test -d ~/.chef; then mkdir ~/.chef; fi
echo "[default]
client_name     = '$CHEF_ADMIN_ID'
client_key      = '/home/$CHEF_ADMIN_ID/.chef/$CHEF_ADMIN_ID.pem'
chef_server_url = 'https://$CHEF_SERVER_NAME/organizations/$CHEF_ORG'
" > ~/.chef/credentials

#############
# UPDATE PATH
#############
PATH=/opt/chef-workstation/bin:$PATH
chef shell-init bash
echo 'eval "$(chef shell-init bash)"' | tee -a ~/.bashrc >> /dev/null

############################
# GENERATE DEFAULT CHEF REPO
############################
chef generate repo "chef-repo" --chef-license 'accept'

echo "###########################"
echo "# CHEF WORKSTATION REBOOT #"
echo '###########################'

echo "Script will automatically reboot server now"
read -p "Press Enter to reboot, CTRL-C to abort reboot" REBOOT
shutdown -r now



