# Ensure you have colorlog installed
# pip install colorlog

import logging
import colorlog

def new_logger(name=None):
    logger = logging.getLogger()
    if name:
      logger = logging.getLogger(name)  # Create logger with class name
    logger.setLevel(logging.DEBUG)

    formatter = colorlog.ColoredFormatter(
        "{log_color}{name}: {levelname}: {message}",
        log_colors={
            'DEBUG': 'white',
            'INFO': 'green',
            'WARNING': 'yellow',
            'ERROR': 'red',
            'CRITICAL': 'red,bg_white',
        },
        style='{'
    )

    console_handler = colorlog.StreamHandler()
    console_handler.setLevel(logging.DEBUG)
    console_handler.setFormatter(formatter)

    # Ensure that multiple handlers are not added
    if not logger.handlers:
        logger.addHandler(console_handler)

    return logger

class SampleClass:
    def __init__(self):
        # Initialize logger for the class
        self.logger = new_logger(self.__class__.__name__)

    def sample_method(self, value):
        if value > 10:
            self.logger.info("Value is greater than 10.")
        elif value == 10:
            self.logger.warning("Value is equal to 10.")
        else:
            self.logger.debug("Value is less than 10.")

    def another_method(self):
        try:
            result = 10 / 0
        except ZeroDivisionError:
            self.logger.error("Tried to divide by zero!")

def main():
    sample = SampleClass()
    sample.sample_method(5)
    sample.sample_method(10)
    sample.sample_method(15)
    sample.another_method()
    logger = new_logger()
    logger.info("root logger")

if __name__ == "__main__":
    main()
