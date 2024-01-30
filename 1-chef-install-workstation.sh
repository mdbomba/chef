# Version 20240129
# Install Chef Workstation on dedicated server
version='20240129'
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
sudo hostnamectl set-hostname "$CHEF_WORKSTATION_NAME.$CHEF_DOMAINNAME"
sudo echo "$CHEF_WORKSTATION_NAME.$CHEF_DOMAINNAME" > /etc/hostname

# Adjust $PATH and make change permanent
export PATH="/opt/chef-workstation/bin:/opt/chef-workstation/embedded/bin:$PATH" 
echo 'export PATH="/opt/chef-workstation/bin:/opt/chef-workstation/embedded/bin:$PATH"' >> ~/.bashrc

source ~/.bashrc                                                             ; # Import new PATH into current bash session

# Download Chef Workstation deb install package
sudo wget "$CHEF_WORKSTATION_DOWNLOAD_URL"                                   ; # Download Chef Workstation package

# Install Chef Workstation
sudo dpkg -i "$DEB"                                                          ; # Install Chef Workstation

echo ''
echo '#######################################################'
echo "Chef Workstation has been installed"
echo "Please exit and reopen bash shell"
echo 'This will refresh the $PATH environmental variable'
echo '#######################################################'
echo ''
read -p "Press any key to continue" newValue

exit

