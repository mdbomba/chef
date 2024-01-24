# Version 2024-01-08-10:07
# Install Chef Workstation on dedicated server

GIT_USER='mdbomba'
GIT_EMAIL='mbomba@kemptechnologies.com'
REPO='chef_demo'
NAME='chef-workstation'
URL="https://packages.chef.io/files/stable/chef-workstation/21.10.640/ubuntu/20.04/chef-workstation_21.10.640-1_amd64.deb"
DEB=$(echo $URL | cut -d '/' -f 10)
STAMP=$(date +"_%Y%j%H%M%S")
WORKSTATION_IP='10.0.0.6'
WORKSTATION_NAME='chef-workstation'
AUTOMATE_IP='10.0.0.7'
AUTOMATE_NAME='chef-automate'

sudo hostnamectl set-hostname "$WORKSTATION_NAME"

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
    echo "################################## ADDING VISUAL STUDIO CODE REPOSITORY TO APT STORE ###########################"
    echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
fi

sudo apt install code -y                                                     ; # Install Visual Studio Code

sudo apt update

sudo wget "$URL"                                                             ; # Download Chef Workstation package

sudo dpkg -i "$DEB"                                                          ; # Install Chef Workstation

chef generate repo "$REPO"                                                   ; # Create first chef repo 

echo ".chef" > "$HOME/$REPO/.gitignore"                                      ; # Ensure git processes does not sync 

echo 'export PATH="/opt/chef-workstation/embedded/bin:$PATH"' >> ~/.bashrc   ; # Ensure bash PATH is updated permanently

source ~/.bashrc                                                             ; # Import new PATH into current bash session


