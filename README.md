# ✂️ KILL la KILL -IF — Tradução PT-BR

> Tradução **não-oficial** para **Português do Brasil** de *KILL la KILL -IF* (Steam, 2019) — **todo o texto do jogo**: história, batalhas, menus e lista de golpes.

<p align="center">
  <img alt="Idioma" src="https://img.shields.io/badge/idioma-Portugu%C3%AAs%20(BR)-009c3b">
  <img alt="Plataforma" src="https://img.shields.io/badge/plataforma-PC%20%2B%20Steam%20Deck-1b2838">
  <img alt="Versão" src="https://img.shields.io/badge/vers%C3%A3o-1.0-c41020">
  <img alt="Cobertura" src="https://img.shields.io/badge/texto-100%25-brightgreen">
  <img alt="Uso" src="https://img.shields.io/badge/uso-n%C3%A3o--comercial-important">
</p>

---

## 📜 Sobre

*KILL la KILL -IF* é o jogo de luta do anime da **Studio Trigger**, e conta um "e se" da história: o que aconteceria se a **Satsuki** tivesse dado o primeiro golpe. Tem modo história com dublagem, os Uniformes Goku, as Fibras de Vida e a Ryuko gritando com uma metade de tesoura na mão. Nunca saiu em português.

Esta tradução leva **todo o texto do jogo** para o português do Brasil: as falas do modo história, as provocações de batalha de cada personagem, os menus, os tutoriais, a galeria e a lista de golpes.

A tradução ocupa o **slot do idioma Inglês** — que é o padrão do jogo. Instalou, abriu, está em português.

> ⚠️ **Aviso:** esta é uma **tradução amadora**, feita por um fã, e **pode conter erros** — algum typo, uma frase com sentido um pouco diferente, ou um texto que estourou a caixa. Se encontrar algo, abra uma [*issue*](../../issues) com um print que eu corrijo. 🙂

---

## 🎮 O que foi traduzido

| Conteúdo | Linhas | Cobertura |
|---|:---:|:---:|
| **Falas de batalha** (por personagem) | 7.705 | ✅ 100% |
| **Modo História** — diálogos | 1.248 | ✅ 100% |
| **Menus, sistema, tutoriais e galeria** | 1.362 | ✅ 100% |
| **Lista de golpes e nomes de ações** | 681 | ✅ 100% |
| **Falas rápidas do modo online** | 528 | ✅ 100% |
| **Total** | **11.524** | **✅ 100%** |

Isso inclui:

- 🗡️ **O modo história inteiro** — o arco da Satsuki e o da Ryuko, com as descrições de episódio e as telas de resultado
- 💢 **As provocações de batalha de todo mundo** — Ryuko, Satsuki, Gamagoori, Sanageyama, Jakuzure, Inumuta, Ragyo, Nui, Mako e a Ryuko de Dois Estrelas, incluindo as falas específicas de cada confronto
- 🥊 **A lista de golpes completa**, com nomes de ataques, combos e mecânicas
- 🧭 **Menus, opções, tutoriais, requisitos de desbloqueio e galeria**
- 💬 **As falas rápidas do modo online**

O texto passou por uma **verificação automática** nos 23 arquivos do jogo: ícones de botão (`{CA}`, `{LA}`, `{BR}`…), marcadores de número (`%d`, `%l`) e quebras de linha. **Zero divergências** no resultado final.

---

## 🇬🇧 O que ficou em inglês — e por quê

Uma parte da interface de *KILL la KILL -IF* **não é texto: é imagem**. Palavras como `STORY`, `VERSUS`, `GALLERY`, `OPTIONS`, `EPISODE`, `FIGHT` e `KO` estão desenhadas dentro de texturas, com a fonte estilizada do jogo.

Essas ficaram **em inglês, de propósito**.

É a convenção de jogo de luta — ninguém estranha um `KO` ou um `FIGHT` na tela — e o resultado fica mais coerente do que meia interface em português e meia em outro idioma. **Todo o texto que importa para entender o jogo está traduzido:** as falas, as descrições, os tutoriais, os requisitos e a lista de golpes.

