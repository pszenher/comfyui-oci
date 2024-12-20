ARG COMFYUI_VERSION
FROM pszenher/comfyui:${COMFYUI_VERSION}

ARG COMFYUI_INSTALL_DIR="/opt/comfyui"
ARG COMFYUI_BINARY="/bin/comfyui"
ARG DEBIAN_FRONTEND=noninteractive

RUN git clone \
    --single-branch \
    --branch "2.55.5" \
    --depth=1 \
    "https://github.com/ltdrdata/ComfyUI-Manager.git" \
    "${COMFYUI_INSTALL_DIR}/custom_nodes/ComfyUI-Manager"

# Install designated snapshot in `snapshots` folder for runtime use/reference
COPY "comfy-snapshot-stripped.json" "${COMFYUI_INSTALL_DIR}/custom_nodes/ComfyUI-Manager/snapshots/base_snapshot.json"

# Install designated snapshot json at restore endpoint to install deps on first startup
COPY "comfy-snapshot-stripped.json" "${COMFYUI_INSTALL_DIR}/custom_nodes/ComfyUI-Manager/startup-scripts/restore-snapshot.json"

# `insightface` package requires install-time build, need g++
# multiple packages require runtime libGL, need mesa
# opencv python package requires libgthread at import-time, need glib2
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Run comfy with CI flags set to trigger ComfyUI-Manager initialization/package install
RUN comfyui \
    --quick-test-for-ci \
    --cpu \
    --verbose
