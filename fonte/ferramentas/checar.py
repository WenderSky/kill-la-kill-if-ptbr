"""Confere a traducao antes de gerar os .mes.

- codigos de controle e marcadores de formato que sumiram ou apareceram
- caracteres que nao existem em nenhum idioma original do jogo (risco de fonte)
- linhas muito mais longas que o ingles (risco de estourar a caixa)

Uso: py checar.py
"""

import json
import re
from collections import Counter
from pathlib import Path

from mes import Mes

GAME = Path(r"E:\SteamLibrary\steamapps\common\KILL la KILL -IF\ResourceWin")
TRAD = Path(r"D:\klk_trad\traduzir")
TAG = re.compile(r"\{[^}]{0,20}\}|%[0-9a-zA-Z]+|\n")


def charset_do_jogo():
    chars = set()
    for lang in ("EN", "FR", "SP", "GR", "IT", "JP"):
        for f in GAME.rglob(f"_{lang}.mes"):
            for _, t, _ in Mes.from_file(f).entries:
                chars |= set(t)
    return chars


def main():
    seguro = charset_do_jogo()
    tags_ruins = []
    longas = []
    fora = Counter()
    total = feitas = 0

    for j in sorted(TRAD.rglob("*.json")):
        d = json.loads(j.read_text(encoding="utf-8"))
        for l in d["linhas"]:
            total += 1
            pt = l.get("pt") or ""
            if not pt.strip():
                continue
            feitas += 1
            en = l["en"]
            if Counter(TAG.findall(en)) != Counter(TAG.findall(pt)):
                tags_ruins.append((j.name, l["id"], en[:60], pt[:60]))
            for c in set(pt) - seguro:
                fora[c] += 1
            if len(en) > 12 and len(pt) > len(en) * 1.6:
                longas.append((j.name, l["id"], len(en), len(pt)))

    print(f"linhas traduzidas: {feitas}/{total}")
    print(f"\ncodigos/quebras divergentes: {len(tags_ruins)}")
    for n, i, a, b in tags_ruins[:15]:
        print(f"  {n} [{i}]\n     en: {a!r}\n     pt: {b!r}")
    print(f"\ncaracteres fora do charset do jogo: {len(fora)}")
    for c, n in fora.most_common(40):
        print(f"  {c!r} U+{ord(c):04X} x{n}")
    print(f"\nlinhas >60% mais longas que o ingles: {len(longas)}")
    for n, i, a, b in longas[:15]:
        print(f"  {n} [{i}] {a} -> {b}")


if __name__ == "__main__":
    main()
