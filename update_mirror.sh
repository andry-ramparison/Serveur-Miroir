#! /bin/bash

SOURCE_DIR="/var/cache/apt/archives"
MIRROR_DIR="/var/www/html/deb-mirror"

sudo mkdir -p "$MIRROR_DIR"

echo "Copie des .deb depuis $SOURCE_DIR vers $MIRROR_DIR..."
sudo cp "$SOURCE_DIR"/*.deb "$MIRROR_DIR/" 2>/dev/null

echo "Génération de Packages.gz"
cd "$MIRROR_DIR"
sudo dpkg-scanpackages . /dev/null | gzip -9c | sudo tee Packages.gz > /dev/null

sudo chown -R www-data:www-data "$MIRROR_DIR"

echo "Miroir APT Apache mis à jour !"
echo "URL du miroir : http://$(hostname -I | awk '{print $1}')/deb-mirror"
