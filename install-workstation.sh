#!/bin/bash -xe
# Version 20240325.1

####################
# SCRIPT PARAMETERS
####################
CHEF_REPO='chef_repo'
CHEF_ADMIN_ID='chef'
CHEF_ORG='progress'
CHEF_SERVER_NAME='chef-server'
DEB_URL='https://packages.chef.io/files/stable/chef-workstation/21.10.640/ubuntu/20.04/chef-workstation_21.10.640-1_amd64.deb'
RPM_URL='https://packages.chef.io/files/stable/chef-workstation/21.10.640/el/8/chef-workstation-21.10.640-1.el8.x86_64.rpm'

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
wget -O "$PKG" "$URL"
if [ "x$ID" = "xubuntu" ] || [ "x$ID" = "xlinuxmint" ] || [ "x$ID" = "xdebian" ]
  then sudo dpkg -i "$PKG"
  else sudo yum localinstall "$PKG"
fi

#########################
# CREATE CREDENTIALS FILE
#########################
if ! test -d ~/.chef; then mkdir ~/.chef; fi
echo "[default]
client_name = '$CHEF_ADMIN_ID'
client_key = '/home/$CHEF_ADMIN_ID/.chef/$CHEF_ADMIN_ID.pem'
validation_client_name = '$CHEF_ORG-validator'
validation_key = '/home/$CHEF_ADMIN_ID/.chef/$CHEF_ORG-validator.pem'
chef_server_url = 'https://$CHEF_SERVER_NAME/organizations/$CHEF_ORG'
cookbook_path  =  ['/home/$CHEF_ADMIN_ID/$CHEF_REPO']
" > ~/.chef/credentials

#############
# UPDATE PATH
#############
PATH=/opt/chef-workstation/bin:$PATH
chef shell-init bash --chef-license accept
echo 'eval "$(chef shell-init bash)"' | tee -a ~/.bashrc >> /dev/null

############################
# GENERATE DEFAULT CHEF REPO
############################
chef generate repo "$CHEF_REPO" --chef-license 'accept'

echo "###########################"
echo "# CHEF WORKSTATION REBOOT #"
echo '###########################'

echo ''
echo "After reboot ensure $CHEF_ADMIN_ID.pem and $CHEF_ORG-validator.pem are copied"
echo "from chef server to ~/.chef directory"
echo ''
echo 'Please also run "knife ssl fetch" to pull chef automate server ssl cert'
echo ''
echo "Script will automatically reboot server now"
read -p "Press Enter to reboot, CTRL-C to abort reboot" REBOOT
shutdown -r now
