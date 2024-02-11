# Version 20240210
#
version='20240210'
#
# This script updates .bashrc, /etc/hosts, and enables cert based ssh auth prior to chef installs
#
echo 'RUN THIS SCRIPT ON ALL CHEF WORKSTATIONS, CHEF SERVERS and CHEF NODES BEFORE RUNNING OTHER CHEF SCRIPTS FROM (mdb)'
echo "Version = $version"
echo ''
if [ ! -d ~/temp ]; then mkdir ~/temp ; fi ; cd ~/temp

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
echo "CHEF_WORKSTATION_NAME='mike-mint'"            >> ~/.chefparams
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
echo "CHEF_ORG='chef-demo'"                         >> ~/.chefparams
echo "export CHEF_ORG"                              >> ~/.chefparams
echo "CHEF_ORG_LONG='Chef Demo Organization'"       >> ~/.chefparams
echo "export CHEF_ORG_LONG"                         >> ~/.chefparams
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
if [ "$HN" = "$CHEF_WORKSTATION_NAME" ]; then 
  echo "# BELOW WILL ADJUST PATH for CHEF"          >> ~/.chefparams
  echo "PATH=$CHEF_WORKSTATION_PATH"                >> ~/.chefparams
  echo "export PATH"                                >> ~/.chefparams
fi

# ADD CHEF PARAMETERS TO ~/.bashrc FILE
grep -v -i 'chefparams' ~/.bashrc > ~/bashrc ; echo ". ~/.chefparams" >> ~/bashrc ; cp ~/bashrc ~/.bashrc ; rm ~/bashrc

# LOAD PARAMETERS
. ~/.chefparams

echo ''
echo "ADDING DATA TO HOSTS FILE (/etc/hosts)"
# UPDATE HOSTS FILE
grep -i -v "$CHEF_WORKSTATION_IP" /etc/hosts | grep -i -v "$CHEF_SERVER_IP" | grep -i -v "$CHEF_NODE1_IP" | grep -i -v "$CHEF_NODE2_IP" | grep -i -v "# CHEF INFO" > ~/hosts
cat >> "~/hosts" << EOF
# CHEF INFO
$CHEF_WORKSTATION_IP  $CHEF_WORKSTATION_NAME  $CHEF_WORKSTATION_NAME.$CHEF_DOMAINNAME
$CHEF_SERVER_IP  $CHEF_SERVER_NAME  $CHEF_SERVER_NAME.$CHEF_DOMAINNAME
$CHEF_NODE1_IP  $CHEF_NODE1_NAME  $CHEF_NODE1_NAME.$CHEF_DOMAINNAME
$CHEF_NODE2_IP  $CHEF_NODE2_NAME  $CHEF_NODE2_NAME.$CHEF_DOMAINNAME
EOF
echo "Copying file ./hosts to /etc/hosts"
sudo cp ~/hosts /etc/hosts ; rm ~/hosts
cd ~ 

# ENABLE SSH CERT BASED LOGIN
echo "BUILDING AND DISTRIBUTING .ssh KNOWN HOSTS (known_hosts) AND AUTHORIZED KEYS (authorized_keys) FILES."
#
if [ ! -d ~/.ssh ] ; then 
  echo ''
  echo "CREATING KEYPAIR FOR SSH. (you may be asked for input)"
  ssh-keygen -b 4092 -f ~/.ssh/id_rsa -N '' 
