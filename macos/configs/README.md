# Configurations **macOS** (Mvnuel)

Fichiers utilisés **uniquement** par `macos/install.sh` (pas par les scripts Linux).

| Fichier | Rôle |
|--------|------|
| `.vimrc` | Vim + Powerline : chemins `pipx` typiques sous macOS |
| `.zshrc` | Zsh + Oh My Zsh + `dircolors` (GNU coreutils Homebrew) |
| `dircolors` | Couleurs `ls` — copie dédiée ; vous pouvez la faire diverger de `../../linux/configs/dircolors` |
| `mvnuel-agnoster.zsh-theme` | Prompt ; idem, copie éditable pour macOS |

**Linux** utilise le dossier **`linux/configs/`**. Pour garder les deux plateformes alignées, vous pouvez reporter manuellement les changements importants d’un côté à l’autre, ou copier ponctuellement :

```bash
# Exemple : resynchroniser le thème depuis Linux vers macOS (à adapter)
cp ../../linux/configs/mvnuel-agnoster.zsh-theme ./mvnuel-agnoster.zsh-theme
```
