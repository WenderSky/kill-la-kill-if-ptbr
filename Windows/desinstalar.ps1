$ErrorActionPreference = 'Stop'
$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8
$marca = 'KILLlaKILL_IF.exe'
$pastaJogo = 'KILL la KILL -IF'

Write-Host ''
Write-Host '  KILL la KILL -IF - remover a traducao PT-BR' -ForegroundColor Cyan
Write-Host '  ------------------------------------------'
Write-Host ''

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
if (-not $destino) { $destino = (Read-Host '  Caminho da pasta do jogo').Trim('"'' ') }

$backup = Join-Path $destino 'ResourceWin\_backup_ptbr'
if (-not (Test-Path $backup)) {
    Write-Host '  Nao achei a copia de seguranca dentro do jogo.' -ForegroundColor Yellow
    Write-Host '  Para voltar ao original: Steam > botao direito no jogo >'
    Write-Host '  Propriedades > Arquivos instalados > Verificar integridade.'
    Write-Host ''
    Read-Host '  Enter para fechar' | Out-Null
    exit 0
}

$n = 0
foreach ($f in Get-ChildItem $backup -Recurse -File) {
    $rel  = $f.FullName.Substring($backup.Length).TrimStart('\')
    $alvo = Join-Path $destino $rel
    Copy-Item $f.FullName $alvo -Force
    $n++
}
Remove-Item $backup -Recurse -Force

Write-Host ''
Write-Host "  Pronto! $n arquivos originais devolvidos." -ForegroundColor Green
Write-Host '  O jogo voltou ao ingles.'
Write-Host ''
Read-Host '  Enter para fechar' | Out-Null
