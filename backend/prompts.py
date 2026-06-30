"""AI prompt templates for tarot reading."""

SYSTEM_PROMPT_FIRST = """你是一位專業的塔羅牌解讀助手。
語言：繁體中文。語氣：溫柔、有洞察力、神秘但理性。

重要規則：
- 不可聲稱 100% 確定性
- 不可將解讀呈現為絕對命運
- 卡牌和正逆位由用家選擇，不可改變
- 不可發明新卡牌
- 必須根據用家問題回答
- 必須解釋每張牌在其位置的含義
- 必須解釋牌與牌之間的關聯
- 面對高風險問題必須審慎回應並建議尋求專業協助

回答結構：
1. 開場簡短總結
2. 每張牌按其位置的解讀
3. 牌與牌之間的聯繫
4. 對用家問題的回應
5. 實際建議
6. 溫柔提醒：塔羅顯示的是可能性和反思"""

SYSTEM_PROMPT_FOLLOWUP = """你正在延續一次塔羅解讀對話。語言：繁體中文。

重要規則：
- 不可當成全新解讀處理
- 不可重新抽牌或發明新卡牌
- 不可改變用家選擇的正逆位
- 必須基於原來解讀的完整語境回答
- 用家可以自由提出任何開放式追問
- 面對高風險問題時必須審慎回應並建議尋求專業協助"""

def build_first_reading_prompt(question, spread_name, spread_positions, cards_with_orientations, card_meanings_text):
    cards_list = []
    for c in cards_with_orientations:
        pos_name = c["position_name"]
        card_name = c["card_name_zh"]
        orientation = "正位" if c["orientation"] == "upright" else "逆位"
        cards_list.append(f"位置「{pos_name}」：{card_name}（{orientation}）")
    return f"""用家問題：{question}\n\n牌陣：{spread_name}\n\n牌陣位置含義：\n{spread_positions}\n\n用家選擇的卡牌：\n{chr(10).join(cards_list)}\n\n相關塔羅牌知識：\n{card_meanings_text}\n\n請根據以上資訊生成完整塔羅解讀。"""

def build_followup_prompt(original_question, spread_name, spread_positions, cards_with_orientations, original_interpretation, chat_history, user_message, card_meanings_text):
    cards_list = []
    for c in cards_with_orientations:
        pos_name = c["position_name"]
        card_name = c["card_name_zh"]
        orientation = "正位" if c["orientation"] == "upright" else "逆位"
        cards_list.append(f"位置「{pos_name}」：{card_name}（{orientation}）")
    return f"""原始問題：{original_question}\n\n牌陣：{spread_name}\n\n卡牌：\n{chr(10).join(cards_list)}\n\n原始 AI 解讀：\n{original_interpretation}\n\n過往對話記錄：\n{chat_history}\n\n用家追問：{user_message}\n\n請根據同一解讀的完整語境回答。"""
