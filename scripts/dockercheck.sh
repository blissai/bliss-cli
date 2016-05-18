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

Docker Machine users should use:
docker-machine start default
eval "\$(docker-machine env default)"

EOF
  exit 1
}

socket_missing() {
  invalid_setup "/var/run/docker.sock must exist as a Unix domain socket"
}

invalid_docker_host() {
  local host=$1
  invalid_setup "invalid DOCKER_HOST=$host, must be unset or unix:///var/run/docker.sock"
}

if command -v docker-machine > /dev/null 2>&1; then
  if ! [ -S /var/run/docker.sock > /dev/null ]; then
    docker-machine ssh $DOCKER_MACHINE_NAME -- \
      test -S /var/run/docker.sock > /dev/null 2>&1 || socket_missing
  else
    if ! docker ps > /dev/null 2>&1 ; then
      invalid_setup "Docker service must be running".
    fi
  fi
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
