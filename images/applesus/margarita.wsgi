import sys
EXTRA_DIR = "/usr/local/margarita"
if EXTRA_DIR not in sys.path:
    sys.path.append(EXTRA_DIR)

from margarita import app as application
