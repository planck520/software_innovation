import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/languages/python.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/cpp.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/styles/vs2015.dart';
import 'editor_settings_page.dart';
import '../services/code_execution_service.dart';
import '../theme/bubei_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/login_theme.dart';
import '../widgets/tech_tag.dart';
import '../widgets/widgets.dart';

/// 代码编辑器页面 - LeetCode风格的编程界面
class CodeEditorPage extends StatefulWidget {
  final Map<String, dynamic> question;

  const CodeEditorPage({
    super.key,
    required this.question,
  });

  @override
  State<CodeEditorPage> createState() => _CodeEditorPageState();
}

class _CodeEditorPageState extends State<CodeEditorPage> {
  late String _selectedLanguage;
  late CodeLineEditingController _codeController;
  late ScrollController _scrollController;
  bool _isRunning = false;
  bool _isSubmitting = false;
  bool _showConsole = false;

  // 编辑器设置
  double _fontSize = 14;
  int _tabSize = 4;
  bool _wrapEnabled = false;

  // 执行结果
  ExecutionResult? _lastResult;
  String _outputText = '';
  List<bool> _testCaseResults = [];

  // 支持的语言
  final List<Map<String, String>> _languages = [
    {'id': 'python', 'name': 'Python', 'extension': '.py'},
    {'id': 'java', 'name': 'Java', 'extension': '.java'},
    {'id': 'javascript', 'name': 'JavaScript', 'extension': '.js'},
    {'id': 'cpp', 'name': 'C++', 'extension': '.cpp'},
    {'id': 'c', 'name': 'C', 'extension': '.c'},
  ];

  // 获取模板代码 - 根据题目名称和语言返回正确的模板
  String _getTemplate(String language) {
    final questionName = widget.question['q']?.toString().toLowerCase() ?? '';

    // 直接根据题目名称返回对应的骨架模板
    // 不使用 question['template'] 字段（因为它包含完整解答）
    if (questionName.contains('两数之和') || questionName.contains('two sum')) {
      return _getTwoSumTemplate(language);
    } else if (questionName.contains('反转字符串') || questionName.contains('reverse string')) {
      return _getReverseStringTemplate(language);
    } else if (questionName.contains('斐波那契') || questionName.contains('fibonacci')) {
      return _getFibonacciTemplate(language);
    } else if (questionName.contains('回文数') || questionName.contains('palindrome')) {
      return _getPalindromeTemplate(language);
    } else if (questionName.contains('最大子数组') || questionName.contains('max subarray')) {
      return _getMaxSubArrayTemplate(language);
    } else if (questionName.contains('两数相加') || questionName.contains('add two')) {
      return _getAddTwoNumbersTemplate(language);
    } else if (questionName.contains('无重复字符') || questionName.contains('longest substring')) {
      return _getLongestSubstringTemplate(language);
    } else if (questionName.contains('有效括号') || questionName.contains('valid parent')) {
      return _getValidParenthesesTemplate(language);
    } else if (questionName.contains('合并有序链表') || questionName.contains('merge two')) {
      return _getMergeTwoListsTemplate(language);
    } else if (questionName.contains('买卖股票') || questionName.contains('best time')) {
      return _getMaxProfitTemplate(language);
    } else if (questionName.contains('lru')) {
      return _getLRUCacheTemplate(language);
    }

    // 默认模板
    return _getDefaultTemplate(language);
  }

  // 两数之和模板
  String _getTwoSumTemplate(String language) {
    switch (language) {
      case 'python':
        return '''class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        # Write your code here
        pass
''';
      case 'java':
        return '''class Solution {
    public int[] twoSum(int[] nums, int target) {
        // Write your code here
        return new int[]{0, 1};
    }
}
''';
      case 'javascript':
        return '''/**
 * @param {number[]} nums
 * @param {number} target
 * @return {number[]}
 */
var twoSum = function(nums, target) {
    // Write your code here
    return [0, 1];
};
''';
      case 'cpp':
        return '''class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        // Write your code here
        return {0, 1};
    }
};
''';
      case 'c':
        return '''/**
 * Note: The returned array must be malloced, assume caller calls free().
 */
int* twoSum(int* nums, int numsSize, int target, int* returnSize) {
    // Write your code here
    *returnSize = 2;
    int* result = (int*)malloc(2 * sizeof(int));
    result[0] = 0;
    result[1] = 1;
    return result;
}
''';
      default:
        return '';
    }
  }

