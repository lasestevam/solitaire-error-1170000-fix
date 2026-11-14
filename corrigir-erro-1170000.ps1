# Microsoft Solitaire Collection erro 1170000 - diagnostico e reparo opcional.
# Execute como administrador. Nao apaga dados do jogo.
$serviceNames = @('XblAuthManager', 'XblGameSave', 'XboxNetApiSvc')
$allNames = @('GamingServices', 'GamingServicesNet') + $serviceNames

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning 'Execute o PowerShell como administrador.'
    exit 1
}

Write-Host 'Servicos encontrados:' -ForegroundColor Cyan
foreach ($name in $allNames) {
    $s = Get-Service -Name $name -ErrorAction SilentlyContinue
    if ($null -eq $s) {
        Write-Warning "$name nao encontrado"
    } else {
        Write-Host ('{0}: {1} / {2}' -f $name, $s.Status, $s.StartType)
    }
}

$disabled = @($serviceNames | Where-Object {
    $s = Get-Service -Name $_ -ErrorAction SilentlyContinue
    $null -ne $s -and $s.StartType -eq 'Disabled'
})

if ($disabled.Count -gt 0) {
    Write-Host ('Servicos desativados: ' + ($disabled -join ', ')) -ForegroundColor Yellow
    $answer = Read-Host 'Mudar SOMENTE esses servicos para Manual? (S/N)'
    if ($answer -notin @('S', 's', 'sim', 'Sim', 'SIM')) {
        Write-Host 'Nenhuma alteracao realizada.'
        exit 0
    }
    foreach ($name in $disabled) {
        try {
            Set-Service -Name $name -StartupType Manual -ErrorAction Stop
            Write-Host "$name configurado como Manual." -ForegroundColor Green
        } catch {
            Write-Warning ('Falha ao configurar {0}: {1}' -f $name, $_.Exception.Message)
        }
    }
} else {
    Write-Host 'Nenhum dos tres servicos Xbox esta desativado.'
}

$auth = Get-Service -Name XblAuthManager -ErrorAction SilentlyContinue
if ($null -eq $auth) {
    Write-Warning 'XblAuthManager nao encontrado.'
} elseif ($auth.Status -eq 'Running') {
    Write-Host 'XblAuthManager ja esta ativo.' -ForegroundColor Green
} elseif ($auth.StartType -eq 'Disabled') {
    Write-Warning 'XblAuthManager continua desativado e nao pode ser iniciado.'
} else {
    try {
        Start-Service -Name XblAuthManager -ErrorAction Stop
        Write-Host 'XblAuthManager iniciado.' -ForegroundColor Green
    } catch {
        Write-Warning ('Falha ao iniciar XblAuthManager: {0}' -f $_.Exception.Message)
    }
}

Write-Host 'Estado final:' -ForegroundColor Cyan
foreach ($name in $allNames) {
    $s = Get-Service -Name $name -ErrorAction SilentlyContinue
    if ($null -ne $s) { Write-Host ('{0}: {1} / {2}' -f $name, $s.Status, $s.StartType) }
}
Write-Host 'Reabra o Solitaire e teste o login.'
