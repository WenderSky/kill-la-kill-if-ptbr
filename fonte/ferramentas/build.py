"""Reconstroi os .mes com o texto traduzido.

Uso:
  py build.py                 -> gera em D:\\klk_trad\\saida (slot SP)
  py build.py --slot EN       -> escreve no slot ingles
  py build.py --instalar      -> copia por cima do jogo (backup ja existe em backup\\)
  py build.py --relatorio     -> so mostra o progresso da traducao
"""

import json
import shutil
import sys
from collections import defaultdict
from pathlib import Path

from mes import Mes, apply_rows

GAME = Path(r"E:\SteamLibrary\steamapps\common\KILL la KILL -IF\ResourceWin")
WORK = Path(r"D:\klk_trad")
TRAD = WORK / "traduzir"
SAIDA = WORK / "saida"
BACKUP = WORK / "backup"
BASE = "EN"


def carregar():
    """Junta as partes traduzidas por arquivo de origem."""
    porta = defaultdict(list)
    for j in sorted(TRAD.rglob("*.json")):
        d = json.loads(j.read_text(encoding="utf-8"))
        idx = int(d["parte"].split("/")[0])
        porta[d["origem"]].append((idx, d["linhas"]))
    return {k: [l for _, parte in sorted(v) for l in parte] for k, v in porta.items()}


def main():
    slot = "SP"
    instalar = "--instalar" in sys.argv
    if "--slot" in sys.argv:
        slot = sys.argv[sys.argv.index("--slot") + 1].upper()

    dados = carregar()
    feitas = restantes = 0
    for origem, linhas in sorted(dados.items()):
        src = GAME / origem / f"_{BASE}.mes"
        base = BACKUP / origem / f"_{BASE}.mes"
        if base.exists():
            src = base
        m = Mes.from_file(src)
        if len(m.entries) != len(linhas):
            print(f"AVISO {origem}: {len(linhas)} linhas no JSON x {len(m.entries)} no jogo")

        rows = []
        for l in linhas:
            pt = (l.get("pt") or "").strip()
            if pt:
                feitas += 1
            else:
                restantes += 1
            rows.append({"id": l["id"], "text": pt or l["en"]})

        if "--relatorio" in sys.argv:
            continue

        apply_rows(m, rows)
        dst = SAIDA / origem / f"_{slot}.mes"
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_bytes(m.build())
        if instalar:
            shutil.copy2(dst, GAME / origem / f"_{slot}.mes")

    total = feitas + restantes
    pct = feitas * 100 / total if total else 0
    print(f"traduzidas {feitas}/{total} linhas ({pct:.1f}%)")
    if "--relatorio" not in sys.argv:
        print(f"gerado em {SAIDA} (slot {slot}){' e instalado no jogo' if instalar else ''}")


if __name__ == "__main__":
    main()
