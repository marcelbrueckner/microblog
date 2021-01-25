requirements: requirements.yml
	ansible-galaxy install -r requirements.yml

play: playbook.yml
	ansible-playbook playbook.yml

all: requirements play

clean:
	@rm -rf files/
	@rm -f group_vars/all.yml
	@rm -f hosts.ini
	@rm -f *.pem
