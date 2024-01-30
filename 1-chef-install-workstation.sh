# Version 20240129
# Install Chef Workstation on dedicated server
version='20240129'
echo ''
echo '#####################################################################'
echo 'This script will install Chef Workstation'
echo "Script Version = $version"
echo '#####################################################################'
echo ''

cd ~

STAMP=$(date +"_%Y%j%H%M%S")
URL="https://packages.chef.io/files/stable/chef-workstation/21.10.640/ubuntu/20.04/chef-workstation_21.10.640-1_amd64.deb"
DEB='./chef-workstation_21.10.640-1_amd64.deb'

# SET HOSTNAME
sudo hostnamectl set-hostname "$CHEF_WORKSTATION_NAME.$CHEF_DOMAINNAME"
sudo echo "$CHEF_WORKSTATION_NAME.$CHEF_DOMAINNAME" > /etc/hostname

# Adjust $PATH and make change permanent
export PATH="/opt/chef-workstation/bin:/opt/chef-workstation/embedded/bin:$PATH" 
echo 'export PATH="/opt/chef-workstation/bin:/opt/chef-workstation/embedded/bin:$PATH"' >> ~/.bashrc

# Import new PATH into current bash session
source ~/.bashrc

# Download Chef Workstation deb install package
sudo wget "$URL"

# Install Chef Workstation
sudo dpkg -i "$DEB"

echo ''
echo '#######################################################'
echo "Chef Workstation has been installed"
echo "Please exit and reopen bash shell"
echo 'This will refresh the $PATH environmental variable'
echo '#######################################################'
echo ''
read -p "Press any key to continue" newValue

exit

