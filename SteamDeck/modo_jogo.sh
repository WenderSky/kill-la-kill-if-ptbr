#!/usr/bin/env bash
# Correção do bug de lançamento no Modo Jogo do Steam Deck.
#
# O launcher do jogo abre a janela com WS_EX_TOPMOST | WS_EX_TOOLWINDOW. Uma
# janela de ferramenta sempre-no-topo não é reconhecida como a janela do jogo
# pelo Modo Jogo, e o jogo fica preso na tela preta. Zerar essas duas flags
# transforma o launcher numa janela normal e o Modo Jogo passa a enxergá-lo.
#
# Descoberta e padrão de bytes: bkacjios
#   https://gist.github.com/bkacjios/649227c6691d2f49faaba871a11e351b
#
# São 4 bytes trocados por zeros dentro do KILLlaKILL_IF.exe. O original fica
# guardado junto com os outros arquivos, e o desinstalar.sh devolve tudo.

#
# Dá para rodar sozinho, se você quiser só a correção e não a tradução:
#     bash modo_jogo.sh

MARCA="${MARCA:-KILLlaKILL_IF.exe}"
# prefixo sem byte nulo, para o grep conseguir procurar
PREFIXO=$(printf '\xcc\x08\xc8\x90\x88\x01')
ORIGINAL="cc 08 c8 90 88 01 00 00"
CORRIGIDO="cc 08 c8 90 00 00 00 00"

# Lê 8 bytes do arquivo a partir de um deslocamento, em hex separado por espaço.
_ler8() {
  dd if="$1" bs=1 skip="$2" count=8 status=none 2>/dev/null | od -An -tx1 | tr -s ' ' | sed 's/^ //;s/ $//'
}

# aplicar_modo_jogo <pasta_do_jogo> <pasta_de_backup>
# Devolve: 0 aplicado, 1 já estava aplicado, 2 não achou o padrão
aplicar_modo_jogo() {
  local jogo="$1" backup="$2"
  local exe="$jogo/$MARCA"

  [ -f "$exe" ] || return 2

  local off
  off=$(LC_ALL=C grep -abo -F "$PREFIXO" "$exe" 2>/dev/null | head -1 | cut -d: -f1)

  if [ -n "$off" ] && [ "$(_ler8 "$exe" "$off")" = "$ORIGINAL" ]; then
    # guarda o executável inteiro antes de mexer
    if [ ! -f "$backup/$MARCA" ]; then
      mkdir -p "$backup"
      cp -- "$exe" "$backup/$MARCA"
    fi
    printf '\0\0\0\0' | dd of="$exe" bs=1 seek=$((off + 4)) conv=notrunc status=none
    [ "$(_ler8 "$exe" "$off")" = "$CORRIGIDO" ] && return 0
    return 2
  fi

  # já corrigido?
  local off2
  off2=$(LC_ALL=C grep -abo -F "$(printf '\xcc\x08\xc8\x90')" "$exe" 2>/dev/null | while IFS=: read -r p _; do
    [ "$(_ler8 "$exe" "$p")" = "$CORRIGIDO" ] && { echo "$p"; break; }
  done)
  [ -n "$off2" ] && return 1

  return 2
}

# Rodando sozinho (e não sendo carregado pelo instalar.sh), aplica só a correção.
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  set -uo pipefail
  _aqui="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  . "$_aqui/comum.sh"

  printf '\n  KILL la KILL -IF — correção do Modo Jogo do Steam Deck\n'
  printf '  -----------------------------------------------------\n\n'

  _destino="$(perguntar_jogo)" || exit 1
  printf '  Jogo encontrado em:\n  %s\n\n' "$_destino"

  aplicar_modo_jogo "$_destino" "$_destino/ResourceWin/_backup_ptbr"
  case $? in
    0) printf '  Pronto! Correção aplicada.\n'
       printf '  O original do executável ficou guardado; o desinstalar.sh devolve.\n\n' ;;
    1) printf '  Já estava aplicada. Nada a fazer.\n\n' ;;
    2) printf '  Não achei o padrão de bytes no executável.\n'
       printf '  O jogo pode ter sido atualizado desde que a correção foi descoberta.\n\n'
       exit 1 ;;
  esac
fi
