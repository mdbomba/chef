This repo will hold work related to automating the installation of Chef Workstation and Chef Server. 

Chef Server installs will use the Chef Automate process (download chef-automate installer and use the -products 
command line options to include Chef Infra Server, Chef Habitat Builder and Chef Automate Server. 

Install scripts are written to use the apt installer on Ubuntu and tested on Ubuntu 22 and Mint 21.

There are many methods to install chef, the scripts in this repo will use an overall process of creating 
environmental variables (creating a ~/.chefparams file and appending it to ~/.bashrc) that can then we used in various config files that chef 
normally reads (e.g. config.toml). They will aslo be used in the chef-install-workstation.sh and chef-install-automate.sh 
scripts. 

It is recommended you download install.sh from https://omnitruck.chef.io/install.sh (e.g. wget -o "install.sh" https://omnitruck.chef.io/install.sh)

It is recommended you create or have available a github account before running the install scripts. 

Step 1 Build 2 x Ubuntu 22 server and 1 x Ubuntu 22 workstation
Step 2 Download this repo to the server and workstation
Step 3 Edit the prep.sh script to set values for your organization (on both server and workstation)
Step 4 Run prep.sh script on chef workstation, chef server, and optionally on chef nodes.
Step 5 Run install-server.sh on Ubuntu server
Step 6 Run install-workstation.sh on Ubuntu workstation (workstation needs a graplical user interface)
Step 7 Run install-node.sh on Chef Nodes (managed endpoints)
