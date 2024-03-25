#!/bin/bash
# Version 20240325
# Author Mike Bomba
# 
############
# start of function declaration
############
# This section has some helper functions to make life easier.
#
# Outputs:
# $tmp_dir: secure-ish temp directory that can be used during installation.
############

usage='
ERROR - usage is: download.sh -P [chef|chef-workstation|chef-server|automate] -c [current|stable] -v [version number]  (-P is mandatory)
'
# create a temp download dir
tmp_dir="."
if ! test -d $tmp_dir; then mkdir $tmp_dir; chmod 777 $tmp_dir; fi

# Check whether a command exists - returns 0 if it does, 1 if it does not
exists() {
  if command -v $1 >/dev/null 2>&1; then return 0; else return 1; fi
}

# Output the instructions to report bug about this script
report_bug() {
  echo "Version: $version"
  echo ""
  echo " This is a custom script and not eligable for bug reporting to Chef"
  echo ""
}

checksum_mismatch() {
  echo "ERROR - Package checksum mismatch!"
  report_bug
  exit 1
}

http_404_error() {
  echo "ERROR - Omnitruck artifact does not exist for $platfoorm and $version or $channel"
  exit 1
}

capture_tmp_stderr() {
  # spool up /tmp/stderr from all the commands we called
  if test -f "$tmp_dir/stderr"; then
    output=`cat $tmp_dir/stderr`
    stderr_results="${stderr_results}\nSTDERR from $1:\n\n$output\n"
    rm $tmp_dir/stderr
  fi
}

# do_wget URL FILENAME
do_wget() {
  wget -q --user-agent="User-Agent: mixlib-install/3.12.30" -O "$2" "$1"
  test $? -ne 0 && return 1
  return 0
}

# do_curl URL FILENAME
do_curl() {
  curl -A "User-Agent: mixlib-install/3.12.30" --retry 5 -sL "$1" > "$2"
  test $? -ne 0 && return 1
  return 0
}

# do_fetch URL FILENAME
do_fetch() {
  fetch --user-agent="User-Agent: mixlib-install/3.12.30" -o "$2" "$1" 
  test $? -ne 0 && return 1
  return 0
}

# returns 0 if checksums match
do_checksum() {
  if exists sha256sum; then
    checksum=`sha256sum $1 | awk '{ print $1 }'`
    return `test "x$checksum" = "x$2"`
  elif exists shasum; then
    checksum=`shasum -a 256 $1 | awk '{ print $1 }'`
    return `test "x$checksum" = "x$2"`
  else
    return 0
  fi
}

# do_download URL FILENAME
do_download() {
  url=`echo $1`
  if exists wget; then do_wget $url $2; return 0; fi
  if exists curl; then do_curl $url $2; return 0; fi
  if exists fetch; then do_fetch $url $2; return 0; fi
  echo "ERROR - unable_to_retrieve_package"
}

############
# end of function declarations
############

############
# start platform detection
############
# This section makes platform detection compatible with omnitruck on the system it runs.
#
# Outputs:
# $platform: Name of the platform.
# $platform_version: Version of the platform.
# $machine: System's architecture.
############

machine=`uname -m`
os=`uname -s`
platform=''
platform_version=''

if test -f "/etc/os-release"; then 
  . /etc/os-release
  platform=$ID
  if test "x$VERSION_ID" = "x"; then VERSION_ID=$VERSION; fi
  platform_version=`echo $VERSION_ID | cut -d '.' -f 1`
  if [ "$ID" = "linuxmint" ]; then platform="ubuntu"; fi
  if [ "$ID" = "linuxmint" ] && [ "$platform_version" = "21" ]; then platform_version="22"; fi
  if [ "$ID" = "linuxmint" ] && [ "$platform_version" = "20" ]; then platform_version="20"; fi
  if [ "$ID" = "linuxmint" ] && [ "$platform_version" = "19" ]; then platform_version="18"; fi
fi

if [ "x$platform" = "x" ]; then echo "Unable to determine platform type!"; report_bug; exit 1; fi
if [ "x$platform_version" = "x" ]; then echo "Unable to determine platform version!"; report_bug; exit 1; fi

# normalize the architecture we detected
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

############
# end of platform_detection
############

############
# start of proxy variable assignment
############
# All of the download utilities in this script load common proxy env vars.
# If variables are set they will override any existing env vars.
# Otherwise, default proxy env vars will be loaded by the respective
# download utility.

if test "x$https_proxy" != "x"; then
  HTTPS_PROXY=$https_proxy
  https_proxy=$https_proxy
  export HTTPS_PROXY
  export https_proxy
