knife ssl fetch
knife bootstrap 10.0.0.7 -y -U chef -P devsecops -N node1 --sudo --use-sudo-password
knife bootstrap 10.0.0.8 -y -U chef -P devsecops -N node2 --sudo --use-sudo-password

