"""Parser/builder do formato .mes (GSAM) de KILL la KILL -IF.

Layout do arquivo:
    0x00  "GSAM"
    0x04  u32  tamanho do cabecalho (0x40)
    0x08  u32  versao (1)
    0x0C  u32  offset da tabela de entradas (0x40)
    0x10  u32  numero de entradas
    0x20  u32  offset da tabela de baldes (hash)
    0x24  u32  numero de baldes (256)
    resto do cabecalho preservado byte a byte

    Cada entrada tem 32 bytes:
        u32 off_label, u32 len_label (bytes, texto ASCII/cp932)
        u32 off_texto, u32 len_texto (caracteres, UTF-16LE)
        u32 flag
        12 bytes zerados

    Cada balde tem 8 bytes: u32 quantidade, u32 offset da lista.
    A lista e um vetor de u32 com offsets de entradas (hash do label & 0xFF).

    Strings terminam em nulo e sao alinhadas em 8 bytes. Depois das listas o
    arquivo tem um bloco de zeros do tamanho do offset onde as strings comecam.
"""

import json
import struct
import sys
from pathlib import Path

MAGIC = b"GSAM"
ENTRY_SIZE = 32
BUCKET_SIZE = 8


def _align8(n):
    return (n + 7) & ~7


def _dec_label(b):
    try:
        return b.decode("ascii")
    except UnicodeDecodeError:
        return b.decode("cp932")


def _enc_label(s):
    try:
        return s.encode("ascii")
    except UnicodeEncodeError:
        return s.encode("cp932")


class Mes:
    def __init__(self, header, entries, buckets):
        self.header = header        # bytes do cabecalho original
        self.entries = entries      # lista de (label, texto, flag)
        self.buckets = buckets      # lista de listas de indices de entrada

    # ---------------------------------------------------------------- leitura
    @classmethod
    def parse(cls, data):
        if data[:4] != MAGIC:
            raise ValueError("assinatura GSAM ausente")
        hdr_size, _version, entry_off, entry_count = struct.unpack_from("<4I", data, 4)
        bucket_off, bucket_count = struct.unpack_from("<2I", data, 0x20)
        header = bytearray(data[:hdr_size])

        entries = []
        for i in range(entry_count):
            lo, ll, to, tl, flag = struct.unpack_from("<5I", data, entry_off + i * ENTRY_SIZE)
            entries.append((_dec_label(data[lo:lo + ll]),
                            data[to:to + tl * 2].decode("utf-16-le"),
                            flag))

        off_to_idx = {entry_off + i * ENTRY_SIZE: i for i in range(entry_count)}
        buckets = []
        for b in range(bucket_count):
            cnt, lst = struct.unpack_from("<2I", data, bucket_off + b * BUCKET_SIZE)
            buckets.append([off_to_idx[struct.unpack_from("<I", data, lst + j * 4)[0]]
                            for j in range(cnt)])

        return cls(header, entries, buckets)

    @classmethod
    def from_file(cls, path):
        return cls.parse(Path(path).read_bytes())

    # ------------------------------------------------------------- construcao
    def build(self):
        n = len(self.entries)
        hdr_size = len(self.header)
        entry_off = hdr_size
        bucket_off = entry_off + n * ENTRY_SIZE
        str_off = bucket_off + len(self.buckets) * BUCKET_SIZE

        blobs = []
        meta = []
        cursor = str_off
        for label, text, flag in self.entries:
            lb = _enc_label(label)
            lo = cursor
            raw = lb + b"\x00"
            raw += b"\x00" * (_align8(len(raw)) - len(raw))
            blobs.append(raw)
            cursor += len(raw)

            tb = text.encode("utf-16-le")
            to = cursor
            raw = tb + b"\x00\x00"
            raw += b"\x00" * (_align8(len(raw)) - len(raw))
            blobs.append(raw)
            cursor += len(raw)

            meta.append((lo, len(lb), to, len(text), flag))

        bucket_meta = []
        lists = []
        for ids in self.buckets:
            if not ids:
                bucket_meta.append((0, 0))
                continue
            pad = _align8(cursor) - cursor          # cada lista comeca alinhada em 8
            if pad:
                lists.append(b"\x00" * pad)
                cursor += pad
            bucket_meta.append((len(ids), cursor))
            for i in ids:
                lists.append(struct.pack("<I", entry_off + i * ENTRY_SIZE))
            cursor += len(ids) * 4

        out = bytearray(self.header)
        struct.pack_into("<2I", out, 0x0C, entry_off, n)
        struct.pack_into("<2I", out, 0x20, bucket_off, len(self.buckets))
        for lo, ll, to, tl, flag in meta:
            out += struct.pack("<5I", lo, ll, to, tl, flag) + b"\x00" * 12
        for cnt, off in bucket_meta:
            out += struct.pack("<2I", cnt, off)
        for b in blobs:
            out += b
        for b in lists:
            out += b

        out += b"\x00" * (_align8(cursor) - cursor + str_off)
        return bytes(out)


# ------------------------------------------------------------------- utilidades
def to_rows(mes):
    return [{"id": lb, "text": tx} for lb, tx, _ in mes.entries]


def apply_rows(mes, rows):
    """Aplica traducoes casando pelo id, respeitando ids repetidos pela ordem."""
    by_id = {}
    for r in rows:
        by_id.setdefault(r["id"], []).append(r.get("text", ""))
    seen = {}
    novas = []
    for lb, tx, flag in mes.entries:
        k = seen.get(lb, 0)
        seen[lb] = k + 1
        cand = by_id.get(lb)
        novas.append((lb, cand[k] if cand and k < len(cand) else tx, flag))
    mes.entries = novas
    return mes


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "dump":
        print(json.dumps(to_rows(Mes.from_file(sys.argv[2])), ensure_ascii=False, indent=1))
    elif cmd == "roundtrip":
        raw = Path(sys.argv[2]).read_bytes()
        print("OK" if Mes.parse(raw).build() == raw else "DIFERENTE", sys.argv[2])
