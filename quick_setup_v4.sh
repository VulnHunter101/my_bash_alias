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


# subs_finder--------------------------------------------------------->
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
    curl -s "https://crt.sh/?q=$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee -a "$tmp_file"
    
    # Remove duplicates and save final results
    cat "$tmp_file" | sort -u >"$output_file"
    
    # Clean up temporary file
    rm "$tmp_file"
    
    echo -e "\033[1;34m[+] Subdomain enumeration completed!\033[0m"
    echo -e "\033[1;32m[+] Results saved in $output_file\033[0m"
}


# make a wordlist for a custom Dom----------->
wordlist() {
    if [ -z "$1" ]; then
        echo "Usage: wordlist <domain.com>"
        return 1
    fi
    
    domain="$1"
    echo "[+] Gathering URLs for $domain ..."
    
    # 1. Download archived URLs
    curl -s "https://web.archive.org/cdx/search/cdx?url=*.$domain/*&collapse=urlkey&output=text&fl=original" -o urls.txt
    
    # 2. Extract data using unfurl
    cat urls.txt | unfurl paths > urls_paths.txt
    cat urls.txt | unfurl keys > keys.txt
    cat urls.txt | unfurl values > values.txt
    cat urls.txt | unfurl keypairs > keypairs.txt
    sed 's#/#\n#g' urls.txt | sort -u | tee all_paths.txt
    
    # 3. Get interesting file types
    grep -Ei '\.(json|php|js|jsp)$' urls.txt > js_files.txt
    
    # 4. Get only URLs with parameters
    grep -E '\?.*=' urls.txt > urls_params.txt
    
    # 5. Extract endpoint-like patterns from JS files
    > js_endpoints.txt
    cat js_files.txt | while read url; do
        if curl -s --max-time 10 "$url" 2>/dev/null | grep -q .; then
            echo "[+] Parsing $url"
            curl -s "$url" | grep -oE "/[a-zA-Z0-9._/-]+" | sort -u >> js_endpoints.txt
            sleep 1
        fi
    done
    
    echo "[+] Done. Files generated:"
    echo "  - urls.txt"
    echo "  - urls_paths.txt"
    echo "  - keys.txt"
    echo "  - values.txt"
    echo "  - keypairs.txt"
    echo "  - all_paths.txt"
    echo "  - js_files.txt"
    echo "  - urls_params.txt"
    echo "  - js_endpoints.txt"
}

# Finish setup
echo "Setup complete! All alias tools command and scripts,Now Find Bug"