fi
#
echo ''
echo 'CREATING AUTHORIZED KEYS FILE (authorized_keys)'
cp ~/.ssh/id_rsa.pem ~/.ssh/authorized_keys
#
echo ''
echo 'CREATING KNOWN HOSTS FILE (known_hosts)'
rm -f ~/known_hosts
if ping -c 1 $CHEF_WORKSTATION_IP &> /dev/null ; then echo ''; echo "Collecting host cert data for $CHEF_WORKSTATION_NAME"; `ssh-keyscan -H $CHEF_WORKSTATION_NAME > ~/known_hosts` ; `ssh-keyscan -H $CHEF_WORKSTATION_IP >> ~/known_hosts`  ; else echo "$CHEF_WORKSTATION_IP not found on network"; fi
if ping -c 1 $CHEF_SERVER_IP      &> /dev/null ; then echo ''; echo "Collecting host cert data for $CHEF_SERVER_NAME"; `ssh-keyscan -H $CHEF_SERVER_NAME     >> ~/known_hosts` ; `ssh-keyscan -H $CHEF_SERVER_IP      >> ~/known_hosts` ; else echo "$CHEF_SERVER_IP not found on network"; fi
if ping -c 1 $CHEF_NODE1_IP       &> /dev/null ; then echo ''; echo "Collecting host cert data for $CHEF_NODE1_NAME"; `ssh-keyscan -H $CHEF_NODE1_NAME      >> ~/known_hosts` ; `ssh-keyscan -H $CHEF_NODE1_IP       >> ~/known_hosts` ; else echo "$CHEF_NODE1_IP not found on network"; fi
if ping -c 1 $CHEF_NODE2_IP       &> /dev/null ; then echo ''; echo "Collecting host cert data for $CHEF_NODE2_NAME"; `ssh-keyscan -H $CHEF_NODE2_NAME      >> ~/known_hosts` ; `ssh-keyscan -H $CHEF_NODE2_IP       >> ~/known_hosts` ; else echo "$CHEF_NODE2_IP not found on network"; fi
cp -f ~/known_hosts ~/.ssh/known_hosts; rm ~/known_hosts
#
echo ''
echo 'DISTRIBUTING ALL FILES IN ~/.ssh TO ALL CHEF SERVERS AND CHEF NODES'
if ping -c 1 $CHEF_SERVER_IP &> /dev/null ; then echo ''; echo "Copying .ssh data to $CHEF_SERVER_NAME" ; scp ~/.ssh/* $CHEF_ADMIN_ID@$CHEF_SERVER_IP:/home/$CHEF_ADMIN_ID/.ssh/; fi
if ping -c 1 $CHEF_NODE1_IP  &> /dev/null ; then echo ''; echo "Copying .ssh data to $CHEF_NODE1_NAME"  ; scp ~/.ssh/* $CHEF_ADMIN_ID@$CHEF_NODE1_IP:/home/$CHEF_ADMIN_ID/.ssh/;  fi
if ping -c 1 $CHEF_NODE2_IP  &> /dev/null ; then echo ''; echo "Copying .ssh data to $CHEF_NODE2_NAME"  ; scp ~/.ssh/* $CHEF_ADMIN_ID@$CHEF_NODE2_IP:/home/$CHEF_ADMIN_ID/.ssh/;  fi

# ADD DEPENDENT PACKAGES
#
echo ''; echo "INSTALLING COMMON DEPENDENT APPLICATIONS"
# Install curl
if [ ! command -v curl ]; then
  echo ''; echo "INSTALLING curl"
  sudo apt install curl -y
fi
# Restrict curl to tls v1.2 and newer
if [ -f ~/.curlrc ];  then
  echo ''; echo "CONFIGURING ~/.curl"
  echo '--tlsv1.2' | tee -a ~/.curlrc
else
  echo '--tlsv1.2' > ~/.curlrc
fi
# Install tree
if [ ! command -v tree ]; then
  echo ''; echo "INSTALLING tree"
  sudo apt install tree -y
fi
# Install gzip
if [ ! command -v gzip ]; then
  echo ''; echo "INSTALLING gzip"
  sudo apt install gzip -y
fi
# ADD PACKAGES IF NODE IP = CHEF WORKSTATION OR CHEF SERVER
#
if test `hostname -i | cut -d ' ' -f 1 | cut -d '.' -f1` = '127' ; then myip=`hostname -i | cut -d ' ' -f 2` ; fi
doit=0
if test "$myip" = "$CHEF_WORKSTATION_IP"; then echo ''; echo "SCRIPT RUNNING ON CHEF WORKSTATION" ; doit=1; fi
if test "$myip" = "$CHEF_SERVER_IP"; then echo ''; echo "SCRIPT RUNNING ON CHEF SERVER" ; doit=1; fi
#
if test "$doit" = "1"; then
  # Install Microsoft Visual Studio Code
  if [ ! command -v code ]; then
    echo ''; echo "INSTALLING Microsoft Visual Studio Code"
    sudo wget -O 'code.deb' 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
    sudo dpkg -i code.deb
  fi

fi


# END OF SCRIPT
