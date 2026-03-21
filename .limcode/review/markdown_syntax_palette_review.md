# Markdown语法色盘与强调解析回归审查
- Date: 2026-03-21
- Overview: 定位并修复粗体解析异常（首字符与冒号丢失）
- Status: in_progress

## Review Scope
# Markdown语法色盘与强调解析回归审查

- 日期：2026-03-21
- 范围：`lib/shared/widgets/markdown_with_highlight.dart`
- 目标：确认并修复 `**bold**` 渲染异常（用户反馈“**我是粗体**：就是很粗”显示为“是粗体就是很粗”）

### 初始结论
已提供可快速执行的针对性测试入口，用于高频验证粗体/斜体/斜粗体/引号解析回归。

## Review Summary
<!-- LIMCODE_REVIEW_SUMMARY_START -->
- Current status: in_progress
- Reviewed modules: lib/shared/widgets/markdown_with_highlight.dart, test/desktop_provider_grouping_compile_test.dart
- Current progress: 3 milestones recorded; latest: m3
- Total milestones: 3
- Completed milestones: 3
- Total findings: 6
- Findings by severity: high 0 / medium 2 / low 4
- Latest conclusion: 已提供可快速执行的针对性测试入口，用于高频验证粗体/斜体/斜粗体/引号解析回归。
- Recommended next action: 本地执行：`flutter test test/desktop_provider_grouping_compile_test.dart -r expanded`。
- Overall decision: pending
<!-- LIMCODE_REVIEW_SUMMARY_END -->

## Review Findings
<!-- LIMCODE_REVIEW_FINDINGS_START -->
- [low] other: 原实现在 inline 命中时直接返回强调片段，潜在会在某些解析调用路径中丢失匹配前后文本。
  - ID: F-原实现在-inline-命中时直接返回强调片段-潜在会在某些解析调用路径中丢失匹配前后文本
  - Evidence Files:
    - `lib/shared/widgets/markdown_with_highlight.dart`
  - Related Milestones: m1

- [medium] javascript: Markdown inline 自定义强调解析存在文本片段丢失风险
  - ID: F-001
  - Description: 强调语法命中后仅返回命中主体，未显式合并前后文本；在特定调用路径下可导致字符丢失。
  - Evidence Files:
    - `lib/shared/widgets/markdown_with_highlight.dart`
  - Related Milestones: m1
  - Recommendation: 对命中结果统一做前后文本合并，或确保引擎仅向 span 传入纯命中片段。

- [low] other: 强调语法规则若未限制相邻分隔符，可能在组件匹配顺序变化时出现错配。
  - ID: F-强调语法规则若未限制相邻分隔符-可能在组件匹配顺序变化时出现错配
  - Evidence Files:
    - `lib/shared/widgets/markdown_with_highlight.dart`
  - Related Milestones: m2

- [medium] javascript: 强调分隔符边界约束不足会引发顺序相关错配
  - ID: F-002
  - Description: 当 `***` / `**` / `*` 规则同时存在时，若未限制分隔符邻接边界，解析器遍历顺序变化可能导致错误命中，表现为粗体失效或局部吞字。
  - Evidence Files:
    - `lib/shared/widgets/markdown_with_highlight.dart`
  - Related Milestones: m2
  - Recommendation: 为强弱强调规则添加邻接分隔符边界，避免低优先级规则误吞高优先级标记。

- [low] other: 此前缺少可快速复现强调解析回归的最小测试入口，导致每次需人工页面验证。
  - ID: F-此前缺少可快速复现强调解析回归的最小测试入口-导致每次需人工页面验证
  - Evidence Files:
    - `test/desktop_provider_grouping_compile_test.dart`
  - Related Milestones: m3

- [low] test: 缺少针对强调语法的轻量回归测试
  - ID: F-003
  - Description: 解析相关回归只能靠手工界面验证，反馈回路慢且易遗漏边界场景。
  - Evidence Files:
    - `test/desktop_provider_grouping_compile_test.dart`
  - Related Milestones: m3
  - Recommendation: 保留单文件快速回归测试命令，作为每次解析规则调整后的必跑项。
<!-- LIMCODE_REVIEW_FINDINGS_END -->

## Review Milestones
<!-- LIMCODE_REVIEW_MILESTONES_START -->
### m1 · 定位粗体语法字符丢失并完成解析器稳健化修复
- Status: completed
- Recorded At: 2026-03-21T04:23:39.489Z
- Reviewed Modules: lib/shared/widgets/markdown_with_highlight.dart
- Summary:
在 `lib/shared/widgets/markdown_with_highlight.dart` 的自定义 inline 强调解析中，确认 `**...**` 路径存在文本片段丢失风险。已完成两类修复：

