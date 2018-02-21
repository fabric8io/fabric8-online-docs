#!/bin/bash

GLOSSARY_FILE=docs/topics/modules/glossary.adoc
JSON_FILE=json/infotips.jo
JO=""

if [ -f $JSON_FILE ]; then rm $JSON_FILE; fi

terms=$(grep '^// term:' $GLOSSARY_FILE | wc -l);

for (( i=1; i<=$terms; i++ )); do
  TERM="$(awk "/^\/\/ term:/ { f = 1; n++ } f && n == $i; /^\/\/ endterm/ { f = 0 }" $GLOSSARY_FILE)"
  UUID=$(echo "$TERM" | sed -e '/^\/\/ term:/!d; s|^// term: \([^,]*\),.*$|\1|')
  L10N=$(echo "$TERM" | sed -e '/^\/\/ term:/!d; s|^// term: \([^,]*\), \(.*\)$|\2|')
  TERM_NAME="$(echo "$TERM" | sed -e '/^.*:: /!d' \
                                 -e 's|^\([^::]*\):: .*$|\1|')"
  TERM_DEFINITION="$(echo "$TERM" | sed -e '/^\/\/ term:/d; /^\/\/ endterm/d' \
                                       -e 's|^[^::]*:: ||')"

  JO="$JO ${UUID}[term]='$TERM_NAME' ${UUID}[${L10N}]='$TERM_DEFINITION' "
#   echo $L10N
#   echo "$TERM_NAME"
#   echo "$TERM_DEFINITION"
#   sed -e '/^\/\/ endterm/d' \
#       -e 's|^// term: \([^,]*\), \(.*\)$|\1[\2]=|' \
#       -e '/=$/N; s/=\n/=/' \
#       -e 's/^\([^=]*\)=\(.*\):: \(.*\)$/\1[term]=\2 \1=/';
done

echo $JO > $JSON_FILE
#jo -p $(echo $JO)
