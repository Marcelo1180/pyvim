FROM debian:stretch-slim
MAINTAINER Marcelo Arteaga <arteagamarcelo@gmail.com>

# Se debe eliminar un plugin tambien del instalador

#
#
# docker build -t nvim:demo .
# docker run \
#   --rm \
#   -it \
#   -v "<path/to/target>:/root/workdir/<target-name>" \
#   "<image-name>"
# https://github.com/soywod/docker-nvim
# https://hub.docker.com/r/fedeg/python-nvim/
# alias python-nvim='docker run -it --rm -v $(pwd):/src --workdir /src fedeg/python-nvim:3'
# controlar server mendiante remote sync al stylo dreamweaber con mi terminal tmux
########################################
# System Stuff
########################################

# Better terminal support
ENV TERM screen-256color
ENV DEBIAN_FRONTEND noninteractive

# Update and install
RUN apt-get update && apt-get install -y \
      bash \
      curl \
      wget \
      git \
      python-dev \
      python-pip \
      python3-dev \
      python3-pip \
      ctags \
      shellcheck \
      ranger \
      libtool \
      libtool-bin \
      autoconf \
      automake \
      cmake \
      g++ \
      pkg-config \
      unzip \
      libmsgpack-dev \
      libuv1-dev \
      libluajit-5.1-dev \
      tmux \
      ctags \
      sqlite3 \
      locales \
      locales-all

# ranger (FileManager)
# ctags (Busca relacion de funciones en archivos)
# shellcheck (Verifica la sintaxis de un shell)
# sqlite3 (base de datos portable)
# locales (idiomas para SO)
# tmux (Gestor de layouts terminal)

# Generally a good idea to have these, extensions sometimes need them
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Instalacion de Neovim
RUN git clone https://github.com/neovim/neovim.git ~/neovim && \
      cd ~/neovim && \
      make CMAKE_BUILD_TYPE=RelWithDebInfo && \
      make install

# Instalacion de Personalizacion para Neovim
RUN git clone https://github.com/kristijanhusak/neovim-config.git ~/neovim-config && \
      mkdir -p ~/.fonts && \
      cd ~/neovim-config && \
      chmod +x install.sh && \
      sed -i '3,${/zsh/d}' install.sh && \
      sed -i 's/apt-get install/apt-get install -y/g' install.sh && \
      sed -i 's/sudo//g' install.sh && \
      sed -i '/nvim -c/d' install.sh

RUN tmux && \
      tmux source-file ~/neovim-config/tmux.conf && \
      sh install.sh

########################################
# Python
########################################
# Install python linting and neovim plugin
RUN pip install neovim jedi flake8 flake8-docstrings flake8-isort flake8-quotes pep8-naming pep257 isort
RUN pip3 install neovim jedi flake8 flake8-docstrings flake8-isort flake8-quotes pep8-naming pep257 isort mypy

########################################
########################################
# Instalacion de Plugins NVIM
RUN nvim -c 'silent' -c 'VimEnter' -c 'PlugInstall' -c 'qa!'
# nvim +silent +VimEnter +PlugInstall +qall

ENV SHELL /bin/bash
CMD ["bash", "-l"]

########################################
# Personalizations
########################################
# # Add some aliases
# ADD bashrc /root/.bashrc
# # Add my git config
# ADD gitconfig /etc/gitconfig
# # Change the workdir, Put it inside root so I can see neovim settings in finder
# WORKDIR /root/app
# # Neovim needs this so that <ctrl-h> can work
# RUN infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > /tmp/$TERM.ti
# RUN tic /tmp/$TERM.ti
# # Command for the image
# CMD ["/bin/bash"]
# # Add nvim config. Put this last since it changes often
# ADD nvim /root/.config/nvim
# # Install neovim Modules
# RUN nvim -i NONE -c PlugInstall -c quitall > /dev/null 2>&1
# RUN nvim -i NONE -c UpdateRemotePlugins -c quitall > /dev/null 2>&1
# # Add flake8 config, don't trigger a long build process
# ADD flake8 /root/.flake8
# # Add local vim-options, can override the one inside
# ADD vim-options /root/.config/nvim/plugged/vim-options
# # Add isort config, also changes often
# ADD isort.cfg /root/.isort.cfg
