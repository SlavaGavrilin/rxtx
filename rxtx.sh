sudo tee /etc/systemd/system/ethtool-rings.service << 'EOF'
[Unit]
Description=Set network ring buffer sizes to maximum
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c '/usr/sbin/ethtool -G $(ls -d /sys/class/net/ens* 2>/dev/null | head -n1 | xargs basename) rx 4096 tx 4096'
ExecStart=/bin/bash -c '/usr/sbin/ethtool -G $(ls -d /sys/class/net/ens* 2>/dev/null | head -n1 | xargs basename) rx 4096 tx 4096'
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && sudo systemctl enable ethtool-rings.service && sudo systemctl start ethtool-rings.service && sudo systemctl status ethtool-rings.service
