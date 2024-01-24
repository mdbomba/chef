# Version 20240121
#
chef-load-params-version='20240121'
#
# This script loads environmental variables related to Chef
#
echo 'This script will prompt for and load environmental variables related to the insallation and operations of Chef'
echo "Version = $load-params-version"
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
echo '###############################################'
echo "Below is a list of Chef Environmental Variables"
echo '###############################################'
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

newValue=''
read -p  "Enter password for Chef Admin Account ($CHEF_ADMIN_ID): " newValue
export CHEF_ADMIN_PASSWORD=$newValue
sed "/CHEF_ADMIN_PASSWORD/d" ~/.bashrc | tee ~/out1 >> /dev/null ; cp ~/out1 ~/.bashrc
echo "export CHEF_ADMIN_PASSWORD=""'""$newValue""'" >> ~/.bashrc

. ~/.bashrc


