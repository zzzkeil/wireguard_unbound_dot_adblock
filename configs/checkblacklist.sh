#!/bin/bash
if [[ -s /root/utils/adblocklist ]]; then
exit 0
fi
cd /root/utils/generate-domains-blacklists/ &&  ./generate-domains-blacklist.py > /root/utils/adblocklist
exit 0
