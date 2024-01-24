# Version 20214-01-12
# Install Automate Package on dedicated server

GIT_USER='mdbomba'
GIT_EMAIL='mbomba@kemptechnologies.com'
STAMP=$(date +"_%Y%j%H%M%S")
WORKSTATION_IP='10.0.0.6'
WORKSTATION_NAME='chef-workstation'
AUTOMATE_IP='10.0.0.7'
AUTOMATE_NAME='chef-automate'
URL='https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip'

sudo hostnamectl set-hostname "$AUTOMATE_NAME"

if ! grep -q "$WORKSTATION_IP" /etc/hosts 
  then 
    sudo echo "$WORKSTATION_IP  $WORKSTATION_NAME" | sudo tee -a /etc/hosts
fi


if ! grep -q "$AUTOMATE_IP" /etc/hosts
  then
    sudo echo "$AUTOMATE_IP  $AUTOMATE_NAME" | sudo tee -a /etc/hosts
 fi

sudo apt install curl -y

if [ -f ~/.curlrc ]
  then
    echo '--tls1.2' | tee -a ~/.curlrc
  else
    echo '--tls1.2' > ~/.curlrc
fi

sudo apt install tree -y

sudo apt install gzip -y

sudo apt install git -y

git config --global user.name "$GIT_USER"

git config --global user.email "$GIT_EMAIL"

sudo apt install software-properties-common apt-transport-https wget -y

###### STARTING CHEF AUTOMATE INSTALL ######

sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w vm.dirty_expire_centisecs=20000
sudo cp /etc/sysctl.conf "/etc/sysctl.conf$STAMP"
echo 'sysctl -w vm.max_map_count=262144'         | sudo tee -a /etc/sysctl.conf
echo 'sysctl -w vm.dirty_expire_centisecs=20000' | sudo tee -a /etc/sysctl.conf

sudo curl "$URL" | sudo gunzip - > chef-automate && sudo chmod +x chef-automate
sudo ./chef-automate init-config 
sudo ./chef-automate deploy --product builder --product automate --product infra-server

USER_NAME='mike'
FIRST_NAME='Mike'
LAST_NAME='Bomba'
EMAIL='mike.bomba@progress.com'
PASSWORD='Kemp1fourall'
FULL_ORGANIZATION_NAME='test demo site'
SHORT_NAME='test-demo'
ORGANIZATION='test-demo'
if [ -f "./$USER_NAME.pem" ]
  then
    :
  else
  sudo chef-server-ctl user-create "$USER_NAME" "$FIRST_NAME" "$LAST_NAME" "$EMAIL" "$PASSWORD" --filename "$USER_NAME.pem"
fi

if [ -f "./$ORGANIZATION-validator.pem" ]
  then
    :
  else
    sudo chef-server-ctl org-create "$SHORT_NAME" "$FULL_ORGANIZATION_NAME" --association_user "$USER_NAME" --filename "$ORGANIZATION-validator.pem"
fi


