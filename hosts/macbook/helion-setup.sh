#!/usr/bin/env bash
# Helion MPS workspace setup -- idempotent, runs once.
# Mirrors nixtorch's helion/setup.sh but targets Apple Silicon (MPS).
set -euo pipefail

WORKSPACE="${HELION_WORKSPACE:-$HOME/workspace}"
HELION_DIR="$WORKSPACE/helion"
VENV="$WORKSPACE/.venv"
MARKER="$WORKSPACE/.helion-setup-done"

if [ -f "$MARKER" ]; then
    echo "==> Helion workspace already set up (remove $MARKER to re-run)"
    exit 0
fi

echo "==> Setting up Helion MPS workspace..."

if [ ! -d "$VENV" ]; then
    echo "==> Creating virtual environment..."
    uv venv "$VENV"
fi
source "$VENV/bin/activate"

# Ensure pip is available
uv pip install pip 2>/dev/null || true

if [ ! -d "$HELION_DIR" ]; then
    echo "==> Cloning ${HELION_REPO} (${HELION_BRANCH})..."
    git clone --branch "${HELION_BRANCH}" "${HELION_REPO}" "$HELION_DIR"
fi

cd "$HELION_DIR"

# Install PyTorch with MPS support (macOS nightly wheels)
if ! python -c "import torch" 2>/dev/null; then
    echo "==> Installing PyTorch (MPS backend)..."
    uv pip install --pre torch \
        --index-url "https://download.pytorch.org/whl/${HELION_TORCH_INDEX}" \
        --extra-index-url https://pypi.org/simple
else
    echo "==> PyTorch already installed ($(python -c 'import torch; print(torch.__version__)'))"
fi

echo "==> Installing Helion (editable, dev extras)..."
SETUPTOOLS_SCM_PRETEND_VERSION_FOR_HELION=0.0+dev \
    uv pip install -e ".[dev]"

uv pip install pyrefly ruff

touch "$MARKER"
echo "==> Helion MPS workspace ready"
