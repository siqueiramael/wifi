# Portal WiFi Hotspot UniFi

Sistema de gerenciamento de hotspot WiFi com autenticação WPA2 Enterprise para pontos de acesso UniFi.

## Requisitos

- Servidor Ubuntu 20.04 LTS
- Mínimo 2GB de RAM
- 20GB de espaço em disco
- Controladora UniFi já configurada em outro servidor
- IP público fixo

## Instalação Rápida

1. Clone este repositório:
```bash
git clone https://github.com/seu-usuario/wifi-portal.git
cd wifi-portal
```

2. Execute o script de instalação:
```bash
chmod +x install.sh
sudo ./install.sh
```

3. Durante a instalação, você será solicitado a:
   - Criar uma senha para o MySQL
   - Definir a senha do administrador do portal

4. Acesse o portal em: http://seu-ip-publico

## Estrutura do Sistema

- `/admin` - Área administrativa
- `/user` - Área do usuário
- `/config` - Arquivos de configuração
- `/database` - Scripts do banco de dados
- `/scripts` - Scripts de instalação e manutenção

## Primeiro Acesso

1. Acesse http://seu-ip-publico/admin
2. Use as credenciais:
   - Usuário: admin
   - Senha: (definida durante a instalação)

## Suporte

Em caso de problemas:

1. Verifique os logs:
```bash
sudo tail -f /var/log/freeradius/radius.log
```

2. Teste o serviço:
```bash
sudo systemctl status freeradius
```

3. Reinicie os serviços:
```bash
sudo systemctl restart freeradius apache2 mysql
```

## Backup

O sistema realiza backups automáticos diariamente às 2h da manhã.
Os backups são armazenados em `/root/backups`.