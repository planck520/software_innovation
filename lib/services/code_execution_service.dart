import 'dart:convert';
import 'package:http/http.dart' as http;

/// 代码执行服务 - 使用Judge0 API执行代码
class CodeExecutionService {
  // Judge0 API配置 (可以使用免费版本或自建服务)
  static const String _baseUrl = 'https://judge0-ce.p.rapidapi.com';
  static const String _rapidApiKey = 'YOUR_RAPIDAPI_KEY'; // 需要替换
  static const String _rapidApiHost = 'judge0-ce.p.rapidapi.com';

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
  static Future<ExecutionResult> executeCode({
    required String code,
    required String language,
    String? stdin,
    String? expectedOutput,
    List<Map<String, String>>? testCases,
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
      return await _executeWithTestCases(code, language, languageId, testCases);
    }

    // 单次执行
    return await _executeSingle(code, languageId, stdin);
  }

  /// 使用测试用例执行
  static Future<ExecutionResult> _executeWithTestCases(
    String code,
    String language,
    int languageId,
    List<Map<String, String>> testCases,
  ) async {
    StringBuffer allResults = StringBuffer();
    int passedCount = 0;
    double totalTime = 0;
    int totalMemory = 0;

    for (int i = 0; i < testCases.length; i++) {
      final testCase = testCases[i];
      final stdin = testCase['input'];
      final expectedOutput = testCase['output'];

      final result = await _executeSingle(code, languageId, stdin);

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
          'X-RapidAPI-Key': _rapidApiKey,
          'X-RapidAPI-Host': _rapidApiHost,
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
          executionTime: result['time'] ?? 0,
          memoryUsage: (result['memory'] ?? 0) ~/ 1024,
        );
      }

      // 检查运行时错误
      if (result['stderr'] != null && result['stderr'].isNotEmpty) {
        return ExecutionResult(
          success: false,
          output: result['stdout'] ?? '',
          error: '运行时错误:\n${result['stderr']}',
          executionTime: result['time'] ?? 0,
          memoryUsage: (result['memory'] ?? 0) ~/ 1024,
        );
      }

      return ExecutionResult(
        success: true,
        output: result['stdout'] ?? '',
        error: '',
        executionTime: double.tryParse(result['time']?.toString() ?? '0') ?? 0,
        memoryUsage: (result['memory'] ?? 0) ~/ 1024,
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
