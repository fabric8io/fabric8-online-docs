
#Name of the html output file
GUIDE_HTML_NAME=openshift-io_user_guide
OUTPUT_DIR=../../html

rm -r $OUTPUT_DIR/images/
cp -r topics/images/ $OUTPUT_DIR/images/

asciidoctor master.adoc -o $OUTPUT_DIR/$GUIDE_HTML_NAME.html
asciidoctor -r asciidoctor-pdf -a imagesdir="topics/images" -b pdf master.adoc -o $OUTPUT_DIR/$GUIDE_HTML_NAME.pdf
