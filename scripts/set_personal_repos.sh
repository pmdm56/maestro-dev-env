#!/usr/bin/bash

set -e

help() {
   # Display Help
   echo "Setup you personal environment by replacing the default repositories with your own."
   echo
   echo "Syntax: setup_personal_env.sh -u [github_user] -c [connection]"
   echo "options:"
   echo "  h               Print this Help."
   echo "  github_user     Github username."
   echo "  connection      Connection type. Can either be \"ssh\" or \"https\"."
   echo

   exit
}

if [[ $# == 0 ]]; then
    help
fi

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -h)
      help
      exit
      ;;
    -u)
      username="$2"
      shift # past argument
      shift # past value
      ;;
    -c)
      connection="$2"
      shift # past argument
      shift # past value
      ;;
    *)
      help
      ;;
  esac
done

case $connection in
    "https"|"ssh") ;;
    *)
        echo "Error: Invalid connection (can only be \"https\" or \"ssh\")"
        exit;;
esac

echo "Running with the following arguments:"
echo "  username:   $username"
echo "  connection: $connection"
echo

if [ "$connection" == "https" ]; then
    prefix="https://github.com/"
else
    prefix="git@github.com:"
fi

vigor_new_remote="$prefix""$username"/vigor.git
klee_new_remote="$prefix""$username"/vigor-klee.git

# change vigor remote repository
echo "Changing vigor remote to \"$vigor_new_remote\""
cd $VIGOR_DIR/vigor
git remote set-url origin $vigor_new_remote > /dev/null 2>&1
git pull origin master > /dev/null 2>&1

# change KLEE remote repository
echo "Changing KLEE remote to \"$klee_new_remote\""
cd $KLEE_DIR
git remote set-url origin $klee_new_remote > /dev/null 2>&1
git pull origin master > /dev/null 2>&1
./build.sh > /dev/null 2>&1

echo "Done!"
