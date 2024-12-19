import requests

def get_organizations(auth, proxies):
    url = "https://example.com/api/organizations"
    response = requests.get(url, headers=auth, proxies=proxies)
    if response.status_code == 200:
        return response.json()  # Assuming response is a JSON array
    else:
        raise Exception(f"Failed to fetch organizations: {response.status_code}")

def get_projects(org_identifier, auth, proxies):
    url = f"https://example.com/api/organizations/{org_identifier}/projects"
    page = 0
    all_projects = []

    while True:
        params = {"page": page}
        response = requests.get(url, headers=auth, proxies=proxies, params=params)
        if response.status_code == 200:
            projects = response.json()  # Assuming response is a JSON array
            all_projects.extend(projects)

            total_elements = int(response.headers.get("x-total-elements", 0))
            page_size = int(response.headers.get("x-page-size", 0))

            if len(all_projects) >= total_elements or page_size == 0:
                break

            page += 1
        else:
            raise Exception(f"Failed to fetch projects for org {org_identifier}: {response.status_code}")

    return all_projects

def collect_orgs_and_projects(auth, proxies):
    final_result = {}
    try:
        orgs = get_organizations(auth, proxies)
        for org in orgs:
            org_identifier = org.get("org", {}).get("identifier")
            if org_identifier:
                projects = get_projects(org_identifier, auth, proxies)
                project_identifiers = [project.get("identifier") for project in projects]
                final_result[org_identifier] = project_identifiers
    except Exception as e:
        print(f"Error occurred: {e}")
    return final_result

if __name__ == "__main__":
    # Replace with actual authentication headers and proxies
    auth_headers = {"Authorization": "Bearer YOUR_ACCESS_TOKEN"}
    proxies_config = {
        "http": "http://proxy.example.com:8080",
        "https": "http://proxy.example.com:8080"
    }
    result = collect_orgs_and_projects(auth_headers, proxies_config)
    print(result)
