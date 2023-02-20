#!/bin/bash

Off='\033[0m'

# Primary Colors
Black="\033[0;30m"        # Black
Red="\033[0;31m"          # Red
Green="\033[0;32m"        # Green
Yellow="\033[0;33m"       # Yellow
Blue="\033[0;34m"         # Blue
Purple="\033[0;35m"       # Purple
Cyan="\033[0;36m"         # Cyan
White="\033[0;37m"        # White
BMagenta="\033[0;45m"  # Block w/ Magenta
Magenta='\033[1;95m' # Magenta

PATH=/usr/local/bin:$PATH
export PATH

# wait for Enter key to be pressed
function wait_for_enter(){
  read -rp "[Enter] Continue..."
}

warn() {
  echo ""
  log_stmt "${BMagenta} ***** $1 ***** ${Off} "; 
  echo ""
}

info() {
  echo ""
  log_stmt "${Cyan} ***** $1 ***** ${Off} "; 
  echo ""
}

log_stmt() { >&2 printf "$1\n"; }


# show info text and command, wait for enter, then execute and print a newline
function info_pause_exec() {
  echo ""
  step "$1"
  read -rp $'\033[1;37m#\033[0m'" Command: "$'\033[1;96m'"$2"$'\033[0m'" [Press enter to continue]"
  exe "$2"
  echo ""
}

# show info text and command, wait for chosen option
function info_pause_exec_options() {
  step "$1"

  read -p $'\033[1;37m#\033[0m'" Command: "$'\033[1;96m'"$2"$'\033[0m'" [y/n] > " -r -n 1 choice
  case "$choice" in 
    y|Y )
      echo ""
      exe "$2"
      echo ""
      return 0
      ;;
    n|N )
      echo ""
      echo "Exited command."
      return 0
      ;;
    * )
      echo ""
      echo "Invalid Choice. Type y or n."
      info_pause_exec_options "$1" "$2" # restart process on invalid choice
      ;;
  esac
  
}

# show command and execute it
exe() {
  echo "\$ $1"
  eval "$1"
}

# highlight a new section
section() {
  echo ""
  log_stmt "***** Running command: ${Magenta}$1${Off} *****"; 
  echo ""
}

# highlight a new section but ask for confirmation to run it
proceed_or_no() {
  read -p $'\033[1;37m#\033[0m\033[1;33m'" Proceed with $1?"$'\033[0m'" [y/n] > " -r -n 1 choice
  case "$choice" in 
    y|Y )
      echo -e "\n"
      return 0
      ;;
    n|N )
      echo -e "\n"
      return 1
      ;;
    * )
      echo ""
      echo "Invalid Choice. Type y or n."
      proceed_or_not "$1" "$2" # restart process on invalid choice
      ;;
  esac
}

# highlight the next step
step() { log_stmt "Step: ${Blue}$1${Off}"; }