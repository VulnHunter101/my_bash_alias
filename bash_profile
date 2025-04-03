#my_bash_alias

#cleane output.txt from hackerone csv file
myscope() {
    command grep "WILDCARD" "$1" | awk -F',' '{print $1}' >wildcard_domains.txt && grep "URL" "$1" | awk -F',' '{print $1}' >urls_domains.txt
}

#crtsh------------------------------------------------------------------------------------->
crtsh() {
    curl -s "https://crt.sh/?q=%25."$1"&output=json" | jq -r '.[].name_value' | sort -u | httpx -sc
}

#urls [quick_wayback_urls_finder]---------------------------------------------------------->
urls() {
    curl -s "https://web.archive.org/cdx/search/cdx?url=*."$1"/*&collapse=urlkey&output=text&fl=original" | sort -u
}

#assetfinder [quick subdomain find]-------------------------------------------------------->
af() {
    local domain="$1" # Accept domain as argument
    assetfinder "$domain" | httpx -sc
}

#dirsearch--------------------------------------------------------------------------------->
dirsearch() {
    command dirsearch -u "$1" -e html,php,js,json,yaml,env -t 100 -F -w "$2"
}

#ffuf-------------------------------------------------------------------------------------->
ffuf() {
    command ffuf -u "$1"FUZZ -w "$2" -t "${3:-100}" -c -ac -mc "${4:-200,204,301,307,401,405,400,302}" | tee "${5:-ffuf_results.txt}"
}

#urls_extension_finder-------------------------------------------------------------------->
urls_ext_finder() {
    read -p "Enter the target domain: " DOMAIN &&
        curl -s "https://web.archive.org/cdx/search/cdx?url=*.$DOMAIN/*&collapse=urlkey&output=text&fl=original&filter=original:.*\.(x1s|xml|xlsx|json|pdf|sql|doc|docx|pptx|txt|git|zip|tar.gz|tgz|bak|7z|rar|log|cache|secret|db|backup|yml|gz|config|csv|yaml|md|md5|exe|dll|bin|ini|bat|sh|tar|deb|rpm|iso|img|env|apk|msi|dmg|tmp|crt|pem|key|pub|asc)$" | sort -u | tee ext_output.txt
}

#subs_finder------------------------------------------------------------------------------->
subs_finder() {
    # Check if a domain is provided
    if [ -z "$1" ]; then
        echo -e "\033[1;31mUsage:\033[0m $0 domain.com"
        exit 1
    fi

    domain=$1
    output_file="${domain}_subdomains_$(date +%F).txt"

    echo -e "\033[1;34m[+] Starting subdomain enumeration for $domain\033[0m"

    # Run all enumeration tools and store output in a temporary file
    tmp_file=$(mktemp)

    echo -e "\033[1;32m[+] Running Subfinder...\033[0m"
    subfinder -d "$domain" -all -silent | tee -a "$tmp_file"

    echo -e "\033[1;32m[+] Running Assetfinder...\033[0m"
    assetfinder --subs-only "$domain" | tee -a "$tmp_file"

    echo -e "\033[1;32m[+] Running Sublist3r...\033[0m"
    sublist3r -d "$domain" -o - | tee -a "$tmp_file"

    echo -e "\033[1;32m[+] Fetching subdomains from crt.sh...\033[0m"
    curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sort -u | tee -a "$tmp_file"

    # Remove duplicates and save final results
    cat "$tmp_file" | sort -u >"$output_file"

    # Clean up temporary file
    rm "$tmp_file"

    echo -e "\033[1;34m[+] Subdomain enumeration completed!\033[0m"
    echo -e "\033[1;32m[+] Results saved in $output_file\033[0m"
}

#http_hv_finder Use: http_hv_finder https://example.com "X-Forwarded-For: 127.0.0.1"]------------------------------------------------------------>
http_hv_finder() { METHODS=("GET" "POST" "PUT" "DELETE" "OPTIONS" "HEAD" "TRACE" "PATCH"); [[ -z "$1" ]] && { echo "Usage: http_hv_finder <URL> [Custom Header]"; return; }; for METHOD in "${METHODS[@]}"; do RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X $METHOD "$1" ${2:+-H "$2"}); COLOR=$([[ $RESPONSE == 200 ]] && echo -e "\e[32m" || ([[ $RESPONSE == 403 ]] && echo -e "\e[31m" || echo -e "\e[33m")); echo -e "Method: $METHOD | Response: ${COLOR}$RESPONSE\e[0m"; done; }


# Finish setup
echo "Setup complete! All alias tools command and scripts,Now Find Bug"

