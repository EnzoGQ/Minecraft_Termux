#!/data/data/com.termux/files/usr/bin/bash

FLAG_FILE="$HOME/.pacotes_instalados"
JAVA_REQUIRED_VERSION="21"

# Função para verificar versão do Java
verificar_java_versao() {
    if ! command -v java >/dev/null 2>&1; then
        echo "❌ Java não está instalado."
        return 1
    fi

    # Captura a versão principal do Java (ex: 21 do 21.0.2)
    JAVA_VERSAO=$(java -version 2>&1 | grep "version" | grep -oP '"\K[0-9]+')
    
    if [ "$JAVA_VERSAO" -ge "$JAVA_REQUIRED_VERSION" ]; then
        echo "✅ Java versão $JAVA_VERSAO detectada (requerido: $JAVA_REQUIRED_VERSION+)."
        return 0
    else
        echo "⚠ Java versão $JAVA_VERSAO detectada. Requer Java $JAVA_REQUIRED_VERSION ou superior."
        return 1
    fi
}

# Instalação só se ainda não foi feita
if [ -f "$FLAG_FILE" ]; then
    echo "✅ Pacotes já foram instalados anteriormente. Pulando esta etapa."
else
    echo "📦 Atualizando Termux e instalando pacotes necessários..."
    pkg update -y && pkg upgrade -y

    # Função para instalar um pacote se ele ainda não estiver instalado
    instalar_pacote() {
        if command -v "$1" > /dev/null 2>&1; then
            echo "✅ $1 já está instalado."
        else
            echo "📥 Instalando $2..."
            pkg install -y "$2"
        fi
    }

    instalar_pacote wget wget
    instalar_pacote zip zip

    # Instalar Java apenas se necessário ou com versão incorreta
    if verificar_java_versao; then
        echo "✅ Java já está na versão correta."
    else
        echo "📥 Instalando OpenJDK 21..."
        pkg install -y openjdk-21
    fi

    touch "$FLAG_FILE"
    echo "✅ Instalação dos pacotes concluída e registrada."
fi


# Ativar acesso ao armazenamento (exige confirmação do usuário)
# Verificar e ativar acesso ao armazenamento (somente se necessário)
if [ ! -d "$HOME/storage" ]; then
    echo "📂 Configurando acesso ao armazenamento interno..."
    termux-setup-storage
    echo "✅ Acesso ao armazenamento solicitado. Reinicie o Termux se necessário."
    sleep 2
else
    echo "✅ Acesso ao armazenamento interno já está configurado."
fi


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

if [ -d "$SERVER_DIR" ]; then
    echo "✅ Diretório do servidor já existe: $SERVER_DIR"
else
    echo "📁 Criando diretório do servidor em: $SERVER_DIR"
    mkdir -p "$SERVER_DIR"
fi

cd "$SERVER_DIR" || { echo "❌ Erro ao acessar $SERVER_DIR"; exit 1; }


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

        # Listar opções numeradas manualmente
        echo "0) Cancelar"
        i=1
        declare -a opcoes
        for ver in "${!versions[@]}"; do
            echo "$i) $ver"
            opcoes[$i]="$ver"
            ((i++))
        done

        # Ler opção do usuário
        read -p "Digite o número da versão desejada: " escolha

        # Verificar entrada
        if [[ "$escolha" == "0" ]]; then
            echo "❌ Instalação cancelada."
        elif [[ "$escolha" =~ ^[0-9]+$ ]] && [[ "$escolha" -gt 0 && "$escolha" -lt "$i" ]]; then
            versao_escolhida="${opcoes[$escolha]}"
            echo "✅ Baixando servidor da versão: $versao_escolhida"

            # Criar diretório se ainda não existir
            if [ ! -d "$SERVER_DIR" ]; then
                mkdir -p "$SERVER_DIR"
                echo "📁 Diretório criado em $SERVER_DIR"
            fi

            cd "$SERVER_DIR" || { echo "❌ Erro ao acessar $SERVER_DIR"; exit 1; }

            # Baixar o arquivo do servidor
            wget -O server.jar "${versions[$versao_escolhida]}" || {
                echo "❌ Falha ao baixar o server.jar"
                exit 1
            }

            echo "eula=true" > eula.txt
            echo "✅ Instalação da versão $versao_escolhida concluída!"
        else
            echo "❌ Opção inválida. Operação abortada."
        fi
        ;;

    2)
        if [ -f "$HOME/start.sh" ]; then
            echo "🚀 Iniciando servidor..."
            bash "$HOME/start.sh"
        else
            echo "❌ Arquivo start.sh não encontrado em $HOME"
        fi
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
