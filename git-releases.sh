#!/bin/bash

# constants
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
declare -r DIR
RELEASES=$DIR/.releases
declare -r RELEASES

# options
SHARED="$DIR/shared"
TAGS="$DIR/tags"
REPO="git://github.com/markwilson/git-releases.git"
CLEANUP=0
OVERWRITE=0

while getopts "s:t:r:co" opt
do
    case $opt in
        s)
            SHARED=$DIR/$OPTARG
            ;;

        t)
            TAGS=$DIR/$OPTARG
            ;;

        r)
            REPO=$OPTARG
            ;;

        c)
            CLEANUP=1
            ;;

        o)
            OVERWRITE=1
            ;;

        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

# clear the options
shift $((OPTIND-1))

# no options supplied, show usage message
if [ $# -eq 0 ]
then
    # no arguments supplied
    if [ ! -e "$RELEASES" ]
    then
        echo "Usage: $0 [-r REPO] [-c] [-o] [-s SHARED] [-t TAGS] <tag|branch>"
        exit 1
    fi
fi

if [ ! -e "$RELEASES" ]
then
    echo "Generating releases file..."
    echo "SHARED=$SHARED" >> $RELEASES
    echo "TAGS=$TAGS" >> $RELEASES
    echo "REPO=$REPO" >> $RELEASES
    echo "CLEANUP=$CLEANUP" >> $RELEASES
    echo "OVERWRITE=$OVERWRITE" >> $RELEASES

    echo "Generated releases file."
else
    echo "Loading configuration..."
    source "$RELEASES"
    echo "Loaded configuration."
fi

function create_git_repo {
    # create a shared branch
    echo "Creating shared repository..."
    git clone $REPO $SHARED > /dev/null 2>&1
    RETVAL=$?
    if [ $RETVAL -ne 0 ]
    then
        echo "Shared repository creation failed."
        exit 1
    fi
    echo "Shared repository created."
}

TAG=$1

if [ -z $TAG ]
then
    echo "Usage: $BASH_SOURCE[0] <tag|branch>"
    exit 2
fi

if [ ! -d "$TAGS" ]
then
    echo "Created tags directory..."
    mkdir "$TAGS"
    RETVAL=$?
    if [ $RETVAL -ne 0 ]
    then
        echo "Creating tags directory failed."
        exit 3
    fi
    echo "Tags directory created."
fi

if [ -d "$TAGS/$TAG" ]
then
    echo "Tag $TAG already exists."
    if [ $OVERWRITE -eq 1 ]
    then
        echo "Removing $TAG..."
        rm -rf "$TAGS/$TAG"
        RETVAL=$?
        if [ $RETVAL -ne 0 ]
        then
            echo "Removing $TAG failed."
            exit 4
        fi
        echo "Removed $TAG."
    else
        exit 5
    fi
fi

if [ ! -d "$SHARED" ]
then
    # no shared git directory
    create_git_repo
else
    if [ ! -d "$SHARED/.git" ]
    then
        # no git folder
        echo "$SHARED already exists but is not a repository."
        exit 6
    fi
    
    cd $SHARED
    echo "Updating repository..."
    git fetch -a > /dev/null 2>&1
    RETVAL=$?
    if [ $RETVAL -ne 0 ]
    then
        echo "Repository update failed."
        exit 7
    fi
    echo "Repository updated."
    cd $DIR
fi

cd $SHARED
echo "Checking out $TAG..."
git checkout $TAG > /dev/null 2>&1
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
    echo "Checkout failed."
    exit 8
fi
echo "Checked out $TAG"
cd $DIR

echo "Copying $TAG to $TAGS/$TAG..."
cp -rf $SHARED $TAGS/$TAG
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
    echo "Copy failed."
    exit 9
fi
echo "Copy complete."

if [ $CLEANUP ]
then
    echo "Cleaning up..."
    rm -rf $TAGS/$TAG/.git
    if [ $RETVAL -ne 0 ]
    then
        echo "Clean up failed."
        exit 8
    fi
    echo "Clean up complete."
fi

echo "Complete."
