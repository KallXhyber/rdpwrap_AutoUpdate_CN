@echo off
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

title RDPWarp������װ
echo ���������ʹ��Apache-2.0���֤�Ŀ�Դ��Ŀ����������ͬ����ʽ�ַ���
echo ������ֿ⣺https://github.com/wuyilingwei/rdpwrap_AutoUpdate_CN
echo û�д�GitHubֱ�����صİ�װ�����ܰ���������Ϊ��Ϊ������豸��ȫ�������Github����ŵ�Github����Դ���ء�
echo ��ȷ�Ͻ�ѹѹ�����������ļ�����Ŀ¼���������ַ�
echo ������ñ����������ȥGithub���star�ɣ�����
timeout /NOBREAK /t 3 >nul
start https://github.com/wuyilingwei/rdpwrap_AutoUpdate_CN
timeout /NOBREAK /t 5 >nul
cls
echo .
if not exist "%~dp0RDPWInst.exe" goto :error
"%~dp0RDPWInst" -i -o
echo ______________________________________________________________
echo.
echo RDPWarp������װ���
echo ������ʹ��RDPCheck������RDP���ܡ�
echo ������ʹ��RDPConf�������ø߼����á�
echo �������������ѹ������"ϵͳ��:\Program Files\RDP Wrapper"���ҵ�
echo.
goto :anykey

:error
echo [-] ERROR��û���ҵ���װ�����ִ���ļ���
echo ���ѹ�����ļ��������ɱ������Ƿ������˲����ļ���

:anykey
echo ����رոô��ڣ�����5���װ�Զ��������
timeout /NOBREAK /t 5 >nul
cls
echo ��װ�Զ����������...
set spath=%windir:~0,3%Program Files\RDP Wrapper
Xcopy "%~dp0autoupdate.bat" "%spath%"
Xcopy "%~dp0install.bat" "%spath%"
Xcopy "%~dp0LICENSE" "%spath%"
Xcopy "%~dp0RDPCheck.exe" "%spath%"
Xcopy "%~dp0RDPConf.exe" "%spath%"
Xcopy "%~dp0RDPWInst.exe" "%spath%"
Xcopy "%~dp0README.md" "%spath%"
Xcopy "%~dp0Setting.bat" "%spath%"
Xcopy "%~dp0subscription.bat" "%spath%"
Xcopy "%~dp0uninstall.bat" "%spath%"
Xcopy "%~dp0update.bat" "%spath%"
cls
echo ������������������������������������������������������������������������
echo �� �� ��ѡ���Զ��������� ��         ��
echo �ǩ���������������������������������������������������������������������
echo �� 1.GitHub����Ĭ��ΪFastGit��    ��
echo �� 2.GitHubֱ��                     ��
::echo �� 3.GitHubֱ����DNS Fix�� ��
echo ������������������������������������������������������������������������
echo ������Ժ���"ϵͳ��:\Program Files\RDP Wrapper"���Ҽ�"subscription.bat"�༭����Դ
echo ����㲢��������Ϲ����������й��밴1�������й��밴2.
set/p "cho=[ѡ��]"
if %cho%==1 set sub=GFW
if %cho%==2 set sub=Nor
if %cho%==3 goto menu
if %sub%==GFW (
    echo set rdpwrap_ini_update_github_1="https://cdn.jsdelivr.net/gh/asmtron/rdpwrap@master/res/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_2="https://cdn.jsdelivr.net/gh/sebaxakerhtc/rdpwrap.ini@master/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_3="https://cdn.jsdelivr.net/gh/affinityv/INI-RDPWRAP@master/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_4="https://cdn.jsdelivr.net/gh/DrDrrae/rdpwrap@master/res/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_5="https://cdn.jsdelivr.net/gh/saurav-biswas/rdpwrap-1@master/res/rdpwrap.ini">>"%spath%"\subscription.bat
)
if %sub%==Nor (
    echo set rdpwrap_ini_update_github_1="https://raw.githubusercontent.com/asmtron/rdpwrap/master/res/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_2="https://raw.githubusercontent.com/sebaxakerhtc/rdpwrap.ini/master/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_3="https://raw.githubusercontent.com/affinityv/INI-RDPWRAP/master/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_4="https://raw.githubusercontent.com/DrDrrae/rdpwrap/master/res/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_5="https://raw.githubusercontent.com/saurav-biswas/rdpwrap-1/master/res/rdpwrap.ini">>"%spath%\subscription.bat"
)
echo [*] ��װ�����
echo ����֮����ֵ��ļ��д����е��autoupdate.bat�Ը��°汾֧�֡�
echo �ڸ����������ļ�������RDPConf.exe�е�Apply��������
echo �������RDPCheck.exe�е�½�����ѳɹ���
echo �������Setting.bat�������Զ�����ѡ����޸�ѡ��
pause
explorer "%spath%"