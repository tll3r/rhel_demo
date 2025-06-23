#!/bin/bash
# Red Hat Tools Demo Showcase Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="rhel-demo-app"
WEB_PORT=8080
DB_PORT=3306
LB_PORT=80

# Header
echo -e "${BLUE}"
echo "=================================================================="
echo "🐧 Red Hat Tools Demo Showcase"
echo "=================================================================="
echo -e "${NC}"

# Function to print section headers
print_section() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print info messages
print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   exit 1
fi

print_section "System Information"
echo "Hostname: $(hostname)"
echo "OS: $(cat /etc/redhat-release)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"

print_section "1. Ansible - Configuration Management"
print_info "Checking Ansible installation..."
if command -v ansible &> /dev/null; then
    print_success "Ansible is installed"
    echo "Version: $(ansible --version | head -n1)"
    
    print_info "Running Ansible playbook..."
    if ansible-playbook -i inventory/hosts playbook.yml --check; then
        print_success "Ansible playbook syntax check passed"
    else
        print_warning "Ansible playbook check failed"
    fi
else
    print_error "Ansible is not installed"
fi

print_section "2. Podman - Container Management"
print_info "Checking Podman installation..."
if command -v podman &> /dev/null; then
    print_success "Podman is installed"
    echo "Version: $(podman --version)"
    
    print_info "Podman system information:"
    podman system info --format json | jq '.host.arch, .host.os, .store.graphDriverName' 2>/dev/null || echo "jq not available"
    
    print_info "Running containers:"
    podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    print_error "Podman is not installed"
fi

print_section "3. systemd - Service Management"
print_info "Checking systemd services..."
echo "Active services:"
systemctl list-units --type=service --state=active | grep -E "(nginx|httpd|mariadb|firewalld)" || echo "No relevant services found"

print_info "Service status:"
for service in nginx httpd mariadb firewalld; do
    if systemctl is-active --quiet $service; then
        print_success "$service is running"
    else
        print_warning "$service is not running"
    fi
done

print_section "4. firewalld - Firewall Management"
print_info "Checking firewalld status..."
if systemctl is-active --quiet firewalld; then
    print_success "firewalld is active"
    echo "Default zone: $(firewall-cmd --get-default-zone)"
    echo "Active zones: $(firewall-cmd --get-active-zones | grep -v '^$' | head -n1)"
    
    print_info "Open ports:"
    firewall-cmd --list-ports
    
    print_info "Enabled services:"
    firewall-cmd --list-services
else
    print_warning "firewalld is not active"
fi

print_section "5. SELinux - Security"
print_info "Checking SELinux status..."
if command -v getenforce &> /dev/null; then
    SELINUX_MODE=$(getenforce)
    echo "SELinux mode: $SELINUX_MODE"
    
    if [[ "$SELINUX_MODE" == "Enforcing" ]]; then
        print_success "SELinux is enforcing"
    elif [[ "$SELINUX_MODE" == "Permissive" ]]; then
        print_warning "SELinux is permissive"
    else
        print_warning "SELinux is disabled"
    fi
    
    print_info "SELinux booleans for web services:"
    getsebool -a | grep -E "(httpd|nginx)" || echo "No web-related booleans found"
else
    print_error "SELinux is not available"
fi

print_section "6. dnf - Package Management"
print_info "Checking dnf package manager..."
if command -v dnf &> /dev/null; then
    print_success "dnf is available"
    echo "Version: $(dnf --version | head -n1)"
    
    print_info "Installed packages count:"
    dnf list installed | wc -l
    
    print_info "Available updates:"
    dnf check-update --quiet || echo "No updates available"
else
    print_error "dnf is not available"
fi

print_section "7. Application Status"
print_info "Checking application components..."

# Check web server
if curl -s -o /dev/null -w "%{http_code}" http://localhost:$WEB_PORT | grep -q "200"; then
    print_success "Web server (Apache) is responding on port $WEB_PORT"
else
    print_warning "Web server (Apache) is not responding on port $WEB_PORT"
fi

# Check load balancer
if curl -s -o /dev/null -w "%{http_code}" http://localhost:$LB_PORT | grep -q "200"; then
    print_success "Load balancer (Nginx) is responding on port $LB_PORT"
else
    print_warning "Load balancer (Nginx) is not responding on port $LB_PORT"
fi

# Check database
if mysql -u root -pRedHatDemo123! -e "SELECT 1;" &>/dev/null; then
    print_success "Database (MariaDB) is accessible on port $DB_PORT"
else
    print_warning "Database (MariaDB) is not accessible on port $DB_PORT"
fi

print_section "8. System Monitoring"
print_info "System resource usage:"
echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory Usage: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
echo "Disk Usage: $(df -h / | tail -1 | awk '{print $5}')"

print_info "Network interfaces:"
ip addr show | grep -E "inet.*scope global" | awk '{print $2}' | head -3

print_section "9. Log Analysis"
print_info "Recent system logs:"
journalctl --since "1 hour ago" --no-pager | grep -E "(error|fail|denied)" | tail -5 || echo "No recent errors found"

print_info "Application logs:"
if [[ -d "/var/log/$APP_NAME" ]]; then
    ls -la /var/log/$APP_NAME/
else
    print_warning "Application log directory not found"
fi

print_section "10. Security Assessment"
print_info "Checking security status..."

# Check for open ports
print_info "Listening ports:"
ss -tulpn | grep -E ":(80|8080|3306|22)" | awk '{print $5}' | sort

# Check for running processes
print_info "Running web processes:"
ps aux | grep -E "(nginx|httpd|mariadb)" | grep -v grep || echo "No web processes found"

# Check file permissions
print_info "Web directory permissions:"
if [[ -d "/var/www/html/$APP_NAME" ]]; then
    ls -la /var/www/html/$APP_NAME/ | head -5
else
    print_warning "Web directory not found"
fi

print_section "Demo Summary"
echo -e "${GREEN}🎉 Red Hat Tools Demo Showcase Complete!${NC}"
echo ""
echo "📊 Demo Components:"
echo "  • Ansible: Configuration management and automation"
echo "  • Podman: Container management"
echo "  • systemd: Service and process management"
echo "  • firewalld: Dynamic firewall management"
echo "  • SELinux: Security-Enhanced Linux"
echo "  • dnf: Package management"
echo ""
echo "🌐 Application URLs:"
echo "  • Load Balancer: http://$(hostname -I | awk '{print $1}'):$LB_PORT"
echo "  • Web Server: http://$(hostname -I | awk '{print $1}'):$WEB_PORT"
echo "  • Database: $(hostname -I | awk '{print $1}'):$DB_PORT"
echo ""
echo "📚 Next Steps:"
echo "  1. Explore the Ansible roles in the roles/ directory"
echo "  2. Modify configurations and re-run the playbook"
echo "  3. Check out the troubleshooting guide"
echo "  4. Experiment with different Red Hat tools"
echo ""
echo -e "${BLUE}Happy learning! 🐧${NC}" 