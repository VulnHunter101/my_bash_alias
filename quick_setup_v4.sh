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

# Install security
echo "Installing security tools..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/owasp-amass/amass/v4/...@master
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/tomnomnom/anew@latest
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest
go install -v github.com/tomnomnom/waybackurls@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/ffuf/ffuf/v2@latest
go install -v github.com/hakluke/hakrawler@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest

# pip3 install toosl
pip3 install wafw00f dirsearch --break-system-packages

# apt isntall tools
sudo apt install dnsrecon nmap whatweb sublist3r -y

# install SecretFinder
git clone https://github.com/m4ll0k/SecretFinder.git /opt/SecretFinder
cd /opt/SecretFinder 
sudo pip install -r requirements.txt --break-system-packages
echo "alias secretfinder='python3 /opt/SecretFinder/SecretFinder.py'" >> ~/.bashrc
source .bashrc
cd

# install ipinfo
echo "deb [trusted=yes] https://ppa.ipinfo.net/ /" | sudo tee  "/etc/apt/sources.list.d/ipinfo.ppa.list"
sudo apt update
sudo apt install ipinfo

## Automatically add source ~/.bash_profile to .bashrc
cd
echo 'source ~/.bash_profile' >> ~/.bashrc
source ~/.bashrc

# Finish setup
echo "Setup complete! All tools and scripts installed."