import 'dart:convert';
import 'package:http/http.dart' as http;

/// 代码执行服务 - 使用Judge0 API执行代码
class CodeExecutionService {
  // Judge0 API配置 - 自建服务
  static const String _baseUrl = 'http://121.29.19.131:2358';

  // 支持的语言及其Judge0 language_id
  static const Map<String, int> languageIds = {
    'python': 71,
    'javascript': 63,
    'c': 50,
    'cpp': 54,
  };

  // 语言显示名称
  static const Map<String, String> languageNames = {
    'python': 'Python',
    'javascript': 'JavaScript',
    'c': 'C',
    'cpp': 'C++',
  };

  /// 执行代码
  /// [code] - 用户代码
  /// [language] - 语言 (python/javascript/c/cpp)
  /// [stdin] - 标准输入 (可选)
  /// [expectedOutput] - 期望输出 (用于测试)
  /// [testCases] - 测试用例列表 (可选)
  /// [template] - 题目模板 (可选)
  static Future<ExecutionResult> executeCode({
    required String code,
    required String language,
    String? stdin,
    String? expectedOutput,
    List<Map<String, String>>? testCases,
    String? template,
  }) async {
    final languageId = languageIds[language.toLowerCase()];
    if (languageId == null) {
      return ExecutionResult(
        success: false,
        output: '',
        error: '不支持的语言: $language',
        executionTime: 0,
        memoryUsage: 0,
      );
    }

    // 如果有测试用例，依次执行
    if (testCases != null && testCases.isNotEmpty) {
      return await _executeWithTestCases(
        code,
        language,
        languageId,
        testCases,
        template: template,
      );
    }

    // 单次执行
    return await _executeSingle(code, languageId, stdin);
  }

