#!/bin/sh

# check OS
case "$(uname -s)" in
   Darwin)
     echo 'macOS detected'
     osascript main.applescript
     ;;

   MINGW*|CYGWIN*|MSYS*|Windows_NT)
     echo 'Windows detected'
     cmd.exe /c main.cmd
     ;;

   *)
     echo 'Unknown operating system'
     ;;
esac
