# HKfree Gitlab Ansible code

## Development environment

1. Install Ansible (apt install ansible, pip install ansible, ...)
2. Launch a minimal Debian (buster) VM using your preferred virtualization method (Virtualbox, KVM, EC2, ...)
3. Update `dev-vm ansible_host=...` in `inventories/dev/hosts` to point to your VM's IP
4. Run ansible-play -i inventories/dev/hosts site.yml

Fresh Gitlab instance should respond at `http://<your_vm_ip>:80/` in a few minutes, after initialization/migration scripts are finished.
User and default password for the first time login is `root` / `5iveL!fe`
