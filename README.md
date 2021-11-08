# SyNAPSE

## Dependencies:
  * VirtualBox
  * Vagrant
  * `bf-sde-9.7.0.tgz` -- this is a confidential file provided by Intel. You can access it via the [SNAP wiki](https://snaplab.2y.net/InstallingTheTofinoSDE). 

## Scripts

### Setting up your personal environment

By default the vigor's setup script grabs the latest information from Luis Pedrosa's github repositories. However, this may not be what you intend. As such, there is a script called `setup_personal_env.sh` in the `scripts` folder which asks which specific vigor repositories you want to target.

If you are using Linux and want to add a repository via SSH instead of cloning via HTTPS, don't forget to add the following configuration to your `~/.ssh/config` file:

```
Host                    *
  ForwardAgent          yes 
```

This way, the vagrant machine can use the keys from your host to access your personal repositories via SSH. If you already did this and keep having issues, don't forget to check if your ssh-agent knows about your keys. Use `ssh-add -l` to check if your key is listed. Otherwise, you can add it using `ssh-add`.

### Generating BDDs

You can generate BDDs for every NF using this script. Just run `generate_bdds.sh` and it will create a `~/bdds` folder containing both the BDDs and the graphviz images for each NF.
