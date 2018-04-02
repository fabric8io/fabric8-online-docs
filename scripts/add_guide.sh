#!/usr/bin/env bash

# Check for args supplied, show usage help
case "$1" in
  "" | "?" | "-h" | "-help" | "--help")
  echo "Create a directory structure for a new guide in the repo.

Usage: $(basename $0) <\"New Guide Name\">

Enter the guide name in quotes.

  -h, --help   Show this help message."
  exit 1
  ;;
esac

# Remove quotes from guide name
GUIDE_NAME=$(echo "$1" | sed 's/"//g')

# Check if name contains non-ASCII chars
if [[ $GUIDE_NAME = *[![:ascii:]]* ]]; then

  # Check whether we have 'iconv' in PATH
  if [ $(which iconv 2> /dev/null) ]; then

    # Convert name to ASCII-only chars
    GUIDE_NAME=$(echo "$GUIDE_NAME" | iconv -f utf8 -t ascii//translit)
  else
    echo "Your chosen guide name ($GUIDE_NAME) contains non-ASCII characters, and the 'iconv' conversion utility isn't available to fix the problem. Change the guide name to ASCII (or install 'iconv')." | fold -s
    exit 1
  fi
fi

# Saves where the user currently is
HOME=$(pwd)

# Changes you to the root of the project, ensuring the script runs consistently
cd $(dirname $0)/..

# Convert guide name to lowercase,
# substitute non-alphanum chars with dashes
DIR_NAME=$(echo "${GUIDE_NAME,,}" | sed -r -e 's/[^[:alnum:]]+/-/g' \
                                           -e 's/^-//')

# Abort if the directory already exists
if [ -d docs/titles/$DIR_NAME ]; then
  echo "Guide directory '$DIR_NAME' already exists. Aborting"
  exit 1
fi

# Check correctness of input with user
echo -n "The following data will be used:

Guide name:     $GUIDE_NAME
Directory name: $DIR_NAME

OK? [Y/n] "
read -n 1 CONFIRM
case "$CONFIRM" in
  "" | "y" | "Y")
    ;;
  "n" | "N")
    echo
    exit 0
    ;;
esac

# Create a new dir for the new guide
mkdir docs/titles/$DIR_NAME

# Go into guide dir we just created
cd docs/titles/$DIR_NAME/

# Create basic symlinks to content dirs
for CONTENT_DIR in files images meta styles topics; do
  ln -s ../../$CONTENT_DIR $CONTENT_DIR
done

# Write a basic master.adoc file
cat > master.adoc << EOF
include::meta/attributes.adoc[]

= OpenShift.io $GUIDE_NAME
:author: {rhd} Documentation Team
:email: openshiftio@redhat.com
:revdate: {docdate} {doctime}

This is the abstract for the new guide.

include::topics/$DIR_NAME.adoc[]
EOF

# Write a basic main assembly for the guide
cat > topics/$DIR_NAME.adoc << EOF
// Includes for all assemblies that form the top-level sections of the $GUIDE_NAME
:context: $DIR_NAME

[id="first-section"]
= First section
EOF

# Offer a basic commit command
echo -e "\n\nTo commit the initial state of $GUIDE_NAME, run:

git commit -am \"Initial commit of the $GUIDE_NAME.\""

# Go back to where user was
cd $HOME
