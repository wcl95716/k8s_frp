
# 📝 TODO: FRP 单例实现 + 用户+IP 绑定 + 动态白名单

---

## 🎯 **项目目标**
1. 通过 FRP 单实例（FRPS）实现多用户代理服务  
2. 在客户端管理每个用户的连接，防止白嫖和滥用  
3. 通过 `用户 + IP` 方式动态生成 IP 白名单  
4. 使用 `ipset` 代替 `iptables`，提高动态 IP 处理性能  
5. 通过 Nginx 为每个用户生成二级域名，动态管理端口转发  

---

## 🚀 **整体架构**
```bash
┌───────────────┐       ┌──────────────────┐         ┌───────────────┐
│  FRPS 实例    │       │  授权服务（Python） │         │   客户端管理  │
│               │       │ - 动态管理 IP       │         │ - 固定 Token   │
│ - 连接管理     │──────▶ │ - 实时更新 ipset    │ ◀───────│ - IP 校验     │
│ - 端口映射     │       │ - Fail2ban 自动封禁 │         │ - 连接控制     │
└───────────────┘       └──────────────────┘         └───────────────┘

               │  
               ▼  
┌───────────────┐  
│  NGINX 反向代理 │  
└───────────────┘  
```

---

## ✅ **1. FRPS 单例服务端实现**
### 📌 任务：
- [ ] 通过 Docker Compose 部署 FRP 服务端  
- [ ] 配置 FRPS 单实例  
- [ ] 启用 Token 认证（固定 Token）  
- [ ] 开启 Dashboard 监控  

### 💡 **配置示例：frps.ini**
```ini
[common]
bind_port = 7000
authentication_method = token
token = fixed-token
dashboard_port = 7500
dashboard_user = admin
dashboard_pwd = admin123
```

---

## ✅ **2. 客户端管理（用户 + IP 绑定）**
### 📌 任务：
- [ ] 在数据库中维护用户 + IP 绑定  
- [ ] 在客户端连接时进行以下校验：  
    - [ ] 用户名  
    - [ ] IP 匹配  
    - [ ] 固定 Token 校验  

### 💡 **数据库结构**
```sql
CREATE TABLE frp_users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    token VARCHAR(128) NOT NULL UNIQUE,
    allowed_ips TEXT NOT NULL,
    status TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## ✅ **3. 授权服务（Python Flask）**
### 📌 任务：
- [ ] 使用 Flask 开发授权服务  
- [ ] 创建以下接口：  
    - [ ] `/validate` → 校验 IP + Token  
    - [ ] `/allowed-ips` → 返回 IP 列表  
- [ ] 整合 MySQL 数据库  

### 💡 **接口示例**
```python
@app.route('/validate', methods=['POST'])
@app.route('/allowed-ips', methods=['GET'])
```

---

## ✅ **4. 动态 IP 生成（使用 ipset）**
### 📌 任务：
- [ ] 使用 `ipset` 生成动态白名单  
- [ ] 通过脚本自动更新 `ipset` 列表  
- [ ] 将 `ipset` 规则与 `iptables` 绑定  

### 💡 **示例脚本**
```bash
ipset create frp_whitelist hash:ip timeout 3600
iptables -A INPUT -p tcp --dport 7000 -m set --match-set frp_whitelist src -j ACCEPT
```

### 💡 **动态更新脚本**
```bash
ALLOWED_IPS=$(curl -s http://127.0.0.1:5000/allowed-ips | jq -r '.[]')

ipset flush frp_whitelist
for ip in ${ALLOWED_IPS}; do
    ipset add frp_whitelist $ip timeout 3600
done
```

---

## ✅ **5. Fail2ban 自动封禁**
### 📌 任务：
- [ ] 安装 `Fail2ban`  
- [ ] 配置 `Fail2ban` 与 `ipset` 集成  
- [ ] 超过 3 次失败自动封禁 IP  
- [ ] 支持手动解封  

### 💡 **Fail2ban 配置示例**
```ini
[frps]
enabled = true
port = 7000
filter = frps
logpath = /var/log/frps.log
maxretry = 3
findtime = 600
bantime = 3600
action = iptables-ipset[name=frp_whitelist, port=7000, protocol=tcp]
```

---

## ✅ **6. 通过 NGINX 生成二级域名**
### 📌 任务：
- [ ] 使用 Nginx 生成动态二级域名  
- [ ] 支持 HTTPS 证书（Let’s Encrypt）  
- [ ] 通过 Nginx 将端口代理到 FRP 服务端  

---

## ✅ **7. Docker Compose 自动部署**
### 📌 任务：
- [ ] 通过 Docker Compose 一键启动  
- [ ] 将 FRPS + Flask + Nginx + Fail2ban 整合在同一网络下  
- [ ] 支持动态扩展  

---

## ✅ **8. 监控（Prometheus + Grafana）**
### 📌 任务：
- [ ] 通过 Prometheus 监控连接数  
- [ ] 通过 Grafana 可视化展示：  
    - [ ] 连接状态  
    - [ ] 用户来源  
    - [ ] 带宽使用  

---

## ✅ **9. 测试与优化**
### 📌 任务：
- [ ] 测试多客户端同时连接  
- [ ] 进行高并发压力测试  
- [ ] 调整 ipset 性能参数  
- [ ] 监控 Fail2ban 拦截情况  

---

## 🏆 **目标效果**
✅ 单实例 FRPS 稳定运行  
✅ 用户+IP 绑定实现严格授权  
✅ 自动封禁和实时更新  
✅ 高效连接 + 无中断  

---

## 😎 **进度追踪**
- ✅ 基础架构完成  
- ⬜ 授权服务开发中  
- ⬜ 动态 IP 更新测试中  
- ⬜ Fail2ban 规则调整中  

---

## 🚀 **完成时间：2024-03-XX**
