#!/bin/sh
#
# Clement Poh
#
# Designed to operate on the gradebook export from the LMS.  It unzips the
# gradebook if it exists and then unpacks each submission into its own folder.
#

# Detect whether 7z is installed
if ! command -v 7z &> /dev/null; then
    printf "Could not find 7z\n"
    exit 1
fi

# Change the working directory to the submissions folder
SUBS=${1:-"../subs"}
cd $SUBS

# The LMS export is named:
# gradebook_DEPTXXXXX_YYYY_SMX_*_YYYY-MM-DD-HH-mm-ss.zip
GRADEBOOK=$(ls | grep 'gradebook_.*.zip')
if [ -n "$GRADEBOOK" ]; then

    printf "Unpacking: $GRADEBOOK\n"
    7z x -aoa "$GRADEBOOK"

    printf "Deleting: $GRADEBOOK\n"
    rm "$GRADEBOOK"
fi

for file in *; do
    if [ -f "$file" ]; then
        # Using extended regexps, no need for backslash parentheses
        # Submissions are in the following format:
        # ASSIGNMENT_USERNAME_attempt_YYYY-MM-DD-HH-mm-ss_SID.FORMAT
        ARCHIVE="^.*_(.*)_attempt_[0-9\-]*_(.*)\.(tar\..*|zip|7z)$"
        NAME="$(echo $file | sed -r "s/$ARCHIVE/\1-\2/g")"

        case "$file" in
            *.zip | *.7z)
                # Change e to x to preserve paths
                7z e -aoa "$file" -o"$NAME"  &> /dev/null

                printf "Unpacking: $NAME\n"
                rm "$file"
                ;;
            *.tar.*)
                EXT=$(echo $file | sed -r "s/.*(\.tar\..*)/\1/g")
                DEST="$(basename "$NAME" "$EXT")"
                mkdir -p "$DEST"
                tar -xvf "$file" -C "$DEST" &> /dev/null

                printf "Unpacking: $NAME\n"
                rm "$file"
                ;;
            *.txt)
                USERNAME="$(echo $file | sed -r "s|^.*_(.*)_attempt_.*.txt$|\1|g")"
                FOLDER="$(find . -type d -name "$USERNAME-*")"
                if [ -n "$FOLDER" ]; then
                    mv "$file" "$FOLDER/lms.txt"
                fi
                ;;
            *) printf "Unrecognized file: $file\n"
        esac
    fi
done
