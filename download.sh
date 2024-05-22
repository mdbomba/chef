#!/bin/bash
# Version 20240522
# Author Mike Bomba
# 
# Script downloads chef install files for ubuntu and redhat based distros only
#

##############
# Data input section
##############
platform=''
while ! [[ "$platform" =~ ^(ubuntu|redhat)$ ]]; do read -p "Enter Distro Name (ubuntu, redhat): " platform; done

platform_version=''
if [ "$platform" == "ubuntu" ]; then while ! [[ "$platform_version" =~ ^(22|20|18)$ ]]; do read -p "Enter ubuntu Distro major version number (22, 20, 18): " platform_version; done; fi
if [ "$platform" == "redhat" ]; then while ! [[ "$platform_version" =~ ^(9|8|7)$ ]]; do read -p "Enter redhat Distro major version number (9, 8, 7): " platform_version; done; fi

project=''
while ! [[ "$project" =~ ^(chef|chef-workstation|chef-server|automate|inspec|supermarket)$ ]]; do read -p "Enter chef product (chef, chef-workstation, chef-server, automate, inspec, supermarket): " project; done

channel=''
while ! [[ "$channel" =~ ^(current|stable)$ ]]; do read -p "Enter chef product channel (current, stable): " channel; done

############
# End of data input section
############

# Assign a download directory
tmp_dir="." 

# If tmp_dir does not exist, create it
if ! test -d $tmp_dir; then mkdir $tmp_dir; chmod 777 $tmp_dir; fi


# normalize the architecture we detected
machine=`uname -m`
case $machine in
  "arm64"|"aarch64")
    machine="aarch64"
    ;;
  "x86_64"|"amd64"|"x64")
    machine="x86_64"
    ;;
  "i386"|"i86pc"|"x86"|"i686")
    machine="i386"
    ;;
  "sparc"|"sun4u"|"sun4v")
    machine="sparc"
    ;;
esac

os=`uname -s`


############
# Chef Automate Download
############
if [ "$project" = "automate" ]; then
  download_filename="$tmp_dir/chef-automate"
  download_url="https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip"
  curl -A "User-Agent: mixlib-install/3.12.30" --retry 5 -sL "${download_url}" | gunzip - > "$download_filename" && chmod +x "$download_filename"
  wget --user-agent="User-Agent: mixlib-install/3.12.30" -O "automate_`date -I`.aib" https://packages.chef.io/airgap_bundle/current/automate/latest.aib
  echo ""
  echo "######################"
  echo "     END OF SCRIPT    "
  echo "######################"
  echo ''
  ls -l
  exit
fi
############
# end Chef Automate Download
############

############
# Fetch metadata (url, sha256hash)
############
metadata_filename="$tmp_dir/metadata.txt"
metadata_url="https://omnitruck.chef.io/$channel/$project/metadata?v=$version&p=$platform&pv=$platform_version&m=$machine"
wget --user-agent="User-Agent: mixlib-install/3.12.30" -O "$metadata_filename" "$metadata_url"
echo ''
echo 'METADATA FETCH RESULTS'
echo '#############################################################'
echo ''
cat $metadata_filename
echo ''
echo '###############################################################'
echo ''
############
# end Fetch metadata
############

############
# Validate metadata
############
download_url=`cat $metadata_filename | grep -i 'url' | cut -f 2`
sha256=`cat $metadata_filename | grep -i 'sha256' | cut -f 2`
if [ "x${download_url}" = "x" ]; then echo "downloaded metadata file is corrupted or an uncaught error was encountered in downloading the file..."; exit 1; fi
if [ "x${sha256}" = "x" ]; then echo "downloaded metadata file is corrupted or an uncaught error was encountered in downloading the file..."; exit 1; fi
############
# End of validate metadata
############

############ 
# start fetch package
############
filename=`echo $download_url | sed -e 's/?.*//' | sed -e 's/^.*\///'`
filetype=`echo $filename | sed -e 's/^.*\.//'`
download_filename="$tmp_dir/$filename"
wget --user-agent="User-Agent: mixlib-install/3.12.30" -O "$download_filename" "$download_url" 
############
# end fetch package
############

echo ""
echo "######################"
echo "     END OF SCRIPT    "
echo "######################"
############
# end of script
############
echo ''
ls -l
