<p align="center">
  <img src="https://habrastorage.org/webt/zm/nm/pr/zmnmprsvbuxifiuo2dcdb6z1vle.png" alt="Logo" />
</p>

This repository contains an example of [Laravel][laravel] _(PHP Framework)_ application that runs in a docker container with [RoadRunner][roadrunner] _(high-performance PHP application server)_ as a web server.

## :fire: Features list

- For local application running, you need just two dependencies - installed `docker` and `docker-compose` (`make` is optional, but strongly recommended)
- [PostgreSQL][postgresql] as a **database** and [Redis][redis] as a **cache** & **queue** driver already configured
- One `Dockerfile` for local application development and running on production
- All used images are based on [Alpine][alpine] (lightweight and security-oriented linux distributive)
- Lightweight final docker image _(compressed size ~65 Mb, ~16 downloadable layers)_
- **Unprivileged** user is used by default
- Easy to update PHP and dependencies
- Ready to run Laravel [task scheduling][laravel_scheduling], [queue workers][laravel_queue], and many others on your choice
- Without file permission problems
- For [cron][cron] jobs running [supercronic][supercronic] is used _(crontab-compatible job runner, designed specifically to run in containers)_
- Self-signed SSL certificate for HTTPS support
- Enabled `opcache` and `jit` compiler for the performance of your application
- [Composer][composer] dependencies caching using separate docker image layer
- Well-documented code
- HTTP server doesn't need to be restarted on source code changes
- Works much faster than `php-fpm` + `nginx` and easy to deploy
- Provided `Makefile` allows to perform familiar operations easy and fast
- Ready to run [phpunit][phpunit] _(with code coverage)_ and [phpstan][phpstan] _(static analysis tool for source code)_
- [GitHub actions](.github/workflows) for tests running, image building, etc.

# How to use

If you want to integrate Docker + RoadRunner into an **existing** application, take a look at [pull requests with the special label][pr_step_by_step] in the current repository - you can repeat these steps.

Another way is repository cloning, forking or [usage this repository as a template][use_repo_template] for your application.

> Don't forget to remove `TestJob`, `TestController`, and routes, that are declared for this controller in the `routes/web.php` file - it is used for internal application working tests.

## First steps

Let's dive deeper and watch how to start application development, based on this template. First, we need to get the sources:

```shell
$ git clone https://github.com/tarampampam/laravel-roadrunner-in-docker.git
$ cd ./laravel-roadrunner-in-docker
```

After that - build image with our application and install composer dependencies:

```shell
$ make install
...
  - Installing spatie/laravel-ignition (2.0.0): Extracting archive
  - Installing symfony/psr-http-message-bridge (v2.1.4): Extracting archive
  - Installing spiral/goridge (v3.2.0): Extracting archive
  - Installing spiral/roadrunner-worker (v2.3.0): Extracting archive
  - Installing spiral/roadrunner-http (v2.2.0): Extracting archive
  - Installing nyholm/psr7 (1.5.1): Extracting archive
  - Installing spiral/roadrunner-laravel (v5.11.1): Extracting archive
Generating optimized autoload files
> Illuminate\Foundation\ComposerScripts::postAutoloadDump
> @php artisan package:discover --ansi

   INFO  Discovering packages.

  laravel/sail ...................................................... DONE
  laravel/sanctum ................................................... DONE
  laravel/tinker .................................................... DONE
  nesbot/carbon ..................................................... DONE
  nunomaduro/collision .............................................. DONE
  nunomaduro/termwind ............................................... DONE
  spatie/laravel-ignition ........................................... DONE
  spiral/roadrunner-laravel ......................................... DONE
```

Make full application initialization:

