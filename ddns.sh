#!/bin/bash

# This is a for from https://gist.github.com/radiantly/3dbff163624ca3dd32ee8ecf225a7b02 that i for personal reasons, wanted to move for a repository, credits for him and authors he forked the original project
# CHANGE THESE
auth_token="TOKEN"   # Generate an API token at https://dash.cloudflare.com/profile/api-tokens with the permission dns_records:edit
zone_identifier="ZONE-IDENTIFIER-LONG"      # Can be found in the "Overview" tab of your domain
record_name=(main1.example.com main2.example.com sub1.example.com)  # List of records you want to be synced

# DO NOT CHANGE LINES BELOW
ip=$(curl -s https://ipv4.icanhazip.com/)

# SCRIPT START
echo "[Cloudflare DDNS] Checks Initiated"

# Seek for all records
for record_loop in "${record_name[@]}"
do
    record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_loop" -H "Authorization: Bearer $auth_token" -H "Content-Type: application/json")
    # Can't do anything without the record
    if [[ "$record" == *"\"count\":0"* ]]; then
      >&2 echo -e "[Cloudflare DDNS] Record $record_loop does not exist, perhaps create one first?"
      continue #We just continue the loop
    fi
    # Set existing IP address from the fetched record
    old_ip=$(echo "$record" | grep -Po '(?<="content":")[^"]*' | head -1)
    # Compare if they're the same
    if [ "$ip" == "$old_ip" ]; then
      echo "[Cloudflare DDNS] IP from $record_loop has not changed."
      continue
    fi
    # Set the record identifier from result
    record_identifier=$(echo "$record" | grep -Po '(?<="id":")[^"]*' | head -1)
    # The execution of update
    update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" -H "Authorization: Bearer $auth_token" -H "Content-Type: application/json" --data "{\"id\":\"$zone_identifier\",\"type\":\"A\",\"proxied\":false,\"name\":\"$record_loop\",\"content\":\"$ip\"}")
    # The moment of truth
    case "$update" in
    *"\"success\":false"*)
      >&2 echo -e "[Cloudflare DDNS] Update failed for $record_identifier. DUMPING RESULTS:\n$update"
      continue;;
    *)
      echo "[Cloudflare DDNS] IPv4 context '$ip' has been synced to Cloudflare for $record_loop.";;
    esac
done