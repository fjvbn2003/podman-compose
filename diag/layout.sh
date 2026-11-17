#!/bin/bash
# 설치된 네트워크 도구의 위치와 podman 이 찾는 위치를 견준다.
set -x
podman --version
dpkg -l | grep -E 'podman|netavark|aardvark|crun|passt|slirp' || true
for p in netavark aardvark-dns pasta slirp4netns; do
  dpkg -L "$p" 2>/dev/null | grep -E "bin/|libexec/|lib/podman/" || true
done
ls -la /usr/libexec/podman /usr/lib/podman /usr/local/libexec/podman /usr/local/lib/podman 2>&1 || true
ls -la /etc/containers /usr/share/containers 2>&1 || true
grep -rn -E 'helper_binaries_dir|network_backend|default_rootless_network_cmd' \
  /etc/containers /usr/share/containers 2>/dev/null || true
strings "$(command -v podman)" | grep -E '^/usr/(local/)?(libexec|lib)/podman' | sort -u | head -20 || true
