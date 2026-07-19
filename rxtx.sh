sudo tee /etc/systemd/system/ethtool-rings.service << 'EOF'
[Unit]
Description=Set network ring buffer sizes and qlen to maximum
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'IFACE=$(ls -d /sys/class/net/e* 2>/dev/null | head -n1 | xargs basename); RX_MAX=$(/usr/sbin/ethtool -g $IFACE 2>/dev/null | grep "RX:" | head -n1 | awk "{print \$2}"); TX_MAX=$(/usr/sbin/ethtool -g $IFACE 2>/dev/null | grep "TX:" | head -n1 | awk "{print \$2}"); if [ "$RX_MAX" != "n/a" ] && [ "$TX_MAX" != "n/a" ] && [ -n "$RX_MAX" ] && [ -n "$TX_MAX" ]; then /usr/sbin/ethtool -G $IFACE rx $RX_MAX tx $TX_MAX; fi; /sbin/ip link set dev $IFACE txqueuelen 10000'
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && sudo systemctl enable ethtool-rings.service && sudo systemctl start ethtool-rings.service && sudo systemctl status ethtool-rings.service
