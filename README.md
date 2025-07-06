BGP Monitoring with Zabbix + BIRD + LLD (IPv4 & IPv6)

Automated monitoring of BGP sessions on BIRD route servers in an Internet Exchange Point (IXP) environment using Zabbix Agent, custom scripts, and Low-Level Discovery (LLD).

Developed and deployed by NIC Costa Rica (CRIX) to monitor dual-stack peers (IPv4/IPv6) across multiple BIRD router-servers.

📊 Features

Discovery of all active BGP sessions on BIRD via birdc socket.

Monitors BGP session status (Established / Down).

Differentiates between IPv4 and IPv6 sessions.

Sends alerts via Zabbix (e.g. Telegram, email).

Tags sessions with:

Peer name (e.g. pb_0001_asXXXXX)

IP Address

ASN / Description

Protocol: IPv4 or IPv6

🎓 Requirements

Zabbix Server (tested on v6+)

Zabbix Agent installed on BIRD server

BIRD 2.x with proper socket files (birdc -s ...)

jq installed for JSON parsing

Access to modify /etc/zabbix/zabbix_agentd.d and script paths

🔧 Installation

1. Deploy Scripts on BIRD Router Server

Path: /etc/zabbix/scripts/

check_bgp_peer.sh  ✅ Checks if specific peer is established

bgp_peer_discovery.sh  ✅ Generates JSON with all peers (IPv4 and IPv6)

Make sure both are executable and readable by zabbix user:

chmod +x /etc/zabbix/scripts/*.sh
chown zabbix:zabbix /etc/zabbix/scripts/*.sh

2. Create Agent Config: bgp.conf

Path: /etc/zabbix/zabbix_agentd.d/bgp.conf

UserParameter=bgp.peer.discovery[*],/etc/zabbix/scripts/bgp_peer_discovery.sh $1
UserParameter=bgp.peer.state[*],/etc/zabbix/scripts/check_bgp_peer.sh $1

Then:

sudo systemctl restart zabbix-agent

3. Import Template to Zabbix

Import the file: zbx_template_bird_bgp_sessions_lld.yaml

Template includes:

Discovery Rule: BIRD BGP Peer Discovery

Item Prototype: BGP Peer State [{#PEER}] - ({#PROTO}) {#ADDR}

Trigger Prototypes:

BGP Session DOWN - IPv4

BGP Session DOWN - IPv6

4. Apply Template

Apply the template to any host that:

Has the scripts installed

Has correct agent config

Has a reachable socket path for birdc

🔔 Example Alert (Telegram)

Problem: BGP session (pb_0001_as65535) is DOWN
Host: Bird1 New
Severity: High
Address: 192.168.0.0
Protocol: IPv4

📂 Repo Structure

/
├── scripts/
│   ├── check_bgp_peer.sh
│   └── bgp_peer_discovery.sh
├── templates/
│   └── zbx_template_bird_bgp_sessions_lld.yaml
├── zabbix_agentd.d/
│   └── bgp.conf
├── README.md

🧠 How It Works

BIRD maintains a list of BGP sessions and their current state (via socket).

bgp_peer_discovery.sh queries BIRD (IPv4 and IPv6 sockets), extracts session names, IPs, protocol version, and description.

It builds a dynamic JSON using jq, returning a list of {#PEER}, {#ADDR}, {#PROTO}, {#DESC} entries.

Zabbix uses Low-Level Discovery (LLD) to create one item and one trigger per peer.

check_bgp_peer.sh checks each session’s status via birdc and returns 1 (up) or 0 (down).

Triggers raise alerts for any peer session that goes down, tagging IPv4 or IPv6 accordingly.

Alerts can be sent via Telegram, email, etc.

🌐 Credit

Developed in production by NIC Costa Rica - CRIX

Community sharing by: @C4rlosp

🌟 Contributions

Pull requests welcome to:

Expand metrics (e.g. prefixes, flaps)

Add Grafana dashboards

Support for other routing daemons (FRR, GoBGP)

📁 License

MIT
