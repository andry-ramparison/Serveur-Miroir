#!/bin/bash
# Script d'alerte quotas (affiche exactement repquota)
# /home_new : blocs
# /data_new : inodes
# Emails si soft limit dépassé
# Flag pour cron quotidien

set -e

PART_HOME="/home_new"
PART_DATA="/data_new"
ADMIN_EMAIL="ton.email@domaine.com"
FLAG_FILE="/tmp/quota_alert_flag"

EXCEED=0

echo "=============================="
echo "📊 Statistiques /home_new (repquota)"

# /home_new : blocs
sudo repquota -u $PART_HOME | tail -n +6 | while read -r line; do
    USER=$(echo "$line" | awk '{print $1}')
    [ -z "$USER" ] && continue
    [ "$USER" = "------" ] && continue

    USED=$(echo "$line" | awk '{print $3}')
    SOFT=$(echo "$line" | awk '{print $4}')
    HARD=$(echo "$line" | awk '{print $5}')

    echo "$USER : utilisé=$USED, soft=$SOFT, hard=$HARD"

    # Vérifie dépassement soft limit si used est numérique
    if [[ "$USED" =~ ^[0-9]+$ ]] && [ "$USED" -gt "$SOFT" ]; then
        EXCEED=1
        MESSAGE="⚠️ Quota soft dépassé sur $PART_HOME
Utilisateur: $USER
Utilisé: $USED
Quota soft: $SOFT
Quota hard: $HARD"

        echo "$MESSAGE" | mail -s "Alerte quota $PART_HOME" $USER
        echo "$MESSAGE" | mail -s "Alerte quota $PART_HOME pour $USER" $ADMIN_EMAIL
    fi
done

echo "=============================="
echo "📊 Statistiques /data_new (inodes)"

# /data_new : inodes (File limits)
sudo repquota -u $PART_DATA | tail -n +6 | while read -r line; do
    USER=$(echo "$line" | awk '{print $1}')
    [ -z "$USER" ] && continue
    [ "$USER" = "------" ] && continue

    INO_USED=$(echo "$line" | awk '{print $6}')
    INO_SOFT=$(echo "$line" | awk '{print $7}')
    INO_HARD=$(echo "$line" | awk '{print $8}')

    echo "$USER : inodes utilisés=$INO_USED, soft=$INO_SOFT, hard=$INO_HARD"

    if [[ "$INO_USED" =~ ^[0-9]+$ ]] && [ "$INO_USED" -gt "$INO_SOFT" ]; then
        EXCEED=1
        MESSAGE="⚠️ Quota soft inodes dépassé sur $PART_DATA
Utilisateur: $USER
Inodes utilisés: $INO_USED
Quota soft: $INO_SOFT
Quota hard: $INO_HARD"

        echo "$MESSAGE" | mail -s "Alerte quota inodes $PART_DATA" $USER
        echo "$MESSAGE" | mail -s "Alerte quota inodes $PART_DATA pour $USER" $ADMIN_EMAIL
    fi
done

# Flag cron
if [ "$EXCEED" -eq 1 ]; then
    touch $FLAG_FILE
else
    [ -f $FLAG_FILE ] && rm $FLAG_FILE
fi

echo "✅ Vérification quotas terminée"

