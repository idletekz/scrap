# time_delta — Parse a time duration
# ref: https://stackoverflow.com/a/51916936/2445204

import re
from datetime import datetime, timedelta

regex = re.compile(r'^((?P<days>\d+?)d)? *'
                   r'((?P<hours>\d+?)h)? *'
                   r'((?P<minutes>\d+?)m)? *'
                   r'((?P<seconds>\d+?)s?)?$')

# Parse a time string e.g. '2h 13m' or '1d' into a timedelta object.
#   time_str: A string identifying a duration, e.g. '2h13m'
# return adatetime.timedelta object
def parse_time(time_str):
  if not time_str.strip():
    return
  parts = regex.match(time_str)
  if not parts:
      return
  parts = parts.groupdict()    
  time_params = {}
  for name, param in parts.items():
    if param:
      time_params[name] = int(param)
  return timedelta(**time_params)
