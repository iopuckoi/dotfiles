#!/bin/bash

set -e

BLINKING_BLUE="\033[1;5;34m"
BOLD="\033[1m"
GREEN="\033[1;32m"
RESET="\033[0m"

DEFAULT_PYTHON3_VERSION=3.7.2
if [ -n "${USE_GIT_URI}" ]; then
  GITHUB="git://github.com"
else
  GITHUB="https://github.com"
fi
PYENV_ROOT="${HOME}/.pyenv"
PYPI_URL="https://pypi.python.org/simple/"
YES_OR_NO="(${GREEN}y${RESET}/${GREEN}n${RESET})"

########################################################################################
usage() {
  echo "Usage: ${0} [COMMAND]..."
  echo "Setup pyenv"
  echo ""
  echo "Arguments are space separated and are as follows:"
  echo "  create        Create a new virtual environment."
  echo "  remove        Remove an existing virtual environment."
  echo "  setup         Install pyenv and set up Python."
  echo "  update        Update pip and setuptools."
  echo ""
  exit 1
}

########################################################################################
# Clone a git repo to a specified folder.
checkout() {
  [ -d "$2" ] || git clone --quiet --depth 1 "$1" "$2" > /dev/null || failed_checkout "$1"
}

########################################################################################
# Configure pip.
configure_pip() {
  mkdir -p ${HOME}/.config/pip/pip.conf
  pypi=$(echo ${PYPI_URL} | cut -d "/" -f 3)
  echo -e "Configuring pip in ${GREEN}~/.pip/pip.conf${RESET}"
  echo \[global\] > ~/.pip/pip.conf
  echo index-url=${PYPI_URL} >> ~/.pip/pip.conf
  #echo extra-index-url=url/to/additional/repo
  echo trusted-host=${pypi} >> ~/.pip/pip.conf
  #                 additional_trusted_host
}

########################################################################################
# Configure pypirc.
configure_pypirc() {
  # Configure ~/.pypirc here
}

########################################################################################
# Check if pyenv is currently installed.
pyenv_check() {
  if [ -f "${PYENV_ROOT}/bin/pyenv" ]"; then
    echo -e "Pyenv is currently installed in ${GREEN}${PYENV_ROOT}${RESET}."
  else
    echo ""
  fi
}

########################################################################################
# Check if a provided virtual environment already exists.
version_check() {
  versions=$(pyenv versions)
  version_regex="^${1}$"
  version_check=false
  for version in ${versions[@]}; do
    if [[ $version =~ $version_regex ]]; then
      version_check=true
    fi
  done
  
  if $version_check; then
    echo "${1} already exists."
  else
    echo ""
  fi
}