```shell
$ make init
...
   INFO  Preparing database.

  Creating migration table ..................................... 15ms DONE

   INFO  Running migrations.

  2014_10_12_000000_create_users_table ......................... 27ms DONE
  2014_10_12_100000_create_password_resets_table ............... 21ms DONE
  2019_08_19_000000_create_failed_jobs_table ................... 17ms DONE
  2019_12_14_000001_create_personal_access_tokens_table ........ 30ms DONE

   INFO  Seeding database.
...
```

Start the application:

```shell
$ make up
...

    Navigate your browser to ⇒ http://127.0.0.1:8080 or https://127.0.0.1:8443
```

Voila! You can open <http://127.0.0.1:8080> (or <https://127.0.0.1:8443>) in your browser and source code in your favorite IDE.

> For watching all supported `make` commands execute `make` without parameters inside the project directory:
> ```
> $ make
>
> Available commands:
> help               Show this help
> install            Install all app dependencies
> shell              Start shell into app container
> init               Make full application initialization
> ...
> ```

## How to

### Open the shell in the application container?

Execute in your terminal:

```shell
$ make shell
```

In this shell, you can use `composer`, `php`, and any other tools, which are installed into a docker image.

### Watch logs?

```shell
$ docker-compose logs -f
```

All messages from all containers output will be listed here.

### Install composer dependency?

As it was told above - execute `make shell` and after that `composer require %needed/package%`.

### Add my own `make` command?

Append into `Makefile` something like:

```makefile
your-command: ## Your command help
	/bin/your/app -goes -here
```

> Tab character in front of your command is mandatory!

Read more about makefiles [here](https://www.gnu.org/software/make/manual/html_node/index.html#SEC_Contents).

## To Do

- [ ] Describe front-end development/building

### Useful links

- <https://habr.com/ru/post/461687/> <sup>ru</sup>
- <https://pythonspeed.com/articles/faster-multi-stage-builds/>

## Troubleshooting

### MacOS Unprivileged User

This repo was created for Linux users. It maps `/etc/passwd` in `docker-compose.yml` to [set the current host user for the Docker containers](https://faun.pub/set-current-host-user-for-docker-container-4e521cef9ffc).

MacOS doesn't use `/etc/passwd` unless it's operating in single-user mode. Instead, it uses a system called [Open Directory](https://superuser.com/questions/191330/users-dont-appear-in-etc-passwd-on-mac-os-x/191333#191333).

If you do `make shell; whoami` and get user errors, then you can fix by running `./scripts/fix_mac_user.sh`. This script will create a `mac_passwd` file that plays nice with `/etc/passwd` used by `docker-compose.yml` under the volumes mapping section.

```bash
#!/bin/sh
// File: ./scripts/fix_mac_user.sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR/../
echo "$USER:x:$(id -u):$(id -g):ns,,,:$HOME:/bin/bash" > mac_passwd
sed -i.backup 's~/etc/passwd:/etc/passwd:ro~./mac_passwd:/etc/passwd:ro~' docker-compose.yml
```

## Support

[![Issues][badge_issues]][link_issues]
[![Issues][badge_pulls]][link_pulls]

If you find any package errors, please, [make an issue][link_create_issue] in current repository.

## License

This project is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).

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

[pr_step_by_step]:https://github.com/tarampampam/laravel-roadrunner-in-docker/pulls?q=is%3Apr+label%3Astep-by-step+sort%3Acreated-asc
[use_repo_template]:https://github.com/tarampampam/laravel-roadrunner-in-docker/generate

[badge_issues]:https://img.shields.io/github/issues/tarampampam/laravel-roadrunner-in-docker.svg?maxAge=45
[badge_pulls]:https://img.shields.io/github/issues-pr/tarampampam/laravel-roadrunner-in-docker.svg?maxAge=45
[link_issues]:https://github.com/tarampampam/laravel-roadrunner-in-docker/issues
[link_pulls]:https://github.com/tarampampam/laravel-roadrunner-in-docker/pulls
[link_create_issue]:https://github.com/tarampampam/laravel-roadrunner-in-docker/issues/new/choose