  // 反转字符串模板
  String _getReverseStringTemplate(String language) {
    switch (language) {
      case 'python':
        return '''def reverseString(s: List[str]) -> None:
    # Write your code here
    pass
''';
      case 'java':
        return '''class Solution {
    public void reverseString(char[] s) {
        // Write your code here
    }
}
''';
      case 'javascript':
        return '''/**
 * @param {character[]} s
 * @return {void} Do not return anything, modify s in-place instead.
 */
var reverseString = function(s) {
    // Write your code here
};
''';
      case 'cpp':
        return '''class Solution {
public:
    void reverseString(vector<char>& s) {
        // Write your code here
    }
};
''';
      case 'c':
        return '''void reverseString(char* s, int sSize) {
    // Write your code here
}
''';
      default:
        return '';
    }
  }

  // 斐波那契模板
  String _getFibonacciTemplate(String language) {
    switch (language) {
      case 'python':
        return '''def fib(n: int) -> int:
    # Write your code here
    pass
''';
      case 'java':
        return '''class Solution {
    public int fib(int n) {
        // Write your code here
        return 0;
    }
}
''';
      case 'javascript':
        return '''/**
 * @param {number} n
 * @return {number}
 */
var fib = function(n) {
    // Write your code here
    return 0;
};
''';
      case 'cpp':
        return '''class Solution {
public:
    int fib(int n) {
        // Write your code here
        return 0;
    }
};
''';
      case 'c':
        return '''int fib(int n) {
    // Write your code here
    return 0;
}
''';
      default:
        return '';
    }
  }

  // 回文数模板
  String _getPalindromeTemplate(String language) {
    switch (language) {
      case 'python':
        return '''def isPalindrome(x: int) -> bool:
    # Write your code here
    pass
''';
      case 'java':
        return '''class Solution {
    public boolean isPalindrome(int x) {
        // Write your code here
        return false;
    }
}
''';
      case 'javascript':
        return '''/**
 * @param {number} x
 * @return {boolean}
 */
var isPalindrome = function(x) {
    // Write your code here
    return false;
};
''';
      case 'cpp':
        return '''class Solution {
public:
    bool isPalindrome(int x) {
        // Write your code here
        return false;
    }
};
''';
      case 'c':
        return '''bool isPalindrome(int x) {
    // Write your code here
    return false;
}
''';
      default:
        return '';
    }
  }

  // 最大子数组和模板
  String _getMaxSubArrayTemplate(String language) {
    switch (language) {
      case 'python':
        return '''def maxSubArray(nums: List[int]) -> int:
    # Write your code here
    pass
''';
      case 'java':
        return '''class Solution {
    public int maxSubArray(int[] nums) {
        // Write your code here
        return 0;
    }
}
''';
      case 'javascript':
        return '''/**
 * @param {number[]} nums
 * @return {number}
 */
var maxSubArray = function(nums) {
    // Write your code here
    return 0;
};
''';
      case 'cpp':
        return '''class Solution {
public:
    int maxSubArray(vector<int>& nums) {
        // Write your code here
        return 0;
    }
};
''';
      case 'c':
        return '''int maxSubArray(int* nums, int numsSize) {
    // Write your code here
    return 0;
}
''';
      default:
        return '';
    }
  }

