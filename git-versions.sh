#/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SHARED="$DIR/shared"

REPO="git://github.com/markwilson/git-releases.git"

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

if [ -d "$DIR/$TAG" ]
then
	echo "$DIR/$TAG already exists."
	exit 3
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
		exit 4
	fi
	
	cd $SHARED
	echo "Updating repository..."
	git fetch -a > /dev/null 2>&1
	RETVAL=$?
	if [ $RETVAL -ne 0 ]
	then
		echo "Repository update failed."
		exit 5
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
	exit 6
fi
echo "$TAG checked out."
cd $DIR

echo "Copying $TAG to $DIR/$TAG..."
cp -rf $SHARED $DIR/$TAG
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
	echo "Copy failed."
	exit 7
fi
echo "Copy complete."

echo "Cleaning up..."
rm -rf $DIR/$TAG/.git
if [ $RETVAL -ne 0 ]
then
	echo "Clean up failed."
	exit 8
fi
echo "Clean up complete."

echo "Complete."
