# 🔍 OpenAPI Analyzer

A simple, powerful Python tool to analyze OpenAPI specs (`.json` or `.yaml`) for risky HTTP methods, security issues, sensitive parameters, and more — perfect for bug bounty hunters and security researchers.

## ✅ Features

- Supports OpenAPI 2.0 & 3.0 in **JSON and YAML**
- Flags risky methods (`PUT`, `DELETE`, `PATCH`)
- Detects deprecated or unauthenticated endpoints
- Highlights sensitive parameter names (`token`, `password`, etc.)
- Lists response status codes for every endpoint
- Optional output to file for reporting
## 🧰 Requirements
- Python 3.7+
- PyYAML (for `.yaml` support)

```bash
pip install -r requirements.txt
