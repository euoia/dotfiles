mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(patsubst %/,%,$(dir $(mkfile_path)))

install:
	mkdir -p ~/.config/nvim/autoload
	echo $(mkfile_dir)
	ln -s $(mkfile_dir)/init.vim ~/.config/nvim/init.vim
	curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

.DEFAULT_GOAL := install
.PHONY: install
