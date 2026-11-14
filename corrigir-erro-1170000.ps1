# Correcao do erro 1170000 do Microsoft Solitaire Collection no Windows 11.
# Leia antes de executar. Requer PowerShell como administrador.
# Nao apaga progresso do jogo nem redefine aplicativos.

$ErrorActionPreference = 'Stop'
$serviceNames = @('XblAuthManager', 'XblGameSave', 'XboxNetApiSvc')
$checkNames = @('GamingServices', 'GamingServicesNet') + $serviceNames

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Abra o PowerShell como administrador e execute novamente.' -ForegroundColor Yellow
    exit 1
}

Write-Host 'Estado atual dos servicos:' -ForegroundColor Cyan
foreach ($name in $checkNames) {
    $service = Get-Service -Name $name -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Write-Host ("{0}: NAO ENCONTRADO" -f $name) -ForegroundColor Yellow
    } else {
        Write-Host ("{0}: {1} / {2}" -f $name, $service.Status, $service.StartType)
    }
}

$disabled = @($serviceNames | Where-Object {
    $s = Get-Service -Name $_ -ErrorAction SilentlyContinue
    $null -ne $s -and $s.StartType -eq 'Disabled'
})

if ($disabled.Count -gt 0) {
    Write-Host ''
    Write-Host 'Servicos Xbox desativados:' -ForegroundColor Yellow
    $disabled | ForEach-Object { Write-Host (" - {0}" -f $_) }
    $answer = Read-Host 'Deseja alterar SOMENTE esses servicos para inicializacao Manual? (S/N)'
    if ($answer -notin @('S','s','Sim','sim')) {
        Write-Host 'Nenhuma configuracao foi alterada.'
        exit 0
    }

    foreach ($name in $disabled) {
        try {
            Set-Service -Name $name -StartupType Manual
            Write-Host ("Configurado como Manual: {0}" -f $name) -ForegroundColor Green
        } catch {
            Write-Warning ("Falha ao configurar {0}: {1}" -f $name, $_.Exception.Message)
        }
    }
} else {
    Write-Host 'Nenhum dos servicos Xbox encontrados esta desativado.'
}

$auth = Get-Service -Name 'XblAuthManager' -ErrorAction SilentlyContinue
if ($null -eq $auth) {
    Write-Warning 'XblAuthManager nao encontrado. Nao e possivel iniciar a autenticacao.'
} elseif ($auth.Status -eq 'Running') {
    Write-Host 'XblAuthManager ja esta em execucao.' -ForegroundColor Green
} elseif ($auth.StartType -eq 'Disabled') {
    Write-Warning 'XblAuthManager permanece desativado.'
} else {
    try {
        Start-Service -Name 'XblAuthManager'
        Write-Host 'XblAuthManager iniciado.' -ForegroundColor Green
    } catch {
        Write-Warning ("Falha ao iniciar XblAuthManager: {0}" -f $_.Exception.Message)
    }
}

Write-Host ''
Write-Host 'Estado final:' -ForegroundColor Cyan
foreach ($name in $checkNames) {
    $service = Get-Service -Name $name -ErrorAction SilentlyContinue
    if ($null -ne $service) {
        Write-Host ("{0}: {1} / {2}" -f $name, $service.Status, $service.StartType)
    }
}
Write-Host 'Teste o login no Microsoft Solitaire Collection.'
