#!/usr/bin/env bash

GUIDE_NAME=$1

#This saves where the user currently is
HOME=`pwd`

#This changes you to the root of the project, ensuring the script runs consistently
cd `dirname $0`/..

mkdir docs/$GUIDE_NAME

#Go into guide dir we just created
cd docs/$GUIDE_NAME/

#Add template files to get things started
cp ../topics/templates/master.adoc .
ln -s ../topics topics

#go back to where user was
cd $HOME
