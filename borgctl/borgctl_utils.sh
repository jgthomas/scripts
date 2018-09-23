#!/bin/bash


BORG_OPTIONS="--remote-path=borg1"
BORG_PATH="$RSYNC_DOT_NET_USER@$RSYNC_DOT_NET_DOMAIN"


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
                        { echo "'$2' is not a repo"; exit 1; }
                        ;;
        esac
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
        if [[ $# -eq 1 ]]; then
                borg delete --remote-path=borg1 \
                        $RSYNC_DOT_NET_USER@$RSYNC_DOT_NET_DOMAIN:"$1"
        elif [[ $# -eq 2 ]]; then
                borg delete --remote-path=borg1 \
                        $RSYNC_DOT_NET_USER@$RSYNC_DOT_NET_DOMAIN:"$1"::"$2"
        fi
}




## Functions only for REPOS

create() {
        borg init --remote-path=borg1 --encryption=keyfile \
                $RSYNC_DOT_NET_USER@$RSYNC_DOT_NET_DOMAIN:"$1"
}



## Functions only for ARCHIVES

mount() {
        mkdir -p /tmp/borg_backup
        borg mount --remote-path=borg1 \
                $RSYNC_DOT_NET_USER@$RSYNC_DOT_NET_DOMAIN:"$1"::"$2" \
                /tmp/borg_backup
}


unmount() {
        if [[ -d /tmp/borg_backup ]]; then
                fusermount -u /tmp/borg_backup && rmdir /tmp/borg_backup
        else
                echo 'No backup mounted'
        fi
}


rename() {
        if [[ $# -eq 3 ]]; then
                borg rename --remote-path=borg1 \
                        $RSYNC_DOT_NET_USER@$RSYNC_DOT_NET_DOMAIN:"$1"::"$2" "$3"
        else
                { echo "Not enough arguments to rename"; exit 1; }
        fi
}


extract() {
        if [[ $# -eq 2 ]]; then
                borg extract -v --list --remote-path=borg1 \
                        $RSYNC_DOT_NET_USER@$RSYNC_DOT_NET_DOMAIN:"$1"::"$2"
        elif [[ $# -eq 3 ]]; then
                borg extract --remote-path=borg1 \
                        $RSYNC_DOT_NET_USER@$RSYNC_DOT_NET_DOMAIN:"$1"::"$2" "$3"
        fi
}
