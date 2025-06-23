# Troubleshooting Guide

This guide helps you resolve common issues with the Red Hat Tools Demo.

## 🔍 Quick Diagnostics

### Check Service Status
```bash
# Check all services
systemctl status nginx httpd mariadb firewalld

# Check specific service
systemctl status nginx

# View service logs
journalctl -u nginx -f
journalctl -u httpd -f
journalctl -u mariadb -f
```

### Check Port Availability
```bash
# Check listening ports
ss -tulpn | grep -E ':(80|8080|3306)'

# Test connectivity
curl -I http://localhost:80
curl -I http://localhost:8080
telnet localhost 3306
```

### Check Firewall Status
```bash
# View firewall rules
firewall-cmd --list-all

# Check specific ports
firewall-cmd --list-ports

# Check services
firewall-cmd --list-services
```

## 🚨 Common Issues

### 1. Service Won't Start

**Problem**: Service fails to start
```bash
# Check service status
systemctl status <service_name>

# View detailed logs
journalctl -u <service_name> -n 50
```

**Solutions**:
- Check configuration syntax: `nginx -t`, `apachectl configtest`
- Verify port availability: `ss -tulpn | grep :<port>`
- Check SELinux context: `ls -laZ /path/to/service/files`
- Review log files: `/var/log/<service>/`

### 2. Port Already in Use

**Problem**: Port 80, 8080, or 3306 is already occupied
```bash
# Find process using port
ss -tulpn | grep :80

# Kill process (replace PID)
kill -9 <PID>
```

**Solutions**:
- Stop conflicting services: `systemctl stop <service>`
- Change port in configuration files
- Use different ports in inventory

### 3. SELinux Denials

**Problem**: SELinux blocking access
```bash
# Check SELinux status
getenforce

# View SELinux denials
ausearch -m AVC -ts recent

# Check file contexts
ls -laZ /var/www/html/
```

**Solutions**:
- Set correct context: `chcon -R -t httpd_exec_t /var/www/html/`
- Allow specific operations: `setsebool -P httpd_can_network_connect 1`
- Temporarily disable: `setenforce 0` (not recommended for production)

### 4. Database Connection Issues

**Problem**: Can't connect to MariaDB
```bash
# Check MariaDB status
systemctl status mariadb

# Test connection
mysql -u root -p

# Check MariaDB logs
tail -f /var/log/mariadb/mysqld.log
```

**Solutions**:
- Start MariaDB: `systemctl start mariadb`
- Reset root password: `mysql_secure_installation`
- Check bind address in `/etc/my.cnf.d/`
- Verify firewall rules for port 3306

### 5. Web Application Not Loading

**Problem**: Website returns error or blank page
```bash
# Check Apache/Nginx status
systemctl status httpd nginx

# Test web server
curl -I http://localhost:8080
curl -I http://localhost:80

# Check error logs
tail -f /var/log/httpd/error_log
tail -f /var/log/nginx/error.log
```

**Solutions**:
- Verify virtual host configuration
- Check file permissions: `ls -la /var/www/html/`
- Test PHP: `php -v`
- Check SELinux context for web files

### 6. Ansible Playbook Failures

**Problem**: Playbook execution fails
```bash
# Run with verbose output
ansible-playbook -i inventory/hosts playbook.yml -vvv

# Check syntax
ansible-playbook --syntax-check playbook.yml

# Dry run
ansible-playbook -i inventory/hosts playbook.yml --check
```

**Solutions**:
- Update Ansible: `pip install --upgrade ansible`
- Check Python version: `python3 --version`
- Verify inventory file syntax
- Check SSH connectivity (if using remote hosts)

## 🔧 Advanced Troubleshooting

### Performance Issues

**Check System Resources**:
```bash
# CPU and memory
htop
free -h
df -h

# Network
iftop
nethogs

# Disk I/O
iotop
```

