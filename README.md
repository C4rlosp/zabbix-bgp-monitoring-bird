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

Problem: BGP session (pb_00<xx>_AS<xxxxxx>) is DOWN
Host: Bird2 New
Severity: High
Address: 2001:db8:85a3::8a2e:370:7334
Protocol: IPv6

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

🌐 Credit

Developed in production by NIC Costa Rica - CRIX

Community sharing by: @C4rlosp

🌟 Contributions

Pull requests welcome to:

Expand metrics (e.g. prefixes, flaps)

Add Grafana dashboards

Support for other routing daemons (FRR, GoBGP)

📑 License
