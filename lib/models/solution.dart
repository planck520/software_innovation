/// 题解数据模型
/// 定义解法方法、编程语言和代码��本等

/// 解法方法枚举
enum SolutionMethod {
  bruteForce('暴力法', '暴力枚举所有可能性'),
  twoPointers('双指针', '使用两个指针从不同方向遍历'),
  hashMap('哈希表', '使用哈希表存储和查找'),
  slidingWindow('滑动窗口', '维护一个动态窗口'),
  dynamicProgramming('动态规划', '状态转移求解'),
  binarySearch('二分查找', '有序数组折半查找'),
  recursion('递归', '函数自身调用'),
  greedy('贪心', '局部最优选择'),
  stack('栈', '使用栈数据结构'),
  queue('队列', '使用队列数据结构'),
  bfs('广度优先', 'BFS广度优先搜索'),
  dfs('深度优先', 'DFS深度优先搜索'),
  backtracking('回溯', '试探与回退');

  final String label;
  final String description;

  const SolutionMethod(this.label, this.description);
}

/// 编程语言枚举
enum ProgrammingLanguage {
  python('Python', '.py', 'py'),
  java('Java', '.java', 'java'),
  javascript('JavaScript', '.js', 'js'),
  cpp('C++', '.cpp', 'cpp');

  final String label;
  final String extension;
  final String highlightLang;

  const ProgrammingLanguage(this.label, this.extension, this.highlightLang);
}

/// 代码版本类 - 存��特定语言的代码
class CodeVersion {
  final ProgrammingLanguage language;
  final String code;
  final String? explanation;

  const CodeVersion({
    required this.language,
    required this.code,
    this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'language': language.name,
    'code': code,
    'explanation': explanation,
  };

  factory CodeVersion.fromJson(Map<String, dynamic> json) {
    return CodeVersion(
      language: ProgrammingLanguage.values.firstWhere(
        (e) => e.name == json['language'],
        orElse: () => ProgrammingLanguage.python,
      ),
      code: json['code'] ?? '',
      explanation: json['explanation'],
    );
  }
}

/// 题解类 - 存储完整的解法信息
class Solution {
  final SolutionMethod method;
  final String approach;
  final String timeComplexity;
  final String spaceComplexity;
  final List<CodeVersion> codeVersions;
  final bool isRecommended;

  const Solution({
    required this.method,
    required this.approach,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.codeVersions,
    this.isRecommended = false,
  });

  /// 获取指定语言的代码
  CodeVersion? getCodeVersion(ProgrammingLanguage language) {
    try {
      return codeVersions.firstWhere((v) => v.language == language);
    } catch (_) {
      return codeVersions.isNotEmpty ? codeVersions.first : null;
    }
  }

  /// 获取支持的语言列表
  List<ProgrammingLanguage> get supportedLanguages {
    return codeVersions.map((v) => v.language).toList();
  }

  Map<String, dynamic> toJson() => {
    'method': method.name,
    'approach': approach,
    'timeComplexity': timeComplexity,
    'spaceComplexity': spaceComplexity,
    'codeVersions': codeVersions.map((v) => v.toJson()).toList(),
    'isRecommended': isRecommended,
  };

  factory Solution.fromJson(Map<String, dynamic> json) {
    return Solution(
      method: SolutionMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => SolutionMethod.bruteForce,
      ),
      approach: json['approach'] ?? '',
      timeComplexity: json['timeComplexity'] ?? 'O(n)',
      spaceComplexity: json['spaceComplexity'] ?? 'O(n)',
      codeVersions: (json['codeVersions'] as List<dynamic>?)
          ?.map((v) => CodeVersion.fromJson(v as Map<String, dynamic>))
          .toList() ?? [],
      isRecommended: json['isRecommended'] ?? false,
    );
  }
}

/// 题目题解集合 - 管理一道题目的所有解法
class ProblemSolutions {
  final String problemId;
  final List<Solution> solutions;

  const ProblemSolutions({
    required this.problemId,
    required this.solutions,
  });

  /// 获取推荐解法
  Solution? get recommendedSolution {
    try {
      return solutions.firstWhere((s) => s.isRecommended);
    } catch (_) {
      return solutions.isNotEmpty ? solutions.first : null;
    }
  }

  /// 按方法类型获取解法
  Solution? getSolutionByMethod(SolutionMethod method) {
    try {
      return solutions.firstWhere((s) => s.method == method);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
    'problemId': problemId,
    'solutions': solutions.map((s) => s.toJson()).toList(),
  };

  factory ProblemSolutions.fromJson(Map<String, dynamic> json) {
    return ProblemSolutions(
      problemId: json['problemId'] ?? '',
      solutions: (json['solutions'] as List<dynamic>?)
          ?.map((s) => Solution.fromJson(s as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
