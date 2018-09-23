#!/bin/bash


BORG_OPTIONS="--remote-path=borg1"
INIT_OPTIONS="--encryption=keyfile"
EXTRACT_OPTIONS="-v --list"
BORG_PATH="$RSYNC_DOT_NET_USER@$RSYNC_DOT_NET_DOMAIN"
BORG_TEMP_DIR="/tmp/borg_backup"


set_passphrase() {
        
        case "$1" in
                $HOME_REPO)
                        export BORG_PASSPHRASE=$HOME_PASSPHRASE
                        ;;
                $SYSTEM_REPO)
                        export BORG_PASSPHRASE=$SYSTEM_PASSPHRASE
                        ;;
                $NEXTCLOUD_REPO)
                        export BORG_PASSPHRASE=$NEXTCLOUD_PASSPHRASE
                        ;;
                $SYNC_REPO)
                        export BORG_PASSPHRASE=$SYNC_PASSPHRASE
                        ;;
                *)
                        { echo "'$1' is not a repo"; exit 1; }
                        ;;
        esac
}


usage() {
        echo "Usage: borgctl COMMAND [OPTIONS]"
        echo ""
        echo "unmount"
        echo "create REPO"
        echo "list REPO [ARCHIVE]"
        echo "check REPO [ARCHIVE]"
        echo "delete REPO [ARCHIVE]"
        echo "mount REPO [ARCHIVE]"
        echo "extract REPO ARCHIVE [PATH]"
        echo "rename REPO ARCHIVE NEW_NAME"
        echo ""
}


## Functions for REPOS and ARCHIVES

list() {

        repo="$1"
        archive="$2"

        if [[ ! -z $archive ]]; then
                borg list $BORG_OPTIONS $BORG_PATH:$repo::$archive
        else
                borg list $BORG_OPTIONS $BORG_PATH:$repo
        fi
}

check() {

        repo="$1"
        archive="$2"

        if [[ ! -z $archive ]]; then
                borg check $BORG_OPTIONS $BORG_PATH:$repo::$archive
        else
                borg check $BORG_OPTIONS $BORG_PATH:$repo
        fi
}


delete() {

        repo="$1"
        archive="$2"

        if [[ ! -z $archive ]]; then
                borg delete $BORG_OPTIONS $BORG_PATH:$repo::$archive
        else
                borg delete $BORG_OPTIONS $BORG_PATH:$repo
        fi
}




## Functions only for REPOS

create() {

        repo="$1"

        borg init $BORG_OPTIONS $INIT_OPTIONS $BORG_PATH:$repo
}



## Functions only for ARCHIVES

mount() {

        repo="$1"
        archive="$2"

        [[ -z $archive ]] && { echo "Must specify an archive to mount"; exit 1; }

        mkdir -p $BORG_TEMP_DIR
        borg mount $BORG_OPTIONS $BORG_PATH:$repo::$archive $BORG_TEMP_DIR
}


unmount() {

        if [[ -d $BORG_TEMP_DIR ]]; then
                fusermount -u $BORG_TEMP_DIR && rmdir $BORG_TEMP_DIR
        else
                echo "No backup mounted"
        fi
}


rename() {

        repo="$1"
        archive="$2"
        new_name="$3"

        [[ -z $archive ]] && { echo "Must specify an archive to rename"; exit 1; }
        [[ -z $new_name ]] && { echo "Must provide a new name for archive"; exit 1; }

        borg rename $BORG_OPTIONS $BORG_PATH:$repo::$archive $new_name
}


extract() {

        repo="$1"
        archive="$2"
        path="$3"

        if [[ ! -z $path ]]; then
                borg extract $EXTRACT_OPTIONS $BORG_OPTIONS $BORG_PATH:$repo::$archive $path
        else
                borg extract $EXTRACT_OPTIONS $BORG_OPTIONS $BORG_PATH:$repo::$archive
        fi
}
