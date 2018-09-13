#!/bin/bash
#
# A script to make dd to a usb drive safer
#

# Assign script name
PROGRAM=$(basename $0)

# Assign colours and formatting
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

# Assign input and output
INPUT="$1"
OUTPUT="$2"

# Test variables
INTERNAL_SCSI="/dev/sd[a,b,c,d]"

usage()
{
        printf "\nThis is $PROGRAM: a script which runs a series of sanity checks on dd\n"
        printf "\n\n$PROGRAM needs two arguments:\n\n"
        printf "(1) an input file (dd's IF=), typically a .iso file.\n"
        printf "(2) an ouput file (dd's OF=), typically a usb thumb drive.\n"
        printf "\n\nSample usage: ddsafer linux-distro.iso /dev/sde\n\n"

        exit
}

confirm()
{
        _file="$2"

        # Prompt for confirmation
        read  -r -p "Is "\'${BOLD}$1${NORMAL}\'" the desired "$_file" file? [y/n] " response
        response=${response,,} # convert to lower case
        if [[ "$response" =~ ^(yes|y)$ ]]; then
               printf '\n%s\n\n' "${GREEN}OK${NORMAL}"
        else
                printf '\n%s\n\n' "dd command aborted...exiting"
                exit
        fi
}


# Exit if incorrect number of arguments used
if [[ ! $# == 2 ]]; then
        usage
fi


### TEST INPUT ###
if [[ "$INPUT" != *.iso ]]; then
        # give warning if input file is not an .iso 
        printf '\n%s\n\n' "${RED}WARNING${NORMAL}: "\'$INPUT\'" does not seem to be a .iso file"
        # ask for confirmation, e.g. may be a .img file or copying directly between disks
        confirm "$INPUT" "input"
else
        printf '\n%s\n\n' "Input file '${BOLD}$INPUT${NORMAL}' appears to be an .iso file...${GREEN}OK${NORMAL}"
fi



### TEST OUTPUT ###
# Check output file is NOT an internal SCSI disk
if [[ "$OUTPUT" == $INTERNAL_SCSI ]]; then
        # give warning if might be an internal disk
        printf '\n%s\n\n' "${RED}WARNING${NORMAL}: "\'$OUTPUT\'" looks like it might be an internal SCSI disk"
        # ask for confirmation, e.g. may be restoring a backup from a .img
        confirm "$OUTPUT" "output"
else
        echo "Ouput file '${BOLD}$OUTPUT${NORMAL}' appears not to be an internal SCSI disk...${GREEN}OK${NORMAL}"
fi

# Check device is NOT mounted
if grep -qs "$OUTPUT" /proc/mounts; then
        # if mounted, give warning and exit - disk must be unmounted for dd
        printf '\n%s\n\n' "${RED}WARNING${NORMAL}: ${BOLD}'$OUTPUT'${NORMAL} is mounted, unmount and try again...exiting"
        exit
else
        printf '\n%s\n\n' "Output file ${BOLD}'$OUTPUT'${NORMAL} is not mounted...${GREEN}OK${NORMAL}"
fi

# Prompt final explicit check of the output file
if [[ "$OUTPUT" == /dev/* ]]; then
        # if output is a block device prompt check against a list...
        printf '\n%s\n\n' "Just to confirm, check "${BOLD}\'$OUTPUT\'${NORMAL}" against this list of block devices:" 
        lsblk --paths | grep --color -E "^$OUTPUT.*$|$"
        printf '\n\n'
        confirm "$OUTPUT" "output"
else
        # ...else just prompt for confirmation, for .img files, etc.
        confirm "$OUTPUT" "output"
fi



### PRINT CONFIRMATION ###
printf '%s\n\n' ""\'${BOLD}$INPUT${NORMAL}\'" is confirmed as the input file"
printf '%s\n\n' ""\'${BOLD}$OUTPUT${NORMAL}\'" is confimed as the output file"
printf '\n%s\n\n' "The following command will be run: "
printf '%s\n\n' "'dd bs=4M if=${BOLD}$INPUT${NORMAL} of=${BOLD}$OUTPUT${NORMAL} status=progress && sync'"



### FINAL PROMPT ###
read  -r -p "If this command is OK, answer yes to run [y/n] " response
response=${response,,} # to lower case
if [[ $response =~ ^(yes|y)$ ]]; then
        printf '\n%s\n\n' "Running command..."
        dd bs=4M if=$INPUT of=$OUTPUT status=progress && sync
else
        printf '\n%s\n\n' "dd command has been aborted"
        exit
fi