fi

if test "x$http_proxy" != "x"; then
  HTTP_PROXY=$http_proxy
  http_proxy=$http_proxy
  export HTTP_PROXY
  export http_proxy
fi

if test "x$ftp_proxy" != "x"; then
  FTP_PROXY=$ftp_proxy
  ftp_proxy=$ftp_proxy
  export FTP_PROXY
  export ftp_proxy
fi

if test "x$no_proxy" != "x"; then
  NO_PROXY=$no_proxy
  no_proxy=$no_proxy
  export NO_PROXY
  export no_proxy
fi
############
# end of proxy variable assignment
############

############
# start read command line arguments
############
# This section reads the CLI parameters for the install script and translates
#   them to the local parameters to be used later by the script.
#
# Outputs:
# $version: Requested version to be installed. If left blank, version is calculated based on channel setting. 
# $channel: Channel to install the product from. Default=current. Acceptable values are current and stable.
# $project: The product name to install. Acceptable values are: automate, chef-server, chef-workstation, 
#           chef, inspec, supermarket, chef-backend, push-jobs-client, and push-jobs-server. 
#
# Defaults
channel="current"
#
# Collect command line parameters
while getopts P:v:c: opt
do
  case "$opt" in

    P)  project="$OPTARG";;
    c)  channel="$OPTARG";;
    v)  version="$OPTARG";;
    \?)   # unknown flag
      echo >&2 \
      "usage: $0 [-P project] [-c release_channel] [-v version]"
      exit 1;;
  esac
done
shift `expr $OPTIND - 1`
############
# end read command line arguments
############

echo "#################################"
echo " SCRIT TO DOWNLOAD CHEF SOFTWARE "
echo "#################################"
echo ""
if [ "x$project" = "x" ]; then echo "${usage}";  exit; fi

############
# end read command line arguments
############

############
# start special case for automate download
############
if [ "$project" = "automate" ]; then
  download_filename="$tmp_dir/chef-automate"
  download_url="https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip"
  echo "Chef component name = automate"
  echo "Chef component channel = current"
  echo "Chef component download file = $download_filename"
  curl -A "User-Agent: mixlib-install/3.12.30" --retry 5 -sL "${download_url}" | gunzip - > "$download_filename" && chmod +x "$download_filename"
  echo ""
  echo "######################"
  echo "     END OF SCRIPT    "
  echo "######################"
  exit
fi
############
# end special case for automate download
############

############
# start fetch metadata (url, sha256hash)
############
# This section calls omnitruck to get the information about the build to be
#   installed.
#
# Inputs:
# $channel:
# $project:
# $version:
# $platform:
# $platform_version:
# $machine:
# $tmp_dir:
#
# Outputs:
# $download_url:
# $sha256:
############

metadata_filename="$tmp_dir/metadata.txt"
metadata_url="https://omnitruck.chef.io/$channel/$project/metadata?v=$version&p=$platform&pv=$platform_version&m=$machine"
do_download "$metadata_url" "$metadata_filename"
download_url=`cat $metadata_filename | grep -i 'url' | cut -f 2`
sha256=`cat $metadata_filename | grep -i 'sha256' | cut -f 2`

# check that all the mandatory fields in the downloaded metadata are there
if [ "x${download_url}" = "x" ]; then echo "downloaded metadata file is corrupted or an uncaught error was encountered in downloading the file..."; exit 1; fi
if [ "x${sha256}" = "x" ]; then echo "downloaded metadata file is corrupted or an uncaught error was encountered in downloading the file..."; exit 1; fi


############
# end fetch metadata
############

############ 
# start fetch package
############
# This section fetches a package from $download_url and verifies its metadata.
#
# Inputs:
# $download_url
# $download_filename
#
# Outputs:
# downloaded file 
# checksum performed against downloaded file
############

filename=`echo $download_url | sed -e 's/?.*//' | sed -e 's/^.*\///'`
filetype=`echo $filename | sed -e 's/^.*\.//'`
download_filename="$tmp_dir/$filename"

echo "Platform Type detected = $platform"
echo "Platform Version detected = $platform_version"
echo "Chef component name = $project"
echo "Chef component channel = $channel"
echo "Chef component download checksum (sha256) = $sha256"
echo "Chef component download url = $download_url"
echo "Chef component download filename = $download_filename"
echo ""

verify_checksum="true"

do_download "$download_url" "$download_filename"

if test "x$verify_checksum" = "xtrue"; then
  do_checksum "$download_filename" "$sha256" || checksum_mismatch
fi

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
