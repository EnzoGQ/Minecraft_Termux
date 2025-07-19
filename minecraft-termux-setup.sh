#!/data/data/com.termux/files/usr/bin/bash

# Atualizar Termux e instalar pacotes necessários
pkg update -y && pkg upgrade -y
pkg install -y wget

# Instalar OpenJDK 21
yes | pkg install openjdk-21

# Ativar acesso ao armazenamento (exige confirmação do usuário)
termux-setup-storage

# Diretório onde o servidor será instalado (visível no Android)
SERVER_DIR="$HOME/storage/shared/ServidorMinecraft"

# Criar pasta do servidor
mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR"

# Baixar servidor Minecraft
wget https://piston-data.mojang.com/v1/objects/6e64dcabba3c01a7271b4fa6bd898483b794c59b/server.jar

# Aceitar EULA
echo "eula=true" > eula.txt

# Criar start.sh dentro da mesma pasta
cat <<EOF > start.sh
#!/data/data/com.termux/files/usr/bin/bash

# Cores ANSI
RED='\\033[0;31m'
NC='\\033[0m' # Sem cor

# Mostrar o diretório do servidor
echo -e "\\n\${RED}Iniciando servidor no diretório:\${NC} $SERVER_DIR"
cd "$SERVER_DIR"

# Detecta IP local real (não 127.0.0.1)
IP=$(ip addr | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)

# Exibe IP
echo -e "\n${RED}Endereço IP local:${NC} $IP\n"

# Iniciar o servidor
java -jar server.jar nogui
EOF

# Tornar o start.sh executável
chmod +x start.sh

echo ""
echo "✅ Servidor instalado com sucesso!"
echo "➡ Arquivos visíveis em: $SERVER_DIR"
echo "➡ Para iniciar: ./start.sh"
