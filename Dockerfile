ARG DOCKER_PYTORCH_DIST="2.5.1-cuda12.4-cudnn9"
ARG DOCKER_PYTORCH_TYPE="runtime"
FROM pytorch/pytorch:${DOCKER_PYTORCH_DIST}-${DOCKER_PYTORCH_TYPE}

ARG COMFYUI_INSTALL_DIR="/opt/comfyui"
ARG COMFYUI_BINARY="/bin/comfyui"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone \
    --single-branch \
    --branch "v0.3.7" \
    --depth=1 \
    "https://github.com/comfyanonymous/ComfyUI.git" \
    "${COMFYUI_INSTALL_DIR}"

RUN git clone \
    --single-branch \
    --branch "2.55.5" \
    --depth=1 \
    "https://github.com/ltdrdata/ComfyUI-Manager.git" \
    "${COMFYUI_INSTALL_DIR}/custom_nodes/comfyui-manager"

RUN pip install -r "${COMFYUI_INSTALL_DIR}/requirements.txt"

RUN test ! -f "${COMFYUI_BINARY}" && \
    printf '#!/usr/bin/env bash\n' >> "${COMFYUI_BINARY}" && \
    printf 'echo "running comfyui with arguments:  ${@}"\n'  >> "${COMFYUI_BINARY}" && \
    printf 'python "%s/main.py" ${@}\n' "${COMFYUI_INSTALL_DIR}" >> "${COMFYUI_BINARY}" && \
    chmod +x "${COMFYUI_BINARY}"

# Install designated snapshot in `snapshots` folder for runtime use/reference
COPY "comfy-snapshot-stripped.json" "${COMFYUI_INSTALL_DIR}/custom_nodes/comfyui-manager/snapshots/base_snapshot.json"

# Install designated snapshot json at restore endpoint to install deps on first startup
COPY "comfy-snapshot-stripped.json" "${COMFYUI_INSTALL_DIR}/custom_nodes/comfyui-manager/startup-scripts/restore-snapshot.json"

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

CMD [ "comfyui" ]
