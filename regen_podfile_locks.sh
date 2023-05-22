#!/bin/bash

flutter pub get

pushd ios
rm Podfile.lock
pod install
popd

pushd macos
rm Podfile.lock
pod install
popd

