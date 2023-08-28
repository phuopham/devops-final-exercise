# Part1
### Run the evironment
- browse to current folder and run:
```shell
vagrant up
```
### Config control vm 
- ssh to control vm to continue configure ansible:
```shell
vagrant ssh control
```
- change user to ansible:
```shell
sudo su - ansible
```
- create ssh key
```shell
ssh-keygen
```
- copy public key to webserver and database vm:
```shell
ssh-copy-id webserver
ssh-copy-id database
```
- add 2 vms to inventory:
```shell
touch /home/ansible/inventory
echo "webserver" >> /home/ansible/inventory
echo "database" >> /home/ansible/inventory
```
### Config webserver and database vm
```shell
vagrant ssh webserver
```
- Add following line to visudo to grant ansible install without password permission
```shell
sudo echo "ansible ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
```
- Repeat the same for database vm

### Run ansible playbook to deploy docker on all vm

- access control vm:
```shell
vagrant ssh control
```

- Create `playbook.yml` and paste content of playbook.yaml in this folder to the destination
```shell
ansible-playbook -i /home/ansible/inventory ./playbook.yml
```