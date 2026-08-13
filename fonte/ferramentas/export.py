"""Exporta o texto de KILL la KILL -IF para JSONs prontos para traducao.

Uso:  py export.py
Gera D:\\klk_trad\\traduzir\\<grupo>\\<nome>_pNN.json
"""

import json
import shutil
import sys
from pathlib import Path

from mes import Mes

GAME = Path(r"E:\SteamLibrary\steamapps\common\KILL la KILL -IF\ResourceWin")
WORK = Path(r"D:\klk_trad")
OUT = WORK / "traduzir"
BACKUP = WORK / "backup"
IDIOMA_BASE = "EN"
POR_ARQUIVO = 200          # linhas por parte

INSTRUCOES = (
    "Traduza o campo 'en' para portugues do Brasil e escreva o resultado em 'pt'. "
    "Nao altere 'id'. Mantenha intactos os codigos entre chaves ({CA}, {LA}, {BR}, {JU}, "
    "{SP}, {GD}, {LS}, {L1}, {R1}, setas), os marcadores de formato (%d, %l, %ls, %hs) e "
    "as quebras de linha \\n. Se uma linha nao precisar de traducao, deixe 'pt' vazio."
)

# nome do grupo -> (pasta de destino, rotulo legivel)
GRUPOS = {
    "message/MES_COMMON": ("01_sistema_menus", "Menus, sistema e avisos"),
    "message/MES_CMD_LIST": ("02_comandos", "Lista de comandos e golpes"),
    "message/MES_ACTION": ("02_comandos", "Nomes de acoes"),
    "message/MES_CHAT": ("03_chat", "Falas rapidas / chat online"),
    "KlkStory/STY_MS_0000/MES_ALL_0000": ("04_historia", "Modo Historia - dialogos"),
}
PERSONAGENS = {
    "RYU": "Ryuko", "SAT": "Satsuki", "GAM": "Gamagoori", "SAN": "Sanageyama",
    "JYA": "Jakuzure", "INU": "Inumuta", "RAG": "Ragyo", "NUI": "Nui",
    "MAK": "Mako", "DTR": "DTR",
}


def grupo_de(rel):
    chave = rel.replace("\\", "/")
    if chave in GRUPOS:
        return GRUPOS[chave]
    if "S701_MES" in chave:
        nome = chave.rsplit("/", 1)[-1]
        for sigla, pers in PERSONAGENS.items():
            if f"_{sigla}_" in nome:
                return ("05_personagens", f"Falas em batalha - {pers}")
        return ("05_personagens", f"Falas em batalha - {nome}")
    return ("99_outros", chave)


def main():
    com_jp = "--com-jp" in sys.argv       # inclui o texto japones como referencia
    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir(parents=True)

    total = 0
    indice = []
    for src in sorted(GAME.rglob(f"_{IDIOMA_BASE}.mes")):
        rel = str(src.parent.relative_to(GAME))

        # backup de todos os idiomas desse diretorio
        for f in src.parent.glob("*.mes"):
            dst = BACKUP / f.relative_to(GAME)
            dst.parent.mkdir(parents=True, exist_ok=True)
            if not dst.exists():
                shutil.copy2(f, dst)

        pasta, rotulo = grupo_de(rel)
        (OUT / pasta).mkdir(exist_ok=True)
        nome = src.parent.name

        entradas = Mes.from_file(src).entries
        linhas = [{"id": lb, "en": tx, "pt": ""} for lb, tx, _ in entradas]
        if com_jp:
            jp = src.parent / "_JP.mes"
            if jp.exists():
                orig = Mes.from_file(jp).entries
                if len(orig) == len(linhas):
                    for l, (_, tx, _) in zip(linhas, orig):
                        l["jp"] = tx
        total += len(linhas)
        partes = [linhas[i:i + POR_ARQUIVO] for i in range(0, len(linhas), POR_ARQUIVO)] or [[]]
        for i, parte in enumerate(partes, 1):
            arq = OUT / pasta / f"{nome}_p{i:02d}.json"
            arq.write_text(json.dumps({
                "origem": rel.replace("\\", "/"),
                "conteudo": rotulo,
                "parte": f"{i}/{len(partes)}",
                "instrucoes": INSTRUCOES,
                "linhas": parte,
            }, ensure_ascii=False, indent=1), encoding="utf-8")
            indice.append((f"{pasta}/{arq.name}", rotulo, len(parte)))

    linhas_md = ["# Indice dos arquivos a traduzir", "",
                 f"Total de {total} linhas.", "",
                 "| arquivo | conteudo | linhas |", "| --- | --- | ---: |"]
    linhas_md += [f"| `{a}` | {r} | {n} |" for a, r, n in indice]
    (OUT / "INDICE.md").write_text("\n".join(linhas_md) + "\n", encoding="utf-8")
    print(f"exportadas {total} linhas em {len(indice)} arquivos -> {OUT}")


if __name__ == "__main__":
    main()
