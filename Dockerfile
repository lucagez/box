FROM ubuntu:22.04

RUN apt update && apt install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
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
		openssh-server \
		openssh-client \
		gh \
		direnv \
		neofetch \
		&& rm -rf /var/lib/apt/lists/* \
		&& mkdir /var/run/sshd

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
COPY go-install.sh /root/
RUN cat /root/go-install.sh | bash

# Patman
RUN source /root/.zshrc && git clone https://github.com/lucagez/patman \
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

# Add `enable_ssh` and `disable_ssh` commands
COPY ssh.sh /root/ssh.sh

ENV EDITOR=nvim

# Preemptively install neovim plugins
RUN nvim --headless "+Lazy! sync" +qa

EXPOSE 22

RUN chmod +x /root/ssh.sh
ENTRYPOINT ["/root/ssh.sh"]
