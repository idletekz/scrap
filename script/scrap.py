import sys
import yaml
import requests
import socket

# default timeout in seconds
default_timeout = 10

def load_yaml(file_path):
    try:
        with open(file_path, 'r') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"error loading yaml file '{file_path}': {e}")
        sys.exit(1)

def verify_http_endpoint(endpoint, failed_endpoints):
    name = endpoint.get("name", "unnamed http endpoint")
    url = endpoint.get("url")
    if not url:
        print(f"[{name}] skipping: 'url' is missing for http endpoint.")
        return
    timeout = endpoint.get("timeout", default_timeout)
    proxies = endpoint.get("proxies", {"http": None, "https": None})
    print(f"[{name}] checking http url: {url}")
    try:
        response = requests.get(url, proxies=proxies, timeout=timeout)
        print(f"[{name}] success: http {response.status_code}")
    except requests.RequestException as e:
        error_message = f"http connection error: {e}"
        print(f"[{name}] {error_message}")
        failed_endpoints.append({
            "name": name,
            "type": "http",
            "endpoint": url,
            "error": str(e)
        })

def verify_tcp_endpoint(endpoint, failed_endpoints):
    name = endpoint.get("name", "unnamed tcp endpoint")
    host = endpoint.get("host")
    port = endpoint.get("port")
    if not host or not port:
        print(f"[{name}] skipping: 'host' or 'port' is missing for tcp endpoint.")
        return
    timeout = endpoint.get("timeout", default_timeout)
    print(f"[{name}] checking tcp connection to {host}:{port}")
    try:
        with socket.create_connection((host, port), timeout=timeout) as conn:
            print(f"[{name}] successfully connected to {host}:{port}")
    except Exception as e:
        error_message = f"tcp connection error: {e}"
        print(f"[{name}] {error_message}")
        failed_endpoints.append({
            "name": name,
            "type": "tcp",
            "endpoint": f"{host}:{port}",
            "error": str(e)
        })

def verify_endpoint(endpoint, failed_endpoints):
    if "url" in endpoint:
        verify_http_endpoint(endpoint, failed_endpoints)
        return
    if "host" in endpoint:
        verify_tcp_endpoint(endpoint, failed_endpoints)
        return
    name = endpoint.get("name", "unnamed endpoint")
    print(f"[{name}] no valid connectivity key ('url' or 'host') found. skipping.")

def main(yaml_file_path):
    data = load_yaml(yaml_file_path)

    endpoints = data.get("api_endpoints")
    if not endpoints:
        print("no 'api_endpoints' key found in the yaml file or the list is empty.")
        sys.exit(1)

    # List to collect endpoints that fail connectivity tests
    failed_endpoints = []

    for endpoint in endpoints:
        verify_endpoint(endpoint, failed_endpoints)

    if not failed_endpoints:
        print("\nall endpoints connected successfully!")
    print("\nfailed connectivity endpoints:")
    for fail in failed_endpoints:
        print(f" - [{fail['type']}] {fail['name']} ({fail['endpoint']}): {fail['error']}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: python verify_endpoints.py <path_to_yaml_file>")
        sys.exit(1)

    yaml_file_path = sys.argv[1]
    main(yaml_file_path)

