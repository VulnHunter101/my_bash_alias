#radha .bash_profile

alias secretfinder="python3 /usr/local/bin/SecretFinder.py"

#cleane output.txt from hackerone csv file
myscope() {
    command grep "WILDCARD" "$1" | awk -F',' '{print $1}' > wildcard_domains.txt && grep "URL" "$1" | awk -F',' '{print $1}' > urls_domains.txt
}

#crtsh------------------------------------------------>
crtsh() {
    if [ -z "$1" ]; then
        echo "Usage: crtsh <domain>"
        return 1
    fi

    local domain=$1
    local url="https://crt.sh/?q=%25.${domain}&output=json"

    curl -s "$url" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u
}

#dirsearch---------------------------------------------->
dirsearch() {
    command dirsearch -u "$1" -e html,php,js,json,yaml,env -t 100  -F -w "$2"
}

#ffuf 
ffuf() {
    command ffuf -u "$1"FUZZ -w "$2" -t "${3:-100}" -c -ac -mc "${4:-200,204,301,307,401,405,400,302}" | tee "${5:-ffuf_results.txt}"
}

#urls_extension_finder---------------------------------------------------->
urls_ext_finder() {
    read -p "Enter the target domain: " DOMAIN && \
curl -s "https://web.archive.org/cdx/search/cdx?url=*.$DOMAIN/*&collapse=urlkey&output=text&fl=original&filter=original:.*\.(x1s|xml|xlsx|json|pdf|sql|doc|docx|pptx|txt|git|zip|tar.gz|tgz|bak|7z|rar|log|cache|secret|db|backup|yml|gz|config|csv|yaml|md|md5|exe|dll|bin|ini|bat|sh|tar|deb|rpm|iso|img|env|apk|msi|dmg|tmp|crt|pem|key|pub|asc)$" | sort -u | tee ext_output.txt
}

#ultra_subs_finder--------------------------------------------------------->
ultra_subs_finder() {
# Check if a domain is provided
if [ -z "$1" ]; then
  echo -e "\033[1;31mUsage:\033[0m $0 domain.com"
  exit 1
fi

domain=$1
output_file="${domain}_subdomains_$(date +%F).txt"

echo -e "\033[1;34m[+] Starting subdomain enumeration for $domain\033[0m"

# Function to check and install missing tools
install_tool() {
  if ! command -v $1 &> /dev/null; then
    echo -e "\033[1;33m[-] $1 not found! Installing...\033[0m"
    sudo apt install -y $1 || echo -e "\033[1;31m[!] Failed to install $1. Install it manually.\033[0m"
  fi
}

# Check and install required tools
install_tool subfinder
install_tool assetfinder
install_tool jq
install_tool curl

# Run all enumeration tools and store output in a temporary file
tmp_file=$(mktemp)

echo -e "\033[1;32m[+] Running Subfinder...\033[0m"
subfinder -d "$domain" -silent | tee -a "$tmp_file"

echo -e "\033[1;32m[+] Running Assetfinder...\033[0m"
assetfinder --subs-only "$domain" | tee -a "$tmp_file"

echo -e "\033[1;32m[+] Fetching subdomains from crt.sh...\033[0m"
curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sort -u | tee -a "$tmp_file"

# Remove duplicates and save final results
cat "$tmp_file" | sort -u > "$output_file"

# Clean up temporary file
rm "$tmp_file"

echo -e "\033[1;34m[+] Subdomain enumeration completed!\033[0m"
echo -e "\033[1;32m[+] Results saved in $output_file\033[0m"
}

#http_hv_finder-------------------------------------------------------->
http_hv_finder() {
    # Define color codes
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Ask the user for the target URL
read -p "Enter the target URL: " TARGET

# Ask the user for custom headers (optional)
read -p "Enter custom headers (e.g., 'X-Forwarded-For: 127.0.0.1') or press Enter to skip: " CUSTOM_HEADER

# List of HTTP methods to test
METHODS=("GET" "POST" "PUT" "DELETE" "OPTIONS" "HEAD" "TRACE" "PATCH")

echo "====================================="
echo " Testing HTTP methods on: $TARGET"
echo "====================================="

# Loop through each HTTP method and send requests
for METHOD in "${METHODS[@]}"; do
    if [[ -n "$CUSTOM_HEADER" ]]; then
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X $METHOD "$TARGET" -H "$CUSTOM_HEADER")
    else
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X $METHOD "$TARGET")
    fi

    # Apply colors based on response code
    if [[ $RESPONSE == 200 ]]; then
        COLOR=$GREEN
    elif [[ $RESPONSE == 403 ]]; then
        COLOR=$RED
    else
        COLOR=$YELLOW
    fi

    echo -e "Method: $METHOD | Response: ${COLOR}$RESPONSE${RESET}"
done
}


#jsleak for find potential secrets inside .js_file ---------------------------------------------->
jsleak() {
    TARGET_URL="$1"

if [[ -z "$TARGET_URL" ]]; then
    echo "Usage: $0 <target-url>"
    exit 1
fi

echo "[+] Running waybackurls on $TARGET_URL..."
waybackurls "$TARGET_URL" | sort -u | tee urls_output.txt

echo "[+] Extracting .js files..."
grep "\.js$" urls_output.txt > js_output.txt

echo "[+] Fetching and scanning JavaScript files for secrets..."
while read url; do
    echo "[*] Searching in $url"
    FOUND_SECRETS=$(curl -s "$url" | grep -i -E "(apiKey|token|client_secret|password|key|access_token|auth_token)")

    if [[ ! -z "$FOUND_SECRETS" ]]; then
        echo -e "\n[+] Found secrets in: $url"
        echo -e "$FOUND_SECRETS\n"
        echo -e "[+] URL: $url\n$FOUND_SECRETS\n" >> secrets_found.txt
    fi
done < js_output.txt

echo "[+] Scan complete! Potential secrets saved in secrets_found.txt"
}
