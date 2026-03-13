import 'dart:ui';
import 'package:flutter/material.dart';
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
    _codeController = CodeLineEditingController.fromText(template);
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
      _codeController = CodeLineEditingController.fromText(
        template.isNotEmpty ? template : currentCode,
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
    for (int i = 0; i < testCaseCount; i++) {
      final resultLine = lines.firstWhere(
        (line) => line.contains('测试用例 ${i + 1}:'),
        orElse: () => '',
      );
      final nextLineIndex = lines.indexOf(resultLine) + 1;
      if (nextLineIndex < lines.length) {
        _testCaseResults[i] = lines[nextLineIndex].contains('✅ 通过');
      }
    }
  }

  Map<String, dynamic> _buildInterviewResult() {
    final int totalCases = _testCaseResults.length;
    final int passedCases = _testCaseResults.where((e) => e).length;

    String status = '未作答';
    if (_lastResult != null) {
      if (totalCases > 0) {
        if (passedCases >= totalCases) {
          status = 'AC';
        } else if (passedCases == 0) {
          status = '全错';
        } else {
          status = '部分AC';
        }
      } else {
        status = _lastResult!.success ? 'AC' : '全错';
      }
    }

    return {
      'status': status,
      'passedCases': passedCases,
      'totalCases': totalCases,
      'language': _selectedLanguage,
    };
  }

  void _exitWithInterviewResult() {
    Navigator.pop(context, _buildInterviewResult());
  }

  // 撤销操作
  void _undo() {
    // 简单实现：重置为模板代码
    setState(() {
      final template = _getTemplate(_selectedLanguage);
      _codeController.text = template;
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
    return Container(
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
    return WillPopScope(
      onWillPop: () async {
        _exitWithInterviewResult();
        return false;
      },
      child: Scaffold(
        backgroundColor: BubeiColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // 代码编辑器区（VSCode Dark+风格）
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1E1E1E),
                      BubeiColors.background,
                    ],
                  ),
                ),
                child: _buildCodeEditor(),
              ),
            ),

            // 控制台面板（可展开/收起）
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _showConsole ? 200 : 0,
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
              color: BubeiColors.surface.withOpacity(0.9),
              border: Border(
                bottom: BorderSide(
                  color: BubeiColors.divider.withOpacity(0.5),
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
      onTap: _exitWithInterviewResult,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: BubeiColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: BubeiColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 16,
        ),
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
          decoration: BoxDecoration(
            color: BubeiColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: BubeiColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              BubeiColors.primary.withOpacity(0.2),
              BubeiColors.primary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTokens.radiusFull),
          border: Border.all(
            color: BubeiColors.primary.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: BubeiColors.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BubeiColors.surface.withOpacity(0.95),
            BubeiColors.background,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: BubeiColors.primary.withOpacity(0.3),
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
                  color: BubeiColors.surface.withOpacity(0.7),
                  border: Border(
                    bottom: BorderSide(
                      color: BubeiColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
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
                    // 执行统计（彩色徽章组）
                    if (_lastResult != null) ...[
                      _buildStatusBadge(_lastResult!.success),
                      const SizedBox(width: 8),
                      _buildExecutionTimeBadge(),
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
              constraints: const BoxConstraints(maxHeight: 36),
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Text(
                  _outputText.isNotEmpty ? _outputText : '点击"运行"查看输出结果...',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.5,
                    color: _lastResult?.success ?? true
                        ? const Color(0xFF9CDCFE)
                        : Colors.redAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
        boxShadow: [
          BoxShadow(
            color: (success ? BubeiColors.success : BubeiColors.error)
                .withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
            '${_lastResult!.executionTime.toStringAsFixed(0)}ms',
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
            color: BubeiColors.surface.withOpacity(0.9),
            border: Border(
              top: BorderSide(
                color: BubeiColors.primary.withOpacity(0.2),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: _showConsole
              ? LinearGradient(
                  colors: [
                    BubeiColors.primary.withOpacity(0.3),
                    BubeiColors.primary.withOpacity(0.15),
                  ],
                )
              : null,
          color: _showConsole
              ? null
              : BubeiColors.surfaceDim,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          border: Border.all(
            color: _showConsole
                ? BubeiColors.primary.withOpacity(0.5)
                : BubeiColors.divider,
            width: 1,
          ),
          boxShadow: _showConsole
              ? [
                  BoxShadow(
                    color: BubeiColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
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
    );
  }

  // 撤销按钮（毛玻璃样式）
  Widget _buildUndoButton() {
    return GestureDetector(
      onTap: _undo,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: BubeiColors.surfaceDim.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          border: Border.all(
            color: BubeiColors.divider.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.undo,
          size: 18,
          color: Colors.white70,
        ),
      ),
    );
  }

  // 运行按钮（渐变+发光）
  // 运行按钮 - 使用 TechCapsuleButton 风格 + 绿色渐变 + 脉冲动画
  Widget _buildRunButton() {
    return _TechButton(
      label: '运行',
      icon: _isRunning ? null : Icons.play_arrow,
      isLoading: _isRunning,
      gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
      glowColor: const Color(0xFF10B981),
      onPressed: _isRunning ? null : _runCode,
    );
  }

  // 提交按钮 - 使用 TechCapsuleButton 风格 + 蓝色渐变 + 脉冲动画
  Widget _buildSubmitButton() {
    return _TechButton(
      label: '提交',
      icon: _isSubmitting ? null : Icons.check,
      isLoading: _isSubmitting,
      gradientColors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
      glowColor: const Color(0xFF3B82F6),
      onPressed: _isSubmitting ? null : _submitCode,
    );
  }
}

/// 科技风格按钮 - 带渐变和脉冲发光效果
class _TechButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final List<Color> gradientColors;
  final Color glowColor;
  final VoidCallback? onPressed;

  const _TechButton({
    required this.label,
    this.icon,
    this.isLoading = false,
    required this.gradientColors,
    required this.glowColor,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
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
