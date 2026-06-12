#!/usr/bin/env bash

echo "Creating TouchDesigner Environment..."
flatpak run --command=bottles-cli com.usebottles.bottles new --bottle-name "TouchDesigner" --environment application

echo "Installing allfonts..."
flatpak run --command=bottles-cli com.usebottles.bottles dependencies --bottle "TouchDesigner" --install allfonts

echo "Installing lucon..."
flatpak run --command=bottles-cli com.usebottles.bottles dependencies --bottle "TouchDesigner" --install lucon

echo "Done! You can now install the TouchDesigner .exe via the Bottles GUI."