  // 两数相加模板
  String _getAddTwoNumbersTemplate(String language) {
    switch (language) {
      case 'python':
        return '''# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next

def addTwoNumbers(l1, l2):
    # Write your code here
    pass
''';
      case 'java':
        return '''/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode() {}
 *     ListNode(int val) { this.val = val; }
 *     ListNode(int val, ListNode next) { this.val = val; this.next = next; }
 * }
 */
class Solution {
    public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
        // Write your code here
        return null;
    }
}
''';
      case 'javascript':
        return '''/**
 * Definition for singly-linked list.
 * function ListNode(val, next) {
 *     this.val = (val===undefined ? 0 : val)
 *     this.next = (next===undefined ? null : next)
 * }
 */
/**
 * @param {ListNode} l1
 * @param {ListNode} l2
 * @return {ListNode}
 */
var addTwoNumbers = function(l1, l2) {
    // Write your code here
    return null;
};
''';
      case 'cpp':
        return '''/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
class Solution {
public:
    ListNode* addTwoNumbers(ListNode* l1, ListNode* l2) {
        // Write your code here
        return nullptr;
    }
};
''';
      case 'c':
        return '''/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     struct ListNode *next;
 * };
 */
struct ListNode* addTwoNumbers(struct ListNode* l1, struct ListNode* l2) {
    // Write your code here
    return NULL;
}
''';
      default:
        return '';
    }
  }

  // 无重复字符最长子串模板
  String _getLongestSubstringTemplate(String language) {
    switch (language) {
      case 'python':
        return '''def lengthOfLongestSubstring(s: str) -> int:
    # Write your code here
    pass
''';
      case 'java':
        return '''class Solution {
    public int lengthOfLongestSubstring(String s) {
        // Write your code here
        return 0;
    }
}
''';
      case 'javascript':
        return '''/**
 * @param {string} s
 * @return {number}
 */
var lengthOfLongestSubstring = function(s) {
    // Write your code here
    return 0;
};
''';
      case 'cpp':
        return '''class Solution {
public:
    int lengthOfLongestSubstring(string s) {
        // Write your code here
        return 0;
    }
};
''';
      case 'c':
        return '''int lengthOfLongestSubstring(char* s) {
    // Write your code here
    return 0;
}
''';
      default:
        return '';
    }
  }

  // 有效括号模板
  String _getValidParenthesesTemplate(String language) {
    switch (language) {
      case 'python':
        return '''def isValid(s: str) -> bool:
    # Write your code here
    pass
''';
      case 'java':
        return '''class Solution {
    public boolean isValid(String s) {
        // Write your code here
        return false;
    }
}
''';
      case 'javascript':
        return '''/**
 * @param {string} s
 * @return {boolean}
 */
var isValid = function(s) {
    // Write your code here
    return false;
};
''';
      case 'cpp':
        return '''class Solution {
public:
    bool isValid(string s) {
        // Write your code here
        return false;
    }
};
''';
      case 'c':
        return '''bool isValid(char* s) {
    // Write your code here
    return false;
}
''';
      default:
        return '';
    }
  }

  // 合并有序链表模板
  String _getMergeTwoListsTemplate(String language) {
    switch (language) {
      case 'python':
        return '''# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next

def mergeTwoLists(l1, l2):
    # Write your code here
    pass
''';
      case 'java':
        return '''/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode() {}
 *     ListNode(int val) { this.val = val; }
 *     ListNode(int val, ListNode next) { this.val = val; this.next = next; }
 * }
 */
class Solution {
    public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
        // Write your code here
        return null;
    }
}
''';
      case 'javascript':
        return '''/**
 * Definition for singly-linked list.
 * function ListNode(val, next) {
 *     this.val = (val===undefined ? 0 : val)
 *     this.next = (next===undefined ? null : next)
 * }
 */
/**
 * @param {ListNode} l1
 * @param {ListNode} l2
 * @return {ListNode}
 */
var mergeTwoLists = function(l1, l2) {
    // Write your code here
    return null;
};
''';
      case 'cpp':
        return '''/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
class Solution {
public:
    ListNode* mergeTwoLists(ListNode* l1, ListNode* l2) {
        // Write your code here
        return nullptr;
    }
};
''';
      case 'c':
        return '''/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     struct ListNode *next;
 * };
 */
struct ListNode* mergeTwoLists(struct ListNode* l1, struct ListNode* l2) {
    // Write your code here
    return NULL;
}
''';
      default:
        return '';
    }
  }

