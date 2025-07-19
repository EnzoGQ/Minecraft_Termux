#!/data/data/com.termux/files/usr/bin/bash

# Atualizar Termux e instalar pacotes necessários
pkg update -y && pkg upgrade -y
pkg install -y wget

# Instalar OpenJDK 21 sem prompts interativos
yes | pkg install -y openjdk-21

# Ativar acesso ao armazenamento
termux-setup-storage

# Diretório atual onde o script está sendo executado
SCRIPT_DIR="$(pwd)"

# Caminho onde o servidor será instalado
SERVER_DIR="/storage/emulated/0/termux-minecraft-server"

# Criar pasta do servidor
mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR"

# Baixar servidor Minecraft
wget https://piston-data.mojang.com/v1/objects/6e64dcabba3c01a7271b4fa6bd898483b794c59b/server.jar

# Aceitar EULA
echo "eula=true" > eula.txt

# Criar o start.sh no mesmo local do script de instalação
cat <<EOF > "$SCRIPT_DIR/start.sh"
#!/data/data/com.termux/files/usr/bin/bash

# Cores ANSI
RED='\033[0;31m'
NC='\033[0m' # Sem cor

# Mostrar o diretório do servidor
echo -e "\n${RED}Iniciando servidor no diretório:${NC} $SERVER_DIR"
cd "$SERVER_DIR"

# Mostrar IP local
IP=\$(ip addr show wlan0 | grep 'inet ' | awk '{print \$2}' | cut -d/ -f1)
echo -e "\n${RED}Endereço IP local:${NC} \$IP\n"

# Iniciar o servidor
java -jar server.jar nogui
EOF


# Tornar executável
chmod +x "$SCRIPT_DIR/start.sh"

echo ""
echo "✅ Servidor instalado com sucesso!"
echo "➡ Arquivos do servidor: $SERVER_DIR"
echo "➡ Inicie com: ./start.sh"
