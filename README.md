# docker-applesus

Dockerized Apple Software Update Services (Reposado + Margarita)

### Contents

* [About](#about)
* [How-to guides](#how-to-guides)
    * [Installing](#installing)
    * [Using Apple SUS](#using-apple-sus)
    * [Upgrading](#upgrading)
    * [Running a one-time manual backup](#running-a-one-time-manual-backup)
    * [Restoring from a backup](#restoring-from-a-backup)
    * [Uninstalling](#uninstalling)

## About

This repo uses [Docker](https://www.docker.com) and [Docker Compose](https://docs.docker.com/compose/) to automate the deployment of Apple Software Update Services (Apple SUS), which consists of [Reposado](https://github.com/wdas/reposado) and [Margarita](https://github.com/jessepeterson/margarita).

This is more than just an Apple SUS image. Included in this repo is everything you need to get Apple SUS up and running as quickly as possible and a **pre-configured backup and restoration solution**.

## How-to guides

*Note: some of the commands in these guides may require root access to your system. If that is the case, either run the commands while logged in to the root account, or simulate a login to the root account using `sudo -i`. Due to the way environment variables are passed on some systems, typing `sudo` before each command is __not__ a supported method of running the commands in these guides with root access.*

### Installing

1. Ensure the following are installed on your system:

    * [Docker](https://docs.docker.com/engine/installation/)
    * [Docker Compose](https://docs.docker.com/compose/install/) **Warning: [installing as a container](https://docs.docker.com/compose/install/#install-as-a-container) is not supported.**
    * `git`
    * `tar`

2. Clone this repo to a location on your system. *Note: in all of the guides on this page, it is assumed the repo is cloned to `/srv/docker/applesus`.*

    ```shell
    git clone https://github.com/ianharrier/docker-applesus.git /srv/docker/applesus
    ```

3. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/applesus
    ```

4. Create the `.env` file using `.env.template` as a template.

    ```shell
    cp .env.template .env
    ```

5. Using a text editor, read the comments in the `.env` file, and make modifications to suit your environment.

    ```shell
    vi .env
    ```

6. Start Apple SUS in the background.

    ```shell
    docker-compose up -d
    ```

### Using Apple SUS

*Note: for more detailed information, refer to the official [Reposado docs](https://github.com/wdas/reposado/tree/master/docs).*

1. Optionally, the first time you use Apple SUS, you can force a synchronization instead of waiting for the first scheduled synchronization to occur.

    ```shell
    docker-compose exec sync reposado-sync
    ```

2. Navigate to the admin console at `http://<Docker-host-IP>:80/admin` (or whatever port you specified in the `.env` file).

3. Create new branches and approve updates.

4. Set the `CatalogURL` to `http://<Docker-host-IP>:80/index_<branch-name>.sucatalog` on a macOS client. [URL rewrites](https://github.com/wdas/reposado/blob/master/docs/URL_rewrites.md) are supported by this image.

### Upgrading

**Warning: the upgrade process will immediately stop and upgrade the current production environment. The application stack will be unavailable while it is being upgraded.**

1. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/jira
    ```

2. Run the upgrade script.

    ```shell
    ./scripts/app-upgrade.sh
    ```

### Running a one-time manual backup

1. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/applesus
    ```

2. Run the backup script.

    ```shell
    docker-compose exec cron app-backup
    ```

### Restoring from a backup

**Warning: the restoration process will immediately stop and delete the current production environment. You will not be asked to save any data before the restoration process starts.**

1. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/applesus
    ```

2. List the available files in the `backups` directory.

    ```shell
    ls -l backups
    ```

3. Specify a file to restore in the following format:

    ```shell
    ./scripts/app-restore.sh <backup-file-name>
    ```

    For example:

    ```shell
    ./scripts/app-restore.sh 20170501T031500+0000.tar.gz
    ```

### Uninstalling

1. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/applesus
    ```

2. Remove the application stack.

    ```shell
    docker-compose down
    ```

3. Delete the repo. **Warning: this step is optional. If you delete the repo, all of your Apple SUS data, including backups, will be lost.**

    ```shell
    rm -rf /srv/docker/applesus
    ```