  // 买卖股票模板
  String _getMaxProfitTemplate(String language) {
    switch (language) {
      case 'python':
        return '''def maxProfit(prices: List[int]) -> int:
    # Write your code here
    pass
''';
      case 'java':
        return '''class Solution {
    public int maxProfit(int[] prices) {
        // Write your code here
        return 0;
    }
}
''';
      case 'javascript':
        return '''/**
 * @param {number[]} prices
 * @return {number}
 */
var maxProfit = function(prices) {
    // Write your code here
    return 0;
};
''';
      case 'cpp':
        return '''class Solution {
public:
    int maxProfit(vector<int>& prices) {
        // Write your code here
        return 0;
    }
};
''';
      case 'c':
        return '''int maxProfit(int* prices, int pricesSize) {
    // Write your code here
    return 0;
}
''';
      default:
        return '';
    }
  }

  // LRU缓存模板
  String _getLRUCacheTemplate(String language) {
    switch (language) {
      case 'python':
        return '''class LRUCache:

    def __init__(self, capacity: int):
        # Write your code here
        pass

    def get(self, key: int) -> int:
        # Write your code here
        pass

    def put(self, key: int, value: int) -> None:
        # Write your code here
        pass
''';
      case 'java':
        return '''class LRUCache {
    public LRUCache(int capacity) {
        // Write your code here
    }

    public int get(int key) {
        // Write your code here
        return -1;
    }

    public void put(int key, int value) {
        // Write your code here
    }
}
''';
      case 'javascript':
        return '''/**
 * @param {number} capacity
 */
var LRUCache = function(capacity) {
    // Write your code here
};

/**
 * @param {number} key
 * @return {number}
 */
LRUCache.prototype.get = function(key) {
    // Write your code here
    return -1;
};

/**
 * @param {number} key
 * @param {number} value
 * @return {void}
 */
LRUCache.prototype.put = function(key, value) {
    // Write your code here
};
''';
      case 'cpp':
        return '''class LRUCache {
public:
    LRUCache(int capacity) {
        // Write your code here
    }

    int get(int key) {
        // Write your code here
        return -1;
    }

    void put(int key, int value) {
        // Write your code here
    }
};
''';
      case 'c':
        return '''typedef struct {
    // Write your code here
} LRUCache;

LRUCache* lRUCacheCreate(int capacity) {
    // Write your code here
    return NULL;
}

int lRUCacheGet(LRUCache* obj, int key) {
    // Write your code here
    return -1;
}

void lRUCachePut(LRUCache* obj, int key, int value) {
    // Write your code here
}

void lRUCacheFree(LRUCache* obj) {
    // Write your code here
}
''';
      default:
        return '';
    }
  }

  // 默认模板
  String _getDefaultTemplate(String language) {
    switch (language) {
      case 'python':
        return '''# Write your code here
def solution():
    pass
''';
      case 'java':
        return '''class Solution {
    // Write your code here
}
''';
      case 'javascript':
        return '''// Write your code here
var solution = function() {
};
''';
      case 'cpp':
        return '''// Write your code here
class Solution {
};
''';
      case 'c':
        return '''// Write your code here
''';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.question['language'] ?? 'python';
    _scrollController = ScrollController();
    _initCodeController();
  }

  void _initCodeController() {
    final template = _getTemplate(_selectedLanguage);
    // 规范化换行符，确保编辑器正确识别多行
    final normalizedTemplate = template.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // 将文本按行分割，手动创建 CodeLines
    final lines = normalizedTemplate.split('\n');
    final codeLines = lines.map((line) => CodeLine(line)).toList();

    _codeController = CodeLineEditingController(
      codeLines: CodeLines.of(codeLines),
    );
  }

  // 自定义粘贴处理方法
  Future<void> _handlePaste() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      String text = clipboardData!.text!;
      // 规范化换行符为 \n
      text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      // 按行分割创建CodeLines
      final lines = text.split('\n');
      final codeLines = lines.map((line) => CodeLine(line)).toList();
      // 更新编辑器，确保保持当前语言设置
      setState(() {
        _codeController.dispose();
        _codeController = CodeLineEditingController(codeLines: CodeLines.of(codeLines));
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 切换语言
  void _changeLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
      final currentCode = _codeController.text;
      _codeController.dispose();
      final template = _getTemplate(language);
      // 规范化换行符，确保编辑器正确识别多行
      final normalizedTemplate = template.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      final normalizedCurrentCode = currentCode.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      final codeToUse = normalizedTemplate.isNotEmpty ? normalizedTemplate : normalizedCurrentCode;

      // 将文本按行分割，手动创建 CodeLines
      final lines = codeToUse.split('\n');
      final codeLines = lines.map((line) => CodeLine(line)).toList();

      _codeController = CodeLineEditingController(
        codeLines: CodeLines.of(codeLines),
      );
      _lastResult = null;
      _testCaseResults = [];
      _outputText = '';
    });
  }

