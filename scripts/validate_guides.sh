#!/usr/bin/env bash

# Builds all books into DocBook 5 XML and validates them using XMLlint.

SCRIPT_SRC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
DOCS_SRC="$( dirname $SCRIPT_SRC )/docs/titles"
XML_SCHEMA="$SCRIPT_SRC/xml-schema/docbook.xsd"

failed_builds=""
failed_validations=""
exit_status=0
build_fail_msg="failed to build"
valid_fail_msg="failed to validate"
valid_succ_msg="validation success"

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
    name=$(basename $dir)
    echo -ne "Processing $name"
    pushd $dir >/dev/null

    # Build title into DocBook XML and see if any errors or warnings were output
    adoctor_stderr="$(asciidoctor -v -a data-uri master.adoc -b docbook5 2>&1)"
    if [ ! -z "$(echo "$adoctor_stderr" | grep "ERROR\|WARNING")" ]; then
        columns_left=$(( 79 - ${#name} ))
        printf '%*s\n' $columns_left "$build_fail_msg"
        echo -e "\n${adoctor_stderr}\n"
        failed_builds="$failed_builds $dir"
        popd >/dev/null
        continue
    fi

    # Validate the DocBook XML
    xmllint_stderr="$(xmllint --noout --schema $XML_SCHEMA master.xml 2>&1)"
    if [ ! $? -eq 0 ]; then
        columns_left=$(( 79 - ${#name} ))
        printf '%*s\n' $columns_left "$valid_fail_msg"
        echo -e "\n${xmllint_stderr}\n"
        failed_validations="$failed_validations $dir"
    else
        columns_left=$(( 79 - ${#name} ))
        printf '%*s\n' $columns_left "$valid_succ_msg"
        rm master.xml
    fi
    popd >/dev/null
done

echo

# Output failed builds
if test -n "$failed_builds"; then
    exit_status=$((exit_status+1))
    echo -e "Failed builds:"
    for failed_build in $failed_builds; do
        echo -e " * $failed_build\n"
    done
fi

# Output failed validations
if test -n "$failed_validations"; then
    exit_status=$((exit_status+1))
    echo -e "Failed validations:"
    for validation in $failed_validations; do
        echo -e " * $validation\n"
    done
fi

# Output result
if (($exit_status)); then
    echo -e "Testing failed.\n"
else
    echo -e "Testing passed.\n"
fi

exit $exit_status
