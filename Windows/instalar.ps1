$ErrorActionPreference = 'Stop'
$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8
$aqui   = Split-Path -Parent $MyInvocation.MyCommand.Path
$dados  = Join-Path $aqui 'dados'
$marca  = 'KILLlaKILL_IF.exe'
$pastaJogo = 'KILL la KILL -IF'

Write-Host ''
Write-Host '  KILL la KILL -IF - traducao PT-BR' -ForegroundColor Cyan
Write-Host '  ---------------------------------'
Write-Host ''

if (-not (Test-Path $dados)) {
    Write-Host '  Nao achei a pasta dados aqui do lado.' -ForegroundColor Red
    Write-Host '  Descompacte o pacote inteiro antes de rodar.'
    Write-Host ''
    Read-Host '  Enter para fechar' | Out-Null
    exit 1
}

function Achar-Jogo {
    $bibliotecas = @()
    try {
        $steam = (Get-ItemProperty 'HKCU:\Software\Valve\Steam' -Name SteamPath -ErrorAction Stop).SteamPath
        $bibliotecas += $steam
        $vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
        if (Test-Path $vdf) {
            foreach ($linha in Get-Content $vdf) {
                if ($linha -match '"path"\s+"(.+?)"') { $bibliotecas += $Matches[1] -replace '\\\\','\' }
            }
        }
    } catch {}
    # discos comuns, caso o registro nao ajude
    foreach ($d in (Get-PSDrive -PSProvider FileSystem).Name) {
        $bibliotecas += "${d}:\SteamLibrary", "${d}:\Steam", "${d}:\Program Files (x86)\Steam"
    }
    foreach ($b in ($bibliotecas | Select-Object -Unique)) {
        $alvo = Join-Path $b "steamapps\common\$pastaJogo"
        if (Test-Path (Join-Path $alvo $marca)) { return $alvo }
    }
    return $null
}

$destino = Achar-Jogo
if (-not $destino) {
    Write-Host '  Nao encontrei a pasta do jogo automaticamente.' -ForegroundColor Yellow
    Write-Host '  No Steam: clique com o botao direito em KILL la KILL -IF >'
    Write-Host '  Gerenciar > Procurar arquivos locais, e cole o caminho aqui.'
    Write-Host ''
    $destino = (Read-Host '  Caminho da pasta do jogo').Trim('"'' ')
}

if (-not (Test-Path (Join-Path $destino $marca))) {
    Write-Host ''
    Write-Host "  Isso nao parece a pasta do jogo: $destino" -ForegroundColor Red
    Write-Host "  Deve existir um $marca la dentro."
    Write-Host ''
    Read-Host '  Enter para fechar' | Out-Null
    exit 1
}

Write-Host '  Jogo encontrado em:'
Write-Host "  $destino" -ForegroundColor Green
Write-Host ''

# Guarda os originais na primeira instalacao, para o desinstalador ter o que devolver
$backup = Join-Path $destino 'ResourceWin\_backup_ptbr'
$novos  = Get-ChildItem $dados -Recurse -File
$guardados = 0
foreach ($f in $novos) {
    $rel  = $f.FullName.Substring($dados.Length).TrimStart('\')
    $orig = Join-Path $destino $rel
    $bkp  = Join-Path $backup $rel
    if ((Test-Path $orig) -and -not (Test-Path $bkp)) {
        New-Item -ItemType Directory -Force -Path (Split-Path $bkp) | Out-Null
        Copy-Item $orig $bkp
        $guardados++
    }
}
if ($guardados) { Write-Host "  Copia de seguranca dos $guardados arquivos originais guardada." }

$copiados = 0
foreach ($f in $novos) {
    $rel  = $f.FullName.Substring($dados.Length).TrimStart('\')
    $alvo = Join-Path $destino $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $alvo) | Out-Null
    Copy-Item $f.FullName $alvo -Force
    $copiados++
}

Write-Host ''
Write-Host "  Pronto! $copiados arquivos instalados." -ForegroundColor Green
Write-Host ''
Write-Host '  IMPORTANTE: o jogo precisa estar em INGLES no Steam.' -ForegroundColor Yellow
Write-Host '  Biblioteca > botao direito no jogo > Propriedades > Idioma > Ingles.'
Write-Host '  (Se voce nunca mexeu nisso, ja esta em ingles e nao precisa fazer nada.)'
Write-Host ''
Write-Host '  Para remover, rode DESINSTALAR.bat.'
Write-Host ''
Read-Host '  Enter para fechar' | Out-Null