| Item | Situação |
|---|---|
| Rótulos desenhados (`STORY`, `VERSUS`, `GALLERY`, `OPTIONS`, `FIGHT`, `KO`, `EPISODE`…) | Inglês, por escolha |
| Cartões de título das cutscenes | Inglês (também são imagem) |
| Nomes próprios (Ryuko, Satsuki, Senketsu, Junketsu, Honnouji, REVOCS…) | Mantidos, como no anime |
| `Bloody Valor` | Mantido — é nome próprio do minigame |
| Sequências de ícone de botão na lista de golpes | Não são texto, são símbolos |

---

## 🎨 Sobre o tom

Kill la Kill é escrachado, gritado e sem freio. A tradução acompanha: **xingamento é xingamento, provocação é provocação**. Nada foi suavizado.

Cada personagem tem a voz mantida — a Ryuko fala na agressividade e na gíria, a Satsuki é imperiosa e formal, a Mako é acelerada e caótica, o Gamagoori é solene e exagerado. Os termos da série seguem a legendagem brasileira do anime: **Fibras de Vida**, **Uniforme Goku**, **Lâmina-Tesoura**, **Academia Honnouji**, **Quatro Elites**.

O [`GLOSSARIO.md`](fonte/GLOSSARIO.md) tem a lista completa de termos fixos.

---

## 🛠️ Como foi feito (resumo)

O texto do jogo fica em **23 arquivos `.mes`**, num formato próprio com assinatura `GSAM`: uma tabela de entradas com rótulo em ASCII e texto em UTF-16, mais uma tabela hash de 256 baldes para busca pelo rótulo.

O formato foi decifrado do zero e a ferramenta de leitura e escrita faz **round-trip byte-perfeito nos 207 arquivos do jogo** — reconstruir sem alterar nada devolve o arquivo idêntico, bit a bit. Só depois disso a tradução começou.

O jogo tem **nove slots de idioma** (`_CS _CT _KO _FR _GR _IT _SP _JP _EN`), escolhidos pelo idioma configurado no Steam. A tradução ocupa o slot **inglês**, que é o padrão — assim ninguém precisa mexer em nada.

Uma boa notícia do caminho: **a fonte do jogo tem todos os acentos do português**. `ã`, `õ`, `ç`, `ê`, `à` — todos renderizam, mesmo não sendo usados por nenhum dos idiomas oficiais. Não precisou remapear glifo nenhum.

### Refazer a partir da fonte

A pasta [`fonte/`](fonte) tem o material que produz a tradução:

- [`traducoes/`](fonte/traducoes) — os textos em JSON, separados por tipo de conteúdo
- [`GLOSSARIO.md`](fonte/GLOSSARIO.md) — termos fixos e a voz de cada personagem
- [`ferramentas/mes.py`](fonte/ferramentas) — leitor e escritor do formato `.mes`
- [`ferramentas/export.py`](fonte/ferramentas) — extrai o texto do jogo para JSON
- [`ferramentas/checar.py`](fonte/ferramentas) — confere ícones, marcadores, quebras de linha e acentos
- [`ferramentas/build.py`](fonte/ferramentas) — remonta os `.mes` e instala no jogo

---

## 💾 Instalação

> **Requisitos:** *KILL la KILL -IF* instalado pela **Steam**. Não precisa de Python, nem de mexer em Proton, variável de ambiente ou opção de inicialização.

Baixe o pacote da sua plataforma na página de [**Releases**](../../releases/latest).

### 🪟 Windows

1. Baixe e **descompacte** `KillLaKill_PTBR_Windows.zip`.
2. **Feche o jogo.**
3. Dê **duplo-clique** em `INSTALAR.bat`.
4. Ele encontra a pasta do jogo sozinho, em qualquer biblioteca do Steam, **inclusive em outro disco**. *(Se não achar, ele pergunta o caminho.)*
5. Abra o jogo — já está em português.

