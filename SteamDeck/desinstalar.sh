#!/usr/bin/env bash
# Devolve os arquivos originais de KILL la KILL -IF, tirando a tradução PT-BR.
set -uo pipefail

MARCA="KILLlaKILL_IF.exe"
PASTA_JOGO="KILL la KILL -IF"

printf '\n  KILL la KILL -IF — remover a tradução PT-BR\n'
printf '  ------------------------------------------\n\n'

CANDIDATAS=(
  "$HOME/.local/share/Steam"
  "$HOME/.steam/steam"
  "$HOME/.var/app/com.valvesoftware.Steam/data/Steam"
)
for m in /run/media/*/ /run/media/deck/*/ ; do
  [ -d "$m" ] && CANDIDATAS+=("${m%/}")
done
for vdf in "$HOME/.local/share/Steam/steamapps/libraryfolders.vdf" \
           "$HOME/.steam/steam/steamapps/libraryfolders.vdf"; do
  [ -f "$vdf" ] && while IFS= read -r p; do
    [ -n "$p" ] && CANDIDATAS+=("$p")
  done < <(sed -n 's/.*"path"[[:space:]]*"\(.*\)".*/\1/p' "$vdf" 2>/dev/null)
done

DESTINO=""
for b in "${CANDIDATAS[@]}"; do
  for alvo in "$b/steamapps/common/$PASTA_JOGO" "$b/common/$PASTA_JOGO"; do
    if [ -f "$alvo/$MARCA" ]; then DESTINO="$alvo"; break 2; fi
  done
done
[ -z "$DESTINO" ] && read -r -p '  Caminho da pasta do jogo: ' DESTINO

BACKUP="$DESTINO/ResourceWin/_backup_ptbr"
if [ ! -d "$BACKUP" ]; then
  printf '  Não achei a cópia de segurança dentro do jogo.\n'
  printf '  Para voltar ao original: Propriedades do jogo >\n'
  printf '  Arquivos instalados > Verificar integridade.\n\n'
  exit 0
fi

N=0
while IFS= read -r -d '' f; do
  REL="${f#$BACKUP/}"
  cp -f -- "$f" "$DESTINO/$REL"
  N=$((N+1))
done < <(find "$BACKUP" -type f -print0)
rm -rf -- "$BACKUP"

printf '\n  Pronto! %s arquivos originais devolvidos.\n' "$N"
printf '  O jogo voltou ao inglês.\n\n'
