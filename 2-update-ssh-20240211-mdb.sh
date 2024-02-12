# Version 20240211
#
version='20240211'
#
# This script enables cert based ssh auth prior to chef installs
#
echo 'RUN THIS SCRIPT ON ALL CHEF WORKSTATIONS TO UPDATE SSH KEYS ON ALL CHEF COMPONENTS'
echo "Version = $version"
echo ''

cd ~

# ENABLE SSH CERT BASED LOGIN
echo ''; echo "CREATING .ssh FILES (id_rsa, id_rsa.pub)"
if ! test -f ~/.ssh/id_rsa; then 
  echo ''; echo "CREATING .ssh FILES (id_rsa, id_rsa.pub)"
  ssh-keygen -b 4092 -f ~/.ssh/id_rsa -N '' 
fi
echo ''
echo 'CREATING .ssh FILE (authorized_keys)'
cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys

# UPDATING KNOWN HOSTS FILE ~/.ssh/known_hosts
echo ''; echo 'CREATING .ssh FILE (known_hosts)'; rm -f ~/known_hosts
if ping -c 1 $CHEF_WORKSTATION_IP &> /dev/null ; then 
  echo ''; echo "COLLECTING CERTIFICATE INFO FOR $CHEF_WORKSTATION_NAME"
  `ssh-keyscan -H $CHEF_WORKSTATION_NAME 			>  ~/known_hosts`
  `ssh-keyscan -H $CHEF_WORKSTATION_NAME.$CHEF_DOMAINNAME 	>> ~/known_hosts`
  `ssh-keyscan -H $CHEF_WORKSTATION_IP 				>> ~/known_hosts`
else echo "$CHEF_WORKSTATION_IP not found on network"
fi

if ping -c 1 $CHEF_SERVER_IP &> /dev/null ; then 
  echo ''; echo "COLLECTING CERTIFICATE INFO FOR $CHEF_SERVER_NAME"
  `ssh-keyscan -H $CHEF_SERVER_NAME     			>> ~/known_hosts`
  `ssh-keyscan -H $CHEF_SERVER_NAME.$CHEF_DOMAINNAME     	>> ~/known_hosts`
  `ssh-keyscan -H $CHEF_SERVER_IP     				>> ~/known_hosts`
else echo "$CHEF_SERVER_IP not found on network"
fi

if ping -c 1 $CHEF_NODE1_IP &> /dev/null ; then 
  echo ''; echo "COLLECTING CERTIFICATE INFO FOR $CHEF_NODE1_NAME"
  `ssh-keyscan -H $CHEF_NODE1_NAME      			>> ~/known_hosts`
  `ssh-keyscan -H $CHEF_NODE1_NAME.$CHEF_DOMAINNAME      	>> ~/known_hosts`
  `ssh-keyscan -H $CHEF_NODE1_IP       				>> ~/known_hosts`
else echo "$CHEF_NODE1_IP not found on network"
fi

if ping -c 1 $CHEF_NODE2_IP &> /dev/null ; then 
  echo ''; echo "COLLECTING CERTIFICATE INFO FOR $CHEF_NODE2_NAME"
  `ssh-keyscan -H $CHEF_NODE2_NAME      			>> ~/known_hosts`
  `ssh-keyscan -H $CHEF_NODE2_NAME.$CHEF_DOMAINNAME      	>> ~/known_hosts`
  `ssh-keyscan -H $CHEF_NODE2_IP       				>> ~/known_hosts`
else echo "$CHEF_NODE2_IP not found on network"
fi

cp -f ~/known_hosts ~/.ssh/known_hosts; rm ~/known_hosts

# COPYING .ssh FILES TO ALL CHEF COMPONENTS
echo ''; echo 'DISTRIBUTING ALL FILES IN ~/.ssh TO ALL CHEF SERVERS AND CHEF NODES'
if ping -c 1 $CHEF_SERVER_IP &> /dev/null ; then echo ''; echo "ENTER PASSWORD FOR LOGIN TO $CHEF_SERVER_NAME" ; scp ~/.ssh/* $CHEF_ADMIN_ID@$CHEF_SERVER_IP:/home/$CHEF_ADMIN_ID/.ssh/; fi
if ping -c 1 $CHEF_NODE1_IP  &> /dev/null ; then echo ''; echo "ENTER PASSWORD FOR LOGIN TO $CHEF_NODE1_NAME"  ; scp ~/.ssh/* $CHEF_ADMIN_ID@$CHEF_NODE1_IP:/home/$CHEF_ADMIN_ID/.ssh/;  fi
if ping -c 1 $CHEF_NODE2_IP  &> /dev/null ; then echo ''; echo "ENTER PASSWORD FOR LOGIN TO $CHEF_NODE2_NAME"  ; scp ~/.ssh/* $CHEF_ADMIN_ID@$CHEF_NODE2_IP:/home/$CHEF_ADMIN_ID/.ssh/;  fi


echo ''
echo 'To complete installation, use one of the following scripts'
echo '    - install-server             (this will install Chef Automate + Infra Server + Insec Server + Habitat Builder)'
echo '    - install-workstation        (this will install Chef Workstation)' 
echo '    - install client             (this will install Chef Client software on a node to be managed - i.e. a Chef Node)'

# END OF SCRIPT
