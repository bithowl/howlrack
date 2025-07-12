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

📄 Prepare or Get Your OpenAPI Spec File
Make sure you have a valid OpenAPI specification file:
openapi.yaml
api-spec.json
swagger.yaml
Place it in the same folder (or know the path).

🚀 Run the Script
Basic usage:
python openapi.py openapi.yaml
With a .json file:
python openapi.py api-spec.json
 💾 (Optional) Save Output to a File
python openapi.py openapi.yaml -o report.txt
This will write the full analysis into report.txt.

📚 Read the Output
The script will show:
API paths and HTTP methods
Flags for risky/deprecated/no-auth endpoints
Sensitive parameter names
Whether request body is present
Response status codes

✅ Example Output:
🌐 Base URL(s): https://api.example.com

📌 Path: `/users`
  ➤ Method: GET — Fetch user list
    📥 Parameters: 1 param(s)
    🔁 Response Codes: 200, 401

  ➤ Method: DELETE — Delete user
    🚩 Flags: ⚠️ Risky HTTP Method, 🔓 No Auth Required
    📦 Request Body: Present
    🔁 Response Codes: 204, 403
--------------------------------------------------
