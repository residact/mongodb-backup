FROM alpine:3.14

# Installer MongoDB tools, cron et les dépendances nécessaires
RUN apk add --no-cache mongodb-tools tzdata dcron ca-certificates

# Définir les variables d'environnement
ENV MONGO_URI=""
ENV ARCHIVE_PATH="/data/backup"

# Copier le script de sauvegarde
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Créer le répertoire de sauvegarde
RUN mkdir -p ${ARCHIVE_PATH}

# Configurer cron
RUN echo "0 0 * * * MONGO_URI=${MONGO_URI} ARCHIVE_PATH=${ARCHIVE_PATH} /usr/local/bin/backup.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root

# Créer les fichiers de log
RUN touch /var/log/cron.log /var/log/backup.log && \
    chmod 0666 /var/log/cron.log /var/log/backup.log

# Script pour démarrer cron et garder le conteneur en cours d'exécution
RUN echo '#!/bin/sh' > /usr/local/bin/docker-entrypoint.sh && \
    echo 'printenv | grep -v "PATH" > /etc/environment' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'crond -f -d 8' >> /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

# Commande pour exécuter au démarrage du conteneur
ENTRYPOINT ["/bin/sh", "/usr/local/bin/docker-entrypoint.sh"]
