# Configurations **macOS** (Mvnuel)

Fichiers utilisés **uniquement** par `macos/install.sh` (pas par les scripts Linux à la racine).

| Fichier | Rôle |
|--------|------|
| `.vimrc` | Vim + Powerline : chemins `pipx` typiques sous macOS |
| `.zshrc` | Zsh + Oh My Zsh + `dircolors` (GNU coreutils Homebrew) |
| `dircolors` | Couleurs `ls` — copie dédiée ; vous pouvez la faire diverger de `../../configs/dircolors` |
| `mvnuel-agnoster.zsh-theme` | Prompt ; idem, copie éditable pour macOS |

**Linux** utilise le dossier **`configs/`** à la racine du dépôt. Pour garder les deux plateformes alignées, vous pouvez reporter manuellement les changements importants d’un côté à l’autre, ou copier ponctuellement :

```bash
# Exemple : resynchroniser le thème depuis Linux vers macOS (à adapter)
cp ../../configs/mvnuel-agnoster.zsh-theme ./mvnuel-agnoster.zsh-theme
```
