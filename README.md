# HKfree Gitlab Ansible code

## Development environment

1. Install Ansible (apt install ansible, pip install ansible, ...)
2. Launch a minimal Debian (buster) VM using your preferred virtualization method (Virtualbox, KVM, EC2, ...)
3. Update `dev-vm ansible_host=...` in `inventories/dev/hosts` to point to your VM's IP
4. Run ansible-play -i inventories/dev/hosts site.yml

Fresh Gitlab instance should respond at `http://<your_vm_ip>:80/` in a few minutes, after initialization/migration scripts are finished.
User and default password for the first time login is `root` / `5iveL!fe`

# Upgrading

There is a scheduled CI job that tries to automatically upgrade a version identifier in roles/gitlab/defaults/main.yaml and merge latest config changes. It produces a branch named `next-auto`.

When the job succeeds there is a very high probability that the upgrade is safe and can be payed by Ansible (TODO: do a manual/auto job for that).

# Caveats

* If a new mayor version of GitLab is released (let's say 15) the upgrade should succeed when done from latest 14.x.y to any 15.0.y. The upgrade directly to 15.1.y (and higher) will fail! Upgrade regularly and you won't have to deal wit this!
