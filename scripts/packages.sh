#!/bin/sh

set -e

DIR=`dirname $0`

flutter pub upgrade
flutter pub pub run dapackages:dapackages.dart ${DIR}/../example/pubspec.yaml
flutter pub outdated