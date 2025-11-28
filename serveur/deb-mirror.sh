#!/bin/bash

# ------------------------------
# Script pour ajouter le miroir local APT dans sources.list.d
# ------------------------------

# Adresse IP ou nom du serveur
SERVER_IP=$(hostname -I | awk '{print $1}')

# Fichier de sortie
OUTPUT_FILE="/etc/apt/sources.list.d/local-mirror.list"

# Vérifier les droits root
if [ "$EUID" -ne 0 ]; then
  echo "Veuillez exécuter ce script en root ou avec sudo."
  exit 1
fi

# Créer le fichier avec le contenu du miroir local
cat <<EOF > $OUTPUT_FILE
deb [trusted=yes] http://$SERVER_IP/deb-mirror ./
EOF

# Permissions du fichier
chmod 644 $OUTPUT_FILE

echo "Le fichier $OUTPUT_FILE a été créé avec succès."
echo "Vous pouvez maintenant exécuter 'sudo apt update' sur ce client pour utiliser le miroir local."
