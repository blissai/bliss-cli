##!/bin/bash
if [ "-n $(command -v docker)" ]; then
  if [ "$(uname)" == "Darwin" ]; then
    printf "Please install Docker, which can be located at:\nhttps://www.docker.com/docker-toolbox";
    printf "Make sure to include Docker Machine.";
  elif [ "$(uname)" == "Linux" ]; then
    printf "Installing docker...";
    curl -sSL https://get.docker.com/ | sh;
    docker pull blissai/collector;
    printf "Installation complete.";
  fi
fi
