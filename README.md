# Minecraft Server no Termux (Android) VERSÃO 1.21.6

Este projeto permite instalar e rodar um servidor **Minecraft Vanilla** no seu **Android** usando o **Termux** de forma automatizada.


---

## ✅ Requisitos
- Android com Termux instalado (recomenda-se a versão da F-Droid ou GitHub)
- Acesso ao armazenamento interno habilitado
- Termux wget
```bash
pkg install -y wget
```

---

## 📥 Como instalar

### Opção 1: Passo a passo

```bash
wget https://raw.githubusercontent.com/EnzoGQ/Minecraft_Termux/refs/heads/main/minecraft-termux-setup.sh
chmod +x minecraft-termux-setup.sh
./minecraft-termux-setup.sh
```

### Opção 2: Comando único (automático) (RECOMENDADO)

```bash
wget https://raw.githubusercontent.com/EnzoGQ/Minecraft_Termux/refs/heads/main/minecraft-termux-setup.sh -O minecraft-termux-setup.sh && chmod +x minecraft-termux-setup.sh && ./minecraft-termux-setup.sh
```

## ▶ Como usar o servidor

**Após a instalação, o script de menu para gerenciar o servidor estará disponivel com o comando (Ele é executado automaticamente após a primeira instalação):**
```bash
./minecraft-termux-setup.sh
```

Você verá o seguinte menu:
```bash
==== MENU ====
1) Instalar novo servidor
2) Iniciar servidor
3) Atualizar server.jar
4) Excluir mapa do servidor
5) Backup do servidor
6) Editar server.properties

1) Instalar novo servidor
Faz a instalação inicial do servidor Minecraft Vanilla.

2) Iniciar servidor
Inicia o servidor Minecraft já instalado.

3) Atualizar server.jar
Baixa a versão selecionada do Minecraft.

4) Excluir mapa do servidor
Apaga o mundo salvo atual para começar um mapa novo.

5) Backup do servidor
Faz um backup do diretório do servidor, incluindo mundo, configurações e arquivos.

6) Editar server.properties
Irá abrir o server.properties para editar.
