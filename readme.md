# Valhalla - a highly configurable DNS tunneling virtual server

![command line interface](https://github.com/mmeyer2k/valhalla/blob/master/docs/img/topology.png?raw=true)

Are you sitting down?
Valhalla combines a range of technologies to provide secure and rapid DNS delivery for your entire network.
At its core, the primary functions of valhalla are:
- to provide a LAN accessible DNS server with highly customizable white and black lists
- to use DNSCrypt to securely forward DNS queries over HTTPS
- to use continuously updated copies of the very good blocklists at [notracking/hosts-blocklists](https://github.com/notracking/hosts-blocklists) to block spam, ads, malware, telemetry and other garbage
- to be able to run as a minimalist virtual machine for portability
- to provide a robust commandline interface to control the system
- to optionally send all outbound traffic through a SOCKS5 proxy for end to end privacy

The basic technology stack is: Ubuntu 18 + Dnsmasq + DNSCrypt + DNSSEC + Vagrant

## How to get started with valhalla

This project is my own personal DNS server builder.
It is written for my own situation and preferences.
If you want to use this for yourself, start by making your own fork/clone.

In the future I may work to make this more universal, but for now this should be considered a demonstration of what is possible.
Pull requests are welcome nonetheless!

**Valhalla is meant to be run on your local network and not exposed to the internet, as it would act as an open DNS resolver!**

### Creating rules

#### The `lists.d` directory

Yaml formatted rules files can be placed into `lists.d/`. 
Any file with a `.yaml` extension will be parsed in lexical order and its options will be merged.
Each file can contain any of the following arrays: `whitelist`, `blacklist` and `raw`.

Raw dnsmasq options can be add by placing them into a `raw` array.
Raw rules are followed in either `tight` or `loose` mode.
Any dnsmasq config parameters can be used here so you might want to read the [manual](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html).

Dnsmasq's default behavior is that **more specific entries take precidence over less specific entries**.
```
blacklist:
  - example.com
  - tld
whitelist:
  - sub.example.com
raw:
  - address=/custom.com/1.2.3.4
```

#### The `hosts.d` directory

Additional hosts files can be loaded into dnsmasq at start up by putting them in the `hosts.d/` directory.

### Basic configuration

General settings used to start the VM are stored in `config.yaml`.

Read more about these settings here [here](https://github.com/mmeyer2k/valhalla/blob/master/docs/configuration.md).

### Starting the vm
Run `vagrant up`.

### Now what?
- set your router to use the VM for its default DHCP DNS.
- set all of your computers and devices to use the VM for DNS.

## Command line interface
For the sake of simplicity, valhalla is command-line focused.
Once booted, use `vagrant ssh` to log in to the vm then `valhalla` to view options.

Please note: interchangeable aliases for the `valhalla` executable are available: `v` and `va`.
Additionally, all parameters can be accessed by their first one or two characters.
For example `valhalla log squid`, `v l s` and `va lo sq` are identical.

![command line interface](https://github.com/mmeyer2k/valhalla/blob/master/docs/img/cli.png?raw=true)

### `build`
`usage: valhalla build [tight, loose, off]`

`build` quickly and easily deploys ruleset changes.
Three build modes are supported. 
These modes do not affect items in the `hosts.d` directory or third-party rule sets.

- `tight` - obey whist and black lists while discarding anything that does not match any list
- `loose` - only obey blacklist but allow everything else
- `off` - disable all dns filtering

### `log`
`usage: valhalla log [dnsmasq, clear, rotate] [past]`

Use the `log` command to tail log files in real time.

Optional `past` parameter will output logs that have already been rotated.

`rotate` will force the logs to rotate.

### `digest`
`usage: valhalla digest [allowed, denied, queried, clients] [past]`

Outputs reports with frequency counts about important dns metrics to standard output.

- `allowed` - queries sent to upstream dns (including cache)
- `denied` - queries sent to black hole
- `queried` - total queries inbound
- `clients` - counts number of queries per client ip

Logrotate will automatically shuffle this log every day for 30 days.
Analyze rotated versions of logs by passing an `past` parameter.
```bash
valhalla digest denied 2
```

Sometimes these lists can be long, easily scroll output with `less` or `more`.

```bash
valhalla digest queried | less
```

![digest denied](https://github.com/mmeyer2k/valhalla/blob/master/docs/img/cli-digest.png?raw=true)

### `stress`
`usage: valhalla stress`

Generate random DNS queries that are likely to be forwarded.
Helpful when checking network stack.

## Why did I do this?
I love Windows 10 but hate how it phones home and updates/restarts your computer without warning.
This problem drove me in search of the optimal solution to being in complete control of my DNS.
I had already heard about pihole, but pihole has lots of limitations and a large code base.
For example, it does not support dnscrypt automatically and requires many extra steps to enable.
The solution I came up with was, as usually happens, more powerful than I had hoped and more useful than I had expected.

So why use valhalla?
- Zero configuration to get started
- Docker is cool but Vagrant works just fine you freakin' hipsters
- Allows you to easily exclude entire swaths of the internet by [**only** allowing tlds you need](https://github.com/mmeyer2k/valhalla/blob/master/lists.d/tlds.yaml)
- Uses dnscrypt and DNSSEC without extra steps.
- Very small project well suited for forking.
- Hate Windows Update? Hate Cortana? Nuke all Microsoft related domains [like i do](https://github.com/mmeyer2k/valhalla/blob/master/lists.d/microsoft.yaml)
- Revision control your DNS rules instead of sticking them in your pihole
- pihole does not allow raw dnsmasq entries

## Monitoring
![NORAD bunker](https://github.com/mmeyer2k/valhalla/blob/master/docs/img/command-bunker.png?raw=true)

Who needs a fancy dashboard when you have `byobu`?

Valhalla ships with a lot of popular monitoring tools so you can easily visualize your network traffic.
- tcptrack
- vnstat
- nload
- iftop 
- htop

You will find that many things you use will break when you apply strict dns rules.
It is helpful to be able to quickly determine if your dns packets are being dropped.
