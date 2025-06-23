# Red Hat Tools Demo

> **⚠️ Work in Progress**  
> This demo is currently under active development and testing. Some components may not work as expected, and the configuration is being optimized for Fedora compatibility. Please check the troubleshooting guide for known issues and workarounds.

This demo showcases common Red Hat Enterprise Linux (RHEL) tools and technologies, with a focus on Ansible automation. The demo deploys a simple multi-tier web application using Red Hat best practices.

## What This Demo Covers

### 🎯 Core Red Hat Tools
- **Ansible** - Configuration management and automation
- **Podman** - Container management (Red Hat's Docker alternative)
- **systemd** - Service and process management
- **firewalld** - Dynamic firewall management
- **SELinux** - Security-Enhanced Linux
- **dnf** - Package management

### 🏗️ Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │    │   Web Server    │    │   Database      │
│   (nginx)       │───▶│   (httpd)       │───▶│   (mariadb)     │
│   Port: 80      │    │   Port: 8080    │    │   Port: 3306    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Prerequisites

- RHEL 8/9 or CentOS 8/9 system
- Python 3.6+
- Ansible 2.9+
- Podman
- Root or sudo access

## Quick Start

1. **Clone and setup:**
   ```bash
   git clone <your-repo>
   cd rhel_demo
   ```

2. **Install dependencies:**
   ```bash
   sudo dnf install -y ansible podman nginx httpd mariadb-server firewalld
   sudo systemctl enable --now firewalld
   ```

3. **Run the demo:**
   ```bash
   ansible-playbook -i inventory/hosts playbook.yml
   ```

4. **Access the application:**
   - Load Balancer: http://localhost
   - Web Server: http://localhost:8080
   - Database: localhost:3306

## Demo Components

### 1. Ansible Playbooks
- `playbook.yml` - Main deployment playbook
- `roles/` - Modular Ansible roles for each component
- `inventory/` - Host definitions and variables

### 2. Container Management
- `containers/` - Podman container definitions
- `systemd/` - systemd service files for containers

### 3. Security Configuration
- `security/` - SELinux policies and firewalld rules
- `templates/` - Configuration templates

### 4. Monitoring
- `monitoring/` - Basic monitoring setup with systemd

## Learning Objectives

After completing this demo, you'll understand:

✅ **Ansible Basics**
- Playbook structure and syntax
- Roles and tasks organization
- Variable management
- Conditionals and loops
- Error handling

✅ **Red Hat Container Strategy**
- Podman vs Docker differences
- Rootless containers
- systemd integration
- Container security

✅ **RHEL Security**
- firewalld zone management
- SELinux context and policies
- Service hardening
- Security best practices

✅ **System Administration**
- systemd service management
- Package management with dnf
- Log management with journald
- Performance monitoring

## Next Steps

1. **Customize the application** - Modify the web app or add new services
2. **Add monitoring** - Integrate with Prometheus/Grafana
3. **Implement CI/CD** - Add GitHub Actions or GitLab CI
4. **Security hardening** - Apply additional security policies
5. **Scaling** - Add more web servers behind the load balancer

## Troubleshooting

See the `troubleshooting.md` file for common issues and solutions.

## Contributing

Feel free to submit issues and enhancement requests! 