#!/bin/bash

# Copy to Windows RC file for now
BUILD_NUMBER=666
VERSION_FROM_PUBSPEC=$(sed -n -e '/version: / s///p' pubspec.yaml | tr -d '\r\n')
VERSION=$(echo -n $VERSION_FROM_PUBSPEC | sed -E -e "s/((([0-9])+\.([0-9])+\.([0-9])+)\+(([0-9])+))/\2+$BUILD_NUMBER/")

echo "Setting windows version to $VERSION"
sed -i -E -e "s/((([0-9])+\.([0-9])+\.([0-9])+(([\+])([0-9])+)?))/$VERSION/" windows/runner/Runner.rc