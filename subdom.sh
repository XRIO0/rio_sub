#!/bin/bash

RED='\033[31m'
RESET='\033[0m'

logo=$(cat <<'EOF'
 .----------------. .----------------. .----------------. .----------------. .----------------. .----------------.
| .--------------. | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. |
| |    _______   | | | _____  _____ | | |   ______     | | |  ________    | | |     ____     | | | ____    ____ | |
| |   /  ___  |  | | ||_   _||_   _|| | |  |_   _ \    | | | |_   ___ `.  | | |   .'    `.   | | ||_   \  /   _|| |
| |  |  (__ \_|  | | |  | |    | |  | | |    | |_) |   | | |   | |   `. \ | | |  /  .--.  \  | | |  |   \/   |  | |
| |   '.___`-.   | | |  | '    ' |  | | |    |  __'.   | | |   | |    | | | | |  | |    | |  | | |  | |\  /| |  | |
| |  |`\____) |  | | |   \ `--' /   | | |   _| |__) |  | | |  _| |___.' / | | |  \  `--'  /  | | | _| |_\/_| |_ | |
| |  |_______.'  | | |    `.__.'    | | |  |_______/   | | | |________.'  | | |   `.____.'   | | ||_____||_____|| |
| |              | | |              | | |              | | |              | | |              | | |              | |
| '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' |
 '----------------' '----------------' '----------------' '----------------' '----------------' '----------------'
EOF
)

type_effect() {
    local text="$1"
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
    done
    echo
}

echo -e "${RED}"
type_effect "$logo"
echo -e "${RESET}"

usage() {
  echo "Usage: $0 -d <domain> [-t <threads>] like google.com "
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
