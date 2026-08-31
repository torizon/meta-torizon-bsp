require tegra-torizon.inc

IMAGE_INSTALL:append:tegra = " nvidia-container-toolkit nvidia-drm-loadconf"

IMAGE_INSTALL:remove:pn-torizon-minimal = " nvidia-container-toolkit"
