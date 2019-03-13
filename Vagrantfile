Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04.4"

  config.vm.define "manager" do |manager|
    # Box Settings
    manager.vm.box = "bento/ubuntu-18.04"
    manager.vm.hostname = "manager"
    manager.vm.network "private_network", ip: "192.168.100.100"

    # Provider Settings
    manager.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false
      vb.name = "manager"
      # Customize the amount of memory on the VM:
      vb.memory = "2048"
    end
    manager.vm.provision "shell", path: "manager/bootsrap-manager.sh", privileged: false
  end

  config.vm.define "data1" do |data1|
    # Box Settings
    data1.vm.box = "bento/ubuntu-18.04"
    data1.vm.hostname = "data1"
    data1.vm.network "private_network", ip: "192.168.100.2"

    # Provider Settings
    data1.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false
      vb.name = "data1"
      # Customize the amount of memory on the VM:
      vb.memory = "1024"
    end
    data1.vm.provision "shell", path: "datanodes/bootsrap-datanode.sh", privileged: false
  end

  config.vm.define "data2" do |data2|
    # Box Settings
    data2.vm.box = "bento/ubuntu-18.04"
    data2.vm.hostname = "data2"
    data2.vm.network "private_network", ip: "192.168.100.3"

    # Provider Settings
    data2.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false
      vb.name = "data2"
      # Customize the amount of memory on the VM:
      vb.memory = "1024"
    end
    data2.vm.provision "shell", path: "datanodes/bootsrap-datanode.sh", privileged: false
  end

  config.vm.define "data3" do |data3|
    # Box Settings
    data3.vm.box = "bento/ubuntu-18.04"
    data3.vm.hostname = "data3"
    data3.vm.network "private_network", ip: "192.168.100.4"

    # Provider Settings
    data3.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false
      vb.name = "data3"
      # Customize the amount of memory on the VM:
      vb.memory = "1024"
    end
    data3.vm.provision "shell", path: "datanodes/bootsrap-datanode.sh", privileged: false
  end
  
  config.vm.define "service1" do |service1|
    # Box Settings
    service1.vm.network "private_network", ip: "192.168.100.11"
    service1.vm.box = "bento/ubuntu-18.04"
    service1.vm.hostname = "service1"

    # Provider Settings
    service1.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "service1"
      vb.memory = "1024"
    end
  end

  config.vm.define "service2" do |service2|
    # Box Settings
    service2.vm.network "private_network", ip: "192.168.100.12"
    service2.vm.box = "bento/ubuntu-18.04"
    service2.vm.hostname = "service2"

    # Provider Settings
    service2.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "service2"
      vb.memory = "1024"
    end
  end

  # config.vm.define "proxy" do |proxy|
  #   # Box Settings
  #   proxy.vm.box = "bento/ubuntu-18.04"
  #   proxy.vm.hostname = "proxy"

  #   # Provider Settings
  #   proxy.vm.provider "virtualbox" do |vb|
  #     vb.gui = false
  #     vb.name = "proxy"
  #     vb.memory = "2048"
  #   end
  #   proxy.vm.network "private_network", ip: "192.168.100."
  #   proxy.vm.provision "shell", path: "provision/bootstrap.sh", privileged: false
  #   proxy.vm.provision "shell", path: "provision/bootstrap-proxy.sh", privileged: false
  # end

end
