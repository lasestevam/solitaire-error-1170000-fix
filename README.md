# Corrigir o erro 1170000 do Microsoft Solitaire Collection — Windows 11

Guia em português para corrigir uma possível causa do erro **1170000** ao entrar no Microsoft Solitaire Collection:

> Não foi possível conectá-lo ao Xbox Live.

## Problema identificado

No caso testado, o aplicativo Xbox permitia fazer login normalmente, mas o Microsoft Solitaire Collection apresentava o erro 1170000. A verificação dos serviços do Windows mostrou:

| Serviço | Status | Tipo de inicialização |
| --- | --- | --- |
| GamingServices | Running | Automatic |
| GamingServicesNet | Running | Automatic |
| XblAuthManager | Stopped | Disabled |
| XblGameSave | Stopped | Disabled |
| XboxNetApiSvc | Stopped | Disabled |

**Resultado:** reativar os três serviços Xbox (inicialização manual) e iniciar o serviço de autenticação `XblAuthManager` resolveu a falha naquele computador.

**Atenção:** o erro 1170000 pode ter outras causas. A solução abaixo é indicada especialmente quando os serviços Xbox estão desativados.

## Método manual

1. Feche o Microsoft Solitaire Collection.
2. Abra o **PowerShell/Terminal como administrador**.
3. Verifique os serviços:

```powershell
Get-Service -Name XblAuthManager,XblGameSave,XboxNetApiSvc,GamingServices,GamingServicesNet -ErrorAction SilentlyContinue |
    Select-Object Name,Status,StartType
```

4. **Se os serviços Xbox estiverem desativados**, configure-os como Manual:

```powershell
'XblAuthManager','XblGameSave','XboxNetApiSvc' | ForEach-Object {
    Set-Service -Name $_ -StartupType Manual
}
```

5. Inicie o serviço de autenticação Xbox Live:

```powershell
Start-Service -Name XblAuthManager
```

6. Abra o Solitaire e tente entrar novamente.

> No Windows PowerShell, `Set-Service -Name` aceita um serviço por chamada. O `ForEach-Object` evita o erro ao tentar passar três nomes de uma vez.

## Método assistido (script)

Arquivo: [corrigir-erro-1170000.ps1](corrigir-erro-1170000.ps1)

O script mostra o estado dos serviços, pede confirmação antes de alterar os que estão desativados, tenta iniciar `XblAuthManager` e exibe os estados finais.

Para executar:
1. Baixe o script e **leia o conteúdo**.
2. Abra o PowerShell como administrador.
3. Entre na pasta em que o script está salvo.
4. Execute:

```powershell
.\corrigir-erro-1170000.ps1
```

Se a política de execução do Windows bloquear o arquivo, não é necessário desativar a proteção do sistema: use o método manual acima.

## Outras verificações

Se a falha continuar, verifique se a Microsoft Store e o Xbox estão conectados à mesma conta e tente **Reparar** o aplicativo Solitaire nas Configurações do Windows. Evite **Redefinir** ou desinstalar o aplicativo antes de confirmar se o progresso está sincronizado.

## Segurança e escopo

- Testado em **Windows 11**.
- A alteração de serviços requer privilégios de administrador.
- Não apaga dados do jogo nem reinstala aplicativos.
- Não garante a resolução de todos os casos do código 1170000.
- Projeto independente, sem afiliação com a Microsoft ou o Xbox.
