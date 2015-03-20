#!/bin/sh
git clone https://github.com/DyCI/dyci-main.git
cd dyci-main/Install/
./install.sh
cd ../..
mv dyci-main ~/.Trash

echo "Installing Kicker Gem... this may take some time."
sudo gem install kicker
