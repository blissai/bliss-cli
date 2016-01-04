##!/bin/bash
if [ "-n $(command -v docker)" ]; then
  if [ "$(uname)" = "Darwin" ]; then
    printf "Please install Docker, which can be located at:\nhttps://www.docker.com/docker-toolbox\n";
    printf "Make sure to include Docker Machine.\n";
  elif [ "$(uname)" = "Linux" ]; then
    curl -sSL https://get.docker.com/ | sh;
    printf "Starting docker service..."
    sudo service docker start;
    printf "Pulling Bliss Engine..."
    docker pull blissai/collector;
    printf "Installation complete.\n";
  fi
fi