1. **正则稳健化**：将强调匹配从回溯/反向引用方案改为更明确的分支匹配（`***`/`___`、`**`/`__`、`*`/`_`），降低边界场景吞字风险。
2. **保留前后文本**：新增 `_mergeSyntaxSpanWithSurroundingText(...)`，在命中语法时显式保留 `match` 前后文本，避免引擎在传入大文本片段时丢失前缀/后缀（对应用户反馈中首字符与冒号消失问题）。

同时将粗体、斜体、斜粗体、引号四类语法组件统一接入该合并函数。
- Conclusion: 已完成针对粗体异常的定向修复，修复点覆盖了“匹配边界”和“周边文本保留”两个维度。
- Evidence Files:
  - `lib/shared/widgets/markdown_with_highlight.dart`
- Recommended Next Action: 请在本地执行回归验证：`**我是粗体**：就是很粗`、`*斜体*`、`***斜粗体***`、以及中英文引号样例。
- Findings:
  - [low] other: 原实现在 inline 命中时直接返回强调片段，潜在会在某些解析调用路径中丢失匹配前后文本。
  - [medium] javascript: Markdown inline 自定义强调解析存在文本片段丢失风险

### m2 · 加固强调语法边界并降低组件顺序冲突风险
- Status: completed
- Recorded At: 2026-03-21T04:31:42.407Z
- Reviewed Modules: lib/shared/widgets/markdown_with_highlight.dart
- Summary:
继续排查“粗体仍异常”的隐藏原因后，对强调语法解析进行了第二轮加固：

- `MarkdownBoldItalicSyntaxMd` / `MarkdownBoldSyntaxMd` 正则增加分隔符边界约束，避免在 `***`、`**`、`__` 相邻分隔符场景被误匹配（例如顺序冲突导致 `**` 提前吞噬 `***`）。
- 保留并统一使用 `_mergeSyntaxSpanWithSurroundingText(...)`，确保命中语法时前后文本不会被丢弃。
- 维持 `MarkdownItalicSyntaxMd` 的单分隔符约束，降低与粗体规则互相踩踏的概率。

本轮改动目标是把潜在“解析器执行顺序不确定”对结果的影响降到最小，避免在不同引擎执行路径下出现吞字或标点丢失。
- Conclusion: 强调解析在边界与顺序容错方面已二次加固，理论上可覆盖用户报告的粗体异常路径。
- Evidence Files:
  - `lib/shared/widgets/markdown_with_highlight.dart`
- Recommended Next Action: 请完整重启应用后回归：`**我是粗体**：就是很粗`、`内容：**我是粗体**：就是很粗`、`***A***`、`**A** **B**`。
- Findings:
  - [low] other: 强调语法规则若未限制相邻分隔符，可能在组件匹配顺序变化时出现错配。
  - [medium] javascript: 强调分隔符边界约束不足会引发顺序相关错配

### m3 · 增加快速脚本化回归用例（无需整包构建）
- Status: completed
- Recorded At: 2026-03-21T04:41:24.752Z
- Reviewed Modules: test/desktop_provider_grouping_compile_test.dart
- Summary:
为减少反复构建成本，已将 Markdown 强调语法的快速回归用例加入现有测试入口：`test/desktop_provider_grouping_compile_test.dart`。新增覆盖点：

- `**我是粗体**` 中文标点边界回归（验证匹配范围与替换后前后文本保持）。
- `***...***` 由 `boldItalic` 命中，`bold` 不应误命中。
- `*...*` 不应误吞 `**...**`。
- 直引号与中文引号双路径匹配。

该用例可单文件执行，避免每次都跑完整构建链。
- Conclusion: 已提供可快速执行的针对性测试入口，用于高频验证粗体/斜体/斜粗体/引号解析回归。
- Evidence Files:
  - `test/desktop_provider_grouping_compile_test.dart`
- Recommended Next Action: 本地执行：`flutter test test/desktop_provider_grouping_compile_test.dart -r expanded`。
- Findings:
  - [low] other: 此前缺少可快速复现强调解析回归的最小测试入口，导致每次需人工页面验证。
  - [low] test: 缺少针对强调语法的轻量回归测试
<!-- LIMCODE_REVIEW_MILESTONES_END -->

