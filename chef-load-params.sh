# Version 20240121
#
chef-load-params-version='20240121'
#
# This script loads environmental variables related to Chef
#
echo ''
echo '##############################################################################################################'
echo 'This script will prompt for and load environmental variables related to the insallation and operations of Chef'
echo "Version = $load-params-version"
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
      newValue=$2
  fi
  export $1=$newValue
  sed "/$1/d" ~/.bashrc | tee ~/out1 >>/dev/null; cp ~/out1 ~/.bashrc
  echo "export $1=""'""$newValue""'" >> ~/.bashrc
  echo "$1=""'""$newValue""'"
}

# ENTER ENVIRONMENTAL VARIABLES FOR CHEF INSTALLATION (saves to ~/.bashrc)
echo ''
echo '#######################################################'
echo "Below is a list of Chef Environmental Variables"
echo '#######################################################'
echo ''
loadEnvironment 'CHEF_ADMIN_ID' 'mike'                          ; # Collect Chef admin login id
loadEnvironment 'CHEF_ADMIN_FIRST' 'Mike'                       ; # Collect Chef admin first name
loadEnvironment 'CHEF_ADMIN_LAST' 'Bomba'                       ; # Collect Chef admin last name
loadEnvironment 'CHEF_ADMIN_EMAIL' 'mike.bomba@progress.com'    ; # Collect Chef admin email
loadEnvironment 'CHEF_DOMAINNAME' 'localhost'                   ; # Collect domain name for Chef environment
loadEnvironment 'CHEF_WORKSTATION_NAME' 'chef-workstation'      ; # Collect Chef Workstation name (lowercase)
loadEnvironment 'CHEF_WORKSTATION_IP' '10.0.0.5'                ; # Collect Chef Workstation IP address
loadEnvironment 'CHEF_SERVER_NAME' 'chef-automate'              ; # Collect Chef Server Name (lowercase)
loadEnvironment 'CHEF_SERVER_IP' '10.0.0.6'                     ; # Collect Chef Server IP address
loadEnvironment 'CHEF_NODE1_NAME' 'chef-node1'                  ; # Collect Chef Node 1 Name
loadEnvironment 'CHEF_NODE1_IP' '10.0.0.7'                      ; # Collect Chef Node 1 IP address
loadEnvironment 'CHEF_ORG' 'chef-demo'                          ; # Collect Chef Organization short name (lowercase)
loadEnvironment 'CHEF_ORG_LONG' 'Chef Demo Organization'        ; # Collect Chef Organization long name
loadEnvironment 'CHEF_ADMIN_PASSWORD' 'ChedDemoPass'            ; # Collect password for Chef Admin account (if left blank the install script for workstation/automate will prompt for value)
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


