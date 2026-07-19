sudo tee /etc/systemd/system/ethtool-rings.service << 'EOF'
[Unit]
Description=Set network ring buffer sizes to maximum
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'IFACE=$(ls -d /sys/class/net/e* 2>/dev/null | head -n1 | xargs basename); RX_MAX=$(/usr/sbin/ethtool -g $IFACE 2>/dev/null | grep "RX:" | head -n1 | awk "{print \$2}"); TX_MAX=$(/usr/sbin/ethtool -g $IFACE 2>/dev/null | grep "TX:" | head -n1 | awk "{print \$2}"); if [ -n "$IFACE" ] && [ "$RX_MAX" != "n/a" ] && [ "$TX_MAX" != "n/a" ] && [ -n "$RX_MAX" ] && [ -n "$TX_MAX" ]; then /usr/sbin/ethtool -G $IFACE rx $RX_MAX tx $TX_MAX; echo "Set $IFACE RX=$RX_MAX TX=$TX_MAX"; else echo "Skipped $IFACE"; fi'
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && sudo systemctl enable ethtool-rings.service && sudo systemctl start ethtool-rings.service && sudo systemctl status ethtool-rings.service
