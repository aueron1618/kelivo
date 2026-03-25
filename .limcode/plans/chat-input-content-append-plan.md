## TODO LIST

<!-- LIMCODE_TODO_LIST_START -->
- [ ] 在 SettingsProvider 新增按会话内容追加 map 的加载、查询、写入与持久化  `#pc-1`
- [ ] 新增桌面/移动内容追加弹窗，支持回填与保存当前会话追加文本  `#pc-2`
- [ ] 在 ChatInputBar/ChatInputSection/HomePage 接入内容追加按钮与当前会话激活态  `#pc-3`
- [ ] 在 HomePageController 增加 editContentAppendForCurrentConversation 入口并完成回调绑定  `#pc-4`
- [ ] 在 MessageGenerationService/MessageBuilderService 按当前会话注入最后一条 user 的追加内容（仅请求内存）  `#pc-5`
- [ ] 补齐 4 个 ARB + flutter gen-l10n + format/analyze/test + 按会话场景验收  `#pc-6`
<!-- LIMCODE_TODO_LIST_END -->

# 聊天输入栏“内容追加”按会话持久化（实施计划）

## 1. 目标（更新后）

- 在输入栏增加“内容追加”入口（交互与编辑消息弹窗一致）。
- 追加内容 **按会话保存**（`conversationId -> appendText`），重启后可恢复。
- 仅在请求阶段注入到“最后一条 user 消息”。
- 不写入 `ChatMessage.content`，不在历史消息 UI 展示。

---

## 2. 存储设计（按会话）

### 2.1 SettingsProvider 持久化结构

在 `lib/core/providers/settings_provider.dart` 新增：

- key（示例）：`chat_input_content_append_by_conversation_v1`
- 字段：`Map<String, String> _chatInputContentAppendByConversation = <String, String>{};`
- 读取方法：
  - `String chatInputContentAppendForConversation(String? conversationId)`
  - `bool hasChatInputContentAppendForConversation(String? conversationId)`
- 写入方法：
  - `Future<void> setChatInputContentAppendForConversation(String conversationId, String value)`
  - 约定：`value.trim().isEmpty` 时从 map 删除该会话键（视为清空）

### 2.2 加载与序列化

在 `_load()` 中：
- 从 SharedPreferences 读取 JSON map；
- 做安全 decode（异常回退为空 map）；
- value 统一转 String，过滤空 key。

在 setter 中：
- 内存更新 + `notifyListeners()`；
- `prefs.setString(key, jsonEncode(map))` 持久化。

> 不改 Hive 模型，避免 DB schema 迁移。

---

## 3. UI 与交互接入

### 3.1 输入栏按钮接入

修改：
- `lib/features/home/widgets/chat_input_bar.dart`
- `lib/features/home/widgets/chat_input_section.dart`
- `lib/features/home/pages/home_page.dart`

新增参数透传：
- `VoidCallback? onEditContentAppend`
- `bool contentAppendActive`
- （可选）`String? currentConversationId`（在 ChatInputSection 计算 active 时使用）

实现：
- 在 `_buildResponsiveLeftActions` 增加 `_OverflowAction`（图标+tooltip+overflow 菜单项）；
- active 逻辑：当前会话 `appendText.trim().isNotEmpty`。

### 3.2 编辑弹窗（复用现有视觉风格）

新增：
- `lib/desktop/message_append_dialog.dart`
- `lib/features/chat/widgets/message_append_sheet.dart`

行为：
- 打开时回填“当前会话”的已保存追加内容；
- 保存后写回当前会话；
- 空字符串即清空该会话追加内容。

---

## 4. 控制器层：按当前会话编辑

修改：
- `lib/features/home/controllers/home_page_controller.dart`

新增方法（示例）：
- `Future<void> editContentAppendForCurrentConversation()`

逻辑：
1. 获取 `currentConversation?.id`；
2. 若为空（极端场景）可先创建草稿会话再继续；
3. 读取 `SettingsProvider` 中该会话的追加内容作为弹窗初值；
4. 弹窗返回后调用 `setChatInputContentAppendForConversation` 保存；
5. 不改动输入框正文，不影响发送附件状态。

---

## 5. 请求注入（只改 API 内存消息）

修改：
- `lib/features/home/services/message_generation_service.dart`
- `lib/features/home/services/message_builder_service.dart`

实现策略：
1. 在 `prepareApiMessagesWithInjections(...)` 里根据 `currentConversation?.id` 读取该会话 appendText；
2. 通过新增参数传入 `processUserMessagesForApi(...)`（例如 `contentAppendText`）；
3. 在 `MessageBuilderService` 内复用 `lastUserIdx`：
   - 仅对最后一条 user 内容拼接 appendText；
   - 建议在 message template 前拼接，使模板统一包裹“用户文本+追加文本”；
4. 只改 `apiMessages` 临时对象，不回写数据库消息。

这样 send 与 regenerate 都会走同一注入路径，行为一致。

---

## 6. 文案与国际化

更新 4 个 ARB：
- `lib/l10n/app_en.arb`
- `lib/l10n/app_zh.arb`
- `lib/l10n/app_zh_Hans.arb`
- `lib/l10n/app_zh_Hant.arb`

建议键：
- `chatInputBarContentAppendTooltip`
- `contentAppendPageTitle`
- `contentAppendPageHint`

执行：
- `flutter gen-l10n`

---

## 7. 验收重点（按会话）

1. 会话 A 设置追加内容 `\n\n要求A`，发送时生效；
2. 切到会话 B，默认无追加或显示 B 自己保存值；
3. 回到 A，追加内容仍在；
4. 重启应用后，A/B 各自追加内容仍正确恢复；
5. 历史消息列表不展示追加文本；
6. DB 中用户消息 content 不被追加内容污染。

---

## 8. 风险与控制

- 风险：注入到错误消息
  - 控制：仅 `lastUserIdx`。
- 风险：误落库
  - 控制：仅修改 `apiMessages`。
- 风险：无当前会话时编辑失败
  - 控制：空会话兜底（创建草稿或禁用按钮并提示，二选一）。
- 风险：会话删除后残留无效键
  - 控制：可作为增强项，在删除会话路径补充清理（P1，可后续补）。
