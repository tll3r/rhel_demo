# Red Hat Tools Demo 🚀

> **TL;DR (60 sec read)**  
> *Automated multi-tier application deployed with one command.*  
> Uses **Ansible** to configure **Nginx**, **Apache HTTPD** and **MariaDB** – **all running in root-less Podman containers** – plus system hardening (SELinux, firewalld) **and** a live dashboard.  
> Clone → `ansible-playbook playbook.yml` → open <http://localhost:8080> and watch the status cards turn green.

---

## 1 Why does this project exist? 🤔

I built this repository as a **portfolio piece** to demonstrate hands-on competence with daily RHEL administration tasks **and** modern automation practices:

* Designing idempotent, role-based **Ansible** playbooks
* Operating system hardening with **SELinux** & **firewalld**
* Service management via **systemd**
* Root-less container workflows with **Podman**
* Lightweight monitoring & troubleshooting

Everything is reproducible – wipe the VM, run the playbook again, get the exact same result.  
*(Great for demos, workshops, interviews or your own learning.)*

---

## 2 Full overview 📝

### 2.1 Stack & features

| Tier | Component | Purpose |
|------|-----------|---------|
| Load Balancer | **Nginx (container)** `:8000` | SSL termination & simple round-robin |
| Application | **Apache HTTPD + PHP-FPM (container)** `:8080` | Serves a micro PHP dashboard & REST API |
| Database | **MariaDB (container)** `:{{ db_port \| default(3306) }}` | Persists demo data |
| Monitoring | **Custom dashboard + system scripts** | Live CPU/Memory/Disk, service health |
| Automation | **Ansible** | One-click provisioning on Fedora/RHEL |
| Security | **SELinux / firewalld** | Enforced, no ports left open by accident |

### 2.2 Architecture diagram

```text
┌──────────────┐    8000/tcp    ┌──────────────┐    8080/tcp    ┌──────────────┐
│  Nginx LB    │ ───────────▶  │  Apache/PHP   │ ───────────▶  │  MariaDB      │
│ (Container)  │               │  Dashboard    │               │  Database     │
└──────────────┘               └──────────────┘               └──────────────┘
```

### 2.3 What the playbook does

1. **Common** – Creates dedicated `appuser`/`appgroup`, sets limits, timezone, etc.
2. **Security** – Enables firewalld zones & persistent SELinux contexts.
3. **Database** – Installs & secures MariaDB, creates schema if required.
4. **Webserver** – Configures Apache + PHP-FPM, deploys the dashboard & API.
5. **Load-balancer** – Deploys Nginx, forwards to the web tier.
6. **Monitoring** – Installs collectd/sysstat, cron scripts, and exposes `/api.php?endpoint=status` consumed by the dashboard.

All tasks are **idempotent** and tagged – run `--tags webserver` to redeploy only that tier.

---

## 3 Getting started 🏁

### 3.1 Prerequisites

* Fedora 38/39/40, RHEL 8/9 or compatible
* `python3` + `ansible-core` ≥ 2.13
* Passwordless *sudo* (or run as root)

### 3.2 Quick start (local single-host demo)

```bash
# Clone
$ git clone https://github.com/<your-fork>/rhel_demo.git
$ cd rhel_demo

# Install deps (Fedora example)
$ sudo dnf install -y ansible-core podman jq

# Inventory already points to localhost
$ ansible-playbook -i inventory/hosts playbook.yml

# Open the app
$ xdg-open http://localhost:8080  # or point your browser manually
```

When the page loads you should quickly see *System Status* cards flash green.

### 3.3 Tearing down / resetting

```bash
# Stop & remove containers
$ podman stop nginx-lb httpd mariadb || true
$ podman rm nginx-lb httpd mariadb || true
# Remove volumes/directories created by the demo
$ sudo rm -rf /opt/rhel-demo-app /var/www/html/rhel-demo-app /opt/rhel-demo-app/db_data
```

---

## 4 Deep dive 🔍

Detailed walk-through lives in [`docs/`](docs/) (design decisions, SELinux policy reasoning, troubleshooting cheatsheet & more).

---

## 5 Roadmap 🛣️

- [ ] Add Prometheus node-exporter + Grafana dashboard
- [ ] Swap MariaDB for PostgreSQL and use roles/variables for DB engine choice
- [ ] Extend to multiple web hosts and demo Ansible inventories/groups
- [ ] CI pipeline that spins up the playbook in a container action

---

## 6 Contributing 🤝

PRs and issues welcome! Feel free to fork or raise suggestions – this repo is first and foremost a **learning playground**.

---

## 7 License 📝

MIT – do what you wish, credit appreciated. 