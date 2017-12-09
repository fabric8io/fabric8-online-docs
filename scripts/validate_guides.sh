#!/usr/bin/env bash

# Builds all books into DocBook 5 XML and validates them using XMLlint.

SCRIPT_SRC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
DOCS_SRC="$( dirname $SCRIPT_SRC )/docs"
XML_SCHEMA="$SCRIPT_SRC/xml-schema/docbook.xsd"

RED='\033[0;31m'
GRN='\033[0;32m'
NOC='\033[0m'

failed_builds=""
failed_validations=""
exit_status=0

# Check for binaries
for binary in asciidoctor xmllint; do
    if ! $binary --version &>/dev/null; then
        echo The "$binary" binary is required for validation, please install it.
        exit 1
    fi
done

# Validate Books
echo -e "=== Validating Guides ===\n"
for book in $DOCS_SRC/*/master.adoc; do
    dir="$(dirname $book)"
    echo -ne "Processing $(basename $dir)\t\t"
    pushd $dir >/dev/null

    # Check if this book is ignored in the CI builds
    if test -e .ci-ignore; then
        popd >/dev/null
        continue
    fi

    # Build title into DocBook XML and see if any errors or warnings were output
    adoctor_stderr="$(asciidoctor master.adoc -b docbook5 2>&1)"
    if [ ! -z "$(echo "$adoctor_stderr" | grep "ERROR\|WARNING")" ]; then
        echo -e "${RED}failed to build${NOC}"
        echo -e "\n${adoctor_stderr}\n"
        failed_builds="$failed_builds $dir"
        popd >/dev/null
        continue
    fi

    # Validate the DocBook XML
    xmllint_stderr="$(xmllint --noout --schema $XML_SCHEMA master.xml 2>&1)"
    if [ ! $? -eq 0 ]; then
        echo -e "${RED}failed to validate${NOC}"
        echo -e "\n${xmllint_stderr}\n"
        failed_validations="$failed_validations $dir"
    else
        echo -e "${GRN}validation success${NOC}"
    fi
    popd >/dev/null
done

echo

# Output failed builds
if test -n "$failed_builds"; then
    exit_status=$((exit_status+1))
    echo -e "Failed builds:"
    for failed_build in $failed_builds; do
        echo " * $failed_build"
    done
fi

# Output failed validations
if test -n "$failed_validations"; then
    exit_status=$((exit_status+1))
    echo -e "Failed validations:"
    for validation in $failed_validations; do
        echo " * $validation"
    done
fi

# Output result
if (($exit_status)); then
    echo -e "\nTesting ${RED}failed${NOC}.\n"
else
    echo -e "\nTesting ${GRN}passed${NOC}.\n"
fi

exit $exit_status

