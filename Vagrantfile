# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
UBUNTU_BOX_URL = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
HOST_PLAYBOOKS_PATH = "#{Dir.pwd}/playbooks"
GUEST_PLAYBOOKS_PATH = "/home/vagrant/playbooks"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider :virtualbox do |vb|
      vb.memory=512
  end

  # Disable the new default behavior introduced in Vagrant 1.7, to
  # ensure that all Vagrant machines will use the same SSH key pair.
  # See https://github.com/mitchellh/vagrant/issues/5005
  # config.ssh.insert_key = false

  config.vm.provision "shell" do |s|
    s.name = "ssh-public-host-key-copy"
    ssh_pub_key_path = "#{Dir.home}/.ssh/id_rsa.pub"
    ssh_pub_key = File.exist?("#{ssh_pub_key_path}") ? File.readlines("#{ssh_pub_key_path}").first.strip : ""
    s.inline = <<-SHELL
       if [ ! -z "#{ssh_pub_key}" -a "#{ssh_pub_key}" != " " ]; then
         echo "#{ssh_pub_key}" >> /home/vagrant/.ssh/authorized_keys
       fi
    SHELL
  end

  config.vm.provision "file", source: ".ssh/id_rsa.pub", destination: "~/id_rsa.pub"
  config.vm.provision "shell", privileged:true, inline: <<-SHELL
      cat /home/vagrant/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
      rm -f /home/vagrant/id_rsa.pub
  SHELL

  config.vm.define "control", primary: true do |control|
    control.vm.box      = "ubuntu-server-trusty-amd64"
    control.vm.hostname = "control"
    control.vm.box_url  = "#{UBUNTU_BOX_URL}"

    control.vm.network "private_network", ip: "10.100.100.10", netmask:"255.255.0.0"
    control.vm.synced_folder ".", "/vagrant", disabled: true

    # Share an additional folder to the guest VM. The first argument is
    # the path on the host node. The second one argument is the path on the guest 
    # to mount the folder.
    control.vm.synced_folder "#{HOST_PLAYBOOKS_PATH}", 
                              "#{GUEST_PLAYBOOKS_PATH}", 
                              disabled: false
    control.vm.synced_folder "#{Dir.pwd}/multi-nodes-wordpress-nginx", 
                             "/home/vagrant/multi-nodes-wordpress-nginx", 
                             disabled: false
    
    control.vm.provision "file", source: ".ssh/id_rsa",     destination: "~/.ssh/id_rsa"
    control.vm.provision "file", source: ".ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"

    control.vm.provision "shell", privileged:true, inline: <<-SHELL
         apt-get update -y \
      && apt-get install -y wget \
      && wget https://bootstrap.pypa.io/get-pip.py \
      && python get-pip.py \
      && pip install ansible \
      && rm -f get-pip.py \
      && echo "10.100.100.11 dbserver" >> /etc/hosts \
      && echo "10.100.100.12 webserver" >> /etc/hosts
    SHELL
  end

  config.vm.define "dbserver" do |dbserver|
    dbserver.vm.box      = "ubuntu-server-trusty-amd64"
    dbserver.vm.hostname = "mysql-db-server"
    dbserver.vm.box_url  = "#{UBUNTU_BOX_URL}"

    dbserver.vm.network "forwarded_port", guest: 3306, host: 3306
    dbserver.vm.network "private_network", ip: "10.100.100.11", netmask:"255.255.0.0"

    # disable the synced folder with the guest machine since all the file of this
    # machine will be provided by another provision. In other world, the guest
    # machine must be completely independent of the host and the control machines.
    dbserver.vm.synced_folder ".", "/vagrant", disabled: true
  end

  config.vm.define "webserver" do |webserver|
    webserver.vm.box      = "ubuntu-server-trusty-amd64"
    webserver.vm.hostname = "webserver"
    webserver.vm.box_url  = "#{UBUNTU_BOX_URL}"

    webserver.vm.network "forwarded_port", guest: 80,  host: 8080
    webserver.vm.network "forwarded_port", guest: 443, host: 8443

    webserver.vm.network "private_network", ip: "10.100.100.12", netmask:"255.255.0.0"

    # disable the synced folder with the guest machine since all the file of this
    # machine will be provided by another provision. In other world, the guest
    # machine must be completely independent of the host machine.
    webserver.vm.synced_folder ".", "/vagrant", disabled: true
  end
end