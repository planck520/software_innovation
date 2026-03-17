# 代码执行服务动态Wrapper修复计划

## 问题概述
当前 `code_execution_service.dart` 中的wrapper代码是硬编码的，只支持"两数之和"题目的 `Solution.twoSum(nums, target)` 调用。其他题目使用不同的函数签名和输入格式，导致无法正确执行。

## 题目类型分析

### 类型1：类方法（两数之和）
```python
class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
```
- 输入：`[2,7,11,15]\n9`（2行：JSON数组 + 整数）
- 输出：`[0,1]`（JSON数组）

### 类型2：单参数函数（无重复字符的最长子串）
```python
def lengthOfLongestSubstring(s):
```
- 输入：`abcabcbb`（1行：字符串）
- 输出：`3`（整数）

### 类型3：单参数函数（最大子数组和）
```python
def maxSubArray(nums):
```
- 输入：`[-2,1,-3,4,-1,2,1,-5,4]`（1行：JSON数���）
- 输出：`6`（整数）

## 修复方案

### 核心思路
从题目的 `template` 中解析函数签名，从 `testCases` 中推断输入格式，动态生成wrapper代码。

---

## 实施检查清单

### 1. 在 `code_execution_service.dart` 中添加数据类

**文件**: `D:\software_innovation\lib\services\code_execution_service.dart`

**位置**: 在 `ExecutionResult` 类之后添加

**添加内容**:
```dart
/// 函数签名信息
class _FunctionSignature {
  final String? className;      // 类名，如 "Solution"
  final String functionName;     // 函数名，如 "twoSum"
  final List<String> parameters; // 参数名列表，如 ["nums", "target"]

  _FunctionSignature({
    this.className,
    required this.functionName,
    required this.parameters,
  });

  /// 是否为类方法
  bool get isClassMethod => className != null;
}

/// 参数类型
enum _ParameterType {
  string,      // 字符串
  int,         // 整数
  jsonArray,   // JSON数组（解析为List）
  unknown,     // 未知类型
}
```

---

### 2. 添加函数签名解析方法

**文件**: `D:\software_innovation\lib\services\code_execution_service.dart`

**位置**: 在 `_wrapCode` 方法之前添加

**方法签名**:
```dart
/// 从template中解析函数签名
static _FunctionSignature _parseFunctionSignature(String template, String language)
```

**实现逻辑**:
- 使用正则表达式匹配函数定义
- Python: `r'class\s+(\w+).*?:\s*def\s+(\w+)\s*\(\s*self\s*,\s*(.*?)\s*\)'` 或 `r'def\s+(\w+)\s*\((.*?)\)'`
- JavaScript: `r'class\s+(\w+).*?{\s*\n\s*(?:\w+\s+)?(\w+)\s*\((.*?)\)'` 或 `r'function\s+(\w+)\s*\((.*?)\)'`
- C++: `r'class\s+(\w+).*?{\s*public:.*?(\w+)\s+(\w+)\s*\((.*?)\)'`
- 提取类名（如果有）、函数名、参数名
- 返回 `_FunctionSignature` 对象

---

### 3. 添加输入格式推断方法

**文件**: `D:\software_innovation\lib\services\code_execution_service.dart`

**位置**: 在 `_parseFunctionSignature` 方法之后添加

**方法签名**:
```dart
/// 从testCases推断参数类型
static List<_ParameterType> _inferParameterTypes(
  List<Map<String, String>> testCases,
  int paramCount,
  String language,
)
```

**实现逻辑**:
- 获取第一个测试用例的input
- 按行分割：`lines = input.split('\n')`
- 根据参数数量和行数推断：
  - 如果 `lines.length >= paramCount`：每行对应一个参数
  - 如果 `lines.length < paramCount`：需要解析JSON
- 对每个参数推断类型：
  - 如果行以 `[` 开头：`jsonArray`
  - 如果可以解析为整数：`int`
  - 否则：`string`
- 返回 `List<_ParameterType>`

---

### 4. 修改 `_wrapCode` 方法

**文件**: `D:\software_innovation\lib\services\code_execution_service.dart`

**当前签名**:
```dart
static String _wrapCode(String code, String language)
```

