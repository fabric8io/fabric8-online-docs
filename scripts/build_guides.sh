#!/usr/bin/env bash

CURRENT_DIR="$( pwd -P)"
SCRIPT_SRC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
OUTPUT_DIR="$( dirname $SCRIPT_SRC )/html"
DOCS_SRC="$( dirname $SCRIPT_SRC )/docs/titles"
BUILD_RESULTS="Build Results:"
BUILD_MESSAGE=$BUILD_RESULTS

# Validate guides
if ! $SCRIPT_SRC/validate_guides.sh; then exit 1; fi

# Move to docs dir
cd $DOCS_SRC
cp index-templ.adoc index.adoc

echo -e "=== Building Guides ===\n"

# Find guide directories and store them in $GUIDE_DIRS
GUIDE_DIRS=$(find . -maxdepth 1 -type d ! -iname ".*" | sort)

# We need to remove OUTPUT_DIR when not building in container because
#   otherwise, permissions wouldn't be changeable later on.
if [ ! -f /.dockerenv ] && [ -d $OUTPUT_DIR ]; then rm -rf $OUTPUT_DIR/ && mkdir -p $OUTPUT_DIR; fi
if [ -d ../images/ ]; then mkdir -p $OUTPUT_DIR/images/ && cp -r ../images/ $OUTPUT_DIR; fi

# Recurse through guide dirs and build ther docs in them
for GUIDE_DIR in $GUIDE_DIRS
do
  # Check if guide dir exists
  if ! [ -e $DOCS_SRC/${GUIDE_DIR##*/} ]; then
    echo "ERROR: ${GUIDE_DIR##*/} does not exist."
    continue
  fi

  # Navigate to the directory
  cd $DOCS_SRC/${GUIDE_DIR##*/}

  echo "Building ${GUIDE_DIR##*/}"
  GUIDE_NAME=${GUIDE_DIR##*/}

  # Build the guide
  asciidoctor master.adoc -o $OUTPUT_DIR/$GUIDE_NAME.html

  # If build successful...
  if [ $? -eq 0 ]; then

    # Assemble info for landing page
    #GUIDE_TITLE=$(sed '/^= .*/!d; q' master.adoc | sed 's/^= //')
    #INDEX_LINK="* link:$GUIDE_NAME.html[$GUIDE_TITLE]"

    # Only build PDFs when in a container & when PDF-building possible
    if [ -f /.dockerenv ] && [ $(which asciidoctor-pdf 2> /dev/null) ]; then
      asciidoctor -r asciidoctor-pdf -b pdf master.adoc -o $OUTPUT_DIR/$GUIDE_NAME.pdf
      if [ $? -eq 1 ]; then
        echo "ERROR: PDF build of $GUIDE_NAME failed. See the log above for details."
      fi
#       if [ $? -eq 0 ]; then
#         INDEX_LINK="$INDEX_LINK (link:$GUIDE_NAME.pdf[PDF])"
#       fi
    else
       sed -i "s/ (link:$GUIDE_NAME\.pdf\[PDF\])//" $DOCS_SRC/index.adoc
    fi

    # Write completed link list item to landing page
    #echo "$INDEX_LINK" >> $DOCS_SRC/index.adoc

  # If build failed, output error messages
  elif [ $? -eq 1 ]; then
    echo "ERROR: Build of $GUIDE_NAME failed. See the log above for details."
  fi
done

# Build the landing page
cd $DOCS_SRC

if [ -f index.adoc ]; then
  echo "Building index.adoc"
  asciidoctor index.adoc -o $OUTPUT_DIR/index.html
  if [ $? -eq 1 ]; then
    echo "ERROR: Build of index.adoc failed. See the log above for details."
  fi
  rm index.adoc
fi

chmod -R a+rwX $OUTPUT_DIR/

# Return to where we started as a courtesy.
cd $CURRENT_DIR
