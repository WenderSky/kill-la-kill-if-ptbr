@echo off
rem Caminho absoluto do proprio .bat: chamada relativa falha em algumas maquinas.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0desinstalar.ps1"
if errorlevel 1 pause
