#!/bin/sh
set -eux
cd "$(dirname "$0")"
elm-make --yes --warn --output=elm.js src/Main.elm
