# Gestion des quotas utilisateurs

Ce projet met en place un système de quotas sur les partitions `/home_new` et `/data_new`, avec alertes par email si les quotas soft sont dépassés.

---

## 1. Éditer `/etc/fstab`

Ajouter les options de quota pour les partitions concernées :

/dev/sda10 /home_new ext4 defaults,usrquota 0 2
/dev/sda9 /data_new ext4 defaults,usrquota,grpquota 0 2


Puis remonter les partitions pour appliquer les options :

```bash
sudo mount -o remount /home_new
sudo mount -o remount /data_new
```

## 2. Exécuter le script de setup

Le script setup_home_quota.sh configure les fichiers de quotas et définit les limites pour les utilisateurs :

```bash
sudo ./setup_home_quota.sh
```

## 3. Configuration de crontab pour alertes

Éditer la crontab de l’utilisateur root :

```bash
sudo crontab -e
```

Ajouter les lignes suivantes :

```bash
# Vérification hebdomadaire des quotas
0 8 * * 0 /chemin/vers/quota_alerte.sh

# Vérification quotidienne si un utilisateur a dépassé le soft limit
0 8 * * * [ -f /tmp/quota_alert_flag ] && /chemin/vers/quota_alerte.sh
```

La première ligne exécute le script chaque semaine pour vérifier tous les quotas.

La deuxième ligne exécute le script chaque jour uniquement si le fichier /tmp/quota_alert_flag existe, c’est-à-dire si un soft limit a été dépassé.

## Notes

Assurez-vous que l’adresse email d’alerte est correctement définie dans quota_alerte.sh.

Les scripts doivent être exécutables :
    
```bash
chmod +x setup_home_quota.sh quota_alerte.sh
```
