<!-- : Begin batch script
@echo off
setLocal EnableExtensions
setlocal EnableDelayedExpansion
::                                        _                   _                
::              _                        | |      _          | |          _    
::   ____ _   _| |_  ___  _   _ ____   _ | | ____| |_  ____  | | _   ____| |_  
::  / _  | | | |  _)/ _ \| | | |  _ \ / || |/ _  |  _)/ _  ) | || \ / _  |  _) 
:: ( ( | | |_| | |_| |_| | |_| | | | ( (_| ( ( | | |_( (/ / _| |_) ( ( | | |__ 
::  \_||_|\____|\___\___/ \____| ||_/ \____|\_||_|\___\____(_|____/ \_||_|\___)
::                             |_|                                             
::
::�Զ�RDP��װ����װ�͸��³���asmtron (2022-01-01) 
:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::ѡ��:
:: -log =����ʾ����ض����ļ�autoupdate.log
:: -taskadd =�ڼƻ��������������ʱautoupdate.bat��autorun
:: -taskremove =�ڵ���������ɾ������ʱautoupdate.bat���Զ�����
::
::��Ϣ:
:: autopdater����ʹ�ò����ٷ���rdpwrap.ini��
:: �����ʽ��rdpwrap.ini��֧���µ�termsrv.dll��
:: autopdater���ȳ���asmtron rdpwrap.ini(�Ѳ�ж��
:: ��asmtron����)��autopdaterҲ��ʹ��rdpwrap.ini�ļ�
:: *���������ߣ��硰sebaxakerhtc, affinityv, DrDrrae, saurav-biswas����
::�����rdpwrap.iniԴҲ���Ա����塭
::
::{�ر��лbinarymaster����������������}
::
:: -----------------------------------------
:: ���� by wuyilingwei
:: -----------------------------------------
:: Ϊ�˷���������趨����Դ���ѽ�����Դ���ֵ�������Ϊ�ļ�subscription.bat
:: -----------------------------------------

:ͨ�ù���ԱȨ�޼��ģ��
title ������Ȩ���С�
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
title �ȴ�����Ա��Ȩ�С�
echo �������ԱȨ��...
mode con cols=20 lines=1
goto UACPrompt
) else ( goto start )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B
:start
:ͨ�ù���ԱȨ�޼��ģ��-����
title �Զ�����RDPWarp�ű�
set autoupdate_bat="%~dp0autoupdate.bat"
set subscription_bat="%~dp0subscription.bat"
set autoupdate_log="%~dp0autoupdate.log"
set RDPWInst_exe="%~dp0RDPWInst.exe"
set rdpwrap_dll="%~dp0rdpwrap.dll"
set rdpwrap_ini="%~dp0rdpwrap.ini"
set rdpwrap_ini_check=%rdpwrap_ini%
set rdpwrap_new_ini="%~dp0rdpwrap_new.ini"
set github_location=1
set retry_network_check=0
::
echo ___________________________________________
echo AutoRDPWarp��װ�͸��³���
echo.
echo ^<���RDPWarp�Ƿ����²������ڹ���^>
echo.

:: �����������
if /i "%~1"=="-reset" (
    echo :: ����rdpwrap.ini�ļ��ĸ���Դ�����ļ�>subscription.bat
    echo :: ����Դʾ��>>subscription.bat
    echo :: set rdpwrap_ini_update_github_{num}="https://raw.githubusercontent.com/{user}/{repository}/(master/main)/res/rdpwrap.ini>>subscription.bat
    echo [*] All subscriptions has been removed
)
if /i "%~1"=="-log" (
    echo %autoupdate_bat% output from %date% at %time% > %autoupdate_log%
    call %autoupdate_bat% >> %autoupdate_log%
    goto :finish
)
if /i "%~1"=="-taskadd" (
    echo [+] add autorun of %autoupdate_bat% on startup in the schedule task.
    schtasks /create /f /sc ONSTART /tn "RDP Wrapper Autoupdate" /tr "cmd.exe /C \"%~dp0autoupdate.bat\" -log" /ru SYSTEM /delay 0000:10
    powershell "$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries; Set-ScheduledTask -TaskName 'RDP Wrapper Autoupdate' -Settings $settings"
    goto :finish
)
if /i "%~1"=="-taskremove" (
    echo [-] remove autorun of %autoupdate_bat% on startup in the schedule task^^!
    schtasks /delete /f /tn "RDP Wrapper Autoupdate"
    goto :finish
)
if /i not "%~1"=="" (
    echo [x] Unknown argument specified: "%~1"
    echo [*] Supported argments/options are:
    echo     -log         =  redirect display output to the file autoupdate.log
    echo     -reset       =  remote all 
    echo     -taskadd     =  add autorun of autoupdate.bat on startup in the schedule task
    echo     -taskremove  =  remove autorun of autoupdate.bat on startup in the schedule task
    goto :finish
)
:: ����Ƿ����"RDPWInst.exe"
if not exist %RDPWInst_exe% goto :error_install
goto :start_check
::
:error_install
echo RDP��װ����װ��������ִ���ļ�(rdpwin .exe)δ�ҵ�^^!
echo ������صİ�װ������ȡ�����ļ��������ķ����������
echo.
goto :finish
::
:start_check
set rdpwrap_installed="0"
:: ----------------------------------
:: 1) ���TermService�Ƿ���������
:: ----------------------------------
sc queryex "TermService"|find "STATE"|find /v "RUNNING" >nul&&(
    echo [-] TermService��������^^!
    call :install
)||(
    echo [+] TermService������.
)
:: ------------------------------------------
:: 2) ���������ỰRDP-TCP�Ƿ����
:: ------------------------------------------
set rdp_tcp_session=""
set rdp_tcp_session_id=0
if exist %windir%\system32\query.exe (
    for /f "tokens=1-2* usebackq" %%a in (
        `query session rdp-tcp`
    ) do (
        set rdp_tcp_session=%%a
        set /a rdp_tcp_session_id=%%b 2>nul
    )
) else (
    for /f "tokens=2* usebackq" %%a in (
        `reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" 2^>nul`
    ) do (
        if "%%a"=="REG_DWORD" (
            set rdp_tcp_session=AllowTSConnection
            if "%%b"=="0x0" (set rdp_tcp_session_id=1)
        )
    )
)
if %rdp_tcp_session_id%==0 (
    echo [-] û���ҵ�RDP-TCP�����Ự^^!
    call :install
) else (
    echo [+] �ҵ������Ự: %rdp_tcp_session% ^(ID: %rdp_tcp_session_id%^).
)
:: -----------------------------------------
:: 3) ���ע������Ƿ����rdpwrap.dll
:: -----------------------------------------
reg query "HKLM\SYSTEM\CurrentControlSet\Services\TermService\Parameters" /f "rdpwrap.dll" >nul&&(
    echo [+] �ҵ�windowsע����� "rdpwrap.dll".
)||(
    echo [-] û���ҵ�windowsע����� "rdpwrap.dll"^^!
    if %rdpwrap_installed%=="0" (
        call :install
    )
)
:: -----------------------------------
:: 4) ���rdpwrap.dll�ļ��Ƿ����
:: -----------------------------------
if exist %rdpwrap_dll% (
    echo [+] �ҵ��ļ�: %rdpwrap_dll%
) else (
    echo [-] û���ҵ��ļ�: %rdpwrap_dll%^^!
    if %rdpwrap_installed%=="0" (
        call :install
    ) 
)
:: ------------------------------
:: 5) ���rdpwrap.ini�Ƿ����
:: ------------------------------
if exist %rdpwrap_ini% (
    echo [+] �ҵ��ļ�: %rdpwrap_ini%.
) else (
    echo [-] û���ҵ��ļ�: %rdpwrap_ini%^^!
    if %rdpwrap_installed%=="0" (
        call :install
    )
)
:: ------------------------------
:: 6) ���subscription.bat�Ƿ����
:: ------------------------------
if exist %subscription_bat% (
    echo [+] �ҵ��ļ�: %subscription_bat%.
) else (
    echo [-] û���ҵ��ļ�: %subscription_bat%^^!
    if %rdpwrap_installed%=="0" (
        call :install
    )
)
    :װ�����Դ�����ļ�
    call "%~dp0subscription.bat"
:: ----------------------------------------------------
:: 7) ��ȡtermsrv����汾��Ϣ %windir%\System32\termsrv.dll
:: ----------------------------------------------------
for /f "tokens=* usebackq" %%a in (
    `cscript //nologo "%~f0?.wsf" //job:fileVersion "%windir%\System32\termsrv.dll"`
) do (
    set termsrv_dll_ver=%%a
)
if "%termsrv_dll_ver%"=="" (
    echo [x] �޷���ȡtermsrv��Ϣ"%windir%\System32\termsrv.dll"^^!
    goto :finish
) else (
    echo [+] �Ѱ�װ"termsrv.dll"�汾: %termsrv_dll_ver%.
)
:: ----------------------------------------------------------------------------------------
:: 8) ����Ѱ�װ���ļ��汾�Ƿ���ע�������󱣴���ļ��汾��ͬ
:: ----------------------------------------------------------------------------------------
echo [*] ���ڶ�ȡע����е�"termsrv.dll"�汾��Ϣ...
for /f "tokens=2* usebackq" %%a in (
    `reg query "HKEY_LOCAL_MACHINE\SOFTWARE\RDP-Wrapper\Autoupdate" /v "termsrv.dll" 2^>nul`
) do (
    set last_termsrv_dll_ver=%%b
)
if "%last_termsrv_dll_ver%"=="%termsrv_dll_ver%" (
   echo [+] ��ǰdll�汾��Ϣ"termsrv.dll v.%termsrv_dll_ver%"���¼�а汾��Ϣ���"termsrv.dll v.%last_termsrv_dll_ver%".
) else (
    echo [-] ��ǰdll�汾��Ϣ"termsrv.dll v.%termsrv_dll_ver%"���¼�а汾��Ϣ����"termsrv.dll v.%last_termsrv_dll_ver%"^^!
    echo [*] ���ڸ���ע����е�"termsrv.dll"�汾��Ϣ...
    if %rdpwrap_installed%=="0" (
        call :install
    )
)
:: ---------------------------------------------------------------
:: 9) ��鰲װ��termsrv.dll�汾�Ƿ���rdpwrap.ini�д���
:: ---------------------------------------------------------------
:check_update
if exist %rdpwrap_ini_check% (
    echo [*] ����%rdpwrap_ini_check%��Ѱ��[%termsrv_dll_ver%]�汾��֧����Ϣ...
    findstr /c:"[%termsrv_dll_ver%]" %rdpwrap_ini_check% >nul&&(
        echo [+] ���ļ�%rdpwrap_ini_check%���ҵ���֧�ֵ�"termsrv.dll"�汾��Ϣ��[%termsrv_dll_ver%]��.
        echo [*] RDPWarp�ƺ������µģ�����������...
    )||(
        echo [-] ���ļ�%rdpwrap_ini_check%��û���ҵ���֧�ֵ�"termsrv.dll"�汾��Ϣ��[%termsrv_dll_ver%]��^^!
        if not "!rdpwrap_ini_update_github_%github_location%!" == "" (
            set rdpwrap_ini_url=!rdpwrap_ini_update_github_%github_location%!
            call :update
            goto :check_update
        )
        goto :finish
    )
) else (
    echo [-] û���ҵ��ļ�: %rdpwrap_ini_check%.
    echo [*] �������-������������/����ǽ�Ƿ���ֹ���ļ� %rdpwrap_ini_check%^^!
    goto :finish
)
goto :finish
::
:: -----------------------------------------------------
:: ��װRDPWarp(׼ȷ��˵��ж�غ����°�װ)
:: -----------------------------------------------------
:install
echo.
echo [*] ж�غ���װRDP Wrapper...
echo.
if exist %rdpwrap_dll% set rdpwrap_force_uninstall=1
if exist %rdpwrap_ini% set rdpwrap_force_uninstall=1
if "%rdpwrap_force_uninstall%"=="1" (
    echo [*] ��Windowsע�����ж��"rdpwrap.dll"...
    reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\TermService\Parameters" /f /v ServiceDll /t REG_EXPAND_SZ /d %rdpwrap_dll%
)
set rdpwrap_installed="1"
%RDPWInst_exe% -u
%RDPWInst_exe% -i -o
call :setNLA
goto :eof
::
:: -------------------
:: ����RDPWarp
:: -------------------
:restart
echo.
echo [*] ͨ���µİ汾֧���ļ�����RDPWarp (ж�غ���װ)...
echo.
%RDPWInst_exe% -u
if exist %rdpwrap_new_ini% (
    echo.
    echo [*] ʹ�ôӸ���Դ�������ص�rdpwrap.ini��
    echo     -^> %rdpwrap_ini_url% 
    echo       -^> %rdpwrap_new_ini%
    echo         -^> %rdpwrap_ini%
    echo [+] ����%rdpwrap_new_ini%��%rdpwrap_ini%...
    copy %rdpwrap_new_ini% %rdpwrap_ini%
    echo.
) else (
    echo [x] ERROR - �ļ�%rdpwrap_new_ini%��ʧ^^!
)
%RDPWInst_exe% -i
call :setNLA
goto :eof
::
:: --------------------------------------------------------------------
:: �Ӹ���Դ�������°汾��rdpwrap.ini
:: --------------------------------------------------------------------
:update
echo [*] �����������...
:netcheck
ping -n 1 bing.com>nul
if errorlevel 1 (
    goto waitnetwork
) else (
    goto download
)
:waitnetwork
echo [.] �ȴ��������ӿ���...
ping 127.0.0.1 -n 11>nul
set /a retry_network_check=retry_network_check+1
:: ���ȴ�5����
if %retry_network_check% LSS 30 goto netcheck
:download
set /a github_location=github_location+1
echo.
echo [*] ���ڴӸ���Դ�������µ�rdpwrap.ini...
echo     -^> %rdpwrap_ini_url%
for /f "tokens=* usebackq" %%a in (
    `cscript //nologo "%~f0?.wsf" //job:fileDownload %rdpwrap_ini_url% %rdpwrap_new_ini%`
) do (
    set "download_status=%%a"
)
if "%download_status%"=="-1" (
    echo [+] �ɹ��Ӹ���Դ�������°汾��%rdpwrap_new_ini%.
    set rdpwrap_ini_check=%rdpwrap_new_ini%
    call :restart
) else (
    echo [-] �Ӹ���Դ�������µ�%rdpwrap_new_ini%ʧ��^^!
    echo [*] ���ڼ���������������ǽ������^^!
)
goto :eof
::
:: --------------------------------
:: �������缶����֤
:: --------------------------------
:setNLA
echo [*] ��windowsע������������缶�������֤...
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SecurityLayer /t reg_dword /d 0x2 /f
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MinEncryptionLevel /t reg_dword /d 0x2 /f
goto :eof
::
:: -------
:: �˳�
:: -------
:finish
echo.
exit /b
::
--- Begin wsf script --- fileVersion/fileDownload --->
<package>
  <job id="fileVersion"><script language="VBScript">
    set args = WScript.Arguments
    Set fso = CreateObject("Scripting.FileSystemObject")
    WScript.Echo fso.GetFileVersion(args(0))
    Wscript.Quit
  </script></job>
  <job id="fileDownload"><script language="VBScript">
    set args = WScript.Arguments
    WScript.Echo SaveWebBinary(args(0), args(1))
    Wscript.Quit
    Function SaveWebBinary(strUrl, strFile) 'As Boolean
        Const adTypeBinary = 1
        Const adSaveCreateOverWrite = 2
        Const ForWriting = 2
        Dim web, varByteArray, strData, strBuffer, lngCounter, ado
        On Error Resume Next
        'Download the file with any available object
        Err.Clear
        Set web = Nothing
        Set web = CreateObject("WinHttp.WinHttpRequest.5.1")
        If web Is Nothing Then Set web = CreateObject("WinHttp.WinHttpRequest")
        If web Is Nothing Then Set web = CreateObject("MSXML2.ServerXMLHTTP")
        If web Is Nothing Then Set web = CreateObject("Microsoft.XMLHTTP")
        web.Open "GET", strURL, False
        web.Send
        If Err.Number <> 0 Then
            SaveWebBinary = False
            Set web = Nothing
            Exit Function
        End If
        If web.Status <> "200" Then
            SaveWebBinary = False
            Set web = Nothing
            Exit Function
        End If
        varByteArray = web.ResponseBody
        Set web = Nothing
        'Now save the file with any available method
        On Error Resume Next
        Set ado = Nothing
        Set ado = CreateObject("ADODB.Stream")
        If ado Is Nothing Then
            Set fs = CreateObject("Scripting.FileSystemObject")
            Set ts = fs.OpenTextFile(strFile, ForWriting, True)
            strData = ""
            strBuffer = ""
            For lngCounter = 0 to UBound(varByteArray)
                ts.Write Chr(255 And Ascb(Midb(varByteArray,lngCounter + 1, 1)))
            Next
            ts.Close
        Else
            ado.Type = adTypeBinary
            ado.Open
            ado.Write varByteArray
            ado.SaveToFile strFile, adSaveCreateOverWrite
            ado.Close
        End If
        SaveWebBinary = True
    End Function
  </script></job>
</package>
