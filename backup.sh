#!/bin/bash

# Charger les variables d'environnement si elles existent
if [ -f /etc/environment ]; then
    source /etc/environment
fi

# Variables
BACKUP_DIR="/data/backup"
ARCHIVE_PATH="${BACKUP_DIR}/mongodb-backup-$(date +"%Y%m%d%H%M").gz"
LOG_FILE="/var/log/backup.log"

# Vérifier si MONGO_URI est défini
if [ -z "${MONGO_URI}" ]; then
    echo "Erreur: La variable MONGO_URI n'est pas définie." >&2
    echo "Erreur: La variable MONGO_URI n'est pas définie. $(date)" >> "${LOG_FILE}"
    exit 1
fi

# Créer le répertoire de sauvegarde s'il n'existe pas
mkdir -p "${BACKUP_DIR}"

# Effectuer le dump de la base de données MongoDB
if mongodump --uri="${MONGO_URI}" --archive="${ARCHIVE_PATH}" --gzip --ssl; then
    echo "Sauvegarde réussie : ${ARCHIVE_PATH}"
    echo "Sauvegarde réussie : ${ARCHIVE_PATH} à $(date)" >> "${LOG_FILE}"
else
    echo "Erreur lors de la sauvegarde MongoDB" >&2
    echo "Erreur lors de la sauvegarde MongoDB à $(date)" >> "${LOG_FILE}"
    exit 1
fi

# Supprimer les backups plus vieux que 14 jours
find ${BACKUP_DIR} -type f -name "*.gz" -mtime +14 -exec rm -f {} \;

echo "Backup et nettoyage terminé à $(date)" >> "${LOG_FILE}"
