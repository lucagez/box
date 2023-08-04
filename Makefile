.PHONY: packer provision

packer:
	@echo "📦 Packing..."
	@packer build packer.pkr.hcl

provision:
	@echo "📦 Provisioning remote server..."
	@ansible-playbook -i inventory.ini playbook.yml