### 🎮 Steam Deck

1. **Feche o jogo** e vá para o **Modo Área de Trabalho**.
2. Copie a pasta `SteamDeck` para o Deck (ex.: `~/Downloads`) e **descompacte**.
3. Abra o **Konsole** e rode:
   ```bash
   cd ~/Downloads/SteamDeck
   bash instalar.sh
   ```
4. Ele detecta o jogo no SSD **ou no cartão SD**.
5. Volte ao **Modo Jogo** e abra o jogo.

> 💡 Rode com `bash instalar.sh` mesmo, e não `./instalar.sh`: o bit de execução se perde quando o arquivo passa pelo Windows.

### 📋 Instalar na mão, sem o instalador

Se preferir copiar e colar, dá. A pasta `dados/ResourceWin` é um espelho da estrutura do jogo: copie **`ResourceWin`** e cole dentro da pasta do jogo, **mesclando** as pastas e sobrescrevendo os arquivos repetidos.

- Windows: `...\steamapps\common\KILL la KILL -IF\`
- Steam Deck: `~/.local/share/Steam/steamapps/common/KILL la KILL -IF/` — ou `/run/media/mmcblk0p1/steamapps/common/KILL la KILL -IF/` se estiver no cartão SD

> ⚠️ No Steam Deck, o Dolphin vai perguntar o que fazer com a pasta que já existe: escolha **Mesclar**, nunca *Substituir*. Substituir apaga o resto do `ResourceWin` e o jogo para de abrir.

Fazendo assim você perde o **backup**: o instalador guarda os 23 arquivos originais antes de copiar, e é isso que o desinstalador usa depois. Para desfazer, aí só pelo Steam — *Propriedades → Arquivos instalados → Verificar integridade*.

### ⚙️ O idioma do jogo tem que estar em Inglês

A tradução ocupa o slot do inglês, que é o **padrão** do jogo — quem nunca mexeu nisso não precisa fazer nada.

Se você já tinha trocado, ajuste em: **Biblioteca → botão direito no jogo → Propriedades → Idioma → Inglês**.

---

## ↩️ Como reverter

Rode o `DESINSTALAR.bat` (Windows) ou `bash desinstalar.sh` (Deck).

O instalador guarda os arquivos originais em `ResourceWin\_backup_ptbr`, dentro da pasta do jogo, e o desinstalador devolve todos eles. Se essa pasta tiver sumido, dá para voltar pelo Steam: **Propriedades → Arquivos instalados → Verificar integridade**.

> ⚠️ **Verificar a integridade também remove a tradução** — é o comportamento normal do Steam com arquivos modificados. Se isso acontecer, é só rodar o instalador de novo.

A tradução **não encosta nos saves** e não atrapalha as conquistas.

---

## ⚖️ Licença e uso

Esta é uma **tradução de fã**, feita **sem fins lucrativos** e **sem qualquer afiliação** com a Arc System Works, a APLUS Games ou a Studio Trigger.

- ✅ **Pode** baixar, usar e compartilhar **gratuitamente**.
- ✅ **Pode** repostar, desde que **credite** o autor e **mantenha** este aviso.
- ❌ **É proibido vender, cobrar, monetizar ou lucrar** de qualquer forma com esta tradução.
- ❌ **É proibido distribuir os arquivos do jogo.** Compartilhe **apenas o pacote** deste repositório.

*KILL la KILL -IF* e todos os nomes relacionados pertencem aos seus respectivos donos. Este projeto não é oficial e não substitui a compra do jogo.

---

## 🙏 Créditos

**Tradução, engenharia reversa e ferramentas:** **Wender_sky** *(Steam)*

Feito com muito café e um respeito enorme pela bagunça gloriosa que a Trigger fez. ✂️

---

<p align="center"><i>“Não tenha medo! Antes do meu corpo secar!”</i><br><sub>— Ryuko Matoi</sub></p>
