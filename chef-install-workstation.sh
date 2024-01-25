# Version 2024-01-08-10:07
# Install Chef Workstation on dedicated server
version='2024-01-24'
echo ''
echo '#####################################################################'
echo 'This script will install git, Visual Studio code and Chef Workstation'
echo "Version = $version"
echo '#####################################################################'
echo ''
STAMP=$(date +"_%Y%j%H%M%S")
DEB=$(echo $CHEF_WORKSTATION_DOWNLOAD_URL | cut -d '/' -f 10)

# CHECK AND LOAD PASSWORD IF NOT ALREADY DEFINED
if [ "x$CHEF_ADMIN_PASSWORD" = "x" ] 
  then
    newValue=''
    read -p  "Enter password for Chef Admin Account ($CHEF_ADMIN_ID): " newValue
    CHEF_ADMIN_PASSWORD="$newValue"
fi

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

# Install curl
sudo apt install curl -y

# Configure curl to use TLS1.2 or higher
if [ -f ~/.curlrc ]
  then
    echo '--tls1.2' | tee -a ~/.curlrc
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

sudo apt update

# Download Chef Workstation deb install package
sudo wget "$CHEF_WORKSTATION_DOWNLOAD_URL"                                   ; # Download Chef Workstation package

# Install Chef Workstation
sudo dpkg -i "$DEB"                                                          ; # Install Chef Workstation

# Create git repo for Chef Workstation
chef generate GIT_REPO "$CHEF_GIT_REPO"                                           ; # Create first chef GIT_REPO 

echo ".chef" > "$HOME/$CHEF_GIT_REPO/.gitignore"                                  ; # Ensure git processes does not sync 

echo 'export PATH="/opt/chef-workstation/embedded/bin:$PATH"' >> ~/.bashrc   ; # Ensure bash PATH is updated permanently

source ~/.bashrc                                                             ; # Import new PATH into current bash session

echo ''
echo '#######################################################'
echo "Chef Workstation has been installed"
echo "Please exit and reopen bash shell"
echo 'This will refresh the $PATH environmental variable'
echo '#######################################################'
echo ''
read -p "Press any key to continue" newValue

exit

