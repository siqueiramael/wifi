#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Função para exibir mensagens
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    print_error "Este script precisa ser executado como root (sudo)"
    exit 1
fi

# Verificar sistema operacional
if [ ! -f /etc/lsb-release ]; then
    print_error "Este script requer Ubuntu 20.04"
    exit 1
fi

# Atualizar sistema
print_message "Atualizando o sistema..."
apt update && apt upgrade -y

# Instalar dependências
print_message "Instalando pacotes necessários..."
apt install -y \
    apache2 \
    php \
    php-mysql \
    php-fpm \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    mariadb-server \
    freeradius \
    freeradius-mysql \
    freeradius-utils \
    git

# Configurar MySQL
print_message "Configurando MySQL..."
mysql_secure_installation

# Criar banco de dados
print_message "Criando banco de dados..."
read -p "Digite a senha para o usuário radius do MySQL: " MYSQL_PASSWORD

mysql -e "CREATE DATABASE radius;"
mysql -e "CREATE USER 'radius'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON radius.* TO 'radius'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Importar esquema do banco
print_message "Importando esquema do banco de dados..."
mysql radius < database/schema.sql

# Configurar FreeRADIUS
print_message "Configurando FreeRADIUS..."
cp config/radiusd.conf /etc/freeradius/3.0/radiusd.conf
cp config/sql /etc/freeradius/3.0/mods-enabled/
chown -R freerad:freerad /etc/freeradius/3.0/mods-enabled/sql

# Configurar Apache
print_message "Configurando Apache..."
cp config/apache-site.conf /etc/apache2/sites-available/portal.conf
a2ensite portal
a2enmod headers rewrite

# Obter IP público
IP_ADDRESS=$(curl -s ifconfig.me)

# Criar primeiro usuário admin
print_message "Criando usuário administrador..."
read -p "Digite a senha para o usuário admin: " ADMIN_PASSWORD
ADMIN_HASH=$(echo -n "$ADMIN_PASSWORD" | sha256sum | awk '{print $1}')

mysql radius -e "INSERT INTO users (username, password, fullname, cpf, email, phone, is_admin) VALUES ('admin', '$ADMIN_HASH', 'Administrador', '00000000000', 'admin@localhost', '0000000000', 1);"

# Configurar backup automático
print_message "Configurando backup automático..."
cp scripts/backup.sh /root/
chmod +x /root/backup.sh
(crontab -l 2>/dev/null; echo "0 2 * * * /root/backup.sh") | crontab -

# Reiniciar serviços
print_message "Reiniciando serviços..."
systemctl restart freeradius mysql apache2

print_message "Instalação concluída!"
echo -e "${GREEN}Acesse http://$IP_ADDRESS/admin${NC}"
echo -e "${GREEN}Usuário: admin${NC}"
echo -e "${GREEN}Senha: $ADMIN_PASSWORD${NC}"