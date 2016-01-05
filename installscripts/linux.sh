##!/bin/bash
if [ $EUID = 0 ]; then
    echo "Please do not run as root. Rather enter your password when prompted."
    exit
fi
if [ ! -n "$(command -v docker)" ]; then
  printf "Docker not detected. Installing Docker...\n"
  curl -sSL https://get.docker.com/ | sh;
  sudo usermod -aG docker $(whoami);
else
  printf "Docker already installed.\n"
fi
# fi
printf "Installation complete. Please reboot your system.\n";
