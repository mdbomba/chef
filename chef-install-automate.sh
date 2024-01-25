# Version 20214-01-24
# Install Automate Package on dedicated server
version='2024-01-24'
echo ''
echo '######################################################################'
echo 'This script Chef Automare, Chef Inspec Server and Chef Habitat Builder'
echo "On a single server name = $CHEF_AUTOMATE_NAME IP = CHEF_AUTOMATE_IP"
echo "Version = $version"
echo '######################################################################'
echo ''

cd ~

STAMP=$(date +"_%Y%j%H%M%S")

# PROMPT FOR PASSWORD TO RUN sudo COMMAND
if [ "x$PASSWORD" = "x" ] 
  then
    newValue=''
    echo 'We will be running the sudo command multiple times'
    read -p  "Enter password for sudo command user ($USER): " newValue
    PASSWORD="$newValue"
fi

# CHECK AND LOAD PASSWORD IF NOT ALREADY DEFINED
if [ "x$CHEF_ADMIN_PASSWORD" = "x" ] 
  then
    newValue=''
    echo 'Chef Server created user accounts seperate from the linux OS accounts'
    read -p  "Enter password for Chef Admin Account ($CHEF_ADMIN_ID): " newValue
    CHEF_ADMIN_PASSWORD="$newValue"
fi

# Set hostname
sudo -S <<< $PASSWORD hostnamectl set-hostname "$CHEF_AUTOMATE_NAME"

# Update hosts file (not needed if DNS holds these values)

sudo -S <<< $PASSWORD cp /etc/hosts "/etc/hosts$STAMP"
if ! grep -q "$CHEF_WORKSTATION_IP" /etc/hosts 
  then 
    echo "$CHEF_WORKSTATION_IP  $CHEF_WORKSTATION_NAME $CHEF_WORKSTATION_NAME.$CHEF_DOMAINNAME" | sudo -S <<< $PASSWORD tee -a /etc/hosts
fi

if ! grep -q "$CHEF_AUTOMATE_IP" /etc/hosts
  then
    echo "$CHEF_AUTOMATE_IP  $CHEF_AUTOMATE_NAME $CHEF_AUTOMATE_NAME.$CHEF_DOMAINNAME" | sudo -S <<< $PASSWORD tee -a /etc/hosts
fi

if ! grep -q "$CHEF_NODE1_IP" /etc/hosts
  then
    echo "$CHEF_NODE1_IP  $CHEF_NODE1_NAME $CHEF_NODE1_NAME.$CHEF_DOMAINNAME" | sudo -S <<< $PASSWORD tee -a /etc/hosts
fi

# Install curl and wget
sudo -S <<< $PASSWORD apt install curl wget -y

# Configure curl to use tls1.2 or higher
if [ -f ~/.curlrc ]
  then
    echo '--tls1.2' | tee -a ~/.curlrc
  else
    echo '--tls1.2' > ~/.curlrc
fi

# Install tree command (ls -lr) with basic graphics
sudo -S <<< $PASSWORD apt install tree -y

# Install gzip
sudo -S <<< $PASSWORD apt install gzip -y

# Install git
sudo -S <<< $PASSWORD apt install git -y

# Configure git
git config --global user.name "$CHEF_GIT_USER"
git config --global user.email "$CHEF_GIT_EMAIL"

###### STARTING CHEF AUTOMATE INSTALL ######

# Update system settings needed for Chef Server
sudo -S <<< $PASSWORD sysctl -w vm.max_map_count=262144
sudo -S <<< $PASSWORD sysctl -w vm.dirty_expire_centisecs=20000
sudo -S <<< $PASSWORD cp /etc/sysctl.conf "/etc/sysctl.conf$STAMP"
echo 'sysctl -w vm.max_map_count=262144'         | sudo -S <<< $PASSWORD tee -a /etc/sysctl.conf
echo 'sysctl -w vm.dirty_expire_centisecs=20000' | sudo -S <<< $PASSWORD tee -a /etc/sysctl.conf

# Download Chef Automate installer
curl "$CHEF_AUTOMATE_DOWNLOAD_URL" | gunzip - > chef-automate && chmod +x chef-automate

# Initialize automate installer
sudo -S <<< $PASSWORD ./chef-automate init-config

# Install builder, automate and infra server 
sudo -S <<< $PASSWORD ./chef-automate deploy --product builder --product automate --product infra-server

if [ -f "./$CHEF_ADMIN_ID.pem" ]
  then
    :
  else
  sudo -S <<< $PASSWORD chef-server-ctl user-create "$CHEF_ADMIN_ID" "$CHEF_ADMIN_FIRST" "$CHEF_ADMIN_LAST" "$CHEF_ADMIN_EMAIL" "$CHEF_ADMIN_PASSWORD" --filename "$CHEF_ADMIN_ID.pem"
fi

if [ -f "./$CHEF_ORG-validator.pem" ]
  then
    :
  else
    sudo -S <<< $PASSWORD chef-server-ctl org-create "$CHEF_ORG" "$CHEF_ORG_LONG" --association_user "$CHED_ADMIN_ID" --filename "$CHEF_ORG-validator.pem"
fi

echo ''
echo '##############################################################################'
echo "Chef Server has been installed including Automate, Inspec, and Habitat Builder"
echo "Please exit and reopen bash shell"
echo '##############################################################################'
echo ''
read -p "Press any key to continue" newValue

exit
