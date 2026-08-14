#!/usr/bin/env bash
# Devolve os arquivos originais de KILL la KILL -IF, tirando a tradução PT-BR
# e a correção do Modo Jogo.
set -uo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$AQUI/comum.sh"

printf '\n  KILL la KILL -IF — remover a tradução PT-BR\n'
printf '  ------------------------------------------\n\n'

DESTINO="$(perguntar_jogo)" || exit 1

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
printf '  O jogo voltou ao inglês, e o executável ao estado de fábrica.\n\n'
