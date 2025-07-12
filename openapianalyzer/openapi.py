import json
import yaml
import os

SENSITIVE_KEYWORDS = ['password', 'token', 'secret', 'auth', 'admin', 'key']
RISKY_METHODS = {'put', 'delete', 'patch'}

def load_spec(file_path):
    with open(file_path, 'r') as f:
        if file_path.endswith(('.yaml', '.yml')):
            return yaml.safe_load(f)
        elif file_path.endswith('.json'):
            return json.load(f)
        else:
            raise ValueError("Unsupported file type. Use .json, .yaml, or .yml")

def flag_sensitive_params(parameters):
    flags = []
    for param in parameters:
        name = param.get('name', '').lower()
        for keyword in SENSITIVE_KEYWORDS:
            if keyword in name:
                flags.append(f"🛑 Sensitive param: `{name}`")
    return flags

def analyze_openapi_spec(file_path, output_file=None):
    spec = load_spec(file_path)
    report_lines = []

    servers = spec.get('servers', [])
    server_urls = [server.get('url', 'unknown') for server in servers]
    report_lines.append(f"\n🌐 Base URL(s): {', '.join(server_urls)}\n")

    paths = spec.get('paths', {})
    for path, methods in paths.items():
        report_lines.append(f"📌 Path: `{path}`")
        for method, details in methods.items():
            method = method.lower()
            summary = details.get('summary', 'No summary provided')
            deprecated = details.get('deprecated', False)
            security = details.get('security', 'No security info')
            parameters = details.get('parameters', [])
            has_request_body = 'requestBody' in details
            responses = list(details.get('responses', {}).keys())

            flags = []

            if method in RISKY_METHODS:
                flags.append('⚠️ Risky HTTP Method')
            if deprecated:
                flags.append('🗑 Deprecated')
            if security == []:
                flags.append('🔓 No Auth Required')

            # Detect sensitive parameters
            flags += flag_sensitive_params(parameters)

            report_lines.append(f"  ➤ Method: **{method.upper()}** — {summary}")
            if flags:
                report_lines.append(f"    🚩 Flags: {', '.join(flags)}")
            if parameters:
                report_lines.append(f"    📥 Parameters: {len(parameters)} param(s)")
            if has_request_body:
                report_lines.append(f"    📦 Request Body: Present")
            if responses:
                report_lines.append(f"    🔁 Response Codes: {', '.join(responses)}")
        report_lines.append("-" * 50)

    report = '\n'.join(report_lines)

    print(report)

    if output_file:
        with open(output_file, 'w') as f:
            f.write(report)
        print(f"\n✅ Output saved to: {output_file}")

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Analyze OpenAPI spec for security and design risks.")
    parser.add_argument("file", help="Path to OpenAPI spec file (.json or .yaml)")
    parser.add_argument("-o", "--output", help="Optional output file to save results")
    args = parser.parse_args()

    if not os.path.exists(args.file):
        print("❌ File not found:", args.file)
    else:
        analyze_openapi_spec(args.file, args.output)
