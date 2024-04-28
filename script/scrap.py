import subprocess
import json

def run_command(command):
    """Run a shell command and return the output"""
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True)
    if result.returncode != 0:
        raise Exception(f"Error executing command: {command}\nError: {result.stderr}")
    return result.stdout

def get_user_provided_env_vars(app_name):
    """Retrieve user-provided environment variables for the given application"""
    command = f"cf env {app_name}"
    output = run_command(command)
    env_vars = []
    recording = False
    for line in output.splitlines():
        if line.strip() == "User-Provided:":
            recording = True
            continue
        if recording:
            if ":" in line:
                var_name = line.split(":", 1)[0].strip()
                env_vars.append(var_name)
                continue
            break
    return env_vars

def unset_environment_variables(app_name):
    """Unset all user-provided environment variables for the application"""
    env_vars = get_user_provided_env_vars(app_name)
    for var in env_vars:
        command = f"cf unset-env {app_name} {var}"
        print(f"Unsetting variable {var}...")
        run_command(command)
    print("All user-provided environment variables have been unset.")

def restage_application(app_name):
    """Restage the application to apply environment changes"""
    command = f"cf restage {app_name}"
    print("Restaging application...")
    run_command(command)
    print("Application restaged.")

if __name__ == "__main__":
    APP_NAME = "your_app_name"  # Replace with your actual app name
    try:
        unset_environment_variables(APP_NAME)
        restage_application(APP_NAME)
    except Exception as e:
        print(f"An error occurred: {str(e)}")
