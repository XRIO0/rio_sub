#!/bin/bash


display_logo() {
    local logo="\

 
 ░▒▓███████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░       ░▒▓█▓▒░░▒▓██████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ 
 ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░       ░▒▓█▓▒░▒▓████████▓▒░▒▓█▓▒░      ░▒▓███████▓▒░  
       ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ 
       ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░ 
                                                                                             
                                                                                             



                                    version:- 2.0

                           https://github.com/XRIO0
NOTE:- READ THE README.txt FOR OPTION AND USE
"
  local delay=0.0001
    for (( i=0; i<${#logo}; i++ )); do
        echo -n "${logo:$i:1}"
        sleep "$delay"
    done
    echo
}
display_logo
usage() {
  echo "Usage: $0 -d <domain> [-t <threads>]"
  exit 1
}


check_command() {
  command -v $1 >/dev/null 2>&1
}

install_tool() {
  echo "[*] Installing $1..."
  case $1 in
    sublist3r)
      pip install sublist3r
      ;;
    assetfinder)
      go install github.com/assetfinder/assetfinder@latest
      ;;
    subfinder)
      go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
      ;;
    *)
      echo "[!] Unknown tool: $1"
      exit 1
      ;;
  esac
}

while getopts ":d:t:" opt; do
  case $opt in
    d)
      DOMAIN=$OPTARG
      ;;
    t)
      THREADS=$OPTARG
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z "$DOMAIN" ]; then
  usage
fi

THREADS=${THREADS:-50}

for tool in sublist3r assetfinder subfinder; do
  if ! check_command $tool; then
    echo "[*] $tool not found."
    install_tool $tool
  else
    echo "[*] $tool is already installed."
  fi
done

OUTPUT_DIR="./subdomains_$DOMAIN"
mkdir -p $OUTPUT_DIR

echo "[*] Running Sublist3r..."
sublist3r -d $DOMAIN -o $OUTPUT_DIR/sublist3r.txt &

echo "[*] Running Assetfinder..."
assetfinder --subs-only $DOMAIN | tee $OUTPUT_DIR/assetfinder.txt &

echo "[*] Running SubFinder..."
subfinder -d $DOMAIN -t $THREADS -o $OUTPUT_DIR/subfinder.txt &

wait

echo "[*] Combining results..."
cat $OUTPUT_DIR/sublist3r.txt $OUTPUT_DIR/assetfinder.txt $OUTPUT_DIR/subfinder.txt | sort -u > $OUTPUT_DIR/all_subdomains.txt

echo "[*] Subdomain enumeration completed. Results saved in $OUTPUT_DIR/all_subdomains.txt"
