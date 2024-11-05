#!/bin/bash
cp static/* docs
elm make src/Main.elm --output docs/elm.js  