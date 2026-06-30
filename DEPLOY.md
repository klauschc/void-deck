# Void Deck — NAS 部署指南

## 方法一：Portainer Stack（建議）

1. 打開 Portainer → Stacks → Add stack
2. Name: `void-deck`
3. Paste 以下內容：

```yaml
services:
  void-deck:
    image: ghcr.io/klauschc/void-deck:latest
    container_name: void-deck
    network_mode: bridge
    ports:
      - "8000:8000"
    environment:
      - LLM_BASE_URL=https://integrate.api.nvidia.com/v1
      - LLM_MODEL=minimaxai/minimax-m3
      - LLM_MAX_TOKENS=4096
      - LLM_TEMPERATURE=0.7
      - NVIDIA_BUILD_API_KEY=你的NVIDIA_API_Key
    restart: unless-stopped
```

4. Deploy

## Cloudflare Tunnel 設定

1. Cloudflare Dashboard → Zero Trust → Networks → Tunnels
2. 揀你現有嘅 Tunnel → Configure → Public Hostname
3. 新增：
   - Subdomain: `tarot`（或其他你鍾意嘅）
   - Domain: `kcloudz.com`
   - Type: `HTTP`
   - URL: `localhost:8000`
4. Save

之後就可以用 `https://tarot.kcloudz.com` access backend。

iOS App Settings 入面 set API URL 做 `https://tarot.kcloudz.com` 就得。

## 更新

當 GitHub 有新 code push：
1. Portainer → void-deck → Recreate（pull latest image）
2. 或者 SSH 入 NAS：
```bash
cd /volume1/docker/void-deck
docker compose pull
docker compose up -d
```
