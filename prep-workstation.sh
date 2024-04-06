# version='20240406'
#

#############
# PARAMETERS
#############
CHEF_GIT_USER='mdbomba'
CHEF_GIT_EMAIL='mbomba@kemptechnologies.com'

###################
# PARAMETER CHECK
##################
echo ''
echo 'SCRIPT TO INSTALL PACKAGES CHEF WORKSTATION DEPENDS ON'
echo 'SCRIPT IS INTENDED TO BE EDITED AND PROPER PARAMETERS ENTERED BEFORE RUNNING'
echo 'PARAMETERS CURRENTLY CONFIGURED IN SCRIPT'
echo "    CHEF_GIT_USER = $CHEF_GIT_USER"
echo "    CHEF_GIT_EMAIL = $CHEF_GIT_EMAIL"
read -p "Press any key to continue, CTRL-C to abort and edit values: " YN

#####################################
# START LOAD APPLICATIONS SECTION
#####################################
sudo apt install curl -y
sudo apt remove apparmor -y
sudo apt install git -y
git config --global user.name "$CHEF_GIT_USER"
git config --global user.email "$CHEF_GIT_EMAIL"
sudo apt install tree -y
sudo apt install gzip -y
sudo apt install openssh-server -y
sudo apt install wget -y
sudo apt install software-properties-common -y
sudo apt install apt-transport-https -y
wget -O 'code.deb' 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
sudo dpkg -i code.deb; rm code.deb
#sudo apt install vagrant -y
#####################################
# END LOAD APPLICATIONS SECTION
#####################################
#
echo ''
echo '##################################################'
echo '#                                                #'
echo '#    ALL APP DEPENDNECIES HAVE NOW BEEN MET      #'
echo '#                                                #'
echo '##################################################'
