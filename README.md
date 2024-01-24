This repo will hold work related to automating the installation of Chef Workstation and Chef Server. 

Chef Server installs will use the Chef Automate process (download chef-automate installer and use the -products 
command line options to include Chef Infra Server, Chef Habitat Builder and Chef Automate Server. 

Install scripts are written to use the apt installer on Ubuntu and tested on Ubuntu 22 and Mint 21.

There are many methods to install chef, the scripts in this repo will use an overall process of creating 
environmental variables (appended to ~/.bashrc) that can then we used in various config files that chef 
normally reads (e.g. config.toml). They will aslo be used in the chef-install-workstation.sh and chef-install-automate.sh 
scripts. 

It is recommended you create or have available a github account before running the install scripts. 
