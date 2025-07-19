#!/data/data/com.termux/files/usr/bin/bash

# Atualizar Termux e instalar pacotes necessários
pkg update -y && pkg upgrade -y
pkg install -y wget

# Instalar OpenJDK 21
pkg install -y openjdk-21
pkg install -y zip

# Ativar acesso ao armazenamento (exige confirmação do usuário)
termux-setup-storage

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

fazer_backup() {
    if [ ! -d "$SERVER_DIR" ]; then
        echo "⚠ Diretório do servidor não encontrado: $SERVER_DIR"
        return
    fi

    mkdir -p "$SERVER_DIR/backups"
    local data=$(date +"%Y-%m-%d_%H-%M-%S")
    local arquivo_backup="$SERVER_DIR/backups/ServidorMinecraft_backup_$data.zip"

    echo "Criando backup em $arquivo_backup ..."
    zip -r "$arquivo_backup" "$SERVER_DIR" > /dev/null

    if [ $? -eq 0 ]; then
        echo "✅ Backup criado com sucesso!"
    else
        echo "❌ Erro ao criar backup."
    fi
}


# Diretório onde o servidor será instalado
SERVER_DIR="$HOME/storage/shared/ServidorMinecraft"
mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR"

# Lista de versões
declare -A versions
versions["1.21.6"]="https://piston-data.mojang.com/v1/objects/6e64dcabba3c01a7271b4fa6bd898483b794c59b/server.jar"

# Menu principal
while true; do
    echo ""
    echo "==== MENU ===="
    echo "1) Instalar novo servidor"
    echo "2) Iniciar servidor"
    echo "3) Atualizar server.jar"
    echo "4) Excluir mapa do servidor"
    echo "5) Backup do servidor"
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
		;;

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
	5) fazer_backup ;;
 	
 	0)
		echo "Saindo..."
		exit 0
		;;
	*)
		echo "❌ Opção inválida."
		;;
	esac
done

echo ""
echo "✅ Script concluído."
echo "➡ Use ./start.sh para iniciar o servidor."