  // 运行代码
  Future<void> _runCode() async {
    setState(() {
      _isRunning = true;
      _showConsole = true;
      _outputText = '⏳ 正在执行...\n';
      _testCaseResults = [];
    });

    try {
      final testCases = widget.question['testCases'] != null
          ? List<Map<String, String>>.from(widget.question['testCases'])
          : null;

      final result = await CodeExecutionService.executeCode(
        code: _codeController.text,
        language: _selectedLanguage,
        testCases: testCases,
        template: widget.question['template'],
      );

      setState(() {
        _lastResult = result;
        _outputText = result.fullOutput;
        if (testCases != null && testCases.isNotEmpty) {
          _parseTestResults(result.fullOutput, testCases.length);
        }
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _outputText = '❌ 执行出错: $e';
        _lastResult = null;
        _isRunning = false;
      });
    }
  }

  // 提交代码
  Future<void> _submitCode() async {
    setState(() {
      _isSubmitting = true;
      _showConsole = true;
      _outputText = '⏳ 正在提交...\n';
      _testCaseResults = [];
    });

    try {
      final testCases = widget.question['testCases'] != null
          ? List<Map<String, String>>.from(widget.question['testCases'])
          : null;

      final result = await CodeExecutionService.executeCode(
        code: _codeController.text,
        language: _selectedLanguage,
        testCases: testCases,
        template: widget.question['template'],
      );

      setState(() {
        _lastResult = result;
        if (result.success) {
          _outputText = '🎉 恭喜！所有测试用例通过！\n\n${result.output}';
        } else {
          _outputText = '😢 测试未通过，请检查代码。\n\n${result.output}';
        }
        if (testCases != null && testCases.isNotEmpty) {
          _parseTestResults(result.output, testCases.length);
        }
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _outputText = '❌ 提交出错: $e';
        _lastResult = null;
        _isSubmitting = false;
      });
    }
  }

