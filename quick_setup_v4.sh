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
go install -v github.com/ffuf/ffuf/v2@latest
go install -v github.com/hakluke/hakrawler@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/tomnomnom/unfurl@latest
go install -v github.com/tomnomnom/httprobe@latest

sudo mv ~/go/bin/* /usr/local/bin/

# pip3 install toosl

# apt isntall tools
sudo apt install dnsrecon nmap sublist3r wafw00f dirsearch -y

# install dirsearch


# install SecretFinder

# install ipinfo


## Automatically add source ~/.bash_profile to .bashrc
cd
echo 'source ~/.bash_profile' >> ~/.bashrc
source ~/.bashrc

# Finish setup
echo "Setup complete! All tools and scripts installed."