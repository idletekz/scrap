## virtual environment
- isolate the required packages for our application
- keep components separated from other projects

```bash
python -m venv venv
./venv/Scripts/activate
python -m pip install  pip setuptools wheel

# requirements.txt
#   specify packages (with their versions)
#   <package>==<version>
#   <package>>=<version>
touch requirements.txt
touch setup.py

# setup.py
from pathlib import Path
from setuptools import find_namespace_packages, setup
# Load packages from requirements.txt
BASE_DIR = Path(__file__).parent
with open(Path(BASE_DIR, "requirements.txt"), "r") as file:
    required_packages = [ln.strip() for ln in file.readlines()]

# setup.py
setup(
    name="tagifai",
    version=0.1,
    description="",
    author="",
    author_email="",
    url="",
    python_requires=">=3.9",
    install_requires=[required_packages],
)

# run setup.py
# installs required packages only
#   -e/--editable flag installs a project in develop mode so we can make changes
#   without having to reinstall packages
python -m pip install -e .

# we should also see a tagifai.egg-info
pip freeze
