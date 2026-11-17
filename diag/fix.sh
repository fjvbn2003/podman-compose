#!/bin/bash
# 후보 수정을 root 로 적용한다. 조합마다 다르다.
#   5.4.2 root  : 시험용 aardvark-dns deb 가 /usr/lib/podman/podman/ 에 깔려 podman 이 못 찾는다.
#                 netavark 가 있는 /usr/local/libexec/podman/ 에 링크를 둔다.
#   rootless    : pasta 대신 slirp4netns 로 바꿔서 pasta 의 AppArmor 프로필 문제인지 가른다.
set -x
case "$1" in
  5.4.2)
    ln -s /usr/lib/podman/podman/aardvark-dns /usr/local/libexec/podman/aardvark-dns
    ls -la /usr/local/libexec/podman/
    ;;
  rootless)
    mkdir -p /etc/containers
    printf '[network]\ndefault_rootless_network_cmd = "slirp4netns"\n' >> /etc/containers/containers.conf
    cat /etc/containers/containers.conf
    ;;
esac
exit 0
