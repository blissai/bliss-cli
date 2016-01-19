Task scheduling (Unix) for [Bliss CLI](https://github.com/founderbliss/bliss-cli)
----------------------
We recommend using cron to run Bliss on a schedule.

More information about cron can be found here:
https://en.wikipedia.org/wiki/Cron

You will need to make sure that when you setup a cron script, you ensure that the cron process has access to Docker.
You can do this by wrapping the docker command and the bliss command into a script.

For OSX the following should work as a cron (OSX) script:
```````````````
docker-machine create --driver virtualbox default # May already exist. If so, just carry on.
eval "$(docker-machine env default)"
bliss [options]
```````````````

For Linux users, ensuring that the docker daemon is running will suffice. You can then set cron up to run the blisscollector.rb ruby script.
