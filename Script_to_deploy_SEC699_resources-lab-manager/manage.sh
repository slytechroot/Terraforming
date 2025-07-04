#!/bin/bash

# By default ask for updating
### Update repository
update_repo() {
    echo "Verifying upstream updates of SEC699 lab-manager"
    git fetch >> /dev/null 2>&1

    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")

    if [ $LOCAL = $REMOTE ]; then
        echo "Your current version is up to date."
    else
        echo "Your current version is out of date. Do you want to update (will overwrite local changes) (Yy/Nn)"
        read -p "... " -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            echo "Updating..."
            git reset --hard >> /dev/null 2>&1
            git pull
            ./install.sh
            echo "SEC699 lab-manager updated"
	    echo "Please relaunch your command"
	    exit 0
        else
            echo "Skipping update..."
        fi
    fi
}
# Verify if update is required on script-
update_repo

if [ -f ./update_lock ]; then
    ./install.sh
    rm ./update_lock
fi

python3 ./manage.py "$@"