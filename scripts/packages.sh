#!/bin/sh

set -e

DIR=`dirname $0`

flutter pub pub run dapackages:dapackages.dart ${DIR}/../example/pubspec.yaml