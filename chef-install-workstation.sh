# Version 2024-01-25
# Install Chef Workstation on dedicated server
version='2024-01-25'
echo ''
echo '#####################################################################'
echo 'This script will install git, Visual Studio code and Chef Workstation'
echo "Version = $version"
echo '#####################################################################'
echo ''

cd ~

STAMP=$(date +"_%Y%j%H%M%S")
DEB=$(echo $CHEF_WORKSTATION_DOWNLOAD_URL | cut -d '/' -f 10)

# SET HOSTNAME
sudo hostnamectl set-hostname "$CHEF_WORKSTATION_NAME"

# UPDATE HOSTS FILE (not needed if you put this into a DNS server)
sudo cp /etc/hosts "/etc/hosts$STAMP"
if ! grep -q "$CHEF_WORKSTATION_IP" /etc/hosts 
  then 
    sudo echo "$CHEF_WORKSTATION_IP  $CHEF_WORKSTATION_NAME $CHEF_WORKSTATION_NAME.$CHEF_DOMAINNAME" | sudo tee -a /etc/hosts
fi

if ! grep -q "$CHEF_AUTOMATE_IP" /etc/hosts
  then
    sudo echo "$CHEF_AUTOMATE_IP  $CHEF_AUTOMATE_NAME $CHEF_AUTOMATE_NAME.$CHEF_DOMAINNAME" | sudo tee -a /etc/hosts
fi

if ! grep -q "$CHEF_NODE1_IP" /etc/hosts
  then
    sudo echo "$CHEF_NODE1_IP  $CHEF_NODE1_NAME $CHEF_NODE1_NAME.$CHEF_DOMAINNAME" | sudo tee -a /etc/hosts
fi
echo ''

# Adjust $PATH and make change permanent
export PATH="/opt/chef-workstation/bin:/opt/chef-workstation/embedded/bin:$PATH" 
echo 'export PATH="/opt/chef-workstation/bin:/opt/chef-workstation/embedded/bin:$PATH"' >> ~/.bashrc   ; # Ensure bash PATH is updated permanently

# Install curl
sudo apt install curl -y

# Configure curl to use TLS1.2 or higher
if [ -f ~/.curlrc ]
  then
    if ! grep -q "tls1.2" ~/.curlrc
      then 
        echo '--tls1.2' | tee -a ~/.curlrc
    fi        
  else
    echo '--tls1.2' > ~/.curlrc
fi

# Install tree (pretty version of "ls -lr" command )
sudo apt install tree -y

# Install gzip
sudo apt install gzip -y

# Install git
sudo apt install git -y

# Congigure git
git config --global user.name "$CHEF_GIT_USER"

git config --global user.email "$CHEF_GIT_EMAIL"

# Ensure openssh-server is installed
sudo git install openssh-server

# Install additional tools
sudo apt install software-properties-common apt-transport-https wget -y

# Add Repo for Microsoft Visual Studio Code
if [ -f /usr/share/keyrings/vscode.gpg ]
  then
    :
  else
    echo "################### GET CODE SIGNING KEY FOR VISUAL STUDIO CODE ############################"
    sudo wget -O- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg
fi

if [ -f /etc/apt/sources.list.d/vscode.list ]
  then
    :
  else
    echo "################################## ADDING VISUAL STUDIO CODE GIT_REPOSITORY TO APT STORE ###########################"
    echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/GIT_REPOs/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
fi

# Install Visual Studio Code
sudo apt install code -y                                                     ; # Install Visual Studio Code

source ~/.bashrc                                                             ; # Import new PATH into current bash session

# Download Chef Workstation deb install package
sudo wget "$CHEF_WORKSTATION_DOWNLOAD_URL"                                   ; # Download Chef Workstation package

# Install Chef Workstation
sudo dpkg -i "$DEB"                                                          ; # Install Chef Workstation

# Create git repo for Chef Workstation
chef generate repo "$CHEF_GIT_REPO"                                           ; # Create first chef GIT_REPO 

echo ''
echo '#######################################################'
echo "Chef Workstation has been installed"
echo "Please exit and reopen bash shell"
echo 'This will refresh the $PATH environmental variable'
echo '#######################################################'
echo ''
read -p "Press any key to continue" newValue

exit