<!-- LIMCODE_REVIEW_METADATA_START -->
{
  "formatVersion": 3,
  "reviewRunId": "review-mmztja5o-j7aayq",
  "createdAt": "2026-03-21T00:00:00.000Z",
  "finalizedAt": null,
  "status": "in_progress",
  "overallDecision": null,
  "latestConclusion": "已提供可快速执行的针对性测试入口，用于高频验证粗体/斜体/斜粗体/引号解析回归。",
  "recommendedNextAction": "本地执行：`flutter test test/desktop_provider_grouping_compile_test.dart -r expanded`。",
  "reviewedModules": [
    "lib/shared/widgets/markdown_with_highlight.dart",
    "test/desktop_provider_grouping_compile_test.dart"
  ],
  "milestones": [
    {
      "id": "m1",
      "title": "定位粗体语法字符丢失并完成解析器稳健化修复",
      "summary": "在 `lib/shared/widgets/markdown_with_highlight.dart` 的自定义 inline 强调解析中，确认 `**...**` 路径存在文本片段丢失风险。已完成两类修复：\n\n1. **正则稳健化**：将强调匹配从回溯/反向引用方案改为更明确的分支匹配（`***`/`___`、`**`/`__`、`*`/`_`），降低边界场景吞字风险。\n2. **保留前后文本**：新增 `_mergeSyntaxSpanWithSurroundingText(...)`，在命中语法时显式保留 `match` 前后文本，避免引擎在传入大文本片段时丢失前缀/后缀（对应用户反馈中首字符与冒号消失问题）。\n\n同时将粗体、斜体、斜粗体、引号四类语法组件统一接入该合并函数。",
      "status": "completed",
      "conclusion": "已完成针对粗体异常的定向修复，修复点覆盖了“匹配边界”和“周边文本保留”两个维度。",
      "evidenceFiles": [
        "lib/shared/widgets/markdown_with_highlight.dart"
      ],
      "reviewedModules": [
        "lib/shared/widgets/markdown_with_highlight.dart"
      ],
      "recommendedNextAction": "请在本地执行回归验证：`**我是粗体**：就是很粗`、`*斜体*`、`***斜粗体***`、以及中英文引号样例。",
      "recordedAt": "2026-03-21T04:23:39.489Z",
      "findingIds": [
        "F-原实现在-inline-命中时直接返回强调片段-潜在会在某些解析调用路径中丢失匹配前后文本",
        "F-001"
      ]
    },
    {
      "id": "m2",
      "title": "加固强调语法边界并降低组件顺序冲突风险",
      "summary": "继续排查“粗体仍异常”的隐藏原因后，对强调语法解析进行了第二轮加固：\n\n- `MarkdownBoldItalicSyntaxMd` / `MarkdownBoldSyntaxMd` 正则增加分隔符边界约束，避免在 `***`、`**`、`__` 相邻分隔符场景被误匹配（例如顺序冲突导致 `**` 提前吞噬 `***`）。\n- 保留并统一使用 `_mergeSyntaxSpanWithSurroundingText(...)`，确保命中语法时前后文本不会被丢弃。\n- 维持 `MarkdownItalicSyntaxMd` 的单分隔符约束，降低与粗体规则互相踩踏的概率。\n\n本轮改动目标是把潜在“解析器执行顺序不确定”对结果的影响降到最小，避免在不同引擎执行路径下出现吞字或标点丢失。",
      "status": "completed",
      "conclusion": "强调解析在边界与顺序容错方面已二次加固，理论上可覆盖用户报告的粗体异常路径。",
      "evidenceFiles": [
        "lib/shared/widgets/markdown_with_highlight.dart"
      ],
      "reviewedModules": [
        "lib/shared/widgets/markdown_with_highlight.dart"
      ],
      "recommendedNextAction": "请完整重启应用后回归：`**我是粗体**：就是很粗`、`内容：**我是粗体**：就是很粗`、`***A***`、`**A** **B**`。",
      "recordedAt": "2026-03-21T04:31:42.407Z",
      "findingIds": [
        "F-强调语法规则若未限制相邻分隔符-可能在组件匹配顺序变化时出现错配",
        "F-002"
      ]
    },
    {
      "id": "m3",
      "title": "增加快速脚本化回归用例（无需整包构建）",
      "summary": "为减少反复构建成本，已将 Markdown 强调语法的快速回归用例加入现有测试入口：`test/desktop_provider_grouping_compile_test.dart`。新增覆盖点：\n\n- `**我是粗体**` 中文标点边界回归（验证匹配范围与替换后前后文本保持）。\n- `***...***` 由 `boldItalic` 命中，`bold` 不应误命中。\n- `*...*` 不应误吞 `**...**`。\n- 直引号与中文引号双路径匹配。\n\n该用例可单文件执行，避免每次都跑完整构建链。",
      "status": "completed",
      "conclusion": "已提供可快速执行的针对性测试入口，用于高频验证粗体/斜体/斜粗体/引号解析回归。",
      "evidenceFiles": [
        "test/desktop_provider_grouping_compile_test.dart"
      ],
      "reviewedModules": [
        "test/desktop_provider_grouping_compile_test.dart"
      ],
      "recommendedNextAction": "本地执行：`flutter test test/desktop_provider_grouping_compile_test.dart -r expanded`。",
      "recordedAt": "2026-03-21T04:41:24.752Z",
      "findingIds": [
        "F-此前缺少可快速复现强调解析回归的最小测试入口-导致每次需人工页面验证",
        "F-003"
      ]
    }
  ],
  "findings": [
    {
      "id": "F-原实现在-inline-命中时直接返回强调片段-潜在会在某些解析调用路径中丢失匹配前后文本",
      "severity": "low",
      "category": "other",
      "title": "原实现在 inline 命中时直接返回强调片段，潜在会在某些解析调用路径中丢失匹配前后文本。",
      "description": null,
      "evidenceFiles": [
        "lib/shared/widgets/markdown_with_highlight.dart"
      ],
      "relatedMilestoneIds": [
        "m1"
      ],
      "recommendation": null
    },
    {
      "id": "F-001",
      "severity": "medium",
      "category": "javascript",
      "title": "Markdown inline 自定义强调解析存在文本片段丢失风险",
      "description": "强调语法命中后仅返回命中主体，未显式合并前后文本；在特定调用路径下可导致字符丢失。",
      "evidenceFiles": [
        "lib/shared/widgets/markdown_with_highlight.dart"
      ],
      "relatedMilestoneIds": [
        "m1"
      ],
      "recommendation": "对命中结果统一做前后文本合并，或确保引擎仅向 span 传入纯命中片段。"
    },
    {
      "id": "F-强调语法规则若未限制相邻分隔符-可能在组件匹配顺序变化时出现错配",
      "severity": "low",
      "category": "other",
      "title": "强调语法规则若未限制相邻分隔符，可能在组件匹配顺序变化时出现错配。",
      "description": null,
      "evidenceFiles": [
        "lib/shared/widgets/markdown_with_highlight.dart"
      ],
      "relatedMilestoneIds": [
        "m2"
      ],
      "recommendation": null
    },
    {
      "id": "F-002",
      "severity": "medium",
      "category": "javascript",
      "title": "强调分隔符边界约束不足会引发顺序相关错配",
      "description": "当 `***` / `**` / `*` 规则同时存在时，若未限制分隔符邻接边界，解析器遍历顺序变化可能导致错误命中，表现为粗体失效或局部吞字。",
      "evidenceFiles": [
        "lib/shared/widgets/markdown_with_highlight.dart"
      ],
      "relatedMilestoneIds": [
        "m2"
      ],
      "recommendation": "为强弱强调规则添加邻接分隔符边界，避免低优先级规则误吞高优先级标记。"
    },
    {
      "id": "F-此前缺少可快速复现强调解析回归的最小测试入口-导致每次需人工页面验证",
      "severity": "low",
      "category": "other",
      "title": "此前缺少可快速复现强调解析回归的最小测试入口，导致每次需人工页面验证。",
      "description": null,
      "evidenceFiles": [
        "test/desktop_provider_grouping_compile_test.dart"
      ],
      "relatedMilestoneIds": [
        "m3"
      ],
      "recommendation": null
    },
    {
      "id": "F-003",
      "severity": "low",
      "category": "test",
      "title": "缺少针对强调语法的轻量回归测试",
      "description": "解析相关回归只能靠手工界面验证，反馈回路慢且易遗漏边界场景。",
      "evidenceFiles": [
        "test/desktop_provider_grouping_compile_test.dart"
      ],
      "relatedMilestoneIds": [
        "m3"
      ],
      "recommendation": "保留单文件快速回归测试命令，作为每次解析规则调整后的必跑项。"
    }
  ]
}
<!-- LIMCODE_REVIEW_METADATA_END -->
