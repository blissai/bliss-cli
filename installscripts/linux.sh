##!/bin/bash
set_package_manager(){
  if [[ -n "$(command -v yum)" ]]
  then
    PACKAGEMGR="sudo yum"
  elif [[ -n "$(command -v apt-get)" ]]
  then
    PACKAGEMGR="sudo yum"
  fi
}
set_package_manager()
echo "Installing docker..."
curl -sSL https://get.docker.com/ | sh
echo "Installation complete. Please reboot your system."
