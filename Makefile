set-up:
	sudo apt install -y software-properties-common 
	sudo apt-add-repository -y ppa:ansible/ansible 
	sudo apt install -y curl ansible build-essential

run: set-up
	ansible-playbook --ask-become-pass --extra-vars "user=$(shell whoami)" ~/.dotfiles/local.yml
