.DEFAULT_GOAL := all
RELEASES := 	v0.3.8 \
		v0.3.7 \
		v0.3.6 \
		v0.3.5 \
		v0.3.4 \
		v0.3.3 \
		v0.3.2 \
		v0.3.1 \
		v0.3.0

.PHONY: all

comfyui-manager/%: comfyui/% comfyui-manager.Dockerfile
	podman build 				\
		--tag    "pszenher/comfyui-manager:$*" 	\
		--file   "comfyui-manager.Dockerfile" 	\
		--build-arg="COMFYUI_VERSION=$*"

comfyui/%: comfyui.Dockerfile
	podman build 				\
		--tag    "pszenher/comfyui:$*" 	\
		--file   "comfyui.Dockerfile" 	\
		--build-arg="COMFYUI_VERSION=$*"

all: $(addprefix comfyui/,$(RELEASES))
