# Version 20240211
# Install Chef Workstation on dedicated UBUNTU 22.04 server
# !!! Currently only works with an ubuntu 22.04 server baseline !!!
#
version='20240211'
STAMP=$(date +"_%Y%j%H%M%S")
echo ''
echo '#####################################################################'
echo 'INSTALL CHEF WORKSTATION'
echo "Version = $version"
echo '#####################################################################'
echo ''

##################
# LOAD PARAM FILES
##################
if test -f ~/.bshrc; then source ~/.bashrc; fi
if test -f ~/.chefparams; then . ~/.chefparams; fi

##############################
# VERIFY & SET CRITICAL PARAMS
##############################
if test "x$CHEF_ADMIN_ID" = 'x'; then $CHEF_ADMIN_ID='mike'; fi
if test "x$CHEF_ORG" = 'x'; then $CHEF_ORG='chef-demo'; fi
if test "x$CHEF_REPO" = "x"; then $CHEF_REPO='chef-repo'; fi
if test "x$CHEF_SERVER_NAME" = 'x'; then $CHEF_SERVER_NAME='chef-automate'; fi

PKG_NAME="chef-workstation.deb"
PKG_URL=https://packages.chef.io/files/stable/chef-workstation/23.12.1055/ubuntu/22.04/chef-workstation_23.12.1055-1_amd64.deb

cd ~

##########################
# INSTALL Chef Workstation
##########################
if ! test `command -v chef`; then
  sudo wget -O "$PKG_NAME" "$PKG_URL"        ; # Download Chef Workstation package
  sudo dpkg -i "$PKG_NAME"                   ; # Install Chef Workstation
  sudo rm -f $PKG_NAME                       ; # Cleanup files
fi

echo 'eval "$(chef shell-init bash)"' >> ~/.bashrc
echo 'eval "$(chef shell-init bash)"' >> ~/.chefparams

. ~/.bashrc
. ~/.chefparams

########################
# CREATE FIRST CHEF REPO
########################
echo '############################################################################'
echo "# CREATE CHEF REPO (chef generate repo $CHEF_GIT_REPO) "
echo '############################################################################'
echo ''
if ! test -d ~/$CHEF_REPO; then 
  chef generate repo "$CHEF_REPO" --chef-license 'accept'
  knife configure --admin-client-name "$CHEF_ADMIN_ID" --server-url "https://$CHEF_SERVER_NAME.$CHEF_DOMAINNAME/organizations/$CHEF_ORG" --admin-client-key "/home/$CHEF_ADMIN_ID/.chef/$CHEF_ADMIN_ID.pem" --user "$CHEF_ADMIN_ID"
fi



#################################
# COLLECT CHEF SERVER CREDENTIALS
#################################
echo '############################################################################'
echo '# DOWNLOAD CHEF INFRA SERVER ADMIN ACCOUNT PEM FILE '
echo '############################################################################'
echo ''
cd ~/.chef
if ! test -f "$HOME/.chef/$CHEF_ADMIN_ID.pem"
  then
    echo "Copying $CHEF_ADMIN_ID.pem file from $CHEF_SERVER_NAME using account $CHEF_ADMIN_ID. Enter associated password with prompted for it."
    scp "$CHEF_ADMIN_ID@$CHEF_SERVER_NAME:/home/$CHEF_ADMIN_ID/$CHEF_ADMIN_ID.pem"      ~/.chef/$CHEF_ADMIN_ID.pem
    scp "$CHEF_ADMIN_ID@$CHEF_SERVER_NAME:/home/$CHEF_ADMIN_ID/$CHEF_ORG-validator.pem" ~/.chef/$CHEF_ORG-validator.pem
fi


#########################
# CREATE CREDENTIALS FILE
#########################
echo '############################################################################'
echo '# UPDATE / REPLACE  (~/.chef/credentials file) '
echo '############################################################################'
echo ''
echo '[default]'                                                                        >  ~/.chef/credentials
echo "client_name     = ""'""$CHEF_ADMIN_ID""'"                                         >> ~/.chef/credentials
echo "client_key      = ""'""$HOME/.chef/$CHEF_ADMIN_ID.pem""'"                         >> ~/.chef/credentials
echo "chef_server_url = ""'""https://$CHEF_SERVER_NAME/organizations/$CHEF_REPO""'"     >> ~/.chef/credentials
echo ''
echo 'CONTENTS OF ~/.chef/crefentials FILE ARE BELOW'
echo ''
cat ~/.chef/credentials
echo ''

################################
# CREATE CONFIG FILE (config.rb)
################################
#
# current_dir = File.dirname(__FILE__)
# log_level                :info
# log_location             STDOUT
# node_name                "hshefu"
# client_key               "#{current_dir}/hshefu.pem"
# chef_server_url          "https://api.chef.io/organizations/4thcafe-web-team"
# cookbook_path            ["#{current_dir}/../cookbooks"]

echo '############################################################################'
echo '# UPDATE / REPLACE (~/.chef/config.rb)'
echo '############################################################################'
echo ''
echo 'current_dir = File.dirname(__FILE__)'                                                          >  ~/.chef/config.rb
echo "log_level        :info"                                                                        >> ~/.chef/config.rb
echo "log_location     STDOUT"                                                                       >> ~/.chef/config.rb
echo "node_name        ""'""$CHEF_ADMIN_ID""'"                                                       >> ~/.chef/config.rb
echo "client_key       ""'""/home/$CHEF_ADMIN_ID/.chef/$CHEF_ADMIN_ID.pem""'"                        >> ~/.chef/config.rb
echo "chef_server_url  ""'""https://$CHEF_SERVER_NAME.$CHEF_DOMAINNAME/organizations/$CHEF_ORG""'"   >> ~/.chef/config.rb
echo "cookbook_path    ""'""/home/$CHEF_ADMIN_ID/$CHEF_REPO/cookbooks""'"                           >> ~/.chef/config.rb

echo "CONTENTS OF CONFIG FILE (config.rb) ARE BELOW"
echo ''
cat config.rb
echo ''

echo '############################################################################'
echo '# TEST COMMUNICATIONS (knife client list) '
echo '############################################################################'
echo ''

echo "Testing communications using knife client list"

knife client list

echo ''
echo '#######################################################'
echo "Chef Workstation has been installed"
echo "Please exit and reopen bash shell"
echo 'This will refresh the $PATH environmental variable'
echo '#######################################################'
echo ''
read -p "Press any key to continue" newValue

exit

