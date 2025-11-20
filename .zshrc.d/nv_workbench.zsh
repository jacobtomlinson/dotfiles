# >>> nvwb
# Sourcing the nvwb wrapper function was added during the NVIDIA AI Workbench installation and
# is required for NVIDIA AI Workbench to function properly. When uninstalling
# NVIDIA AI Workbench, it will be removed. 

if [ -f $HOME/.local/share/nvwb/nvwb-wrapper.sh ]; then
    source $HOME/.local/share/nvwb/nvwb-wrapper.sh
fi
# >>> nvwb
