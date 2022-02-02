# SNAP lab setup

## First steps

1. **Install `docker` and `docker-compose`**

2. **Setup the SNAP workspace.** After cloning this repository, execute the `scripts/init.sh` script: `$ ./scripts/init.sh`. This will create a `shared` folder in this repository directory, which will contain all the SNAP relevant projects and will be shared with the containers. *This script should run only once.*

## Vigor

### Cheat sheet

|  Action  |                                Commands                                |
|:--------:|:----------------------------------------------------------------------:|
|   Build  | ``` $ docker-compose build snap <br \> $ docker-compose build vigor ``` |
|  Spin up |                  ``` $ docker-compose up -d vigor ```                  |
|  Access  |                 ``` $ docker-compose exec vigor zsh ```                |
| Shutdown |                      ``` $ docker-compose down ```                     |

### Hugepages

To allocate hugepages on linux, just execute the `hugepages.sh` provided script:

```
$ sudo ./scripts/hugepages.sh
```

This will allocate 2M hugepages, mounted on `/mnt/hugepages2M`, and later shared with the vigor container.

## SyNAPSE

### Dependencies:
  * `patches.tgz` \*
  * `bf-sde-9.7.0.tgz` \*
  * `bf-reference-bsp-9.7.0.tgz` \*
  * `ica-tools.tgz` \*

\* This is a confidential file provided by Intel. You can access it via the [SNAP wiki](https://snaplab.2y.net/InstallingTheTofinoSDE). 

### Cheat sheet

|  Action  |                                Commands                                |
|:--------:|:----------------------------------------------------------------------:|
|   Build  | ``` $ docker-compose build snap <br \> $ docker-compose build synapse ``` |
|  Spin up |                  ``` $ docker-compose up -d synapse ```                  |
|  Access  |                 ``` $ docker-compose exec synapse zsh ```                |
| Shutdown |                      ``` $ docker-compose down ```                     |

### Run p4 programs using the tofino model

Let's consider you want to compile your p4 program named `my_program.p4`:

1. `$ ~/tools/veth_setup.sh [number of virtual interfaces]`
2. `$ ~/tools/p4_build.sh my_program.p4`
3. `$ $SDE/run_tofino_model.sh -p my_program` (on another terminal)
4. `$ $SDE/run_switchd.sh -p my_program` (on yet another terminal)

## Scripts

### Setting up your personal environment

By default the vigor's setup script grabs the latest information from Francisco Pereira's github repositories. However, this may not be what you intend. As such, there is a script called `setup_personal_env.sh` in the `scripts` folder which asks which specific vigor repositories you want to target.

If you are using Linux and want to add a repository via SSH instead of cloning via HTTPS, don't forget to add the following configuration to your `~/.ssh/config` file:

```
Host                    *
  ForwardAgent          yes 
```

This way, the vagrant machine can use the keys from your host to access your personal repositories via SSH. If you already did this and keep having issues, don't forget to check if your ssh-agent knows about your keys. Use `ssh-add -l` to check if your key is listed. Otherwise, you can add it using `ssh-add`.

### Generating BDDs

You can generate BDDs for every NF using this script. Just run `generate_bdds.sh` and it will create a `~/bdds` folder containing both the BDDs and the graphviz images for each NF.
