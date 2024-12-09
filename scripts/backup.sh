#!/bin/bash

# Configurações
BACKUP_DIR="/root/backups"
DATE=$(date +%Y%m%d)
MYSQL_USER="radius"
MYSQL_PASS="your_password_here"

# Criar diretório de backup se não existir
mkdir -p $BACKUP_DIR

# Backup do banco de dados
mysqldump -u$MYSQL_USER -p$MYSQL_PASS radius > $BACKUP_DIR/radius_$DATE.sql

# Backup dos arquivos do portal
tar -czf $BACKUP_DIR/portal_$DATE.tar.gz /var/www/portal

# Backup das configurações
tar -czf $BACKUP_DIR/config_$DATE.tar.gz /etc/freeradius/3.0

# Manter apenas os últimos 7 dias de backup
find $BACKUP_DIR -type f -mtime +7 -delete

# Log do backup
echo "Backup realizado em $(date)" >> $BACKUP_DIR/backup.log