#!/bin/sh
invalid_setup() {
  local reason=$1

  cat >&2 <<EOF
Docker is not running or is not accessible by this shell:

  > $reason

We require a local Docker daemon to be running and accessible to your shell before using Bliss Collector.

See https://github.com/founderbliss/docker for more details.

If using Unix, you should use:
sudo service docker start

Docker Machine (OSX and Windows) users should use:
docker-machine start default
eval "\$(docker-machine env default)"

EOF
  exit 1
}

start_docker_osx() {
  $host = $(uname)
  if [ $host = 'Darwin' ]; then
    if command -v docker-machine > /dev/null 2>&1; then
      docker-machine start default
      eval "$(docker-machine env default)"
    fi
  fi
}

socket_missing() {
  invalid_setup "/var/run/docker.sock must exist as a Unix domain socket"
}

invalid_docker_host() {
  local host=$1
  invalid_setup "invalid DOCKER_HOST=$host, must be unset or unix:///var/run/docker.sock"
}

function abspath() {
    # generate absolute path from relative path
    # $1     : relative filename
    # return : absolute path
    if [ -d "$1" ]; then
        # dir
        (cd "$1"; pwd)
    elif [ -f "$1" ]; then
        # file
        if [[ $1 == */* ]]; then
            echo "$(cd "${1%/*}"; pwd)/${1##*/}"
        else
            echo "$(pwd)/$1"
        fi
    fi
}

if command -v docker-machine > /dev/null 2>&1; then
  docker-machine ssh $DOCKER_MACHINE_NAME -- \
    test -S /var/run/docker.sock > /dev/null 2>&1 || socket_missing

  docker-machine ssh $DOCKER_MACHINE_NAME -- \
    'test -n "$DOCKER_HOST" -a "$DOCKER_HOST" != "unix:///var/run/docker.sock"' > /dev/null 2>&1 \
    && invalid_docker_host $(boot2docker ssh -- 'echo "$DOCKER_HOST"')
elif command -v boot2docker > /dev/null 2>&1; then
  boot2docker ssh -- \
    test -S /var/run/docker.sock > /dev/null 2>&1 || socket_missing

  boot2docker ssh -- \
    'test -n "$DOCKER_HOST" -a "$DOCKER_HOST" != "unix:///var/run/docker.sock"' > /dev/null 2>&1 \
    && invalid_docker_host $(boot2docker ssh -- 'echo "$DOCKER_HOST"')
else
  test -S /var/run/docker.sock || socket_missing
  test -n "$DOCKER_HOST" -a "$DOCKER_HOST" != "unix:///var/run/docker.sock" \
    && invalid_docker_host "$DOCKER_HOST"
fi

if [ -t 1 ]; then
  echo "Docker is setup correctly."
fi