########################################################################################
# Create a new virtual environment.
create() {
  # Exit if pyenv isn't installed.
  if [[ -z $(pyenv_check) ]]; then
    echo -e "Pyenv installation not found in root ${GREEN}${PYENV_ROOT}${RESET}.  Maybe run '${0} setup'?"
    exit 1
  fi
  
  REPLY="X"
  # Prompt for desired Python version.
  while [[ $REPLY =~ ^[^YyNn]$ ]] || [[ -z $REPLY ]]; do
    read -p "$(echo -e "Use default Python version (${GREEN}${DEFAULT_PYTHON3_VERSION}${RESET}) for environment? ${YES_OR_NO} :  ")" -n 1 -r
    echo
  done
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    python_version=${DEFAULT_PYTHON3_VERSION}
  else
    REPLY=""
    while [[ -z $REPLY ]]; do
      read -p "$(echo "What Python version would you like to use? :  ")" -r
      echo
    done
    python_version=${REPLY}
  fi
  
  if [[ -z $(version_check ${python_version}) ]]; then
    # Offer to install Python version if its not installed.
    REPLY="X"
    while [[ $REPLY =~ ^[^YyNn]$ ]] || [[ -z $REPLY ]]; do
      read -p "$(echo -e "Python version ${GREEN}${python_version}${RESET} is not installed.  Install now ${YES_OR_NO}? :  ")" -n 1 -r
      echo
    done
    if ! [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Could not continue with creation of virtual environment."
      exit 1
    fi
    pyenv install -s ${python_version}
  else
    echo -e "Version ${GREEN}${python_version}${RESET} is already installed."
  fi
  
  # Prompt for desired project name.
  project_name=""
  current_directory=${PWD##*/}
  REPLY="X"
  while [[ $REPLY =~ ^[^YyNn]$ ]] || [[ -z $REPLY ]]; do
    read -p "$(echo -e "Use current directory name (${GREEN}${current_dirname}${RESET}) for virtual lenvironment ${YES_OR_NO}? :  ")" -n 1 -r
    echo
  done
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    project_name=${current_dirname}
  else
    REPLY=""
    while [[ -z $REPLY ]]; do
      read -p "$(echo "What is the name of the project? :  ")" -r
      echo
    done
    project_name=${REPLY}
  fi
 
  project_name=${project_name//_/-}
  venv=${python_version}_${project_name}
 
  # Create the virtual environment if it doesn't already exist.
  if [[ -z $(version_check $venv) ]]; then
    echo -e "Creating virtual environment: ${GREEN}${venv}${RESET}..."
    pyenv virtualenv ${python_version} ${venv}
  
    echo "Creating .python-version file..."
    echo "${venv}" > .python-version
    echo "=================================================================================="
  
    update
  
    echo "=================================================================================="
  
    REPLY="X"
    # TODO: create py-cli
    #while [[ $REPLY =~ ^[^YyNn]$ ]] || [[ -z $REPLY ]]; do
    #  read -p "$(echo -e "Would you like to install py-cli for this project ${YES_OR_NO}? :  ")" -n 1 -r
    #  echo
    #done
    #
    #if [[ $REPLY =~ ^[Yy]$ ]]; then
    #  echo "Installing py-cli..."
    #  pip install --quiet py-cli
    #
    #  echo "=================================================================================="
    #
    #  REPLY="X"
    #  while [[ $REPLY =~ ^[^YyNn]$ ]] || [[ -z $REPLY ]]; do
    #    read -p "$(echo -e "Would you like to install dependencies for this project ${YES_OR_NO}? :  ")" -n 1 -r
    #    echo
    #  done
    # 
    #  if [[ $REPLY =~ ^[Yy]$ ]]; then
    #    echo "Installing dependencies and configuring project for VSCode..."
    #    py-cli install ---quiet
    #  fi
    #fi
  
    echo "=================================================================================="
    echo -e "${BOLD}Finished creation of new virtual environment ${GREEN}${venv}${RESET}."
  else
    echo -e "Virtual environment ${GREEN}${venv}${RESET} already exists.  Maybe run '${0} remove'?"
    exit 1
  fi    
}

########################################################################################
# Delete an existing virtual environment.
remove() {
  # Exit if pyenv isn't installed.
  if [[ -z $(pyenv_check) ]]; then
    echo -e "Pyenv installation not found in root ${GREEN}${PYENV_ROOT}${RESET}.  Maybe run '${0} setup'?"
    exit 1
  fi
  
  local_version=""
  if [ -f .python-version ]; then
    local_version=$(cat .python-version)
  fi
  
  # Prompt for desired project name.
  venv=""
  if [ "$local_version" ]; then
    REPLY="X"
    while [[ $REPLY =~ ^[^YyNn]$ ]] || [[ -z $REPLY ]]; do
      read -p "$(echo -e "Delete current directory's environment (${GREEN}${local_version}${RESET})? ${YES_OR_NO} :  ")" -n 1 -r
      echo
    done
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      venv=${local_version}
    fi
  fi
  
  if [ -z "$venv" ]; then
    REPLY=""
    while [[ -z $REPLY ]]; do
      read -p "What virtual environment would you like to delete?  " -r
      echo
    done
    venv=${REPLY}
  fi
  
  if [[ -z $(version_check $venv) ]]; then
    echo -e "No virtual environment called ${GREEN}${venv}${RESET} exists, exiting."
    exit 1
  else
    REPLY="X"
    while [[ $REPLY =~ ^[^YyNn]$ ]] || [[ -z $REPLY ]]; do
      read -p "$(echo -e "Are you sure you want to delete ${GREEN}${venv}${RESET} ${YES_OR_NO}? :  ")" -n 1 -r
      echo
    done
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo -e "Removing virtual environment ${GREEN}${venv}${RESET}..."
      pyenv virtualenv-delete -f ${venv}
      if [ -f .python-version ]; then
        echo "Found version file in .python-version..."
        local_version=$(cat .python-version)
        if [ "$local_version" = "$venv" ]; then
          echo "Version file matches, deleting .python-version file..."
          rm -f .python-version
        else
          echo "Version file does not match, leaving .python-version file untouched.."
        fi
      fi
    else
      echo "Performing no action, exiting."
      exit 1
    fi
  fi
}

########################################################################################
# Update packages for user.
update() {
  echo "Updating pip..."
  pip install pip --quiet --upgrade
  echo "Updating setuptools..."
  pip install setuptools --quiet --upgrade
  echo "Updates compete."
}

########################################################################################
# Setup and install pyenv.
setup() {
  # Check to see if pyenv is already installed.
  if [[ $(pyenv_check) ]]; then
    echo -e "Pyenv is currently installed in ${GREEN}${PYENV_ROOT}${RESET}."
    exit 1
  fi
  
  # Prompt user to make sure they want to install.
  echo -e "Pyenv does not currently exist in ${GREEN}${PYENV_ROOT}${RESET}."
  echo "Continuing will install pyenv."
  
  REPLY="X"
  while [[ $REPLY =~ ^[^YyNn]$ ]] || [[ -z $REPLY ]]; do
    read -p "$(echo -e "Are you sure you would like to continue ${YES_OR_NO}? :  ")" -n 1 -r
    echo
  done
  
  if ! [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Could not continue with configuration."
    exit 1
  fi
  
  # eval `ssh-agent`
  # ssh-add
  echo -e "Cloning ${GREEN}pyenv${RESET} to ${GREEN}${PYENV_ROOT}${RESET}..."
  checkout "${GITHUB}/pyenv/pyenv.git"            "${PYENV_ROOT}"
  echo -e "Cloning ${GREEN}pyenv-doctor${RESET} to ${GREEN}${PYENV_ROOT}/plugins${RESET}..."
  checkout "${GITHUB}/pyenv/pyenv-doctor.git"     "${PYENV_ROOT}/plugins/pyenv-doctor"  
  echo -e "Cloning ${GREEN}pyenv-update${RESET} to ${GREEN}${PYENV_ROOT}/plugins${RESET}..."
  checkout "${GITHUB}/pyenv/pyenv-update.git"     "${PYENV_ROOT}/plugins/pyenv-update"  
  echo -e "Cloning ${GREEN}pyenv-virtualenv${RESET} to ${GREEN}${PYENV_ROOT}/plugins${RESET}..."
  checkout "${GITHUB}/pyenv/pyenv-virtualenv.git" "${PYENV_ROOT}/plugins/pyenv-virtualenv"  
  echo -e "Cloning ${GREEN}pyenv-which-ext${RESET} to ${GREEN}${PYENV_ROOT}/plugins${RESET}..."
  checkout "${GITHUB}/pyenv/pyenv-which-ext.git"  "${PYENV_ROOT}/plugins/pyenv-which-ext"  
  
  echo "=================================================================================="
  
  echo -e "Installing default Python3 shim into pyenv: ${GREEN}${DEFAULT_PYTHON3_VERSION}${RESET}..."
  pyenv install -s ${DEFAULT_PYTHON3_VERSION}
  
  echo -e "Setting global Python version: ${GREEN}${DEFAULT_PYTHON3_VERSION}${RESET}..."
  pyenv global ${DEFAULT_PYTHON3_VERSION}
  
  echo "=================================================================================="
  
  configure_pip
  
  echo "=================================================================================="
  
  configure_pypirc
  
  echo "=================================================================================="
  
  update_profile
  
  echo "=================================================================================="
  echo -e "${BOLD}Setup complete.${RESET}"
}

########################################################################################
# Inform user they need to update their profile.
update_profile() {
    case "$shell" in
    bash )
      profile="~/.bashrc"
      ;;
    zsh )
      profile="~/.zshrc"
      ;;
    ksh )
      profile="~/.profile"
      ;;
    fish )
      profile="~/.config/fish/config.fish"
      ;;
    * )
      profile="your profile"
      ;;
    esac

    { echo -e "${BLINKING_BLUE}# Load pyenv automatically by adding${RESET}"
      echo -e "${BLINKING_BLUE}# the following to ${profile}:${RESET}"
      echo
      case "$shell" in
      fish )
        echo -e "${GREEN}set -x PATH \"${PYENV_ROOT}/bin\" \$PATH${RESET}"
        echo -e "${GREEN}status --is-interactive; and . (pyenv init -|psub)${RESET}"
        echo -e "${GREEN}status --is-interactive; and . (pyenv virtualenv-init -|psub)${RESET}"
        ;;
      * )
        echo -e "${GREEN}export PYENV_ROOT=${HOME}/pyenv${RESET}"
        echo -e "${GREEN}export PATH=\"${PYENV_ROOT}/bin:\$PATH\"${RESET}"
        echo -e "${GREEN}eval \"\$(pyenv init -)\"${RESET}"
        echo -e "${GREEN}eval \"\$(pyenv virtualenv-init -)\"${RESET}"
        ;;
      esac
    } >&2
  fi
}

########################################################################################
# Main entrypoint.
if [ $# -eq 0 ]; then
  usage
  exit 1
fi

case $1 in
  create)
    create
    ;;
  remove)
    remove
    ;;
  setup)
    setup
    ;;
  update)
    update
    ;;
  *)
    echo -e "Unknown argument: $1"
    usage
    exit
esac
