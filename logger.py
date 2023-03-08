import logging
import sys

# Create logging filter to only allow warning level and below messages
class WarningFilter(logging.Filter):
    def filter(self, record):
        return record.levelno <= logging.WARNING

# Create stdout handler
stdout_handler = logging.StreamHandler(sys.stdout)
stdout_handler.addFilter(WarningFilter())

# Create stderr handler
stderr_handler = logging.StreamHandler(sys.stderr)
stderr_handler.setLevel(logging.ERROR)

# Create formatter for logging handler 
formatter = logging.Formatter('%(name)s - %(levelname)s - %(message)s')

# Set formatter for handlers
stdout_handler.setFormatter(formatter)
stderr_handler.setFormatter(formatter)

# Configure the global logger
logging.basicConfig(level=logging.DEBUG, handlers=[stdout_handler, stderr_handler])
