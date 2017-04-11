 /var/log/bittorrent/*.log {
      rotate 30
      weekly
      compress
      size 50k
      missingok
      notifempty
      create 600 bittorrent nogroup
 }
