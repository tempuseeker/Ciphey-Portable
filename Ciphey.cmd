@echo off
rem ==================================================================
rem  Ciphey 5.14.0 - portable launcher
rem
rem  Everything is resolved relative to this file, so the whole folder
rem  can be moved or copied anywhere (including paths with spaces).
rem
rem  Usage:
rem     Ciphey.cmd -g -t "aGVsbG8gbXkgbmFtZSBpcyBiZWU="
rem     Ciphey.cmd --help
rem     Ciphey.cmd -f cipher.txt
rem     type cipher.txt | Ciphey.cmd -g
rem
rem  Environment this wrapper sets (both are required, see README):
rem     CIPHEY_CONFIG_DIR  keep Ciphey's config inside this folder
rem     PYTHONUTF8         pywhat reads JSON with the locale encoding;
rem                        GBK on zh-CN Windows breaks it on Python 3.8
rem ==================================================================
setlocal
set "ROOT=%~dp0"
set "CIPHEY_CONFIG_DIR=%ROOT%config"
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"
rem  Config dir: prefer this folder; if it cannot be written (read-only media,
rem  locked share, missing permissions), fall back to %TEMP%.
rem  Writability is probed by creating and removing a subdirectory, because
rem  cmd's own "if exist <dir>\" reports a plain file as an existing directory
rem  here. One statement per line on purpose: %VAR% inside a parenthesised
rem  block would be expanded before the reassignment takes effect.
set "CIPHEY_PROBE="
mkdir "%CIPHEY_CONFIG_DIR%" 2>nul
mkdir "%CIPHEY_CONFIG_DIR%\.c-wprobe" 2>nul
if exist "%CIPHEY_CONFIG_DIR%\.c-wprobe" set "CIPHEY_PROBE=ok"
if defined CIPHEY_PROBE rmdir "%CIPHEY_CONFIG_DIR%\.c-wprobe" 2>nul
if not defined CIPHEY_PROBE if defined TEMP set "CIPHEY_CONFIG_DIR=%TEMP%\ciphey-portable"
if not defined CIPHEY_PROBE mkdir "%CIPHEY_CONFIG_DIR%" 2>nul
"%ROOT%python\python.exe" -m ciphey %*
endlocal
