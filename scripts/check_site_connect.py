#--------------------------------------#
# Script name:   check_site_connect.py #
# Script author: Pete Olbrys           #
# Last update:   1/7/2014              #
# Details:       This script checks    #
#                whether or not a site #
#                is reachable over     #
#                http.                 #
#--------------------------------------#

import urllib

# Get the HTTP return code
def check_http(site_url):
    is_http = site_url.split("/",2)

    # Parse URL to make sure you have full URL including http:// or https://
    if (is_http[0] == "http:") or (is_http[0] == "https:"):
        return urllib.urlopen(site_url).getcode()
    else:
        return urllib.urlopen("http://" + site_url).getcode()

site_url_input = raw_input("Enter the full URL to check: ")
status = check_http(site_url_input)

print "-----------------------------"

# Check the returned status code
if status == 200:
    print site_url_input, " is UP!"
elif (status == 400) or (status == 401) or (status == 402) or (status == 403) or (status == 404):
    print site_irl_input, " is DOWN!"
else:
    print "Unknown return code."

print "-----------------------------"
