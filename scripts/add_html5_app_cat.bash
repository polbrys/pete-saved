# !/bin/bash
# Title: add_html5_app_cat.bash
# Description: This script pushes out a custom HTML5 App Catalog
#     on an Apperian web server.
# Author: polbrys
# Date: 08/04/2014
#

# Variables
HTML5_DIR=/var/www/apperian/html5_catalogs/
ZIPFILELOC=''
APPCATURL=''

# Verify Script Run as Root
if [ "$(id -u)" != "0" ]; then
    echo "Root privileges required, please re-run as root."
    exit 1
fi

# Check arguments
while getopts 'hfu' flag; do
    case "${flag}" in
        h)  echo "Usage -> /var/www/apperian/bin/add_html5_app_cat.bash -h -f <FILE PATH>"
            echo " "
            echo "Options:"
            echo "-f <FILEPATH>  Full path to HTML5 App Catalog zip file (provided by Customer Support)"
            echo "-u <URL>       URL for App Catalog, must match exactly to the link the customer will use to access catalog"
            echo "-h             Display this help menu"
            exit 0
            ;;
        f)  ZIPFILELOC="${OPTARG}" ;;
        u)  APPCATURL="${OPTARG}" ;;
        *)  error "Unexpected option ${flag}" ;;
    esac
done

# User input error checking
if [ "$ZIPFILELOC" == "" ]; then
    echo "Error: Missing zip file location argument. Please re-run with -f <FILE PATH> option."
    exit 1
elif [ "$APPCATURL" == "" ]; then
    echo "Error: Missing App Catalog URL. Please re-run with -u <URL> option."
    exit 1
elif [ "$ZIPFILELOC" == *tar.gz* ]
    echo "Error: App Catalog must be a .zip file. Please contact support or use this doc: https://apperian.jira.com/wiki/display/ops/Adding+a+Custom+HTML5+App+Catalog"
    exit 1
fi

# Verify App Catalog directory does not exist yet
FULLAPPCATPATH=$HTML5_DIR$APPCATURL

if [ ! -d "$FULLAPPCATPATH" ]; then
    echo "Creating $APPCATURL directory in /var/www/apperian/html5_catalogs/"
    mkdir $FULLAPPCATPATH
else
    echo "$FULLAPPCATPATH already exists. Would you like to remove the old directory? (y/n): "
    read REMOVE_DIR

    if [ "$REMOVE_DIR" == "y" ]; then
        echo "Removing $FULLAPPCATPATH"
        rm -rf $FULLAPPCATPATH
    elif [ "$REMOVE_DIR" == "n" ]; then
        echo "$FULLAPPCATPATH must be removed before adding new catalog. Please remove and re-run script."
        exit 1
    else
        echo "Invalid option $REMOVE_DIR"
        exit 1
    fi
fi

# Copy and unpack zip file
echo "Copying zip file to $FULLAPPCATPATH"
cp $ZIPFILELOC $FULLAPPCATPATH

echo "Unzipping file to $FULLAPPCATPATH"
sudo -u apache unzip $FULLAPPCATPATH/*.zip

# Create symlinks necessary for app cat functionality
echo "Creating svc symlink to /var/www/apperian/easeweb/websvc/easesvc"
sudo -u apache ln -s /var/www/apperian/easeweb/websvc/easesvc $FULLAPPCATPATH/svc

echo "Creating wsproxy.php symlink to /var/www/apperian/easeweb/web/easeadmin/web/wsproxy.php"
sudo -u apache ln -s /var/www/apperian/easeweb/web/easeadmin/web/wsproxy.php $FULLAPPCATPATH/wsproxy.php

echo "Creating uploads symlink to /var/www/apperian/easeweb/websvc/easesvc/uploads"
sudo -u apache ln -s /var/www/apperian/easeweb/websvc/easesvc/uploads/ $FULLAPPCATPATH/uploads

exit 1
