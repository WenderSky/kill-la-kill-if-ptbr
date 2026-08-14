#!/usr/bin/env bash
# Localização da pasta do jogo. Usado pelo instalar.sh, pelo desinstalar.sh e
# pelo modo_jogo.sh quando ele roda sozinho.

MARCA="KILLlaKILL_IF.exe"
PASTA_JOGO="KILL la KILL -IF"

# achar_jogo -> imprime o caminho, ou nada se não encontrar
achar_jogo() {
  local candidatas=(
    "$HOME/.local/share/Steam"
    "$HOME/.steam/steam"
    "$HOME/.var/app/com.valvesoftware.Steam/data/Steam"
  )
  local m
  for m in /run/media/*/ /run/media/deck/*/ ; do
    [ -d "$m" ] && candidatas+=("${m%/}")
  done
  local vdf p
  for vdf in "$HOME/.local/share/Steam/steamapps/libraryfolders.vdf" \
             "$HOME/.steam/steam/steamapps/libraryfolders.vdf"; do
    # sed POSIX em vez de grep -oP: -P depende do locale e nem sempre existe
    [ -f "$vdf" ] && while IFS= read -r p; do
      [ -n "$p" ] && candidatas+=("$p")
    done < <(sed -n 's/.*"path"[[:space:]]*"\(.*\)".*/\1/p' "$vdf" 2>/dev/null)
  done

  local b alvo
  for b in "${candidatas[@]}"; do
    for alvo in "$b/steamapps/common/$PASTA_JOGO" "$b/common/$PASTA_JOGO"; do
      if [ -f "$alvo/$MARCA" ]; then printf '%s' "$alvo"; return 0; fi
    done
  done
  return 1
}

# perguntar_jogo -> caminho validado, perguntando ao usuário se preciso
perguntar_jogo() {
  local destino
  destino="$(achar_jogo)" || true
  if [ -z "$destino" ]; then
    printf '  Não encontrei a pasta do jogo automaticamente.\n' >&2
    printf '  No Steam: KILL la KILL -IF > engrenagem > Propriedades >\n' >&2
    printf '  Arquivos instalados > Procurar, e cole o caminho aqui.\n\n' >&2
    read -r -p '  Caminho da pasta do jogo: ' destino
    destino="${destino%\"}"; destino="${destino#\"}"
  fi
  if [ ! -f "$destino/$MARCA" ]; then
    printf '\n  Isso não parece a pasta do jogo: %s\n' "$destino" >&2
    printf '  Deve existir um %s lá dentro.\n\n' "$MARCA" >&2
    return 1
  fi
  printf '%s' "$destino"
}
