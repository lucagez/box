FROM golang:1.20 as golang
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt update && apt install -y \
		ninja-build \
		gettext \
		curl \
		wget \
		git \
		dnsutils \
		ripgrep \
		fzf \
		zsh \
		python3.10 \
		python3-pip \
		unzip \
		clang \
		gcc \
		cmake \
		libssl-dev \
		tmux \
		jq \
		htop \
		redis-server \
		postgresql \
		&& rm -rf /var/lib/apt/lists/*

# Tmux
RUN git clone https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm
COPY .tmux.conf /root/
RUN /root/.tmux/plugins/tpm/bin/install_plugins

# Neovim
RUN git clone https://github.com/neovim/neovim \
	&& cd neovim \
	&& make CMAKE_BUILD_TYPE=RelWithDebInfo \
	&& make install \
	&& cd .. \
	&& rm -rf neovim

SHELL ["/bin/zsh", "-c"]

RUN chsh -s $(which zsh)

COPY catppuccin.omp.json /root/
COPY .zshrc /root/

# Go
COPY --from=golang /usr/local/go /usr/local/go
ENV GOPATH /go
ENV PATH /usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"

# Patman
RUN git clone https://github.com/lucagez/patman \
	&& cd patman \
	&& make patman \
	&& cp build/patman /usr/local/bin

# Terminal niceness
RUN curl -s https://ohmyposh.dev/install.sh | bash -s

# Node.js version manager
RUN curl -fsSL https://fnm.vercel.app/install | bash

# Ensure fnm is in path
RUN source /root/.zshrc && fnm install 18

# Croc file transfer
RUN curl https://getcroc.schollz.com | bash

COPY init.lua /root/.config/nvim/init.lua

# Preemptively install neovim plugins
RUN nvim --headless "+Lazy! sync" +qa
