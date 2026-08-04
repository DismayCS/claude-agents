#!/usr/bin/env bash
# Ativa os agentes deste repositorio em nivel de usuario no macOS/Linux/Git Bash.
# Cria um symlink entre ~/.claude/agents e a pasta agents/ deste repo.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TARGET="$CLAUDE_DIR/agents"

mkdir -p "$CLAUDE_DIR"

if [ -L "$TARGET" ]; then
  echo "Link existente encontrado em $TARGET, recriando..."
  rm "$TARGET"
elif [ -d "$TARGET" ]; then
  echo "Ja existe uma pasta REAL (nao e link) em $TARGET. Mova/mescle o conteudo manualmente e rode o script de novo." >&2
  exit 1
fi

ln -s "$REPO_DIR/agents" "$TARGET"
echo "OK: $TARGET -> $REPO_DIR/agents"
