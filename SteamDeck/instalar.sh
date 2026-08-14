#!/usr/bin/env bash
# Instala a tradução PT-BR de KILL la KILL -IF no Steam Deck (ou qualquer Linux com Steam).
set -uo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DADOS="$AQUI/dados"
. "$AQUI/comum.sh"

# Correção do Modo Jogo (ver modo_jogo.sh). Para pular: bash instalar.sh --sem-modo-jogo
MODO_JOGO=1
[ "${1:-}" = "--sem-modo-jogo" ] && MODO_JOGO=0
. "$AQUI/modo_jogo.sh"

printf '\n  KILL la KILL -IF — tradução PT-BR\n'
printf '  ---------------------------------\n\n'

if [ ! -d "$DADOS" ]; then
  printf '  Não achei a pasta dados aqui do lado.\n'
  printf '  Extraia o pacote inteiro antes de rodar este script.\n\n'
  exit 1
fi

DESTINO="$(perguntar_jogo)" || exit 1
printf '  Jogo encontrado em:\n  %s\n\n' "$DESTINO"

BACKUP="$DESTINO/ResourceWin/_backup_ptbr"

# Guarda os originais na primeira instalação, para o desinstalador ter o que devolver
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

printf '\n  Pronto! %s arquivos instalados.\n' "$COPIADOS"

# Sem isso o jogo trava numa tela preta no Modo Jogo do Deck
if [ "$MODO_JOGO" = "1" ]; then
  aplicar_modo_jogo "$DESTINO" "$BACKUP"
  case $? in
    0) printf '  Correção do Modo Jogo aplicada no executável.\n' ;;
    1) printf '  Correção do Modo Jogo: já estava aplicada.\n' ;;
    2) printf '  Correção do Modo Jogo: padrão não encontrado — o jogo pode ter\n'
       printf '  sido atualizado. A tradução funciona do mesmo jeito.\n' ;;
  esac
fi

printf '\n  IMPORTANTE: o jogo precisa estar em INGLÊS no Steam.\n'
printf '  Propriedades do jogo > Idioma > Inglês.\n'
printf '  (Se você nunca mexeu nisso, já está em inglês.)\n\n'
printf '  Para remover: bash desinstalar.sh\n\n'
