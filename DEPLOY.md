# Void Deck — NAS 部署指南

## 事前準備

確保你已經有：
- Synology NAS 已安裝 Portainer
- Cloudflare Tunnel 已在 NAS 上運行（cloudflared）
- NVIDIA API Key（用於 MiniMax-M3 模型）

## Portainer Stack 部署

1. 打開 **Portainer** → **Stacks** → **Add stack**
2. Name 填：`void-deck`
3. 貼上以下內容：

```yaml
services:
  void-deck:
    build: .
    container_name: void-deck
    ports:
      - "8000:8000"
    environment:
      - LLM_BASE_URL=https://integrate.api.nvidia.com/v1
      - LLM_MODEL=minimaxai/minimax-m3
      - LLM_TEMPERATURE=0.7
      - NVIDIA_BUILD_API_KEY=你的API_Key
    restart: unless-stopped
```

4. 將 `NVIDIA_BUILD_API_KEY` 換成你實際嘅 Key
5. 撳 **Deploy the stack**

## Cloudflare Tunnel 設定

1. Cloudflare Dashboard → **Zero Trust** → **Networks** → **Tunnels**
2. 揀你現有嘅 Tunnel → **Configure** → **Public Hostname**
3. 新增一筆：
   - Subdomain: `tarot`
   - Domain: `kcloudz.com`
   - Type: `HTTP`
   - URL: `localhost:8000`
4. Save

完成後可以透過 `https://tarot.kcloudz.com` 訪問後端。

## 疑難排解

- **Portainer build 失敗**：檢查 NAS 有冇足夠空間（`df -h`）
- **連唔到 API**：確認 Cloudflare Tunnel 係咪運行緊同 public hostname 有冇 save
- **AI 解讀失敗**：檢查 NVIDIA API Key 係咪正確，NVIDIA Credit 係咪用晒

## 驗證部署

```bash
curl https://tarot.kcloudz.com/api/spreads
# 應該回傳 3 個牌陣嘅 JSON
```
