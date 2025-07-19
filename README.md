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

### ▶ Como iniciar o servidor

```bash
./start.sh