**Database Performance**:
```bash
# Check slow queries
tail -f /var/log/mariadb/slow.log

# Monitor connections
mysql -e "SHOW PROCESSLIST;"

# Check InnoDB status
mysql -e "SHOW ENGINE INNODB STATUS\G"
```

### Security Issues

**Check Security Status**:
```bash
# SELinux status
sestatus
getenforce

# Firewall status
firewall-cmd --state
firewall-cmd --list-all

# Audit logs
ausearch -m AVC -ts recent
```

**Security Hardening**:
```bash
# Run security scan
rpm -qa | grep -E "(openssh|openssl)"

# Check file permissions
find /var/www/html/ -type f -exec ls -la {} \;

# Verify SSL certificates (if using HTTPS)
openssl x509 -in /path/to/cert.pem -text -noout
```

### Log Analysis

**Centralized Log Viewing**:
```bash
# View all application logs
tail -f /var/log/{{ app_name }}/*.log

# Search for errors
grep -i error /var/log/*.log

# Monitor real-time logs
journalctl -f
```

**Log Rotation Issues**:
```bash
# Check logrotate status
logrotate -d /etc/logrotate.d/{{ app_name }}-web

# Force log rotation
logrotate -f /etc/logrotate.d/{{ app_name }}-web
```

## 🛠️ Recovery Procedures

### Complete Reset
```bash
# Stop all services
systemctl stop nginx httpd mariadb

# Remove application data
rm -rf /opt/{{ app_name }}
rm -rf /var/www/html/{{ app_name }}

# Reset database
mysql -e "DROP DATABASE IF EXISTS {{ app_name }};"

# Re-run playbook
ansible-playbook -i inventory/hosts playbook.yml
```

### Database Recovery
```bash
# Restore from backup
mysql {{ app_name }} < /opt/{{ app_name }}/backups/latest.sql

# Reset root password
mysql_secure_installation
```

### Service Recovery
```bash
# Restart all services
systemctl restart nginx httpd mariadb firewalld

# Reload configurations
systemctl reload nginx
systemctl reload httpd
```

## 📞 Getting Help

### Useful Commands
```bash
# System information
uname -a
cat /etc/redhat-release
rpm -qa | grep -E "(ansible|nginx|httpd|mariadb)"

# Network information
ip addr show
route -n
cat /etc/hosts

# Process information
ps aux | grep -E "(nginx|httpd|mariadb)"
```

### Log Locations
- **Nginx**: `/var/log/nginx/`
- **Apache**: `/var/log/httpd/`
- **MariaDB**: `/var/log/mariadb/`
- **System**: `/var/log/messages`
- **Application**: `/var/log/{{ app_name }}/`

### Configuration Files
- **Nginx**: `/etc/nginx/nginx.conf`, `/etc/nginx/conf.d/`
- **Apache**: `/etc/httpd/conf/httpd.conf`, `/etc/httpd/conf.d/`
- **MariaDB**: `/etc/my.cnf`, `/etc/my.cnf.d/`
- **Firewall**: `/etc/firewalld/`
- **SELinux**: `/etc/selinux/config`

## 🎯 Performance Optimization

### Web Server Tuning
```bash
# Apache tuning
# Edit /etc/httpd/conf/httpd.conf
MaxKeepAliveRequests 100
KeepAliveTimeout 5
MaxClients 150

# Nginx tuning
# Edit /etc/nginx/nginx.conf
worker_processes auto;
worker_connections 1024;
```

### Database Tuning
```bash
# MariaDB tuning
# Edit /etc/my.cnf.d/rhel-demo.cnf
innodb_buffer_pool_size = 256M
query_cache_size = 32M
max_connections = 300
```

### System Tuning
```bash
# Kernel parameters
echo 'net.core.somaxconn = 65535' >> /etc/sysctl.conf
echo 'vm.swappiness = 10' >> /etc/sysctl.conf
sysctl -p
``` 