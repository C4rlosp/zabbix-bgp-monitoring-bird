#!/bin/bash

SOCKETS=(
  "/var/run/bird/bird-rs1-lan1-ipv4.ctl"
  "/var/run/bird/bird-rs1-lan1-ipv6.ctl"
)

ALL_ENTRIES=""

for SOCKET in "${SOCKETS[@]}"; do
  # Determinar si es IPv6 o IPv4
  if [[ "$SOCKET" == *"ipv6"* ]]; then
    PROTO="IPv6"
  else
    PROTO="IPv4"
  fi

  birdc -s "$SOCKET" show protocols all 2>/dev/null | awk -v proto="$PROTO" '
    BEGIN {
      in_block = 0;
      peer = "";
      desc = "";
      addr = "";
    }
    /^pb_[^ ]+ *BGP/ {
      in_block = 1;
      match($1, /^pb_[^ ]+/, arr);
      peer = arr[0];
    }
    in_block && /Description:/ {
      sub(/^[ \t]*Description:[ \t]*/, "", $0);
      desc = $0;
    }
    in_block && /Neighbor address:/ {
      sub(/^[ \t]*Neighbor address:[ \t]*/, "", $0);
      addr = $0;
    }
    /^$/ && in_block {
      in_block = 0;
      # Escapar comillas dobles
      gsub(/"/, "\\\"", desc);
      gsub(/"/, "\\\"", addr);
      print "  {";
      print "    \"{#PEER}\": \"" peer "\",";
      print "    \"{#DESC}\": \"" desc "\",";
      print "    \"{#ADDR}\": \"" addr "\",";
      print "    \"{#PROTO}\": \"" proto "\"";
      print "  },";
    }
  ' >> /tmp/bgp_peers_raw.json
done

# Limpiar última coma y cerrar el JSON
JSON=$(cat /tmp/bgp_peers_raw.json | sed '$ s/},/}/')
echo -e "{\n  \"data\": [\n$JSON\n  ]}"

# Limpiar temporal
rm -f /tmp/bgp_peers_raw.json
