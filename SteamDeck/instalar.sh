#!/usr/bin/env bash
# Instala a tradução PT-BR de KILL la KILL -IF no Steam Deck (ou qualquer Linux com Steam).
set -uo pipefail

MARCA="KILLlaKILL_IF.exe"
PASTA_JOGO="KILL la KILL -IF"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DADOS="$AQUI/dados"

printf '\n  KILL la KILL -IF — tradução PT-BR\n'
printf '  ---------------------------------\n\n'

if [ ! -d "$DADOS" ]; then
  printf '  Não achei a pasta dados aqui do lado.\n'
  printf '  Extraia o pacote inteiro antes de rodar este script.\n\n'
  exit 1
fi

# Bibliotecas Steam: as padrão, as do cartão SD e as declaradas no libraryfolders.vdf
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
  # sed POSIX em vez de grep -oP: -P depende do locale e nem sempre existe
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

if [ -z "$DESTINO" ]; then
  printf '  Não encontrei a pasta do jogo automaticamente.\n'
  printf '  No Steam: KILL la KILL -IF > engrenagem > Propriedades >\n'
  printf '  Arquivos instalados > Procurar, e cole o caminho aqui.\n\n'
  read -r -p '  Caminho da pasta do jogo: ' DESTINO
  DESTINO="${DESTINO%\"}"; DESTINO="${DESTINO#\"}"
fi

if [ ! -f "$DESTINO/$MARCA" ]; then
  printf '\n  Isso não parece a pasta do jogo: %s\n' "$DESTINO"
  printf '  Deve existir um %s lá dentro.\n\n' "$MARCA"
  exit 1
fi

printf '  Jogo encontrado em:\n  %s\n\n' "$DESTINO"

# Guarda os originais na primeira instalação, para o desinstalador ter o que devolver
BACKUP="$DESTINO/ResourceWin/_backup_ptbr"
GUARDADOS=0
while IFS= read -r -d '' f; do
  REL="${f#$DADOS/}"
  if [ -f "$DESTINO/$REL" ] && [ ! -f "$BACKUP/$REL" ]; then
    mkdir -p "$(dirname "$BACKUP/$REL")"
    cp -- "$DESTINO/$REL" "$BACKUP/$REL"
    GUARDADOS=$((GUARDADOS+1))
  fi
done < <(find "$DADOS" -type f -print0)
[ "$GUARDADOS" -gt 0 ] && printf '  Cópia de segurança dos %s arquivos originais guardada.\n' "$GUARDADOS"

COPIADOS=0
while IFS= read -r -d '' f; do
  REL="${f#$DADOS/}"
  mkdir -p "$(dirname "$DESTINO/$REL")"
  cp -f -- "$f" "$DESTINO/$REL"
  COPIADOS=$((COPIADOS+1))
done < <(find "$DADOS" -type f -print0)

printf '\n  Pronto! %s arquivos instalados.\n\n' "$COPIADOS"
printf '  IMPORTANTE: o jogo precisa estar em INGLÊS no Steam.\n'
printf '  Propriedades do jogo > Idioma > Inglês.\n'
printf '  (Se você nunca mexeu nisso, já está em inglês.)\n\n'
printf '  Para remover: bash desinstalar.sh\n\n'
