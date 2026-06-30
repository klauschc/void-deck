# Void Deck — NAS 部署指南

## Portainer Stack 部署

1. Portainer → Stacks → Add stack
2. Name: `void-deck`
3. Paste:

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

## Cloudflare Tunnel

1. Cloudflare Dashboard → Zero Trust → Tunnels
2. 揀現有 Tunnel → Configure → Public Hostname
3. 新增：Subdomain `tarot`, Domain `kcloudz.com`, Type `HTTP`, URL `localhost:8000`
4. 之後用 `https://tarot.kcloudz.com` 就得

iOS App Settings 入面 set API URL 做上面嗰個 URL。
