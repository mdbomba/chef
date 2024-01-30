# Version 20240129
#
version='20240129'
#
# This script loads environmental variables related to Chef
#
echo 'This script will prompt for and load environmental variables related to the insallation and operations of Chef'
echo "Version = $version"
echo ''
#
STAMP=$(date +"_%Y%j%H%M%S")
#
# Create function to set environment variables for Chef installs
# usage is  $ loadEnvironment 'variablename' 'value'
#
loadEnvironment() { 
newalue=''  
if [ "x$1" = "x" ] || [ "x$2" = 'x' ]
  then 
    echo "function loadEnvironment requires 2 arguments"
    echo "Example is  $  loadEnvironment 'CHEF_ADMIN_ID' 'mike' "
    return
  else 
    OUT="$HOME/OUT$STAMP"
    newValue=$2
    export $1=$newValue
    sed "/$1/d" ~/.bashrc | tee "$OUT" >>/dev/null; cp "$OUT" ~/.bashrc; rm "$OUT"
    echo "export $1=""'""$newValue""'" >> ~/.bashrc
    echo "$1=""'""$newValue""'"
fi
}

#
# Create function to update /etc/hosts file with chef componnets
# usage is  $ loadHost 'ip address' 'hostname' 'domainname'
#
loadHost() {
if [ "x$1" = "x" ] || [ "x$2" = 'x' ] || [ "x$3" = "x" ]
  then 
    echo "function loadHost requires 3 arguments" 
    echo "usage is  $ loadHost 'ip address' 'hostname' 'domainname'"
     return
  else 
    if ! grep -q "$1" /etc/hosts 
      then 
        sudo echo "$1  $2 $2.$3" | sudo tee -a /etc/hosts
    fi
fi
}

# ENTER ENVIRONMENTAL VARIABLES FOR CHEF INSTALLATION (saves to ~/.bashrc)
echo '###############################################'
echo "Below is a list of Chef Environmental Variables"
echo '###############################################'
echo ''
loadEnvironment 'CHEF_ORG' 'chef-demo'                          ; # Collect Chef Organization short name (lowercase)
loadEnvironment 'CHEF_ORG_LONG' 'Chef Demo Organization'        ; # Collect Chef Organization long name
loadEnvironment 'CHEF_DOMAINNAME' 'localhost'                   ; # Collect domain name for Chef environment

loadEnvironment 'CHEF_ADMIN_ID' 'mike'                          ; # Collect Chef admin login id
loadEnvironment 'CHEF_ADMIN_FIRST' 'Mike'                       ; # Collect Chef admin first name
loadEnvironment 'CHEF_ADMIN_LAST' 'Bomba'                       ; # Collect Chef admin last name
loadEnvironment 'CHEF_ADMIN_EMAIL' 'mike.bomba@progress.com'    ; # Collect Chef admin email

loadEnvironment 'CHEF_WORKSTATION_NAME' 'chef-workstation'      ; # Collect Chef Workstation name (lowercase)
loadEnvironment 'CHEF_WORKSTATION_IP' '10.0.0.5'                ; # Collect Chef Workstation IP address

loadEnvironment 'CHEF_INFRA_NAME' 'chef-automate'               ; # Collect Chef Infra Server Name (lowercase)
loadEnvironment 'CHEF_INFRA_IP' '10.0.0.6'                      ; # Collect Chef Infra Server IP address

loadEnvironment 'CHEF_AUTOMATE_NAME' 'chef-automate'            ; # Collect Chef Automate Server Name (lowercase)
loadEnvironment 'CHEF_AUTOMATE_IP' '10.0.0.7'                   ; # Collect Chef Automate Server IP address

loadEnvironment 'CHEF_NODE1_NAME' 'chef-node1'                  ; # Collect Chef Node 1 Name
loadEnvironment 'CHEF_NODE1_IP' '10.0.0.8'                      ; # Collect Chef Node 1 IP address

loadEnvironment 'CHEF_NODE2_NAME' 'chef-node2'                  ; # Collect Chef Node 2 Name
loadEnvironment 'CHEF_NODE2_IP' '10.0.0.9'                      ; # Collect Chef Node 2 IP address

. ~/.bashrc

# need to update /etc/hosts to add all above names and IP addresses
sudo cp /etc/hosts "/etc/hosts$STAMP"
loadHost "$CHEF_WORKSTATION_IP" "$CHEF_WORKSTATION_NAME" "$CHEF_DOMAINNAME"
loadHost "$CHEF_INFRA_IP" "$CHEF_INFRA_NAME" "$CHEF_DOMAINNAME"
loadHost "$CHEF_AUTOMATE_IP" "$CHEF_AUTOMATE_NAME" "$CHEF_DOMAINNAME"
loadHost "$CHEF_NODE1_IP" "$CHEF_NODE1_NAME" "$CHEF_DOMAINNAME"
loadHost "$CHEF_NODE2_IP" "$CHEF_NODE2_NAME" "$CHEF_DOMAINNAME"

# apparmor can cause issues with Chef Server(s), so below will remove apparmor
sudo apt remove apparmor -y

# git is used for most chef components
sudo apt install git -y
git config --global user.name "$CHEF_GIT_USER"
git config --global user.email "$CHEF_GIT_EMAIL"

# curl is used across all chef components
sudo apt install curl -y
sed '/tls1.2/d' ~/.curlrc > ~/.curlrc
sed '/insecure/d' ~/.curlrc > ~/.curlrc
echo "--tls1.2" >> ~/.curlrc
echo '--insecure' >> ~/.curlrc

# Install tree (pretty version of "ls -lr" command )
sudo apt install tree -y

# Install gzip
sudo apt install gzip -y

# Ensure openssh-server is installed
sudo git install openssh-server -y

# Install additional tools
sudo apt install software-properties-common apt-transport-https wget -y

# Add Repo for Microsoft Visual Studio Code
if [ ! -f /usr/share/keyrings/vscode.gpg ]
  then
    echo "################### GET CODE SIGNING KEY FOR VISUAL STUDIO CODE ############################"
    sudo wget -O- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg
fi

if [ ! -f /etc/apt/sources.list.d/vscode.list ]
  then
    echo "################################## ADDING VISUAL STUDIO CODE GIT_REPOSITORY TO APT STORE ###########################"
    echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list
fi

# Install Visual Studio Code
sudo apt update
sudo apt install code -y



