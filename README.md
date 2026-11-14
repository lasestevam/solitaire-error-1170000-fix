Correção do erro 1170000 — Microsoft Solitaire Collection
Guia em português para Windows 11. O erro 1170000 pode aparecer na entrada do Solitaire mesmo que o aplicativo Xbox faça login normalmente.
Diagnóstico confirmado em um computador
Serviço	Situação encontrada
GamingServices	Running / Automatic
GamingServicesNet	Running / Automatic
XblAuthManager	Stopped / Disabled
XblGameSave	Stopped / Disabled
XboxNetApiSvc	Stopped / Disabled


Neste caso, restaurar a inicialização manual dos três serviços Xbox e iniciar XblAuthManager resolveu o problema. Não é uma solução garantida para todas as causas do erro.
Correção manual
1. Feche o Microsoft Solitaire Collection.
2. Abra PowerShell como administrador.
3. Verifique os serviços:
Get-Service -Name XblAuthManager,XblGameSave,XboxNetApiSvc,GamingServices,GamingServicesNet -ErrorAction SilentlyContinue | Select-Object Name,Status,StartType
4. Se os serviços Xbox estiverem desativados, configure-os para inicialização manual:
'XblAuthManager','XblGameSave','XboxNetApiSvc' | ForEach-Object { Set-Service -Name $_ -StartupType Manual }
5. Inicie o serviço de autenticação:
Start-Service -Name XblAuthManager
6. Abra o Solitaire e tente entrar novamente.
Nota: Set-Service -Name recebe um único nome por chamada; o ForEach-Object permite percorrer os três serviços sem erro de argumento.
Script com confirmação
O arquivo [`corrigir-erro-1170000.ps1`](corrigir-erro-1170000.ps1) confere quais serviços existem, mostra os estados, pede autorização antes de modificar os serviços desativados e tenta iniciar o serviço de autenticação. Para usar, revise o arquivo, abra o PowerShell como administrador, navegue até a pasta onde está salvo e execute:
.\corrigir-erro-1170000.ps1
O script não redefine o jogo, não exclui arquivos e não apaga progresso local.
Caso o erro continue
Confira se a mesma conta Microsoft está conectada ao Xbox e à Microsoft Store. Experimente Reparar o Solitaire nas configurações do Windows, depois de fechar o aplicativo. Evite Redefinir sem confirmar que seu progresso está sincronizado.
Aviso
Execute os comandos somente em um computador que você administra. Eles alteram a configuração de serviços do Windows. Solução independente, sem vínculo com a Microsoft. Testada no Windows 11 com PowerShell 5.1.
