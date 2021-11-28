# Prometheus and Grafana
## _Step by step instructions to install and set up Prometheus and Grafana_


Prometheus is an open-source systems monitoring and alerting toolkit originally built at SoundCloud. Since its inception in 2012, many companies and organizations have adopted Prometheus, and the project has a very active developer and user community.

In layman terms, metrics are numeric measurements, time series mean that changes are recorded over time. What users want to measure differs from application to application. For a web server it might be request times, for a database it might be number of active connections or number of active queries etc.



## Installing Prometheus

```
wget https://github.com/prometheus/prometheus/releases/download/v2.13.0/prometheus-2.13.0.linux-amd64.tar.gz
tar -xzvf prometheus-2.13.0.linux-amd64.tar.gz
mv prometheus-2.13.0.linux-amd64 prometheus-files
```

Create a user for prometheus and change ownership for files.

```
useradd --no-create-home --shell /bin/false prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus
```
Change ownership for additional files

```
cp prometheus-files/prometheus /usr/local/bin/
cp prometheus-files/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
```

```
cp -r prometheus-files/consoles /etc/prometheus
cp -r prometheus-files/console_libraries /etc/prometheus
chown prometheus:prometheus /etc/prometheus/consoles
chown prometheus:prometheus /etc/prometheus/console_libraries
```

#### Prometheus Configurations
All the prometheus configurations should be present in prometheus.yaml file

```
vi /etc/prometheus/prometheus.yaml


# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
```

NOTE: Be careful with the indendation.

Change ownership as well.

```
chown prometheus:prometheus /etc/prometheus/prometheus.yaml
```

### Setup prometheus startup service

```
sudo vi /etc/systemd/system/prometheus.service

[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yaml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```

### Then reload the systemd service

```
systemctl daemon-reload

systemctl start prometheus
systemctl status prometheus
systemctl enable prometheus
```


### Access Prometheus Web UI
```
http://<IP>:9090/graph

http://64.227.177.207:9090/graph
```




- [AngularJS] - HTML enhanced for web apps!
- [Ace Editor] - awesome web-based text editor
- [markdown-it] - Markdown parser done right. Fast and easy to extend.
- [Twitter Bootstrap] - great UI boilerplate for modern web apps
- [node.js] - evented I/O for the backend
- [Express] - fast node.js network app framework [@tjholowaychuk]
- [Gulp] - the streaming build system
- [Breakdance](https://breakdance.github.io/breakdance/) - HTML
to Markdown converter
- [jQuery] - duh



## Install Node Exporter:

**Step 1** Create a repository:

```
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz

tar xvfz node_exporter-0.18.1.linux-amd64.tar.gz

mv node_exporter-0.18.1.linux-amd64/node_exporter /usr/local/bin/
```

**Step 2** Create user node_exporter

```
useradd -rs /bin/false node_exporter
```

**Step 3** Create a startup service for Node Exporter

```
vi /etc/systemd/system/node_exporter.service

[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```
### Then reload the systemd service

```
systemctl daemon-reload

systemctl start node_exporter.service
systemctl status node_exporter.service
systemctl enable node_exporter.service
```


## Configure the Server as Target on Prometheus Server
This configuration should be done on the Prometheus server.


```
vi /etc/prometheus/prometheus.yaml
```

Under Scrape Config section add the node exporter target as shown below. Job name can be your server hostname or IP for identification purposes.
```
scrape_configs:
  - job_name: node
    static_configs:
      - targets: ["localhost:9100"]
```

##### Restart Prometheus
```
systemctl restart prometheus
systemctl status prometheus
```

Check for the targets are configured correctly

```
http://64.227.177.207:9090/targets
```

## Install Grafana

Install Grafana with YUM
```
vi /etc/yum.repos.d/grafana.repo

[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
```

Installing Grafana.

```
yum install grafana
```
The package des the following things:

 - Installs binary to /usr/sbin/grafana-server
 - Copies init.d script to /etc/init.d/grafana-server
 - Installs default file to /etc/sysconfig/grafana-server
 - Copies configuration file to /etc/grafana/grafana.ini 
 - Installs systemd service (id systemd is available) name grafana-server.service
 - The default configuration uses a log file at /varlog/grafana/grafana.log

 
**Step 3** Install additional fonts packages
```
yum install freetype*
```

**Step 4** Start and Enable Grafana Service

```
systemctl status grafana-server
systemctl start grafana-server
systemctl status grafana-server
systemctl enable grafana-server
```

**Step 5** Change firewall configuration to allow Grafana port.

1. Either in Management Console enable port in firewall or security Group. 
2. Run the below command in machine to opn port 3000


```
firewall-cmd --zone=public --add-port=3000/tcp --permanent

firewall-cmd --reload
```

**Step 6** Browse Grafana on web browser.

```
http://<IP>:3000
http://64.227.177.207:3000
```

**Add Datasource**
Select Prometheus and provide the URL -- ```http://localhost:9090```

**Step 7** Add a Dashboard

+ Create > Import -- 1860
