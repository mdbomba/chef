# Version 20240211
#
version='20240211'
#
# This script updates .bashrc, /etc/hosts, and enables cert based ssh auth prior to chef installs
#
echo 'RUN THIS SCRIPT ON ALL CHEF WORKSTATIONS, CHEF SERVERS and CHEF NODES BEFORE RUNNING OTHER CHEF SCRIPTS FROM (mdb)'
echo "Version = $version"
echo ''

cd ~

CHEF_WORKSTATION_PATH='/opt/chef-workstation/bin:/home/mike/.chefdk/gem/ruby/3.0.0/bin:/opt/chef-workstation/embedded/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/opt/chef-workstation/gitbin'

# CREATE CHEF PARAMETERS FILE ~/.chefparamsrc
echo 'CREATING CHEF PARAMETERS FILE ~/.chefparams TO BE USED BY ALL OTHER CHEF SCRIPTS'
echo '# FOLLOWING IS ADDED BY CHEF INSTALL SCRITS'  > ~/.chefparams
echo '# BELOW GLOBAL VARIABLES ARE CALLED BY OTHER CHEF SCRIPTS' >> ~/.chefparams
echo "CHEF_ADMIN_ID='mike'"                         >> ~/.chefparams
echo "export CHEF_ADMIN_ID"                         >> ~/.chefparams
echo "CHEF_ADMIN_FIRST='Mike'"                      >> ~/.chefparams
echo "export CHEF_ADMIN_FIRST"                      >> ~/.chefparams
echo "CHEF_ADMIN_LAST='Bomba'"                      >> ~/.chefparams
echo "export CHEF_ADMIN_LAST"                       >> ~/.chefparams
echo "CHEF_ADMIN_EMAIL='mike.bomba@progress.com'"   >> ~/.chefparams
echo "export CHEF_ADMIN_EMAIL"                      >> ~/.chefparams
echo "CHEF_DOMAINNAME='localhost'"                  >> ~/.chefparams
echo "export CHEF_DOMAINNAME"                       >> ~/.chefparams
echo "CHEF_WORKSTATION_NAME='chef-workstation'"     >> ~/.chefparams
echo "export CHEF_WORKSTATION_NAME"                 >> ~/.chefparams
echo "CHEF_WORKSTATION_IP='192.168.56.1'"           >> ~/.chefparams
echo "export CHEF_WORKSTATION_IP"                   >> ~/.chefparams
echo "CHEF_SERVER_NAME='chef-automate'"             >> ~/.chefparams
echo "export CHEF_SERVER_NAME"                      >> ~/.chefparams
echo "CHEF_SERVER_IP='192.168.56.5'"                >> ~/.chefparams
echo "export CHEF_SERVER_IP"                        >> ~/.chefparams
echo "CHEF_NODE1_NAME='chef-node1'"                 >> ~/.chefparams
echo "export CHEF_NODE1_NAME"                       >> ~/.chefparams
echo "CHEF_NODE1_IP='192.168.56.6'"                 >> ~/.chefparams
echo "export CHEF_NODE1_IP"                         >> ~/.chefparams
echo "CHEF_NODE2_NAME='chef-node2'"                 >> ~/.chefparams
echo "export CHEF_NODE2_NAME"                       >> ~/.chefparams
echo "CHEF_NODE2_IP='192.168.56.7'"                 >> ~/.chefparams
echo "export CHEF_NODE2_IP"                         >> ~/.chefparams
echo "CHEF_REPO='chef-repo'"                         >> ~/.chefparams
echo "export CHEF_REPO"                              >> ~/.chefparams
echo "CHEF_ORG='chef-demo'"                         >> ~/.chefparams
echo "export CHEF_ORG"                              >> ~/.chefparams
echo "CHEF_ORG_LONG='Chef Demo Organization'"       >> ~/.chefparams
echo "export CHEF_ORG_LONG"                         >> ~/.chefparams
echo "CHEF_GIT_USER='mdbomba'"                      >> ~/.chefparams
echo "export CHEF_GIT_USER"                         >> ~/.chefparams
echo "CHEF_GIT_EMAIL='mbomba@kemptechnologies.com'" >> ~/.chefparams
echo "export CHEF_GIT_EMAIL"                        >> ~/.chefparams
echo '# URL TO DOWNLOAD Chef Workstation deb file'  >> ~/.chefparams
echo "URL_WORKSTATION='https://packages.chef.io/files/stable/chef-workstation/23.12.1055/ubuntu/22.04/chef-workstation_23.12.1055-1_amd64.deb'"    >> ~/.chefparams
echo "export URL_WORKSTATION"                       >> ~/.chefparams
echo '# URL TO DOWNLOAD Chef Server deb file'       >> ~/.chefparams
echo "URL_SERVER='https://packages.chef.io/files/stable/chef-server-core/15.9.20/ubuntu/22.04/chef-server-core_15.9.20-1_amd64.deb'"   >> ~/.chefparams
echo "export URL_SERVER"                            >> ~/.chefparams
echo "# URL TO DOWNLOAD Chef Client deb file"       >> ~/.chefparams
echo "URL_CLIENT='https://packages.chef.io/files/stable/chef/18.4.2/ubuntu/22.04/chef_18.4.2-1_amd64.deb'"  >> ~/.chefparams
echo "export URL_CLIENT"                            >> ~/.chefparams
echo "# URL TO DOWNLOAD Chef Automate installer executable"     >> ~/.chefparams
echo "URL_AUTOMATE='https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip'"  >> ~/.chefparams
echo "export URL_AUTOMATE"                          >> ~/.chefparams
echo '# URL TO DOWNLOAD Chef install.sh'            >> ~/.chefparams
echo "URL_INSTALL='https://omnitruck.chef.io/install.sh'"   >> ~/.chefparams
echo "export URL_INSTALL"                           >> ~/.chefparams
. ~/.chefparams

