# Lucky Terminal — Linux

![Aperçu du terminal linux](./linux.png)

Bienvenue dans le coin **Linux** du projet. Ici tout est pensé pour **Ubuntu** (et souvent les environnements **GNOME Terminal** / `dconf`) : Zsh, thème Automnale, couleurs pour `ls`, Vim avec Powerline si tu en as besoin, et polices **Roboto Mono for Powerline** pour que les séparateurs du prompt s’affichent correctement.

---
## 📌 Prérequis rapides

Avant la première installation, avoir **git** et **vim** (et un terminal prêt pour les commandes `sudo` si le script les demande) :

```bash
# Si ce n'est pas déjà fait
sudo apt-get update && sudo apt-get install -y git vim
```
---

## Arborescence du dossier

Le dossier de configuration Linux est arboré comme suit :

```
linux/
├── configs/
│   ├── .vimrc
│   ├── .zshrc
│   ├── dircolors
│   ├── mvnuel-agnoster.zsh-theme
│   └── terminal_profile.dconf
├── fonts/
│   ├── RobotoMono/          # Polices Powerline
│   └── install.sh
├── install.sh               # Enchaîne les grandes étapes
├── install_powerline.sh     # Polices, Vim, powerline-status…
├── install_terminal.sh      # Zsh, Oh My Zsh
├── install_profile.sh       # Plugins, ~/.zshrc, thème, profil terminal
├── purge_zsh.sh             # Nettoyage résiduel Oh My Zsh / zsh
├── uninstall.sh             # Desinstallation du thème customisé
└── README.md
```

Les scripts **copient** ou **appliquent** ce qui est dans `configs/` et `fonts/` vers ton répertoire utilisateur et le profil GNOME Terminal quand c’est prévu.

---

## 💡 À quoi ils servent ?

### Mode one-clic (Installation en un clic)
- **`install.sh`** : le **parcours tout-en-un** — idéal si tu veux « tout d’un coup » après avoir lu les prérequis. Avec lui plus besoin des autres scripts !
---
### Mode step (Installation étapée)
- **`install_powerline.sh`** : pose les bases visuelles (polices, chaîne Powerline côté Vim/outils).
- **`install_terminal.sh`** : met en place le shell **Zsh** et **Oh My Zsh**.
- **`install_profile.sh`** : termine la personnalisation (fichiers dans ton `$HOME`, thème Mvnuel, couleurs du terminal GNOME si ton environnement le permet).
---
### Désinstallation
- **`uninstall.sh`** : revient en arrière **proprement** sur ce que le projet a installé (avec des options pour aller plus loin).
- **`purge_zsh.sh`** : quand il reste des traces (configs, caches, parfois l’historique si tu le demandes) — utile avant une réinstallation propre.

---

## Commandes

**Installation one-clic** (depuis la racine du dépôt) :

```bash
chmod +x linux/install.sh
./linux/install.sh
```

**Installation étape par étape** (même ordre que le script maître) :

```bash
chmod +x linux/install_powerline.sh linux/install_terminal.sh linux/install_profile.sh
./linux/install_powerline.sh
./linux/install_terminal.sh
./linux/install_profile.sh
```

**Désinstallation** :

```bash
chmod +x linux/uninstall.sh
./linux/uninstall.sh

#Sans questions : 
./linux/uninstall.sh --yes  
#Avec option paquets (voir le script pour le détail): 
./linux/uninstall.sh --yes --apt
```


**Purge zsh** (à lancer si tu ne veux plus rien conserver du **Lucky Terminal**) :

```bash
chmod +x linux/purge_zsh.sh
./linux/purge_zsh.sh

#Sans invite (options supplémentaires éventuelles dans le script): 
./linux/purge_zsh.sh --yes 
```

---

## 🌍 Autres systèmes & doc générale

- **macOS** → dossier [`macos/`](../macos/) (ne lance pas les scripts `linux/` sur Mac).
- **Windows** → dossier [`windows/`](../windows/).
- Vue globale du dépôt : [README à la racine](../README.md).

---

Bon terminal ! 🍀
