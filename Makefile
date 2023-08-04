.PHONY: packer provision digitalocean digitalocean_destroy

packer:
	@echo "📦 Packing..."
	@packer build packer.pkr.hcl

provision:
	@echo "📦 Provisioning remote server..."
	@ansible-playbook -i inventory.ini playbook.yml

digitalocean:
	@echo "📦 Provisioning remote server..."
	@cd ./tf/digitalocean && terraform apply
	@cd ./tf/digitalocean && echo "📦 to monitor cloud-init logs run: ssh root@$(shell terraform output droplet_output) 'tail -f /var/log/cloud-init-output.log'"

digitalocean_destroy:
	@echo "📦 Destroying remote server..."
	@cd ./tf/digitalocean && terraform destroy
