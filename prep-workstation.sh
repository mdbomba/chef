# version='20240317'
#
CHEF_GIT_USER='mbomba'
CHEF_GIT_EMAIL='mbomba@kemptechnologies.com'
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
