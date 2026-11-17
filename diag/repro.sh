#!/bin/bash
# podman-compose 없이 podman 만으로, compose 가 하는 일(이름 붙은 네트워크에 컨테이너를 올리고
# stop 한다)을 재현한다. 각 단계의 종료 코드를 남긴다.
set -x
id
podman info --format '{{.Host.NetworkBackend}} rootless={{.Host.Security.Rootless}} {{.Host.NetworkBackendInfo.Package}}' || true
podman info --format json | python3 -c 'import json,sys; h=json.load(sys.stdin)["host"]; print(json.dumps({k:h.get(k) for k in ("networkBackend","networkBackendInfo","pasta","slirp4netns","rootlessNetworkCmd")}, indent=1))' || true
IMG=docker.io/library/busybox:1.36
podman pull -q $IMG
podman network create diagnet; echo "network create rc=$?"
podman network inspect diagnet --format '{{.DNSEnabled}} {{.Driver}}' ; echo "inspect rc=$?"

podman run -d --name c1 --network diagnet $IMG sleep 300; echo "run rc=$?"
sleep 1
ls -la /run/containers/networks/aardvark-dns "${XDG_RUNTIME_DIR:-/nonexistent}/containers/networks/aardvark-dns" 2>&1
# rootless 네트워크 프로세스(pasta·slirp4netns)가 어떤 AppArmor 프로필로 도는지 본다.
for e in /proc/[0-9]*/exe; do
  t=$(readlink "$e" 2>/dev/null) || continue
  case "$t" in *pasta*|*passt*|*slirp4netns*|*aardvark*)
    p=${e#/proc/}; p=${p%/exe}
    echo "netproc pid=$p exe=$t label=$(cat /proc/$p/attr/current 2>&1) uid=$(stat -c %u /proc/$p)";;
  esac
done
podman --log-level=debug stop -t 1 c1 > /tmp/stop.out 2> /tmp/stop.err; echo "stop rc=$?"
grep -v -E 'level=debug msg="(Called|Using|Initializing|Cached|Not|Setting|Configured|Overriding|Merged|Reading|Found|Successfully)' /tmp/stop.err | tail -40
podman rm c1; echo "rm rc=$?"

# 기본 네트워크(podman, DNS 꺼짐)에서도 같은지 본다.
podman run -d --name c2 $IMG sleep 300; echo "run(default net) rc=$?"
sleep 1
podman stop -t 1 c2; echo "stop(default net) rc=$?"
podman rm c2; echo "rm(default net) rc=$?"

# DNS 를 끈 이름 붙은 네트워크.
podman network create --disable-dns diagnet2; echo "network create(nodns) rc=$?"
podman run -d --name c3 --network diagnet2 $IMG sleep 300; echo "run(nodns) rc=$?"
sleep 1
podman stop -t 1 c3; echo "stop(nodns) rc=$?"
podman rm c3; echo "rm(nodns) rc=$?"
podman network rm -f diagnet diagnet2
exit 0