  // 解析测试结果
  void _parseTestResults(String output, int testCaseCount) {
    _testCaseResults = List.filled(testCaseCount, false);
    final lines = output.split('\n');

    // 按测试用例分组解析
    int currentTestCase = -1;
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // 检查是否是新的测试用例开始
      final testCaseMatch = RegExp(r'测试用例 (\d+):').firstMatch(line);
      if (testCaseMatch != null) {
        currentTestCase = int.parse(testCaseMatch.group(1)!) - 1;
        continue;
      }

      // 在当前测试用例范围内查找结果行
      if (currentTestCase >= 0 && currentTestCase < testCaseCount) {
        if (line.contains('结果:')) {
          _testCaseResults[currentTestCase] = line.contains('✅ 通过');
          currentTestCase = -1; // 重置
        }
      }
    }
  }

  // 撤销操作
  void _undo() {
    // 简单实现：重置为模板代码
    setState(() {
      final template = _getTemplate(_selectedLanguage);
      // 规范化换行符，确保编辑器正确识别多行
      final normalizedTemplate = template.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      // 将文本按行分割，手动��建 CodeLines
      final lines = normalizedTemplate.split('\n');
      final codeLines = lines.map((line) => CodeLine(line)).toList();

      _codeController = CodeLineEditingController(
        codeLines: CodeLines.of(codeLines),
      );
      _lastResult = null;
      _testCaseResults = [];
      _outputText = '';
    });
  }

  // 获取当前语言的语法高亮模式
  CodeHighlightThemeMode _getHighlightMode(String lang) {
    Mode mode;
    switch (lang) {
      case 'python':
        mode = langPython;
        break;
      case 'javascript':
        mode = langJavascript;
        break;
      case 'java':
        mode = langJava;
        break;
      case 'cpp':
      case 'c':
        mode = langCpp;
        break;
      default:
        mode = langPython;
    }
    return mode.themeMode;
  }

  // 构建代码编辑器
  Widget _buildCodeEditor() {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV): const _PasteIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyV): const _PasteIntent(),
      },
      child: Actions(
        actions: {
          _PasteIntent: CallbackAction<_PasteIntent>(onInvoke: (_) => _handlePaste()),
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E1E1E),
                Color(0xFF1E1E1E),
              ],
            ),
          ),
          width: double.infinity,
          child: CodeEditor(
            controller: _codeController,
            style: CodeEditorStyle(
              fontSize: _fontSize,
              fontFamily: 'Consolas, Monaco, monospace',
              fontHeight: 1.6,
              textColor: const Color(0xFFD4D4D4),
              backgroundColor: const Color(0xFF1E1E1E),
              cursorColor: BubeiColors.primaryLight,
              codeTheme: CodeHighlightTheme(
                languages: {
                  'python': _getHighlightMode('python'),
                  'javascript': _getHighlightMode('javascript'),
                  'java': _getHighlightMode('java'),
                  'cpp': _getHighlightMode('cpp'),
                  'c': _getHighlightMode('c'),
                },
                theme: vs2015Theme,
              ),
            ),
            wordWrap: true,
            indicatorBuilder: (context, editingController, chunkController, notifier) {
              return DefaultCodeLineNumber(
                controller: editingController,
                notifier: notifier,
              );
            },
            sperator: const SizedBox(
              width: 1,
              child: VerticalDivider(
                color: Color(0xFF3C3C3C),
                thickness: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 打开设置页面
  void _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorSettingsPage(
          initialFontSize: _fontSize,
          initialTabSize: 4,
          initialWrapEnabled: false,
          onSave: (fontSize, tabSize, wrapEnabled) {
            setState(() {
              _fontSize = fontSize;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumStaticBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // 代码编辑器区（VSCode Dark+风格）
            Expanded(
              child: _buildCodeEditor(),
            ),

            // 控制台面板（可展开/收起）
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _showConsole ? 360 : 0,
              child: _showConsole ? _buildConsolePanel() : const SizedBox.shrink(),
            ),

            // 底部按钮栏
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // 构建AppBar（带毛玻璃效果和悬停发光）
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: LoginTheme.background,
              border: Border(
                bottom: BorderSide(
                  color: LoginTheme.cardBorder,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: _buildBackButton(),
              title: Center(child: _buildLanguageSelector()),
              actions: [
                _buildSettingsButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 返回按钮（带滑动返回动画）
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: CustomPaint(
        size: const Size(16, 16),
        painter: _TriangleArrowPainter(),
      ),
    );
  }

  // 设置按钮（带悬停发光效果）
  Widget _buildSettingsButton() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: _openSettings,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(),  // 无边框和填充
          child: const Icon(
            Icons.settings,
            color: BubeiColors.primaryLight,
            size: 16,
          ),
        ),
      ),
    );
  }

  // 构建语言选择器（使用 LanguageSelector 组件）
  Widget _buildLanguageSelector() {
    return GestureDetector(
      onTap: () => _showLanguagePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: const BoxDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.code,
              color: BubeiColors.primaryLight,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              _languages.firstWhere((l) => l['id'] == _selectedLanguage)['name'] ?? 'Python',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: BubeiColors.primaryLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // 显示语言选择底部弹窗
  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: BubeiColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppTokens.radiusLg),
            topRight: Radius.circular(AppTokens.radiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: BubeiColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.code, color: BubeiColors.primaryLight, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '选择编程语言',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: BubeiColors.divider),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: _languages.map((lang) => _buildLanguageItem(lang)).toList(),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(Map<String, String> lang) {
    final isSelected = lang['id'] == _selectedLanguage;
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _changeLanguage(lang['id']!);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? BubeiColors.primary.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getLanguageColor(lang['id']).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getLanguageIcon(lang['id']),
                size: 16,
                color: _getLanguageColor(lang['id']),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                lang['name'] ?? '',
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? BubeiColors.primaryLight : Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                size: 20,
                color: BubeiColors.primaryLight,
              ),
          ],
        ),
      ),
    );
  }

  Color _getLanguageColor(String? langId) {
    switch (langId) {
      case 'python':
        return const Color(0xFF3776AB);
      case 'java':
        return const Color(0xFFED8B00);
      case 'javascript':
        return const Color(0xFFF7DF1E);
      case 'cpp':
      case 'c':
        return const Color(0xFF00599C);
      default:
        return BubeiColors.primary;
    }
  }

  IconData _getLanguageIcon(String? langId) {
    switch (langId) {
      case 'python':
        return Icons.psychology;  // Python 代表智慧/蛇
      case 'java':
        return Icons.coffee;       // Java 代表咖啡
      case 'javascript':
        return Icons.javascript;    // JavaScript
      case 'cpp':
        return Icons.memory;        // C++ 保持不变
      case 'c':
        return Icons.developer_mode; // C 改用新图标
      default:
        return Icons.code;
    }
  }

  // 构建控制台面板（NeonBorderCard包装）
  Widget _buildConsolePanel() {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            LoginTheme.cardBackground,
            LoginTheme.background,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: LoginTheme.cardBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: BubeiColors.primary.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 控制台标题栏（毛玻璃效果）
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: LoginTheme.cardBackground,
                  border: Border(
                    bottom: BorderSide(
                      color: LoginTheme.cardBorder,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.terminal,
                      size: 16,
                      color: BubeiColors.primaryLight,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '控制台',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // 执行统计（彩色徽章组）- 与控制台标题同一行
                    if (_lastResult != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusBadge(_lastResult!.success),
                          const SizedBox(width: 8),
                          _buildExecutionTimeBadge(),
                        ],
                      ),
                    ],
                    const SizedBox(width: 8),
                    _buildCloseButton(),
                  ],
                ),
              ),
            ),
          ),
          // 测试用例状态指示器（彩色徽章组）
          if (_testCaseResults.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              height: 36,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_testCaseResults.length, (index) {
                    final passed = _testCaseResults[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _buildTestCaseBadge(index + 1, passed),
                    );
                  }),
                ),
              ),
            ),
          // 输出内容（终端风格配色）
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Text(
                  _outputText.isNotEmpty ? _outputText : '点击"运行"查看输出结果...',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.white,  // 改为白色
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 状态徽章
  Widget _buildStatusBadge(bool success) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: success
              ? [
                  BubeiColors.success.withOpacity(0.25),
                  BubeiColors.success.withOpacity(0.15),
                ]
              : [
                  BubeiColors.error.withOpacity(0.25),
                  BubeiColors.error.withOpacity(0.15),
                ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(
          color: success
              ? BubeiColors.success.withOpacity(0.5)
              : BubeiColors.error.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            success ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: success ? BubeiColors.success : BubeiColors.error,
          ),
          const SizedBox(width: 4),
          Text(
            success ? 'Accepted' : 'Wrong Answer',
            style: TextStyle(
              fontSize: 11,
              color: success ? BubeiColors.success : BubeiColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 执行时间徽章
  Widget _buildExecutionTimeBadge() {
    // 格式化时间显示，避免显示0ms
    String timeText;
    if (_lastResult!.executionTime < 1) {
      timeText = '${(_lastResult!.executionTime * 1000).toStringAsFixed(0)}μs';
    } else if (_lastResult!.executionTime < 10) {
      timeText = '${_lastResult!.executionTime.toStringAsFixed(2)}ms';
    } else {
      timeText = '${_lastResult!.executionTime.toStringAsFixed(1)}ms';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: BubeiColors.info.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(
          color: BubeiColors.info.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule,
            size: 10,
            color: BubeiColors.info,
          ),
          const SizedBox(width: 3),
          Text(
            timeText,
            style: const TextStyle(
              fontSize: 10,
              color: BubeiColors.info,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 测试用例徽章
  Widget _buildTestCaseBadge(int caseNum, bool passed) {
    final color = passed ? BubeiColors.success : BubeiColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Case $caseNum',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            passed ? Icons.check : Icons.close,
            size: 10,
            color: color,
          ),
        ],
      ),
    );
  }

  // 关闭按钮
  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showConsole = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: BubeiColors.surfaceDim,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close,
          size: 16,
          color: Colors.white54,
        ),
      ),
    );
  }

  // 构建底部工具栏（美化版）
  Widget _buildBottomBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: LoginTheme.cardBackground,
            border: Border(
              top: BorderSide(
                color: LoginTheme.cardBorder,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 控制台按钮（图标+文字组合）
              _buildConsoleButton(),

              const Spacer(),

              // 右侧紧凑按钮组
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 撤销按钮（毛玻璃样式）
                  _buildUndoButton(),

                  const SizedBox(width: 8),

                  // 运行按钮（渐变+发光）
                  _buildRunButton(),

                  const SizedBox(width: 8),

                  // 提交按钮（渐变+发光）
                  _buildSubmitButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 控制台按钮
  Widget _buildConsoleButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showConsole = !_showConsole;
        });
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),  // 黑色填充
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          // 去掉边框
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.terminal_outlined,
                size: 16,
                color: _showConsole
                    ? BubeiColors.primaryLight
                    : Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                '控制台',
                style: TextStyle(
                  fontSize: 13,
                  color: _showConsole
                      ? BubeiColors.primaryLight
                      : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 撤销按钮（毛玻璃样式）
  Widget _buildUndoButton() {
    return GestureDetector(
      onTap: _undo,
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: BubeiColors.surfaceDim.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.undo,
          size: 18,
          color: Colors.white70,
        ),
      ),
    );
  }

  // 运行按钮 - 圆形，无发光特效
  Widget _buildRunButton() {
    return GestureDetector(
      onTap: _isRunning ? null : _runCode,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: _isRunning
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
      ),
    );
  }

  // 提交按钮 - 使用 TechCapsuleButton 风格 + 黑色填充 + 无边框
  Widget _buildSubmitButton() {
    return _TechButton(
      label: '提交',
      icon: null,  // 不显示icon
      isLoading: _isSubmitting,
      gradientColors: const [Color(0xFF1A1A1A), Color(0xFF1A1A1A)],  // 黑色填充
      glowColor: Colors.transparent,  // 无发光效果
      borderColor: Colors.transparent,  // 无边框
      onPressed: _isSubmitting ? null : _submitCode,
    );
  }
}

