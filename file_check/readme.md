# Recon File Check

`recon_file_check.sh` is a Bash script designed to scan a target domain or a list of URLs for common sensitive or hidden files. 
It helps security researchers and penetration testers quickly discover important files such as `robots.txt`, `sitemap.xml`, `.env`, and many others. 
The script extracts useful information from these files (e.g., disallowed paths from `robots.txt` and URLs from `sitemap.xml`) and optionally saves the results to disk.

---

## Features

- Scans common sensitive and hidden files on a target domain
- Supports scanning a list of exact URLs from a file
- Extracts `Disallow` entries from `robots.txt`
- Extracts `<loc>` URLs from `sitemap.xml`
- Saves raw file contents and extracted URLs to an output directory
- Handles HTTP status codes with informative output
- Flexible command-line flags for easy use

---

## Requirements

- Bash shell
- `curl` installed on your system

---

## Usage

```bash
./recon_file_check.sh [options]
| Flag            | Description                                                    |
| --------------- | -------------------------------------------------------------- |
| `-u, --url`     | Target domain URL (include `http://` or `https://`)            |
| `-L, --urllist` | File containing a list of full URLs to scan (one URL per line) |
| `-o, --output`  | Directory to save output files and extracted URLs              |
| `-h, --help`    | Show this help message                                         |

Scan a single domain for common files

./recon_file_check.sh -u https://example.com -o results
This scans https://example.com for many common sensitive files and saves the results to the results folder.

Scan a list of URLs from a file
Create a file named urls.txt with URLs such as:
https://example.com/robots.txt
https://example.com/.env
https://example.org/sitemap.xml
Then run:
./recon_file_check.sh -L urls.txt -o output_dir
