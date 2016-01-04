##!/bin/bash
if [ "$(uname)" = "Darwin" ]; then
  if [ -n "$(command -v docker)" ]; then
    printf "Please install Docker Toolbox, which can be located at:\nhttps://www.docker.com/docker-toolbox\n";
  fi
elif [ "$(uname)" = "Linux" ]; then
  printf "Installing ruby dependencies...\n"
  if [ -n "$(command -v yum)" ]; then
    sudo yum -y install gcc g++ make automake autoconf ruby-devel build-essential
  elif [ -n "$(command -v apt-get)" ]; then
    sudo apt-get -y install gcc g++ make automake autoconf ruby-devel build-essential
  fi
  gem install bundler
  bundle install
  if [ -n "$(command -v docker)" ]; then
    printf "Docker not detected. Installing Docker...\n"
    curl -sSL https://get.docker.com/ | sh;
    sudo usermod -aG docker ec2-user
  else
    printf "Docker already installed.\n"
  fi
fi
printf "Installation complete. Please reboot your system.\n";
