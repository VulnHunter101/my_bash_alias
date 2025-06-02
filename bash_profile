#my_bash_alias

#cleane output.txt from hackerone csv file
myscope() {
    command grep "WILDCARD" "$1" | awk -F',' '{print $1}' >wildcard_domains.txt && grep "URL" "$1" | awk -F',' '{print $1}' >urls_domains.txt
}

# nmap port scan-------------------------------------->
nmap_ps() {
    nmap "$1" -n -sV -Pn -sS -p 21,22,23,25,80,139,161,443,445,2087,3000,3366,3868,4000,4040,4044,5000,5432,5673,5900,6000,7077,7080,7443,7447,8000,8080,8081,8089,8181,8443,8880,8888,8983,9000,9091,9200,9443,9999,10000,15672,3389 -T4 --open
}

# crtsh------------------------------------------------>
crtsh() {
    curl -s "https://crt.sh/?q="$1"&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u
}

# assetfinder [quick subdomain find]-------------------------------------------------->
af() {
    local domain="$1" # Accept domain as argument
    assetfinder "$domain" | httpx -sc
}

# dirsearch---------------------------------------------->
dirsearch() {
    python3 /opt/dirsearch/dirsearch.py \
    -u "$1" \
    -e asp,jsp,aspx,html,php,js,json,yaml \
    -t 100 \
    -F \
    -x 200,204,301,307,401,405,400,302 \
    -w "$2"
}

# Finish setup
echo "Setup complete! All alias tools command and scripts,Now Find Bug"

