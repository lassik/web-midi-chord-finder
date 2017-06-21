#!/bin/sh
set -eux
cd "$(dirname "$0")"
elm-make --yes --warn --output=elm.js src/Main.elm
closure-compiler \
    --language_in=ECMASCRIPT5 \
    --js=elm.js \
    --js_output_file=elm.js.new
mv elm.js.new elm.js
