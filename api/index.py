import sys
import os

# Add paygo_backend to sys.path so it can find models, services, mock_data
backend_dir = os.path.join(os.path.dirname(__file__), "..", "paygo_backend")
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from main import app