**修改为**:
```dart
static String _wrapCode(
  String code,
  String language, {
  _FunctionSignature? functionSignature,
  List<_ParameterType>? parameterTypes,
})
```

**修改逻辑**:
- 如果提供了 `functionSignature` 和 `parameterTypes`，使用动态wrapper
- 否则使用原有逻辑（向后兼容）

---

### 5. 重写 `_wrapPythonCode` 方法

**文件**: `D:\software_innovation\lib\services\code_execution_service.dart`

**修改签名**:
```dart
static String _wrapPythonCode(
  String code, {
  _FunctionSignature? functionSignature,
  List<_ParameterType>? parameterTypes,
})
```

**修改实现**:
```dart
static String _wrapPythonCode(
  String code, {
  _FunctionSignature? functionSignature,
  List<_ParameterType>? parameterTypes,
}) {
  // 如果没有提供函数签名，使用默认逻辑（两数之和）
  if (functionSignature == null) {
    return _wrapPythonCodeDefault(code);
  }

  final className = functionSignature.className;
  final functionName = functionSignature.functionName;
  final parameters = functionSignature.parameters;
  final types = parameterTypes ?? List.generate(parameters.length, (_) => _ParameterType.unknown);

  // 生成参数解析代码
  String parseCode = '';
  for (int i = 0; i < parameters.length; i++) {
    final paramName = parameters[i];
    final type = types[i];

    if (i == 0) {
      parseCode += "    lines = sys.stdin.read().strip().split('\\n')\n";
    }

    if (parameters.length == 1 && lines.length == 1) {
      // 单参数单行输入
      parseCode += _generateSingleLineParse(paramName, type);
    } else if (lines.length >= parameters.length) {
      // 多行输入，每行一个参数
      parseCode += _generateMultiLineParse(paramName, i, type);
    }
  }

  // 生成函数调用代码
  String callCode;
  if (className != null) {
    callCode = '''
    solution = $className()
    result = solution.$functionName(${parameters.join(', ')})
''';
  } else {
    callCode = '''
    result = $functionName(${parameters.join(', ')})
''';
  }

  // 生成输出代码
  String outputCode = '''    print(json.dumps(result, separators=(',', ':')))''';

  return '''
import sys
import json
from typing import List

$code

if __name__ == "__main__":
    try:
$parseCode
$callCode$outputCode
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
''';
}
```

---

### 6. 修改 `_executeWithTestCases` 方法

**文件**: `D:\software_innovation\lib\services\code_execution_service.dart`

**当前实现**:
```dart
static Future<ExecutionResult> _executeWithTestCases(
  String code,
  String language,
  int languageId,
  List<Map<String, String>> testCases,
) async {
  // 包装代码以自动调用Solution类方法
  final wrappedCode = _wrapCode(code, language);
  // ...
}
```

**修改为**:
```dart
static Future<ExecutionResult> _executeWithTestCases(
  String code,
  String language,
  int languageId,
  List<Map<String, String>> testCases, {
  String? template,  // 新增：题目模板
}) async {
  // 如果提供了template，解析函数签名和参数类型
  _FunctionSignature? functionSignature;
  List<_ParameterType>? parameterTypes;

  if (template != null && template.isNotEmpty) {
    functionSignature = _parseFunctionSignature(template, language);
    if (functionSignature != null) {
      parameterTypes = _inferParameterTypes(
        testCases,
        functionSignature.parameters.length,
        language,
      );
    }
  }

  // 使用动态wrapper包装代码
  final wrappedCode = _wrapCode(
    code,
    language,
    functionSignature: functionSignature,
    parameterTypes: parameterTypes,
  );

  // ... 其余逻辑保持不变
}
```

---

### 7. 修改 `executeCode` 方法

**文件**: `D:\software_innovation\lib\services\code_execution_service.dart`

**当前签名**:
```dart
static Future<ExecutionResult> executeCode({
  required String code,
  required String language,
  String? stdin,
  String? expectedOutput,
  List<Map<String, String>>? testCases,
}) async
```

**修改为**:
```dart
static Future<ExecutionResult> executeCode({
  required String code,
  required String language,
  String? stdin,
  String? expectedOutput,
  List<Map<String, String>>? testCases,
  String? template,  // 新增：题目模板
}) async
```

