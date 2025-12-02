@echo off
echo Running Maven tests...
cd "%~dp0"
mvn clean test
pause

