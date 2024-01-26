# Version 2024-01-25
#
version='2024-01-25'
#
# This script loads environmental variables related to Chef
#
echo ''
echo '##############################################################################################################'
echo 'This script will prompt for and load environmental variables related to the insallation and operations of Chef'
echo "Version = $version"
echo '##############################################################################################################'
echo ''
#
# Create function to set environment variables for Chef installs
# usage is  $ loadEnvironment 'variablename' 'value'
#
loadEnvironment() { 
  if [ "x$1" = "x" ] || [ "x$2" = 'x' ]
    then 
      echo "function loadEnvironment requires 2 arguments"
      echo "Example is  $  loadEnvironment 'CHEF_ADMIN_ID' 'mike' "
      return
    else 
      export $1=$2
      sed "/$1/d" ~/.bashrc | tee ~/out1 >>/dev/null; cp ~/out1 ~/.bashrc
      echo "export $1=""'""$2""'" >> ~/.bashrc
      echo "$1=""'""$2""'"
  fi
}

# ENTER ENVIRONMENTAL VARIABLES FOR CHEF INSTALLATION (saves to ~/.bashrc)
echo ''
echo '#######################################################'
echo "Below is a list of Chef Environmental Variables"
echo '#######################################################'
echo ''

loadEnvironment 'CHEF_DOMAINNAME' 'localhost'                    ; # Collect domain name for Chef environment

loadEnvironment 'CHEF_ORG' 'chef-demo'                          ; # Collect Chef Organization short name (lowercase)
loadEnvironment 'CHEF_ORG_LONG' 'Chef Demo Organization'        ; # Collect Chef Organization long name

loadEnvironment 'CHEF_ADMIN_ID' 'mike'                          ; # Collect Chef admin login id (chef server will create a name.pem file for auth related to this user)
loadEnvironment 'CHEF_ADMIN_FIRST' 'Mike'                       ; # Collect Chef admin first name
loadEnvironment 'CHEF_ADMIN_LAST' 'Bomba'                       ; # Collect Chef admin last name
loadEnvironment 'CHEF_ADMIN_EMAIL' 'mike.bomba@progress.com'    ; # Collect Chef admin email

loadEnvironment 'CHEF_WORKSTATION_NAME' 'mike-mint'             ; # Collect Chef Workstation name (lowercase)
loadEnvironment 'CHEF_WORKSTATION_IP' '192.168.56.1'            ; # Collect Chef Workstation IP address
loadEnvironment 'CHEF_WORKSTATION_ADMIN' 'mike'                 ; # Collect Chef Workstation Admin User ID
# loadEnvironment 'CHEF_WORKSTATION_PASSWORD' ''                  ; # Collect Chef Workstation Admin User Password (if empty, chef-install-workstation.sh will prompt for value)

loadEnvironment 'CHEF_SERVER_NAME' 'chef-automate'              ; # Collect Chef Server Name (lowercase)
loadEnvironment 'CHEF_SERVER_IP' '192.168.56.5'                 ; # Collect Chef Server IP address
loadEnvironment 'CHEF_SERVER_ADMIN' 'mike'                      ; # Collect Chef Server Admin User ID
# loadEnvironment 'CHEF_SERVER_PASSWORD' ''                       ; # Collect Chef Server Admin User Password (if left empty, chef-install-automate.sh will prompt for value)

loadEnvironment 'CHEF_NODE1_NAME' 'chef-node1'                  ; # Collect Chef Node 1 Name
loadEnvironment 'CHEF_NODE1_IP' '192.168.56.6'                  ; # Collect Chef Node 1 IP address (used by knife command)
loadEnvironment 'CHEF_NODE1_ADMIN' 'mike'                       ; # Collect Chef Node 1 Name (used by knife command)
# loadEnvironment 'CHEF_NODE1_PASSWORD' ''                        ; # Collect Chef Node 1 Admin User ID (used by knife command) (if left empty, chef-bootstrap.sh will prompt for value)

loadEnvironment 'CHEF_NODE2_NAME' 'chef-node2'                  ; # Collect Chef Node 2 Admin User Password (used by knife command)
loadEnvironment 'CHEF_NODE2_IP' '192.168.56.7'                  ; # Collect Chef Node 2 IP address
loadEnvironment 'CHEF_NODE2_ADMIN' 'mike'                       ; # Collect Chef Node 2 Admin User ID
# loadEnvironment 'CHEF_NODE2_PASSWORD' ''                        ; # Collect Chef Node 2 Admin User Password (used by knfe command) (if left empty, chef-bootstrap.sh will prompt for value)
    
loadEnvironment "CHEF_GIT_EMAIL" "mbomba@kemptechnologies.com"  ; # Collect info to configure git on Chef Workstation
loadEnvironment 'CHEF_GIT_USER' 'mdbomba'                       ; # Collect info to configure git on Chef Workstation
loadEnvironment 'CHEF_GIT_REPO' 'chef-demo'                     ; # Collect info to configure git on Chef Workstation

loadEnvironment 'CHEF_WORKSTATION_DOWNLOAD_URL' "https://packages.chef.io/files/stable/chef-workstation/21.10.640/ubuntu/20.04/chef-workstation_21.10.640-1_amd64.deb"
loadEnvironment 'CHEF_AUTOMATE_DOWNLOAD_URL' 'https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip'

export CHEF_ADMIN_PASSWORD=$newValue
# sed "/CHEF_ADMIN_PASSWORD/d" ~/.bashrc | tee ~/out1 >> /dev/null ; cp ~/out1 ~/.bashrc
# echo "export CHEF_ADMIN_PASSWORD=""'""$newValue""'" >> ~/.bashrc

. ~/.bashrc

echo ''
echo '#######################################################'
echo "Parameters have been loaded into ~/.bashrc "
echo "Please exit and reopen bash shell"
echo 'Parameters will be available as environmental variables'
echo '#######################################################'
echo ''
read -p "Press any key to continue" newValue

exit