# UPATE PATH for CHEF_WORKSTATION ONLY 
HN=`hostname -s`
if test "$HN" = "$CHEF_WORKSTATION_NAME"; then 
  echo "# BELOW WILL ADJUST PATH for CHEF"          >> ~/.chefparams
  echo "PATH=$CHEF_WORKSTATION_PATH"                >> ~/.chefparams
  echo "export PATH"                                >> ~/.chefparams
fi

# ADD CHEF PARAMETERS TO ~/.bashrc FILE
grep -v -i 'chefparams' ~/.bashrc > ~/bashrc ; echo ". ~/.chefparams" >> ~/bashrc ; cp ~/bashrc ~/.bashrc

# LOAD PARAMETERS
. ~/.chefparams

# UPDATE HOSTS FILE
cd ~
echo ''
echo "ADDING DATA TO HOSTS FILE (/etc/hosts)"
grep -i -v "$CHEF_WORKSTATION_IP" /etc/hosts | grep -i -v "$CHEF_SERVER_IP" | grep -i -v "$CHEF_NODE1_IP" | grep -i -v "$CHEF_NODE2_IP" | grep -i -v "# CHEF INFO" > ~/hosts
cat >> "hosts" << EOF
# CHEF INFO
$CHEF_WORKSTATION_IP  $CHEF_WORKSTATION_NAME  $CHEF_WORKSTATION_NAME.$CHEF_DOMAINNAME
$CHEF_SERVER_IP  $CHEF_SERVER_NAME  $CHEF_SERVER_NAME.$CHEF_DOMAINNAME
$CHEF_NODE1_IP  $CHEF_NODE1_NAME  $CHEF_NODE1_NAME.$CHEF_DOMAINNAME
$CHEF_NODE2_IP  $CHEF_NODE2_NAME  $CHEF_NODE2_NAME.$CHEF_DOMAINNAME
EOF
echo "Copying file hosts to /etc/hosts"
cat hosts | sudo tee /etc/hosts 

# ADDING DOMAINNAME TO HOSTNAME
fqdn="`hostname -s`.localhost"
sudo hostname $fqdn
echo ''
echo "UPDATING /etc/hostname TO INCLUDE DOMAIN NAME ($fqdn)"
echo ''
echo 'CONTENTS OF /etc/hostname'
echo $fqdn | sudo tee /etc/hostname

########################
# ADD DEPENDENT PACKAGES
########################
echo ''; echo "INSTALLING COMMON DEPENDENT APPLICATIONS"

# Install or update openssh-server
echo ''; echo "INSTALLING OR UPDATING openssh-server"; sudo apt install openssh-server

# Install or update curl
echo ''; echo "INSTALLING or UPDATING curl"; sudo apt install curl -y; echo '--tlsv1.2' | tee -a ~/.curlrc >> /dev/null

# Install or update tree
echo ''; echo "INSTALLING or UPDATING tree"; sudo apt install tree -y

# Install gzip
echo ''; echo "INSTALLING or UPDATING gzip"; sudo apt install gzip -y

# Install or update git
echo ''; echo "INSTALLING or UPDATING git"; sudo apt install git -y; git config --global user.name "$CHEF_GIT_USER"; git config --global user.email "$CHEF_GIT_EMAIL"

# Install or update wget
echo ''; echo "INSTALLING or Updating wget"; sudo apt install wget -y

# Install or update software-properties-common
echo ''; echo "INSTALLING or UPDATING software-properties-common"; sudo apt install software-properties-common -y

# Install additional tools
echo ''; echo 'INSTALLING or UPDATING apt-transport-https'; sudo apt install apt-transport-https -y

# Install Microsoft Visual Studio code (use firefox test to ensure this is a workstation and not a server)
if test `command -v firefox`; then
  echo ''; echo "INSTALLING or UPDATING Microsoft Vistual Studio Code";
  if ! test `command -v code`; then 
    sudo wget -O 'code.deb' 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
    sudo dpkg -i code.deb
  fi
fi

# END OF SCRIPT
