#!/bin/bash
# -----------------------------------------------------
# file_check.sh
# Scans a target domain for common sensitive/hidden files.
# Parses robots.txt & sitemap.xml, and optionally saves output.
# Crafted in the shadows by: bithowl
# -----------------------------------------------------

# -------- Colors --------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GRAY='\033[1;30m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# -------- File Targets --------
FILES=(
    "robots.txt"
    "sitemap.xml"
    "security.txt"
    "humans.txt"
    ".git/config"
    ".gitignore"
    ".svn/entries"
    ".hg/hgrc"
    ".bzr/branch/last-revision"
    ".env"
    ".htaccess"
    ".htpasswd"
    ".npmrc"
    ".yarnrc"
    ".bash_history"
    ".vscode/settings.json"
    ".idea/workspace.xml"
    "config.json"
    "settings.json"
    "composer.lock"
    "package-lock.json"
    "phpinfo.php"
    "debug.log"
    "error_log"
    "server-status"
    "config.php.bak"
    "config.php.old"
    "config.php.save"
    "config.php~"
    ".env.bak"
    ".env.old"
    ".env~"
    ".htaccess.bak"
    ".htaccess.old"
    ".htpasswd.bak"
    ".htpasswd.old"
    "index.php~"
    ".DS_Store"
)

# -------- Usage --------
usage() {
    echo "Usage: $0 -u <url> [-o <output_directory>]"
    echo "  -u, --url       Target domain (with http/https)"
    echo "  -o, --output    Directory to save found files and extracted URLs"
    exit 1
}

# -------- Parse Arguments --------
DOMAIN=""
OUTDIR=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -u|--url) DOMAIN="$2"; shift ;;
        -o|--output) OUTDIR="$2"; shift ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

if [ -z "$DOMAIN" ]; then
    usage
fi

# -------- Normalize Domain --------
DOMAIN=$(echo "$DOMAIN" | sed 's:/*$::')

if [ -n "$OUTDIR" ]; then
    mkdir -p "$OUTDIR"
    echo -e "${BLUE}[*] Output will be saved in:${NC} $OUTDIR"
fi

# -------- Counters --------
FOUND_COUNT=0
FORBIDDEN_COUNT=0
REDIRECT_COUNT=0
NOT_FOUND_COUNT=0

# -------- Check File Function --------
check_file() {
    FILE="$1"
    URL="${DOMAIN}/${FILE}"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" -k "$URL")

    if [ "$STATUS" = "200" ]; then
        ((FOUND_COUNT++))
        echo -e "${GREEN}[FOUND]${NC} $FILE -> Status: 200"
        CONTENT=$(curl -s -k "$URL")
        echo "-------- CONTENT --------"
        echo "$CONTENT"
        echo "-------------------------"

        if [ -n "$OUTDIR" ]; then
            SAFE_NAME=$(echo "$FILE" | tr '/:?&' '____')
            echo "$CONTENT" > "$OUTDIR/$SAFE_NAME"
        fi

        # ----- Special handling for robots.txt -----
        if [[ "$FILE" == "robots.txt" ]]; then
            echo -e "\n${BLUE}[INFO] Disallowed paths in robots.txt:${NC}"
            echo "$CONTENT" | grep -i '^Disallow:' | while read -r line; do
                path="${line#*:}"                                 # Remove 'Disallow:'
                path="${path#"${path%%[![:space:]]*}"}"           # Trim leading spaces
                clean_path="/${path#/}"                           # Normalize leading slash
                full_url="${DOMAIN}${clean_path}"
                echo "$full_url"
                [ -n "$OUTDIR" ] && echo "$full_url" >> "$OUTDIR/disallowed_urls.txt"
            done

            echo "$CONTENT" | grep -i '^Sitemap:' | while read -r sm_line; do
                sm_url="${sm_line#*:}"
                sm_url="${sm_url#"${sm_url%%[![:space:]]*}"}"
                echo -e "\n${BLUE}[INFO] Sitemap listed in robots.txt: $sm_url${NC}"
                SM_CONTENT=$(curl -s -k "$sm_url")
                echo "$SM_CONTENT" | grep -oP '(?<=<loc>).*?(?=</loc>)' | while read -r loc; do
                    echo "$loc"
                    [ -n "$OUTDIR" ] && echo "$loc" >> "$OUTDIR/sitemap_urls.txt"
                done
            done
        fi

        # ----- Special handling for sitemap.xml -----
        if [[ "$FILE" == "sitemap.xml" ]]; then
            echo -e "\n${BLUE}[INFO] URLs in sitemap.xml:${NC}"
            echo "$CONTENT" | grep -oP '(?<=<loc>).*?(?=</loc>)' | while read -r loc; do
                echo "$loc"
                [ -n "$OUTDIR" ] && echo "$loc" >> "$OUTDIR/sitemap_urls.txt"
            done
        fi

    elif [ "$STATUS" = "403" ]; then
        ((FORBIDDEN_COUNT++))
        echo -e "${RED}[FORBIDDEN]${NC} $FILE -> Status: 403"
    elif [[ "$STATUS" == 301 || "$STATUS" == 302 ]]; then
        ((REDIRECT_COUNT++))
        echo -e "${YELLOW}[REDIRECT] ${NC} $FILE -> Status: $STATUS"
    else
        ((NOT_FOUND_COUNT++))
        echo -e "${GRAY}[NOT FOUND]${NC} $FILE -> Status: $STATUS"
    fi
}

# -------- Begin Scan --------
echo -e "\n${BLUE}[*] Starting scan of:${NC} $DOMAIN"
echo -e "${BLUE}[*] Total files to check:${NC} ${#FILES[@]}"
echo "${BLUE}[*] This may take a moment...${NC}"

for file in "${FILES[@]}"; do
    check_file "$file"
done

# -------- Summary --------
echo -e "\n${GREEN}[✔] Scan complete.${NC}"
echo "----------------------------------------"
echo -e "${GREEN}[+] FOUND     : $FOUND_COUNT${NC}"
echo -e "${RED}[+] FORBIDDEN : $FORBIDDEN_COUNT${NC}"
echo -e "${YELLOW}[+] REDIRECT  : $REDIRECT_COUNT${NC}"
echo -e "${GRAY}[+] NOT FOUND : $NOT_FOUND_COUNT${NC}"
echo "----------------------------------------"

if [ -n "$OUTDIR" ]; then
    echo -e "${BLUE}[*] Results saved to:${NC} $OUTDIR"
fi
