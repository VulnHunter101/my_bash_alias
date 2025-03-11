#!/bin/bash

# Updating and upgrading system
echo "Updating and upgrading system..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt-get install -y jq ruby-full python3-pip git wget curl

# Install Golang
echo "Installing Golang..."
wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
echo 'alias secretfinder="python3 /usr/local/bin/SecretFinder.py"' >> ~/.bashrc
source ~/.bashrc


# Install security tools
echo "Installing security tools..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/tomnomnom/anew@latest
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest
go install -v github.com/tomnomnom/waybackurls@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/ffuf/ffuf/v2@latest
go install -v github.com/hakluke/hakrawler@latest

pip3 install wafw00f --break-system-packages

sudo apt install -y nmap  ffuf dirsearch

#install SecretFinder tool:
git clone https://github.com/m4ll0k/SecretFinder.git secretfinder
cd secretfinder
sudo pip3 install -r requirements.txt --break-system-packages
sudo mv SecretFinder.py /usr/local/bin
cd ..
echo 'alias secretfinder="python3 /usr/local/bin/SecretFinder.py"' >> ~/.bashrc
source ~/.bashrc
#test SecretFinder:
secretfinder -i https://testphp.vulnweb.com -o cli
#done

#install bash alias_scripts from aws:


# Finish setup
echo "Setup complete! All tools and scripts installed."
