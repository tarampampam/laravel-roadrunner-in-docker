<p align="center">
  <img src="https://habrastorage.org/webt/zm/nm/pr/zmnmprsvbuxifiuo2dcdb6z1vle.png" alt="Logo" />
</p>

This repository contains an example of [Laravel][laravel] _(PHP Framework)_ application that runs in a docker container with [RoadRunner][roadrunner] _(high-performance PHP application server)_ as a web server.

## :fire: Features list

- One `Dockerfile` for local application development and running on production
- For local application running, you need just two dependencies - installed `docker` and `docker-compose` (`make` is optional, but strongly recommended)
- [PostgreSQL][postgresql] as a **database** and [Redis][redis] as a **cache** & **queue** driver already configured
- **Unprivileged** user is used by default
- All used images are based on [Alpine][alpine] (lightweight and security-oriented linux distributive)
- Easy to update PHP and dependencies versions (all versions defined in one place - `Dockerfile`)
- Ready to run Laravel [task scheduling][laravel_scheduling], [queue workers][laravel_queue], and many others on your choice
- For [cron][cron] jobs running [supercronic][supercronic] _(crontab-compatible job runner, designed specifically to run in containers)_ is used
- Self-signed SSL certificate for HTTPS support
- Enabled `opcache` and `jit` compiler for the performance of your application
- [Composer][composer] dependencies caching using separate docker image layer
- Well-documented code
- Lightweight final docker image
- HTTP server doesn't need to be restarted on source code changes
- Works much faster than `php-fpm` + `nginx` and easy to deploy
- Provided `Makefile` allows to perform familiar operations easy and fast
- Ready to run [phpunit][phpunit] _(with code coverage)_ and [phpstan][phpstan] _(static analysis tool)_
- [GitHub actions](.github/workflows) for tests running, image building, etc.

### Links

- <https://pythonspeed.com/articles/faster-multi-stage-builds/>

[laravel]:https://laravel.com/
[roadrunner]:https://roadrunner.dev/
[postgresql]:https://www.postgresql.org/
[redis]:https://redis.io/
[alpine]:https://alpinelinux.org/
[laravel_scheduling]:https://laravel.com/docs/8.x/scheduling
[laravel_queue]:https://laravel.com/docs/8.x/queues
[cron]:https://en.wikipedia.org/wiki/Cron
[supercronic]:https://github.com/aptible/supercronic
[composer]:https://getcomposer.org/
[phpunit]:https://phpunit.de/
[phpstan]:https://phpstan.org/
