export PATH="$HOME/.local/share/fnm:$PATH"
eval "`fnm env`"

eval "$(oh-my-posh init zsh --config /root/catppuccin.omp.json)"

function sync_nvim() {
	echo "☁️  syncing nvim plugins"
	nvim --headless "+Lazy! sync" +qa
}
