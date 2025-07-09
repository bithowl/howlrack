import json

def analyze_openapi_spec(file_path):
    with open(file_path) as f:
        spec = json.load(f)
    
    risky_methods = {'put', 'delete', 'patch'}
    print(f"Base URL(s): {', '.join([server['url'] for server in spec.get('servers', [])])}\n")

    for path, methods in spec.get('paths', {}).items():
        print(f"Path: {path}")
        for method, details in methods.items():
            method = method.lower()
            summary = details.get('summary', 'No summary')
            deprecated = details.get('deprecated', False)
            security = details.get('security', 'No security info')
            parameters = details.get('parameters', [])
            has_request_body = 'requestBody' in details
            
            flags = []
            if method in risky_methods:
                flags.append('⚠️ Risky HTTP method')
            if deprecated:
                flags.append('🗑 Deprecated')
            if security == []:
                flags.append('🔓 No auth required')
            
            print(f"  Method: {method.upper()} - {summary}")
            if flags:
                print(f"    Flags: {', '.join(flags)}")
            if parameters:
                print(f"    Parameters: {len(parameters)} params")
            if has_request_body:
                print("    Request Body: Present")
        print("-" * 40)

if __name__ == "__main__":
    analyze_openapi_spec("openapi.json")
