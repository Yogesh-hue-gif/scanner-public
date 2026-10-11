"""
SpecGuard Web Application Server Launcher.
Imports the fully-configured FastAPI app instance from specguard.server.app.
"""

import sys
import os
import argparse
import logging
from pathlib import Path
import uvicorn

# 1. Force the root project directory onto Python's search path
BASE_DIR = Path(__file__).resolve().parent          # .../SpecGuard-Offline-Conda/app
ROOT_DIR = BASE_DIR.parent                          # .../SpecGuard-Offline-Conda
SPECGUARD_DIR = ROOT_DIR / "specguard"              # .../SpecGuard-Offline-Conda/specguard

for path in [ROOT_DIR, SPECGUARD_DIR, BASE_DIR]:
    if path.exists() and str(path) not in sys.path:
        sys.path.insert(0, str(path))

# 2. Import app and create_app from specguard.server.app
try:
    from specguard.server.app import app, create_app
except ModuleNotFoundError:
    try:
        from server.app import app, create_app
    except ModuleNotFoundError:
        # Fallback if specguard module directory is flat
        from app import app, create_app

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("SpecGuard")


def main():
    parser = argparse.ArgumentParser(
        description="SpecGuard — Engineering Document Quality & Compliance Inspection Web Platform"
    )
    default_host = os.environ.get("SPECGUARD_HOST", "0.0.0.0")
    default_port = int(os.environ.get("SPECGUARD_PORT", "8765"))

    parser.add_argument("--host", type=str, default=default_host, help="Host address (default: 0.0.0.0)")
    parser.add_argument("--port", type=int, default=default_port, help="Port number (default: 8765)")
    parser.add_argument("--reload", action="store_true", help="Enable auto-reload")

    args = parser.parse_args()

    logger.info("Starting SpecGuard Server on http://127.0.0.1:%d", args.port)

    if args.reload:
        uvicorn.run("specguard.server.app:app", host=args.host, port=args.port, reload=True, log_level="info")
    else:
        uvicorn.run(app, host=args.host, port=args.port, log_level="info")


if __name__ == "__main__":
    main()