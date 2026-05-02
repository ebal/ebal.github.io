# I want to run Ubuntu Virtual Machines on my Macbook

  I use multiple computers and multiple mobile devices. This is mostly because I like keeping my personal devices/accounts separated from my work-related things, also ... company policy. The last 4 years I am using an apple macbook, it's a managed and restricted device. With managed devices, a lot of features like virtualization, containers or even VPN, anything that has network access and many other functionality were restricted. Recently I got a replacement macbook, thanks to our IT, and now for the first time I can use my old device as an unmanaged macbook.

Oh, I missed a lot!

![so_it_begins](https://raw.githubusercontent.com/ebal/ebal.github.io/main/img/so_it_begins.gif)

## Tart

To start my journey, I want to quickly spawn virtual machines (mostly ubuntu server) to test/run self hosted applications. I found [Tart Virtualization](https://tart.run) to be excellent for this.

> Tart is a virtualization toolset to build, run and manage macOS and Linux virtual machines on Apple Silicon.

To install and use tart is extremely easy:

```bash
brew install cirruslabs/cli/tart

tart clone ghcr.io/cirruslabs/macos-tahoe-base:latest tahoe-base
tart run tahoe-base
```

![tart_tahoe](https://raw.githubusercontent.com/ebal/ebal.github.io/main/img/tart_tahoe.png)

## Ubuntu virtual machine

is very easy to setup an ubuntu virtual machine with tart, as an ubuntu image already exist

```bash
tart clone ghcr.io/cirruslabs/ubuntu:24.04 ubuntu
tart set ubuntu --disk-size 20
tart run ubuntu

```

and the default credentials are:

  Username: `admin`
  Password: `admin`

> caveat: Change them if you are going to use them in production.

![tart_ubuntu](https://raw.githubusercontent.com/ebal/ebal.github.io/main/img/tart_ubuntu.png)

## We can also change the default values

like cpu and/or memory settings, as disk size above

```bash
❯ tart set ubuntu --memory 8192
❯ tart set ubuntu --cpu 4
```

![tart_specs](https://raw.githubusercontent.com/ebal/ebal.github.io/main/img/tart_ubuntu_specs.png)

## We can start the VM without graphics


```bash
❯ tart run ubuntu --no-graphics &
```

### Is this vm running ?

```bash
✦ ❯ tart list | grep -i ubuntu
local  ubuntu                                      20   3    6 seconds ago running

OCI    ghcr.io/cirruslabs/ubuntu:24.04             20   5    14 hours ago  stopped
OCI    ghcr.io/cirruslabs/ubuntu@sha256:9e71b46... 20   5    14 hours ago  stopped

```

## We can find the IP of the virtual machine

```bash
✦ ❯ tart ip ubuntu
192.168.64.2
```

## ... and we can ssh into the VM

```bash
✦ ❯ ssh admin@$(tart ip ubuntu)
admin@192.168.64.2's password:

```

![tart_ssh](https://raw.githubusercontent.com/ebal/ebal.github.io/main/img/tart_ubuntu_ssh.png)

## We can even add it to our tailscale network

I guess you already know how to add machines to your tailnet

![tart_tailscale](https://raw.githubusercontent.com/ebal/ebal.github.io/main/img/tart_ubuntu_tailscale.png)


and don't forget to stop or delete your VMs if you do not need them

```bash
tart stop ubuntu
tart delete ubuntu

```

It works !
Evaggelos

