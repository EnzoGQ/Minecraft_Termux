#!/data/data/com.termux/files/usr/bin/bash

# Atualizar Termux e instalar pacotes necessários
pkg update -y && pkg upgrade -y
pkg install -y wget

# Instalar OpenJDK 21
pkg install -y openjdk-21

# Ativar acesso ao armazenamento (exige confirmação do usuário)
termux-setup-storage

# Diretório onde o servidor será instalado
SERVER_DIR="$HOME/storage/shared/ServidorMinecraft"
mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR"

# Lista de versões
declare -A versions
versions["1.21.6"]="https://piston-data.mojang.com/v1/objects/6e64dcabba3c01a7271b4fa6bd898483b794c59b/server.jar"
versions["1.20.6"]="https://piston-data.mojang.com/v1/objects/5f2542cfeb5907e09ffb3b3b06c1886a3ed4d66f/server.jar"
versions["1.20.4"]="https://piston-data.mojang.com/v1/objects/01722f3963ec004c94fdfed8b88f796fd2c59f17/server.jar"
versions["1.20.1"]="https://piston-data.mojang.com/v1/objects/6e64dcabba3c01a7271b4fa6bd898483b794c59b/server.jar"
versions["1.20"]="https://piston-data.mojang.com/v1/objects/9246f1fdb24fa7902780b5c1b6f6b953147934e5/server.jar"
versions["1.19.4"]="https://piston-data.mojang.com/v1/objects/2d71e9d6b8f4a1ed34b2cd6c3bcf317fd28d0e49/server.jar"
versions["1.19.2"]="https://piston-data.mojang.com/v1/objects/a1a8b295b9b645b5b5c9bb3c5049ad2e1b0d911b/server.jar"
versions["1.18.2"]="https://piston-data.mojang.com/v1/objects/edc94857fcbfd7eb28687abb77dbb42c9c4f7c84/server.jar"
versions["1.17.1"]="https://piston-data.mojang.com/v1/objects/b5cd67fdfb29870dbb2ff3d574017c213c5f1d67/server.jar"
versions["1.16.5"]="https://piston-data.mojang.com/v1/objects/8f68d6116f0d07f94e4bcf13e9e9cc68c97f744b/server.jar"
versions["1.15.2"]="https://piston-data.mojang.com/v1/objects/f5b14db03b2aa602d0bce49e213b1f595bc834f3/server.jar"
versions["1.14.4"]="https://piston-data.mojang.com/v1/objects/3f9ad714a729b7c6c9c5b2d7c8aa8a4e049f560c/server.jar"
versions["1.13.2"]="https://piston-data.mojang.com/v1/objects/e3c5572a3b5b4b6cdd5f25bc6c7d9ad064b3a8c8/server.jar"
versions["1.12.2"]="https://piston-data.mojang.com/v1/objects/a1b6be1f09f8aa1ff69961e7a47a006a300c5f57/server.jar"
versions["1.11.2"]="https://piston-data.mojang.com/v1/objects/f8496df3ecb0b0f3a1e749c38dd2c31e56261b2c/server.jar"
versions["1.10.2"]="https://piston-data.mojang.com/v1/objects/4ca2032f2f1702c8fc9e6cb47c3937c9139d4c6d/server.jar"
versions["1.9.4"]="https://piston-data.mojang.com/v1/objects/29ddac5f733731a29c2cfe217f42b4cd03c2ef51/server.jar"
versions["1.8.9"]="https://piston-data.mojang.com/v1/objects/2055ac0a3c9869b30cefa597f7c4f33c7d30c8cf/server.jar"
versions["1.7.10"]="https://piston-data.mojang.com/v1/objects/fb4c9be0c77db8792c4b08fd67c89fdf048c8c8c/server.jar"

# Menu principal
while true; do
    echo ""
    echo "==== MENU ===="
    echo "1) Instalar novo servidor"
	echo "2) Iniciar servidor"
    echo "3) Atualizar server.jar"
    echo "4) Fazer backup do servidor"
    echo "5) Excluir servidor"
    echo "0) Sair"
    echo -n "Escolha uma opção: "
    read op

    case "$op" in
    1)
        echo ""
        echo "📥 Selecione a versão do servidor Minecraft:"
        select ver in "${!versions[@]}" "Cancelar"; do
            if [[ "$REPLY" -gt 0 && "$REPLY" -le "${#versions[@]}" ]]; then
                mkdir -p "$SERVER_DIR"
                cd "$SERVER_DIR"
                echo "Baixando servidor da versão $ver..."
                wget -O server.jar "${versions[$ver]}"
                echo "eula=true" > eula.txt
                break
            elif [[ "$ver" == "Cancelar" ]]; then
                echo "Cancelado."
                break
            else
                echo "Opção inválida. Tente novamente."
            fi
        done
        ;;
	2)
		"$HOME/start.sh"
		;;)

    3)
        if [[ -f "$SERVER_DIR/server.jar" ]]; then
            echo ""
            echo "server.jar encontrado. Deseja substituir por uma nova versão."
            echo "📥 Selecione a nova versão:"
            select ver in "${!versions[@]}" "Cancelar"; do
                if [[ "$REPLY" -gt 0 && "$REPLY" -le "${#versions[@]}" ]]; then
                    cd "$SERVER_DIR"
                    echo "Removendo server.jar antigo..."
                    rm -f server.jar
                    echo "Baixando nova versão $ver..."
                    wget -O server.jar "${versions[$ver]}"
                    break
                elif [[ "$ver" == "Cancelar" ]]; then
                    echo "Atualização cancelada."
                    break
                else
                    echo "Opção inválida. Tente novamente."
                fi
            done
        else
            echo "⚠ Nenhum server.jar encontrado em $SERVER_DIR. Use a opção 1 para instalar primeiro."
        fi
        ;;

	4)
	    echo -e "${RED}Tem certeza que deseja excluir o mapa atual? Isso não poderá ser desfeito.${NC}"
		read -p "Digite 'SIM' para confirmar: " confirm
		if [ "$confirm" = "SIM" ]; then
		  cd "$SERVER_DIR"
		  rm -rf world world_nether world_the_end
		  echo "🗑️  Mapa removido com sucesso!"
		else
		  echo "❌ Operação cancelada."
		fi
		;;
	5)
		echo "Saindo..."
		exit 0
		;;
	*)
		echo "❌ Opção inválida."
		;;
	esac
done

# Criar start.sh
cd ~/
cat <<EOF > start.sh
#!/data/data/com.termux/files/usr/bin/bash

RED='\\033[0;31m'
NC='\\033[0m'

echo -e "\\n\${RED}Iniciando servidor no diretório:\${NC} $SERVER_DIR"
cd "$SERVER_DIR"
java -jar server.jar nogui
EOF

chmod +x start.sh

echo ""
echo "✅ Script concluído."
echo "➡ Use ./start.sh para iniciar o servidor."
