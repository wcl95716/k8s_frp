version: '3.8'

services:
  frps:
    image: ghcr.io/fatedier/frps:v0.53.0
    container_name: frps
    restart: always
    ports:
      - "7001:7000"   # 映射 FRP 服务端口（容器内 7000 映射到宿主机 7001）
      - "7500:7500"   # 映射 Web Dashboard 端口
    volumes:
      - ./frps.ini:/etc/frp/frps.ini
    command: ["-c", "/etc/frp/frps.ini"]
