#!/bin/sh
git clone https://github.com/DyCI/dyci-main.git
cd dyci-main/Install/
./install.sh
cd ../..
mv dyci-main ~/.Trash
sudo gem install kicker
