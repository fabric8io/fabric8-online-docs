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

# Copy landing page template
cp index-templ.adoc index.adoc

echo -e "=== Building Guides ===\n"
# Recurse through the guide directories and build them.
subdirs=`find . -maxdepth 1 -type d ! -iname ".*" ! -iname "topics" | sort`

# We need to remove OUTPUT_DIR when not building in container because
# otherwise, permissions wouldn't be changeable later on.
if [ ! -f /.dockerenv ] && [ -d $OUTPUT_DIR ]; then rm -rf $OUTPUT_DIR/ && mkdir -p $OUTPUT_DIR; fi
if [ -d ../images/ ]; then mkdir -p $OUTPUT_DIR/images/ && cp -r ../images/ $OUTPUT_DIR; fi

#echo $PWD
for subdir in $subdirs
do
  echo "Building $DOCS_SRC/${subdir##*/}"
  # Navigate to the directory and build it
  if ! [ -e $DOCS_SRC/${subdir##*/} ]; then
    BUILD_MESSAGE="$BUILD_MESSAGE\nERROR: $DOCS_SRC/${subdir##*/} does not exist."
    continue
  fi
  cd $DOCS_SRC/${subdir##*/}
  GUIDE_NAME=${PWD##*/}

  asciidoctor master.adoc -o $OUTPUT_DIR/$GUIDE_NAME.html
  if [ $? -eq 0 ]; then
    GUIDE_TITLE=$(sed '/^= .*/!d; q' master.adoc | sed 's/^= //')
    INDEX_LINK="* link:$GUIDE_NAME.html[$GUIDE_TITLE]"

    # Only build PDFs when in a container & when PDF-building possible
    if [ -f /.dockerenv ] && [ $(which asciidoctor-pdf 2> /dev/null) ]; then
      asciidoctor -r asciidoctor-pdf -b pdf master.adoc -o $OUTPUT_DIR/$GUIDE_NAME.pdf
      if [ $? -eq 0 ]; then
        INDEX_LINK="$INDEX_LINK (link:$GUIDE_NAME.pdf[PDF])"
      fi
    fi

    # Write completed link list item to landing page
    echo "$INDEX_LINK" >> $DOCS_SRC/index.adoc

  elif [ $? -eq 1 ]; then
    BUILD_ERROR="ERROR: Build of $GUIDE_NAME failed. See the log above for details."
    BUILD_MESSAGE="$BUILD_MESSAGE\n$BUILD_ERROR"
  fi
done

# Build the landing page
if [ -f $DOCS_SRC/index.adoc ]; then
  echo "Building $DOCS_SRC/index.adoc"
  asciidoctor $DOCS_SRC/index.adoc -o $OUTPUT_DIR/index.html
  if [ $? -eq 1 ]; then
    BUILD_ERROR="ERROR: Build of index.adoc failed. See the log above for details."
    BUILD_MESSAGE="$BUILD_MESSAGE\n$BUILD_ERROR"
  fi
  rm $DOCS_SRC/index.adoc
fi

chmod -R a+rwX $OUTPUT_DIR/

# Return to where we started as a courtesy.
cd $CURRENT_DIR