**修改实现**:
在调用 `_executeWithTestCases` 时传递 `template`:
```dart
if (testCases != null && testCases.isNotEmpty) {
  return await _executeWithTestCases(
    code,
    language,
    languageId,
    testCases,
    template: template,  // 传递template
  );
}
```

---

### 8. 修改 `code_editor_page.dart` 传递template

**文件**: `D:\software_innovation\lib\pages\code_editor_page.dart`

**位置1**: `_runCode` 方法（第862行）

**当前代码**:
```dart
final result = await CodeExecutionService.executeCode(
  code: _codeController.text,
  language: _selectedLanguage,
  testCases: testCases,
);
```

**修改为**:
```dart
final result = await CodeExecutionService.executeCode(
  code: _codeController.text,
  language: _selectedLanguage,
  testCases: testCases,
  template: widget.question['template'],  // 添加template参数
);
```

**位置2**: `_submitCode` 方法（第899行）

**当前代码**:
```dart
final result = await CodeExecutionService.executeCode(
  code: _codeController.text,
  language: _selectedLanguage,
  testCases: testCases,
);
```

**修改为**:
```dart
final result = await CodeExecutionService.executeCode(
  code: _codeController.text,
  language: _selectedLanguage,
  testCases: testCases,
  template: widget.question['template'],  // 添加template参数
);
```

---

### 9. 添加辅助方法（可选优化）

**文件**: `D:\software_innovation\lib\services\code_execution_service.dart`

**位置**: 在 `_wrapPythonCode` 方法之后添加

**添加内容**:
```dart
/// 生成单行输入的解析代码
static String _generateSingleLineParse(String paramName, _ParameterType type) {
  switch (type) {
    case _ParameterType.jsonArray:
      return "    $paramName = json.loads(lines[0]) if lines[0].strip() else []\n";
    case _ParameterType.int:
      return "    $paramName = int(lines[0]) if lines[0].strip() else 0\n";
    case _ParameterType.string:
    default:
      return "    $paramName = lines[0].strip()\n";
  }
}

/// 生成多行输入的解析代码
static String _generateMultiLineParse(String paramName, int index, _ParameterType type) {
  switch (type) {
    case _ParameterType.jsonArray:
      return "    $paramName = json.loads(lines[$index]) if len(lines) > $index and lines[$index].strip() else []\n";
    case _ParameterType.int:
      return "    $paramName = int(lines[$index]) if len(lines) > $index and lines[$index].strip() else 0\n";
    case _ParameterType.string:
    default:
      return "    $paramName = lines[$index].strip() if len(lines) > $index else ''\n";
  }
}
```

---

### 10. 保留默认wrapper方法（向后兼容）

**文件**: `D:\software_innovation\lib\services\code_execution_service.dart`

**将原有的 `_wrapPythonCode` 重命名为** `_wrapPythonCodeDefault`

**类似地修改其他语言的wrapper方法**:
- `_wrapJavaScriptCode` → `_wrapJavaScriptCodeDefault`
- `_wrapCppCode` → `_wrapCppCodeDefault`

---

## 验证步骤

1. **测试两数之和**（类方法，多参数）
   - 输入：`[2,7,11,15]\n9`
   - 预期输出：`[0,1]`

2. **测试无重复字符的最长子串**（函数，单参数字符串）
   - 输入：`abcabcbb`
   - 预期输出：`3`

3. **测试最大子数组和**（函数，单参数JSON数组）
   - 输入：`[-2,1,-3,4,-1,2,1,-5,4]`
   - 预期输出：`6`

4. **测试斐波那契数列**（函数，单参数整数）
   - 输入：`2`
   - 预期输出：`1`

5. **测试所有题目的运行和提交功能**

---

## 注意事项

1. **向后兼容**：保留默认wrapper方法，确保没有template的旧代码仍能运行
2. **错误处理**：如果解析失败，回退到默认wrapper
3. **类型推断准确性**：基于第一个测试用例推断，可能需要优化
4. **支持更多语言**：当前优先实现Python，JavaScript和C++可后续实现
5. **性能考虑**：解析操作在每个测试用例执行前进行，可能需要缓存

---

## 最终动作

修改完成后，运行应用程序并测试所有题目的代码执行功能，确保所有题目都能正确通过测试用例。
