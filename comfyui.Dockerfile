ARG DOCKER_PYTORCH_DIST="2.5.1-cuda12.4-cudnn9"
ARG DOCKER_PYTORCH_TYPE="runtime"
FROM docker.io/pytorch/pytorch:${DOCKER_PYTORCH_DIST}-${DOCKER_PYTORCH_TYPE}

ARG COMFYUI_VERSION
ARG COMFYUI_INSTALL_DIR="/opt/comfyui"
ARG COMFYUI_BINARY="/bin/comfyui"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone ComfyUI git repository at tag ${COMFYUI_VERSION}
RUN git clone \
    --single-branch \
    --depth=1 \
    --branch "${COMFYUI_VERSION:?COMFYUI_VERSION must be set and non-empty}" \
    "https://github.com/comfyanonymous/ComfyUI.git" \
    "${COMFYUI_INSTALL_DIR}"

# Prevent warnings due to root-user pip invocation in build+runtime context
#   see:  https://github.com/pypa/pip/issues/10556
ENV PIP_ROOT_USER_ACTION=ignore
RUN pip install -r "${COMFYUI_INSTALL_DIR}/requirements.txt"

# Create `comfyui` executable script for clearer user interaction
RUN test ! -f "${COMFYUI_BINARY}" && \
    printf '#!/usr/bin/env bash\n' >> "${COMFYUI_BINARY}" && \
    printf 'echo "running comfyui with arguments:  ${@}"\n'  >> "${COMFYUI_BINARY}" && \
    printf 'exec python "%s/main.py" ${@}\n' "${COMFYUI_INSTALL_DIR}" >> "${COMFYUI_BINARY}" && \
    chmod +x "${COMFYUI_BINARY}"

# `insightface` package requires install-time build, need g++
# multiple packages require runtime libGL, need mesa
# opencv python package requires libgthread at import-time, need glib2
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Run comfy with CI flags set to for initialization and validation checks
RUN comfyui \
    --quick-test-for-ci \
    --cpu \
    --verbose

CMD [ "comfyui", "--port", "8188", "--listen", "0.0.0.0" ]
