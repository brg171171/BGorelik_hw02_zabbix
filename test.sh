
#!/usr/bin/env bash

echo "===== SYSTEM INFO ====="
echo "Hostname: $(hostname 2>/dev/null || echo unknown)"
echo "Date: $(date 2>/dev/null || echo unknown)"
echo "Kernel: $(uname -sr 2>/dev/null || echo unknown)"
echo

case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*)
    echo "Среда: Git Bash / Windows"
    echo "Это не Linux-виртуальная машина, поэтому команды lscpu/free/ip/uptime могут отсутствовать."
    echo
    echo "===== WINDOWS/GIT BASH BASIC INFO ====="
    echo "User: ${USERNAME:-unknown}"
    echo "Shell: ${SHELL:-unknown}"
    echo "PWD: $(pwd)"
    echo
    echo "Файловые системы:"
    df -h 2>/dev/null
    echo "Сетевые адаптеры:"
    ipconfig 2>/dev/null
    exit 0
    ;;
esac

echo "===== OS ====="
if [ -r /etc/os-release ]; then
  . /etc/os-release
  echo "Name: ${PRETTY_NAME:-unknown}"
else
  echo "Name: unknown"
fi
echo "Architecture: $(uname -m 2>/dev/null || echo unknown)"
echo

echo "===== VIRTUALIZATION ====="
if command -v systemd-detect-virt >/dev/null 2>&1; then
  systemd-detect-virt 2>/dev/null || echo "not detected"
else
  grep -qi hypervisor /proc/cpuinfo 2>/dev/null && echo "virtualized (hypervisor flag found)" || echo "unknown"
fi
echo

echo "===== CPU ====="
if [ -r /proc/cpuinfo ]; then
  cpu_model=$(awk -F: '/model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}' /proc/cpuinfo)
  cpu_count=$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)
  echo "Model: ${cpu_model:-unknown}"
  echo "vCPU(s): ${cpu_count:-unknown}"
else
  echo "CPU info unavailable"
fi
echo

echo "===== MEMORY ====="
if [ -r /proc/meminfo ]; then
  awk '
    /MemTotal/ {mt=$2}
    /MemAvailable/ {ma=$2}
    END {
      printf "MemTotal: %.2f GB\n", mt/1024/1024;
      printf "MemAvailable: %.2f GB\n", ma/1024/1024;
      printf "MemUsed: %.2f GB\n", (mt-ma)/1024/1024;
    }
  ' /proc/meminfo
else
  echo "Memory info unavailable"
fi
echo

echo "===== DISK ====="
df -h / 2>/dev/null || df -h 2>/dev/null
echo

echo "===== NETWORK ====="
if command -v ip >/dev/null 2>&1; then
  ip -brief addr
elif command -v ifconfig >/dev/null 2>&1; then
  ipconfig
else
  echo "No ip/ifconfig command found"
fi
echo

echo "===== UPTIME ====="
if [ -r /proc/uptime ]; then
  awk '{printf "Uptime: %.0f seconds\n", $1}' /proc/uptime
elif command -v uptime >/dev/null 2>&1; then
  uptime
else
  echo "Uptime unavailable"
fi
