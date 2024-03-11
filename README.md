This repo will hold work related to automating the installation of Chef Workstation and Chef Server. 

Chef Server installs will use the Chef Automate process (download chef-automate installer and use the -products 
command line options to include Chef Infra Server, Chef Habitat Builder and Chef Automate Server. 

Install scripts are written to use the apt installer on Ubuntu and tested on Ubuntu 22 and Mint 21.

Step 1 Build servers: 
    1 x Ubuntu 20 server (100G disk, 8G ram, 4cores) for Chef Server (automate + infra + habitat + inspec)
    1 x Ubuntu 20 workstation (20G disk, 4G ram, 2cores) for Chef Workstation 
    2 x Ubuntu 20 server (20G disk, 4G ram, 2cores) for Chef Linux Nodes
Step 2 Add chef-server, chef-workstation, and chef-node(s) to /etc/hosts and/or to DNS
Step 3 Download this repo to the server and workstation
Step 3 Edit each install=???? scrips to properly set parameters
Step 5 Run install-server.sh on Ubuntu server
Step 6 Run install-workstation.sh on Ubuntu workstation (workstation needs a graplical user interface)
Step 7 Run install-node.sh on Chef Nodes (managed endpoints)