/// 自定义粘贴Intent
class _PasteIntent extends Intent {
  const _PasteIntent();
}

/// 科技风格按钮 - 带渐变和脉冲发光效果
class _TechButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final List<Color> gradientColors;
  final Color glowColor;
  final Color? borderColor;
  final VoidCallback? onPressed;

  const _TechButton({
    required this.label,
    this.icon,
    this.isLoading = false,
    required this.gradientColors,
    required this.glowColor,
    this.borderColor,
    this.onPressed,
  });

  @override
  State<_TechButton> createState() => _TechButtonState();
}

class _TechButtonState extends State<_TechButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: widget.onPressed != null
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              border: widget.borderColor != null
                  ? Border.all(color: widget.borderColor!, width: 1)
                  : null,
              boxShadow: widget.onPressed != null
                  ? [
                      BoxShadow(
                        color: widget.glowColor.withOpacity(_pulseAnimation.value * 0.5),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else if (widget.icon != null)
                  Icon(
                    widget.icon,
                    size: 16,
                    color: Colors.white,
                  ),
                if (widget.icon != null || widget.isLoading)
                  const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 三角形向下箭头绘制器（只有箭头头部）
class _TriangleArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    // 绘制向下的三角形箭头
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final arrowSize = 4.0;

    path.moveTo(centerX - arrowSize, centerY - arrowSize);
    path.lineTo(centerX + arrowSize, centerY - arrowSize);
    path.lineTo(centerX, centerY + arrowSize);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
