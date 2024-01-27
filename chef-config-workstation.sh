# Version 2024-01-26
# Iniital Config for Chef Workstation on dedicated server
version='2024-01-26'
echo ''
echo '##############################################################################'
echo 'This script will do initial configuation on newly installed Chef Workstation  '
echo "Version = $version"
echo '##############################################################################'
echo ''


echo '############################################################################'
echo '# CREATE ~/.chef/config.rb'
echo '############################################################################'
echo ''

cd ~/.chef

echo 'current_dir = File.dirname(__FILE__)'                                         >  config.rb
echo "log_level        :info"                                                       >> config.rb
echo "log_location     STDOUT"                                                      >> config.rb
echo "node_name        ""'""$CHEF_ADMIN_ID""'"                                      >> config.rb
echo "client_key       ""'""$HOME/.chef/$CHEF_ADMIN_ID.pem""'"                      >> config.rb
echo "chef_server_url  ""'""https://$CHEF_SERVER_NAME/organizations/$CHEF_ORG""'"   >> config.rb
echo 'cookbook_path    ["#{current_dir}/../cookbooks"]'                             >> config.rb

echo "cat config.rb"
echo ''
cat config.rb
echo ''

echo '############################################################################'
echo '# DOWNLOAD CHEF INFRA SERVER ADMIN ACCOUNT PEM FILE '
echo '############################################################################'
echo ''

cd "$HOME/.chef"
if [ -f "$HOME/.chef/$CHEF_ADMIN_ID.pem" ]
  then
    :
  else
    echo "Copying $CHEF_ADMIN_ID.pem file from $CHEF_SERVER_NAME using account $CHEF_ADMIN_ID. Enter associated password with prompted for it."
    scp "$CHEF_ADMIN_ID@$CHEF_SERVER_NAME:/home/$CHEF_ADMIN_ID/$CHEF_ADMIN_ID.pem" .
fi

echo '############################################################################'
echo "# CREATE FIRST CHEF REPO (chef generate repo $CHEF_GIT_REPO) "
echo '############################################################################'
echo ''

chef generate repo "$CHEF_GIT_REPO"

echo '############################################################################'
echo '# CREATE CREDENTIALS FILE (knife configure) '
echo '############################################################################'
echo ''

knife configure 

echo '############################################################################'
echo '# UPDATE / REPLACE  (~/.chef/credentials file) '
echo '############################################################################'
echo ''

echo '[default]'                                                                        >  credentials
echo "client_name     = ""'""$CHEF_ADMIN_ID""'"                                         >> credentials
echo "client_key      = ""'""$HOME/.chef/$CHEF_ADMIN_ID.pem""'"                         >> credentials
echo "chef_server_url = ""'""https://$CHEF_SERVER_NAME/organizations/$CHEF_ORG""'"      >> credentials


echo '############################################################################'
echo '# TEST COMMUNICATIONS (knife client list) '
echo '############################################################################'
echo ''

echo "Testing communications using knife client list"

knife client list

echo '############################################################################'
echo '# FETCHING CHEF SERVER CERTIFICATE (knife ssl fetch)  '
echo '############################################################################'
echo ''

knife ssl fetch











