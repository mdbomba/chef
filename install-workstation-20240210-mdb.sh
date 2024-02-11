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

#################
# LOAD PARAMETERS
#################
if test -f ~/.bshrc; then source ~/.bashrc; fi
if test -f ~/.chefparams; then source ~/.chefparams; fi
if test "x$CHEF_ADMIN_ID" = 'x'; then $CHEF_ADMIN_ID='mike'; fi
if test "x$CHEF_ORG" = 'x'; then $CHEF_ORG='chef-demo'; fi
if test "x$CHEF_SERVER_NAME" = 'x'; then $CHEF_SERVER_NAME='chef-automate'; fi
if test "x$URL_WORKSTATION" = 'x'; then $URL_WORKSTATION='https://packages.chef.io/files/stable/chef-workstation/23.12.1055/ubuntu/22.04/chef-workstation_23.12.1055-1_amd64.deb' ; fi
PKG="chef-workstation.deb"

cd ~

##########################
# INSTALL Chef Workstation
##########################
if ! test `command -v chef`; then
  sudo wget -o "$PKG" "$URL_WORKSTATION"        ; # Download Chef Workstation package
  sudo dpkg -i "$PKG"                           ; # Install Chef Workstation
  sudo rm -f $PKG                               ; # Cleanup files
fi


#################################
# COLLECT CHEF SERVER CREDENTIALS
#################################
echo '############################################################################'
echo '# DOWNLOAD CHEF INFRA SERVER ADMIN ACCOUNT PEM FILE '
echo '############################################################################'
echo ''

if ! test -d ~/.chef; then mkdir ~/.chef; fi

cd ~/.chef
if ! test -f "$HOME/.chef/$CHEF_ADMIN_ID.pem"
  then
    echo "Copying $CHEF_ADMIN_ID.pem file from $CHEF_SERVER_NAME using account $CHEF_ADMIN_ID. Enter associated password with prompted for it."
    scp "$CHEF_ADMIN_ID@$CHEF_SERVER_NAME:/home/$CHEF_ADMIN_ID/$CHEF_ADMIN_ID.pem"      ~/.chef/$CHEF_ADMIN_ID.pem
    scp "$CHEF_ADMIN_ID@$CHEF_SERVER_NAME:/home/$CHEF_ADMIN_ID/$CHEF_ORG-validator.pem" ~/.chef/$CHEF_ORG-validator.pem
fi

########################
# CREATE FIRST CHEF REPO
########################
echo '############################################################################'
echo "# CREATE CHEF REPO (chef generate repo $CHEF_GIT_REPO) "
echo '############################################################################'
echo ''
if ! test -d ~/$CHEF_ORG; then chef generate repo "$CHEF_ORG"; fi

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
echo "chef_server_url = ""'""https://$CHEF_SERVER_NAME/organizations/$CHEF_ORG""'"      >> ~/.chef/credentials
echo ''
echo 'CONTENTS OF ~/.chef/crefentials FILE ARE BELOW'
echo ''
cat ~/.chef/credentials
echo ''

################################
# CREATE CONFIG FILE (config.rb)
################################
echo '############################################################################'
echo '# UPDATE / REPLACE (~/.chef/config.rb)'
echo '############################################################################'
echo ''
echo 'current_dir = File.dirname(__FILE__)'                                         >  ~/.chef/config.rb
echo "log_level        :info"                                                       >> ~/.chef/config.rb
echo "log_location     STDOUT"                                                      >> ~/.chef/config.rb
echo "node_name        ""'""$CHEF_ADMIN_ID""'"                                      >> ~/.chef/config.rb
echo "client_key       ""'""$HOME/.chef/$CHEF_ADMIN_ID.pem""'"                      >> ~/.chef/config.rb
echo "chef_server_url  ""'""https://$CHEF_SERVER_NAME/organizations/$CHEF_ORG""'"   >> ~/.chef/config.rb
echo "cookbook_path     ""'""$HOME/$CHEF_ORG/cookbooks""'"                          >> ~/.chef/config.rb

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


















chef generate repo "$CHEF_ORG"



# CREATE .chef directory if it does not exist
if ! test -d ~/.chef; then 
  mkdir ~/.chef
fi

#CREATE config.rb in ~/.chef if it does not exist
if ! test -f ~/.chef/config.rb; then


fi

# CREATE credentials file in ~/.chef if it does not exist
if ! test -f ~/.chef/credentials; then



fi



echo ''
echo '#######################################################'
echo "Chef Workstation has been installed"
echo "Please exit and reopen bash shell"
echo 'This will refresh the $PATH environmental variable'
echo '#######################################################'
echo ''
read -p "Press any key to continue" newValue

exit