  /// 从template中解析函数签名
  static _FunctionSignature? _parseFunctionSignature(String template, String language) {
    try {
      switch (language.toLowerCase()) {
        case 'python':
          return _parsePythonSignature(template);
        case 'javascript':
          return _parseJavaScriptSignature(template);
        case 'cpp':
        case 'c':
          return _parseCppSignature(template);
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// 解析Python函数签名
  static _FunctionSignature? _parsePythonSignature(String template) {
    // 尝试匹配类方法: class Solution: def twoSum(self, nums, target)
    final classMethodPattern = RegExp(
      r'class\s+(\w+)\s*:[\s\S]*?def\s+(\w+)\s*\(\s*self\s*,\s*(.*?)\s*\)',
      caseSensitive: false,
    );
    final classMatch = classMethodPattern.firstMatch(template);
    if (classMatch != null) {
      final className = classMatch.group(1);
      final functionName = classMatch.group(2);
      final paramsStr = classMatch.group(3) ?? '';
      final parameters = _parseParameters(paramsStr);

      // 跳过特殊方法（如__init__）
      if (functionName != null && !functionName.startsWith('__')) {
        return _FunctionSignature(
          className: className,
          functionName: functionName,
          parameters: parameters,
        );
      }
    }

    // 尝试匹配普通函数: def twoSum(nums, target)
    // 找所有函数定义，选择第一个非特殊方法
    final functionPattern = RegExp(
      r'^def\s+(\w+)\s*\((.*?)\)',
      multiLine: true,
      caseSensitive: false,
    );
    final functionMatches = functionPattern.allMatches(template);

    for (final match in functionMatches) {
      final functionName = match.group(1);
      if (functionName != null && !functionName.startsWith('__')) {
        final paramsStr = match.group(2) ?? '';
        final parameters = _parseParameters(paramsStr);
        return _FunctionSignature(
          functionName: functionName,
          parameters: parameters,
        );
      }
    }

    return null;
  }

  /// 解析JavaScript函数签名
  static _FunctionSignature? _parseJavaScriptSignature(String template) {
    // 尝试匹配类方法
    final classMethodPattern = RegExp(
      r'class\s+(\w+)[\s\S]*?(\w+)\s*\((.*?)\)\s*{',
      caseSensitive: false,
    );
    final classMatch = classMethodPattern.firstMatch(template);
    if (classMatch != null) {
      final className = classMatch.group(1);
      final functionName = classMatch.group(2);
      final paramsStr = classMatch.group(3) ?? '';
      final parameters = _parseParameters(paramsStr);
      if (functionName != null) {
        return _FunctionSignature(
          className: className,
          functionName: functionName,
          parameters: parameters,
        );
      }
    }

    // 尝试匹配普通函数
    final functionPattern = RegExp(
      r'function\s+(\w+)\s*\((.*?)\)',
      caseSensitive: false,
    );
    final functionMatch = functionPattern.firstMatch(template);
    if (functionMatch != null) {
      final functionName = functionMatch.group(1)!;
      final paramsStr = functionMatch.group(2) ?? '';
      final parameters = _parseParameters(paramsStr);
      return _FunctionSignature(
        functionName: functionName,
        parameters: parameters,
      );
    }

    return null;
  }

  /// 解析C++函数签名
  static _FunctionSignature? _parseCppSignature(String template) {
    // 简化匹配，只匹配基本的类方法
    final classMethodPattern = RegExp(
      r'class\s+(\w+)[\s\S]*?(\w+)\s+(\w+)\s*\((.*?)\)',
      caseSensitive: false,
    );
    final match = classMethodPattern.firstMatch(template);
    if (match != null) {
      final className = match.group(1);
      final functionName = match.group(3);
      final paramsStr = match.group(4) ?? '';
      final parameters = _parseParameters(paramsStr);
      if (functionName != null) {
        return _FunctionSignature(
          className: className,
          functionName: functionName,
          parameters: parameters,
        );
      }
    }

    return null;
  }

  /// 解析参数字符串，提取参数名
  static List<String> _parseParameters(String paramsStr) {
    if (paramsStr.trim().isEmpty) return [];

    // 分割参数并去除类型注解
    final params = paramsStr.split(',').map((param) {
      // 移除类型注解（如 nums: List[int] -> nums）
      final parts = param.trim().split(RegExp(r'[:=]'));
      return parts[0].trim();
    }).where((param) => param.isNotEmpty).toList();

    return params;
  }

  /// 从testCases推断参数类型
  static List<_ParameterType> _inferParameterTypes(
    List<Map<String, String>> testCases,
    int paramCount,
    String language,
  ) {
    if (testCases.isEmpty || paramCount == 0) {
      return List.generate(paramCount, (_) => _ParameterType.unknown);
    }

    final firstInput = testCases[0]['input'] ?? '';
    final lines = firstInput.split('\n');

    final types = <_ParameterType>[];

    for (int i = 0; i < paramCount; i++) {
      String? line;
      if (lines.length >= paramCount) {
        // 多行输入，每行一个参数
        line = lines[i].trim();
      } else if (lines.length == 1) {
        // 单行输入，可能是JSON数组
        line = lines[0].trim();
      }

      if (line == null || line.isEmpty) {
        types.add(_ParameterType.unknown);
        continue;
      }

      // 推断类型
      if (line.startsWith('[') || line.startsWith('{')) {
        types.add(_ParameterType.jsonArray);
      } else if (int.tryParse(line) != null) {
        types.add(_ParameterType.int);
      } else if (line == 'true' || line == 'false') {
        types.add(_ParameterType.string); // 布尔值作为字符串处理
      } else {
        types.add(_ParameterType.string);
      }
    }

    return types;
  }

  /// 检查是否是LRU缓存类型的题目
  static bool _isLRUCacheQuestion(String template, String language) {
    if (language.toLowerCase() != 'python') return false;
    return template.contains('class LRUCache') &&
           template.contains('def __init__') &&
           template.contains('def get(') &&
           template.contains('def put(');
  }

  /// 为LRU缓存生成专门的wrapper
  static String _wrapPythonCodeForLRUCache(String code) {
    return '''
import sys
import json
from collections import OrderedDict

$code

# LRU缓存专用wrapper
if __name__ == "__main__":
    try:
        # 读取输入
        lines = sys.stdin.read().strip().split('\\n')
        if len(lines) < 2:
            print("[]")
            sys.exit(0)

        # 解析方法名列表
        methods = json.loads(lines[0])
        # 解析参数列表
        params = json.loads(lines[1])

        # 创建LRUCache实例
        if methods and methods[0] == "LRUCache":
            cache = LRUCache(params[0][0])
            results = [None]  # 构���函数返回null

        # 执行方法调用
        i = 1
        while i < len(methods) and i < len(params):
            method = methods[i]
            param = params[i]

            if method == "get":
                result = cache.get(param[0])
                results.append(result)
            elif method == "put":
                cache.put(param[0], param[1])
                results.append(None)

            i += 1

        # 输出结果
        print(json.dumps(results))
    except Exception as e:
        import traceback
        print(f"Error: {e}", file=sys.stderr)
        traceback.print_exc(file=sys.stderr)
''';
  }

  /// 包装代码以自动调用Solution类方法
  static String _wrapCode(
    String code,
    String language, {
    _FunctionSignature? functionSignature,
    List<_ParameterType>? parameterTypes,
    String? template,
  }) {
    // 检查代码是否已经包含main函数或wrapper，避免重复包装
    if (_isAlreadyWrapped(code, language)) {
      return code;
    }

    // 特殊处理：LRU缓存
    if (template != null && _isLRUCacheQuestion(template, language)) {
      return _wrapPythonCodeForLRUCache(code);
    }

    switch (language.toLowerCase()) {
      case 'python':
        return _wrapPythonCode(
          code,
          functionSignature: functionSignature,
          parameterTypes: parameterTypes,
        );
      case 'javascript':
        return _wrapJavaScriptCode(
          code,
          functionSignature: functionSignature,
          parameterTypes: parameterTypes,
        );
      case 'cpp':
        return _wrapCppCode(
          code,
          functionSignature: functionSignature,
          parameterTypes: parameterTypes,
        );
      case 'c':
        return _wrapCCode(code);
      default:
        return code;
    }
  }

  /// 检查代码是否已经包含wrapper或main函数
  static bool _isAlreadyWrapped(String code, String language) {
    final lowerCode = code.toLowerCase();
    switch (language.toLowerCase()) {
      case 'python':
        // 检查是否已经有if __name__ == "__main__":
        return lowerCode.contains('if __name__') ||
               lowerCode.contains('__main__');
      case 'javascript':
        // 检查是否已经有readline或main函数
        return lowerCode.contains('readline') ||
               lowerCode.contains('require(\'readline\'') ||
               lowerCode.contains('process.stdin');
      case 'cpp':
      case 'c':
        // 检查是否已经有main函数
        return lowerCode.contains('int main(') ||
               lowerCode.contains('void main(');
      default:
        return false;
    }
  }

  /// 包装Python代码（默认版本，向后兼容）
  static String _wrapPythonCodeDefault(String code) {
    return '''
import sys
import json
from typing import List

$code

# 自动添加的wrapper - 读取stdin并调用Solution类方法
if __name__ == "__main__":
    try:
        lines = sys.stdin.read().strip().split('\\n')
        if len(lines) >= 2:
            # 解析输入参数
            nums = json.loads(lines[0]) if lines[0].strip() else []
            target = int(lines[1]) if len(lines) > 1 else 0

            # 调用Solution类的方法
            solution = Solution()
            result = solution.twoSum(nums, target)
            # 使用json.dumps并指定separators，去除多余空格
            print(json.dumps(result, separators=(',', ':')))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
''';
  }

  /// 包装Python代码（动态版本）
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
    StringBuffer parseCode = StringBuffer();

    if (parameters.isNotEmpty) {
      // 定义lines变量
      parseCode.writeln("        lines = sys.stdin.read().strip().split('\\n')");

      for (int i = 0; i < parameters.length; i++) {
        final paramName = parameters[i];
        final type = types[i];

        if (parameters.length == 1) {
          // 单参数
          parseCode.writeln('        ${_generateSingleLineParsePython(paramName, type, 0)}');
        } else {
          // 多参数，每行一个参数
          parseCode.writeln('        ${_generateMultiLineParsePython(paramName, i, type)}');
        }
      }
    }

    // 生成函数调用代码
    String callCode;
    if (className != null) {
      callCode = '''
        # 调用类方法
        solution = $className()
        result = solution.$functionName(${parameters.join(', ')})
''';
    } else {
      callCode = '''
        # 调用函数
        result = $functionName(${parameters.join(', ')})
''';
    }

    return '''
import sys
import json
from typing import List

$code

# 动态生成的wrapper
if __name__ == "__main__":
    try:
$parseCode$callCode        # 输出结果
        if isinstance(result, bool):
            # 布尔值直接输出，保持Python的True/False格式
            print(str(result))
        elif isinstance(result, str):
            # 字符串直接输出
            print(result)
        else:
            # 其他类型使用JSON格式
            print(json.dumps(result, separators=(',', ':')))
    except Exception as e:
        import traceback
        print(f"Error: {e}", file=sys.stderr)
        traceback.print_exc(file=sys.stderr)
''';
  }

  /// 生成Python单行输入的解析代码
  static String _generateSingleLineParsePython(String paramName, _ParameterType type, int lineIndex) {
    switch (type) {
      case _ParameterType.jsonArray:
        return "$paramName = json.loads(lines[$lineIndex]) if len(lines) > $lineIndex and lines[$lineIndex].strip() else []";
      case _ParameterType.int:
        return "$paramName = int(lines[$lineIndex]) if len(lines) > $lineIndex and lines[$lineIndex].strip() else 0";
      case _ParameterType.string:
      default:
        return "$paramName = lines[$lineIndex].strip() if len(lines) > $lineIndex else ''";
    }
  }

  /// 生成Python多行输入的解析代码
  static String _generateMultiLineParsePython(String paramName, int index, _ParameterType type) {
    switch (type) {
      case _ParameterType.jsonArray:
        return "$paramName = json.loads(lines[$index]) if len(lines) > $index and lines[$index].strip() else []";
      case _ParameterType.int:
        return "$paramName = int(lines[$index]) if len(lines) > $index and lines[$index].strip() else 0";
      case _ParameterType.string:
      default:
        return "$paramName = lines[$index].strip() if len(lines) > $index else ''";
    }
  }

  /// 包装JavaScript代码（默认版本，向后兼容）
  static String _wrapJavaScriptCodeDefault(String code) {
    return '''
$code

// 自动添加的wrapper - 读取stdin并调用Solution类方法
const readline = require('readline');
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const lines = [];
rl.on('line', (line) => {
  lines.push(line);
}).on('close', () => {
  try {
    if (lines.length >= 2) {
      // 解析输入参数
      const nums = JSON.parse(lines[0] || '[]');
      const target = parseInt(lines[1]);

      // 调用Solution类的方法
      const solution = new Solution();
      const result = solution.twoSum(nums, target);
      // 使用JSON.stringify并移除多余空格
      const jsonStr = JSON.stringify(result);
      console.log(jsonStr.replace(/,\s+/g, ',').replace(/:\s+/g, ':'));
    }
  } catch (e) {
    console.error('Error:', e.message);
  }
});
''';
  }

  /// 包装JavaScript代码（动态版本）
  static String _wrapJavaScriptCode(
    String code, {
    _FunctionSignature? functionSignature,
    List<_ParameterType>? parameterTypes,
  }) {
    // 如果没有提供函数签名，使用默认逻辑
    if (functionSignature == null) {
      return _wrapJavaScriptCodeDefault(code);
    }

    final className = functionSignature.className;
    final functionName = functionSignature.functionName;
    final parameters = functionSignature.parameters;
    final types = parameterTypes ?? List.generate(parameters.length, (_) => _ParameterType.unknown);

    // 生成参数解析代码
    StringBuffer parseCode = StringBuffer();
    for (int i = 0; i < parameters.length; i++) {
      final paramName = parameters[i];
      final type = types[i];

      if (parameters.length == 1) {
        parseCode.writeln('    ${_generateSingleLineParseJavaScript(paramName, type, 0)}');
      } else {
        parseCode.writeln('    ${_generateMultiLineParseJavaScript(paramName, i, type)}');
      }
    }

    // 生成函数调用代码
    String callCode;
    if (className != null) {
      callCode = '''
    // 调用类方法
    const solution = new $className();
    const result = solution.$functionName(${parameters.join(', ')});
''';
    } else {
      callCode = '''
    // 调用函数
    const result = $functionName(${parameters.join(', ')});
''';
    }

    return '''
$code

// 动态生成的wrapper
const readline = require('readline');
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const lines = [];
rl.on('line', (line) => {
  lines.push(line);
}).on('close', () => {
  try {
$parseCode$callCode    // 输出结果
    const jsonStr = JSON.stringify(result);
    console.log(jsonStr.replace(/,\s+/g, ',').replace(/:\s+/g, ':'));
  } catch (e) {
    console.error('Error:', e.message);
  }
});
''';
  }

  /// 生成JavaScript单行输入的解析代码
  static String _generateSingleLineParseJavaScript(String paramName, _ParameterType type, int lineIndex) {
    switch (type) {
      case _ParameterType.jsonArray:
        return "const $paramName = JSON.parse(lines[$lineIndex] || '[]');";
      case _ParameterType.int:
        return "const $paramName = parseInt(lines[$lineIndex]);";
      case _ParameterType.string:
      default:
        return "const $paramName = lines[$lineIndex] || '';";
    }
  }

  /// 生成JavaScript多行输入的解析代码
  static String _generateMultiLineParseJavaScript(String paramName, int index, _ParameterType type) {
    switch (type) {
      case _ParameterType.jsonArray:
        return "const $paramName = JSON.parse(lines[$index] || '[]');";
      case _ParameterType.int:
        return "const $paramName = parseInt(lines[$index]);";
      case _ParameterType.string:
      default:
        return "const $paramName = lines[$index] || '';";
    }
  }

  /// 包装C++代码（默认版本，向后兼容）
  static String _wrapCppCodeDefault(String code) {
    return '''
#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <algorithm>

using namespace std;

$code

// 自动添加的wrapper - 读取stdin并调用Solution类方法
int main() {
    try {
        string line1, line2;
        getline(cin, line1);
        getline(cin, line2);

        // 解析数组输入
        vector<int> nums;
        if (!line1.empty()) {
            // 移除方括号
            line1.erase(remove(line1.begin(), line1.end(), '['), line1.end());
            line1.erase(remove(line1.begin(), line1.end(), ']'), line1.end());

            if (!line1.empty()) {
                istringstream iss(line1);
                string token;
                while (getline(iss, token, ',')) {
                    nums.push_back(stoi(token));
                }
            }
        }

        int target = !line2.empty() ? stoi(line2) : 0;

        // 调用Solution类的方法
        Solution solution;
        vector<int> result = solution.twoSum(nums, target);

        // 输出结果
        cout << "[";
        for (size_t i = 0; i < result.size(); i++) {
            cout << result[i];
            if (i < result.size() - 1) cout << ",";
        }
        cout << "]" << endl;

        return 0;
    } catch (exception& e) {
        cerr << "Error: " << e.what() << endl;
        return 1;
    }
}
''';
  }

  /// 包装C++代码（动态版本）
  static String _wrapCppCode(
    String code, {
    _FunctionSignature? functionSignature,
    List<_ParameterType>? parameterTypes,
  }) {
    // 如果没有提供函数签名，使用默认逻辑
    if (functionSignature == null) {
      return _wrapCppCodeDefault(code);
    }

    final className = functionSignature.className;
    final functionName = functionSignature.functionName;
    final parameters = functionSignature.parameters;
    final types = parameterTypes ?? List.generate(parameters.length, (_) => _ParameterType.unknown);

    // 生成参数解析代码（简化版）
    StringBuffer parseCode = StringBuffer();
    for (int i = 0; i < parameters.length; i++) {
      final paramName = parameters[i];
      if (parameters.length == 1) {
        parseCode.writeln('    ${_generateSingleLineParseCpp(paramName, types[i], 0)}');
      } else {
        parseCode.writeln('    ${_generateMultiLineParseCpp(paramName, i, types[i])}');
      }
    }

    // 生成函数调用代码
    String callCode;
    if (className != null) {
      callCode = '''
    // 调用类方法
    $className solution;
    auto result = solution.$functionName(${parameters.join(', ')});
''';
    } else {
      callCode = '''
    // 调用函数
    auto result = $functionName(${parameters.join(', ')});
''';
    }

    return '''
#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <algorithm>

using namespace std;

$code

// 动态生成的wrapper
int main() {
    try {
$parseCode$callCode    // 输出结果
        cout << result << endl;
        return 0;
    } catch (exception& e) {
        cerr << "Error: " << e.what() << endl;
        return 1;
    }
}
''';
  }

  /// 生成C++单行输入的解析代码（简化版）
  static String _generateSingleLineParseCpp(String paramName, _ParameterType type, int lineIndex) {
    switch (type) {
      case _ParameterType.jsonArray:
        return "vector<int> $paramName; // TODO: 解析JSON数组";
      case _ParameterType.int:
        return "int $paramName = stoi(lines[$lineIndex]);";
      case _ParameterType.string:
      default:
        return "string $paramName = lines[$lineIndex];";
    }
  }

  /// 生成C++多行输入的解析代码（简化版）
  static String _generateMultiLineParseCpp(String paramName, int index, _ParameterType type) {
    switch (type) {
      case _ParameterType.jsonArray:
        return "vector<int> $paramName; // TODO: 解析JSON数组 (line $index)";
      case _ParameterType.int:
        return "int $paramName = stoi(lines[$index]);";
      case _ParameterType.string:
      default:
        return "string $paramName = lines[$index];";
    }
  }

  /// 包装C代码
  static String _wrapCCode(String code) {
    // C语言通常不使用类，直接返回原代码
    return code;
  }

  /// 使用测试用例执行
  static Future<ExecutionResult> _executeWithTestCases(
    String code,
    String language,
    int languageId,
    List<Map<String, String>> testCases, {
    String? template,
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
      template: template,
    );

    StringBuffer allResults = StringBuffer();
    int passedCount = 0;
    double totalTime = 0;
    int totalMemory = 0;

    for (int i = 0; i < testCases.length; i++) {
      final testCase = testCases[i];
      final stdin = testCase['input'];
      final expectedOutput = testCase['output'];

      final result = await _executeSingle(wrappedCode, languageId, stdin);

      if (!result.success) {
        return result;
      }

      // 清理输出进行比较
      final actualOutput = result.output.trim();
      final expected = expectedOutput?.trim() ?? '';

      final isPassed = actualOutput == expected;

      if (isPassed) {
        passedCount++;
      }

      allResults.writeln('测试用例 ${i + 1}:');
      allResults.writeln('输入: ${stdin ?? "(无)"}');
      allResults.writeln('期望输出: $expected');
      allResults.writeln('实际输出: $actualOutput');
      allResults.writeln('结果: ${isPassed ? "✅ 通过" : "❌ 失败"}');
      allResults.writeln('');

      totalTime += result.executionTime;
      totalMemory += result.memoryUsage;
    }

    final summary = '测试结果: $passedCount/${testCases.length} 通过\n'
        '平均执行时间: ${(totalTime / testCases.length).toStringAsFixed(2)} ms\n'
        '平均内存使用: ${(totalMemory / testCases.length).toStringAsFixed(2)} KB\n'
        '━━━━━━━━━━━━━━━━━━━━\n\n'
        '${allResults.toString()}';

    return ExecutionResult(
      success: passedCount == testCases.length,
      output: summary,
      error: '',
      executionTime: totalTime / testCases.length,
      memoryUsage: totalMemory ~/ testCases.length,
    );
  }

  /// 单次执行
  static Future<ExecutionResult> _executeSingle(
    String code,
    int languageId,
    String? stdin,
  ) async {
    try {
      // 创建提交
      final createResponse = await http.post(
        Uri.parse('$_baseUrl/submissions?base64_encoded=false&wait=true'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'source_code': code,
          'language_id': languageId,
          'stdin': stdin ?? '',
        }),
      );

      if (createResponse.statusCode != 201) {
        return ExecutionResult(
          success: false,
          output: '',
          error: '提交失败: ${createResponse.statusCode}',
          executionTime: 0,
          memoryUsage: 0,
        );
      }

      final result = jsonDecode(createResponse.body);

      // 检查编译错误
      if (result['compile_output'] != null && result['compile_output'].isNotEmpty) {
        return ExecutionResult(
          success: false,
          output: '',
          error: '编译错误:\n${result['compile_output']}',
          executionTime: double.tryParse(result['time']?.toString() ?? '0') ?? 0,
          memoryUsage: int.tryParse(result['memory']?.toString() ?? '0') ?? 0 ~/ 1024,
        );
      }

      // 检查运行时错误
      if (result['stderr'] != null && result['stderr'].isNotEmpty) {
        return ExecutionResult(
          success: false,
          output: result['stdout'] ?? '',
          error: '运行时错误:\n${result['stderr']}',
          executionTime: double.tryParse(result['time']?.toString() ?? '0') ?? 0,
          memoryUsage: int.tryParse(result['memory']?.toString() ?? '0') ?? 0 ~/ 1024,
        );
      }

      return ExecutionResult(
        success: true,
        output: result['stdout'] ?? '',
        error: '',
        executionTime: double.tryParse(result['time']?.toString() ?? '0') ?? 0,
        memoryUsage: int.tryParse(result['memory']?.toString() ?? '0') ?? 0 ~/ 1024,
      );
    } catch (e) {
      return ExecutionResult(
        success: false,
        output: '',
        error: '执行出错: $e',
        executionTime: 0,
        memoryUsage: 0,
      );
    }
  }

  /// 获取支持的语言列表
  static List<Map<String, String>> getSupportedLanguages() {
    return languageIds.entries
        .map((e) => {'id': e.key, 'name': e.value.toString()})
        .toList();
  }
}

/// 执行结果
class ExecutionResult {
  final bool success;
  final String output;
  final String error;
  final double executionTime;
  final int memoryUsage;

  ExecutionResult({
    required this.success,
    required this.output,
    required this.error,
    required this.executionTime,
    required this.memoryUsage,
  });

  String get fullOutput {
    if (error.isNotEmpty) {
      return '❌ 错误:\n$error';
    }
    if (output.isEmpty) {
      return '(无输出)';
    }
    return output;
  }
}

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
