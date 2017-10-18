
#Name of the html output file
GUIDE_HTML_NAME=openshift-io_end_to_end_workshop.html
OUTPUT_DIR=../../html

rm -r $OUTPUT_DIR/images/
cp -r topics/images/ $OUTPUT_DIR/images/

asciidoctor master.adoc -o $OUTPUT_DIR/$GUIDE_HTML_NAME
