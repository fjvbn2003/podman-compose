#!/bin/bash
# 러너 커널에 올라간 AppArmor 프로필 중 pasta·passt·podman 관련이 있는지 본다(컨테이너는 privileged).
set -x
cat /proc/self/attr/current 2>&1
ls /sys/kernel/security/apparmor/ 2>&1 | head
wc -l /sys/kernel/security/apparmor/profiles 2>&1
grep -i -E 'pass|pasta|podman|crun|netavark|aardvark|slirp' /sys/kernel/security/apparmor/profiles 2>&1
command -v pasta passt 2>&1; ls -la /usr/bin/pasta* /usr/bin/passt* 2>&1
exit 0
