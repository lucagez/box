FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
	python3 \
	python3-pip \
	&& rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --user ansible

ENV PATH="/root/.local/bin:$PATH"

WORKDIR /root

COPY local.playbook.yml .
COPY tasks.yml .
COPY .tmux.conf .
COPY .zshrc .
COPY go-install.sh .
COPY init.lua .config/nvim/
COPY lazy-lock.json .config/nvim/
COPY ssh_init /usr/local/bin/

RUN ansible-playbook -i localhost, local.playbook.yml -vvvv

# TODO: improve in order to mount the whole home dir
# without overriding with local empty fs

CMD ["tail", "-f", "/dev/null"]
