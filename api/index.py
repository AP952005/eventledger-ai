import sys
import os

# Add current directory to sys.path so modules in api/ are directly discoverable
sys.path.insert(0, os.path.dirname(__file__))

from main import app
