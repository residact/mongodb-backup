# Utiliser une image de base avec MongoDB tools
FROM mongo:latest

# Installer cron
RUN apt-get update && apt-get install -y cron

# Définir les variables d'environnement
ENV MONGO_URI=""
ENV ARCHIVE_PATH="/data/backup"

# Copier le script de sauvegarde
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Créer le répertoire de sauvegarde
RUN mkdir -p ${ARCHIVE_PATH}

# Configurer cron
RUN echo "0 0 * * * root MONGO_URI=${MONGO_URI} ARCHIVE_PATH=${ARCHIVE_PATH} /usr/local/bin/backup.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/mongodb-backup
RUN chmod 0644 /etc/cron.d/mongodb-backup

# Créer les fichiers de log
RUN touch /var/log/cron.log /var/log/backup.log && \
    chmod 0666 /var/log/cron.log /var/log/backup.log

# Script pour démarrer cron et garder le conteneur en cours d'exécution
RUN echo '#!/bin/bash' > /usr/local/bin/docker-entrypoint.sh && \
    echo 'printenv | grep -v "PATH" > /etc/environment' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'cron' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'tail -f /var/log/cron.log' >> /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

# Commande pour exécuter au démarrage du conteneur
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
