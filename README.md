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

### Installing

1. Ensure the following are installed on your system:

    * [Docker](https://docs.docker.com/engine/installation/)
    * [Docker Compose](https://docs.docker.com/compose/install/) **Warning: [installing as a container](https://docs.docker.com/compose/install/#install-as-a-container) is not supported.**
    * `git`

2. Clone this repo to a location on your system. *Note: in all of the guides on this page, it is assumed the repo is cloned to `/srv/docker/applesus`.*

    ```shell
    sudo git clone https://github.com/ianharrier/docker-applesus.git /srv/docker/applesus
    ```

3. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/applesus
    ```

4. Create the `.env` file using `.env.template` as a template.

    ```shell
    sudo cp .env.template .env
    ```

5. Using a text editor, read the comments in the `.env` file, and make modifications to suit your environment.

    ```shell
    sudo vi .env
    ```

6. Start Apple SUS in the background.

    ```shell
    sudo docker-compose up -d
    ```

### Using Apple SUS

*Note: for more detailed information, refer to the official [Reposado docs](https://github.com/wdas/reposado/tree/master/docs).*

1. Optionally, the first time you use Apple SUS, you can force a synchronization instead of waiting for the first scheduled synchronization to occur.

    ```shell
    sudo docker-compose exec sync /usr/local/reposado/code/repo_sync
    sudo docker-compose exec sync chmod -R 664 /srv/reposado/html /srv/reposado/metadata
    sudo docker-compose exec sync chgrp -R 33 /srv/reposado/html /srv/reposado/metadata
    ```

2. Navigate to the admin console at `http://<Docker-host-IP>:80/admin` (or whatever port you specified in the `.env` file).

3. Create new branches and approve updates.

4. Set the `CatalogURL` to `http://<Docker-host-IP>:80/index_<branch-name>.sucatalog` on a macOS client. [URL rewrites](https://github.com/wdas/reposado/blob/master/docs/URL_rewrites.md) are supported by this image.

### Upgrading

*Note: neither Reposado nor Margarita publish 'releases' on GitHub, so these instructions simply delete the current images and build new ones, effectively pulling any changes from the two upstream repositories.*

1. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/applesus
    ```

2. Remove the current application stack.

    ```shell
    sudo docker-compose down
    ```

3. Pull any changes from the repo.

    ```shell
    sudo git pull
    ```

4. Backup the `.env` file.

    ```shell
    sudo mv .env backups/.env.old
    ```

5. Create a new `.env` file using `.env.template` as a template.

    ```shell
    sudo cp .env.template .env
    ```

6. Using a text editor, modify the new `.env` file.

    ```shell
    sudo vi .env
    ```

7. Delete the current images.

    ```shell
    sudo docker rmi ianharrier/reposado
    sudo docker rmi ianharrier/margarita
    ```

8. Start Apple SUS in the background.

    ```shell
    sudo docker-compose up -d
    ```

9. When all is confirmed working, remove the the `.env.old` file.

    ```shell
    sudo rm backups/.env.old
    ```

### Running a one-time manual backup

1. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/applesus
    ```

2. Run the backup script.

    ```shell
    sudo docker-compose exec backup app-backup
    ```

### Restoring from a backup

**Warning: the restoration process will immediately stop and delete the current production environment. You will not be asked to save any data before the restoration process starts.**

1. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/applesus
    ```

2. Make sure the **backup** container is running. *Note: if the container is already running, you can skip this step, but it will not hurt to run it anyway.*

    ```shell
    sudo docker-compose up -d backup
    ```

3. List the available files in the `backups` directory.

    ```shell
    ls -l backups
    ```

4. Specify a file to restore in the following format:

    ```shell
    sudo docker-compose exec backup app-restore <backup-file-name>
    ```

    For example:

    ```shell
    sudo docker-compose exec backup app-restore 20170501T031500+0000.tar.gz
    ```

### Uninstalling

1. Set the working directory to the root of the repo.

    ```shell
    cd /srv/docker/applesus
    ```

2. Remove the application stack.

    ```shell
    sudo docker-compose down
    ```

3. Delete the repo. **Warning: this step is optional. If you delete the repo, all of your Apple SUS data, including backups, will be lost.**

    ```shell
    sudo rm -rf /srv/docker/applesus
    ```
