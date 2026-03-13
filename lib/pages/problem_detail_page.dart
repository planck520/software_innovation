import 'dart:ui';
import 'package:flutter/material.dart';
import 'code_editor_page.dart';
import 'package:flutter/services.dart';
import '../theme/bubei_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/tech_tag.dart';
import '../widgets/code_block.dart';
import '../widgets/data_display.dart';
import '../widgets/background_decorations.dart';
import '../widgets/solution_method_selector.dart';
import '../widgets/language_selector.dart';
import '../models/solution.dart';
import '../data/solution_data.dart';
import '../data/company_data.dart';

/// 问题详情页面 - 包含4个标签页：题目详情、题解、相关企业、提交记录
class ProblemDetailPage extends StatefulWidget {
  final Map<String, dynamic> question;

  const ProblemDetailPage({
    super.key,
    required this.question,
  });

  @override
  State<ProblemDetailPage> createState() => _ProblemDetailPageState();
}

class _ProblemDetailPageState extends State<ProblemDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 题解相关状态
  List<Solution> _solutions = [];
  int _selectedSolutionIndex = 0;
  ProgrammingLanguage _selectedLanguage = ProgrammingLanguage.python;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSolutions();
  }

  void _loadSolutions() {
    // 尝试从数据源加载题解
    // 优先使用 id，如果没有则使用题目名称 'q'
    String problemId = widget.question['id']?.toString() ?? '';

    // 如果没有 id，尝试用题目名称匹配
    if (problemId.isEmpty) {
      problemId = widget.question['q']?.toString() ?? '';
    }

    final problemSolutions = getProblemSolutions(problemId);

    if (problemSolutions != null && problemSolutions.solutions.isNotEmpty) {
      _solutions = problemSolutions.solutions;
      // 默认选中推荐解法
      final recommendedIndex = _solutions.indexWhere((s) => s.isRecommended);
      _selectedSolutionIndex = recommendedIndex >= 0 ? recommendedIndex : 0;
    } else {
      // 向后兼容：创建多个默认解法供用户选择
      _solutions = _createDefaultSolutions();
    }

    // 设置默认语言为Python
    if (_solutions.isNotEmpty) {
      final supportedLangs = _solutions[_selectedSolutionIndex].supportedLanguages;
      if (supportedLangs.isNotEmpty) {
        _selectedLanguage = supportedLangs.first;
      }
    }
  }

  /// 创建多个默认解法（向后兼容）
  List<Solution> _createDefaultSolutions() {
    final baseApproach = widget.question['solutionApproach'] ?? _getDefaultSolutionApproach();
    final baseCode = widget.question['solutionCode'] ?? _getDefaultSolutionCode();
    final timeComplexity = widget.question['timeComplexity'] ?? 'O(n)';
    final spaceComplexity = widget.question['spaceComplexity'] ?? 'O(n)';

    return [
      // 解法1：哈希表（推荐）
      Solution(
        method: SolutionMethod.hashMap,
        approach: baseApproach,
        timeComplexity: timeComplexity,
        spaceComplexity: spaceComplexity,
        isRecommended: true,
        codeVersions: [
          CodeVersion(language: ProgrammingLanguage.python, code: baseCode),
          CodeVersion(language: ProgrammingLanguage.java, code: _getDefaultJavaCode()),
          CodeVersion(language: ProgrammingLanguage.javascript, code: _getDefaultJsCode()),
          CodeVersion(language: ProgrammingLanguage.cpp, code: _getDefaultCppCode()),
        ],
      ),
      // 解法2：暴力法
      Solution(
        method: SolutionMethod.bruteForce,
        approach: '''使用两层循环枚举所有可能的数对。

**核心思路：**
1. 外层循环遍历第一个数
2. 内层循环遍历第二个数
3. 检查两数之和是否等于目标值

这种方法直观易懂，但时间复杂度较高。''',
        timeComplexity: 'O(n²)',
        spaceComplexity: 'O(1)',
        isRecommended: false,
        codeVersions: [
          CodeVersion(language: ProgrammingLanguage.python, code: _getDefaultBruteForceCode()),
        ],
      ),
    ];
  }

  String _getDefaultJavaCode() {
    return '''class Solution {
    public int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> numMap = new HashMap<>();
        for (int i = 0; i < nums.length; i++) {
            int complement = target - nums[i];
            if (numMap.containsKey(complement)) {
                return new int[] { numMap.get(complement), i };
            }
            numMap.put(nums[i], i);
        }
        return new int[] {};
    }
}''';
  }

  String _getDefaultJsCode() {
    return '''var twoSum = function(nums, target) {
    const numMap = new Map();
    for (let i = 0; i < nums.length; i++) {
        const complement = target - nums[i];
        if (numMap.has(complement)) {
            return [numMap.get(complement), i];
        }
        numMap.set(nums[i], i);
    }
    return [];
};''';
  }

  String _getDefaultCppCode() {
    return '''class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        unordered_map<int, int> numMap;
        for (int i = 0; i < nums.size(); i++) {
            int complement = target - nums[i];
            if (numMap.find(complement) != numMap.end()) {
                return {numMap[complement], i};
            }
            numMap[nums[i]] = i;
        }
        return {};
    }
};''';
  }

  String _getDefaultBruteForceCode() {
    return '''class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        n = len(nums)
        for i in range(n):
            for j in range(i + 1, n):
                if nums[i] + nums[j] == target:
                    return [i, j]
        return []''';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TechBackground(
      showGradientOrbs: false,  // 不显示渐变光球，与题库有所区别
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // 自定义AppBar
            _buildAppBar(context),
            // TabBar
            _buildTabBar(),
            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProblemDetailTab(),
                  _buildSolutionTab(),
                  _buildCompaniesTab(),
                  _buildSubmissionTab(),
                ],
              ),
            ),
          ],
        ),
        // 右下角悬浮按钮
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // 构建AppBar - 返回按钮回到题库的算法编程界面（带毛玻璃效果）
  Widget _buildAppBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: AppTokens.space2,
            right: AppTokens.space2,
            bottom: AppTokens.space2,
          ),
          decoration: BoxDecoration(
            color: BubeiColors.surface.withOpacity(0.85),
            border: Border(
              bottom: BorderSide(
                color: BubeiColors.divider.withOpacity(0.5),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildBackButton(),
              const SizedBox(width: 8),
              _buildNeonIdTag(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.question['q'] ?? '编程题',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildDifficultyBadge(widget.question['difficulty'] ?? '中等'),
            ],
          ),
        ),
      ),
    );
  }

  // 霓虹ID标签
  Widget _buildNeonIdTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BubeiColors.primary,
            BubeiColors.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        boxShadow: [
          BoxShadow(
            color: BubeiColors.primary.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        '#${widget.question['id'] ?? widget.question['displayIndex'] ?? 1}',
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // 通过率进度条样式
  Widget _buildAcceptanceRate(dynamic rate) {
    final rateValue = double.tryParse(rate.toString()) ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: BubeiColors.success.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(
          color: BubeiColors.success.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            size: 10,
            color: BubeiColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            '$rateValue%',
            style: const TextStyle(
              fontSize: 11,
              color: BubeiColors.success,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // 返回按钮（带滑动返回动画效果）
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
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
          size: 20,
        ),
      ),
    );
  }

  // 构建TabBar（圆角胶囊样式）
  Widget _buildTabBar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: BubeiColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: BubeiColors.primaryGradient,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,  // 白色选中文字，更清晰
        unselectedLabelColor: BubeiColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '题目详情'),
          Tab(text: '题解'),
          Tab(text: '相关企业'),
          Tab(text: '提交记录'),
        ],
      ),
    );
  }

  // 构建题目详情标签页 - 简化结构，合并进阶理解到题目描述
  Widget _buildProblemDetailTab() {
    final question = widget.question;
    final description = question['description'] ??
                       question['a'] ??  // 优先使用 'a' 字段（答案/描述）
                       question['q'] ?? '';
    final hint = question['hint'];
    final testCases = question['testCases'];
    final constraints = question['constraints'];
    final tags = question['tags'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags标签显示（霓虹胶囊样式）
          if (tags != null && tags is List && tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (tags as List).map<Widget>((tag) {
                return TechTag(
                  label: tag.toString(),
                  color: BubeiColors.primary,
                  showGlow: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // 题目描述（包含进阶理解）
          _buildSectionTitle('题目描述'),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          // 进阶理解融入题目描述下方
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BubeiColors.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: BubeiColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology_outlined, size: 14, color: BubeiColors.primaryLight),
                    SizedBox(width: 6),
                    Text(
                      '进阶理解',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: BubeiColors.primaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  question['advancedUnderstanding'] ?? _getDefaultAdvancedUnderstanding(question),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 关键知识点 - 紧凑显示
          _buildKeyPointsCompact(question),

          const SizedBox(height: 20),

          // 示例区 - 2-3个代表性示例
          _buildExamplesSection(testCases),

          const SizedBox(height: 20),

          // 约束条件区
          if (constraints != null && constraints.toString().isNotEmpty)
            _buildConstraintsSection(constraints.toString()),

          const SizedBox(height: 20),

          // 边界情况
          _buildEdgeCasesCompact(question),

          const SizedBox(height: 20),

          // 提示区
          if (hint != null) _buildHintSection(hint.toString()),

          const SizedBox(height: 80), // 底部留白给悬浮按钮
        ],
      ),
    );
  }

  // 构建小节标题
  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: BubeiColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(
          color: BubeiColors.primary.withOpacity(0.4),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: BubeiColors.primaryLight,
        ),
      ),
    );
  }

  // 构建进阶理解
  Widget _buildAdvancedUnderstanding(Map<String, dynamic> question) {
    final understanding = question['advancedUnderstanding'] ?? _getDefaultAdvancedUnderstanding(question);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BubeiColors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: BubeiColors.divider),
      ),
      child: Text(
        understanding,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white70,
          height: 1.6,
        ),
      ),
    );
  }

  // 构建解题思路
  Widget _buildSolutionAnalysis(Map<String, dynamic> question) {
    final analysis = question['solutionAnalysis'] ?? _getDefaultSolutionAnalysis(question);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BubeiColors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: BubeiColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_outlined, size: 16, color: BubeiColors.primaryLight),
              SizedBox(width: 8),
              Text(
                '思路分析',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: BubeiColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            analysis,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // 构建关键知识点
  Widget _buildKeyPoints(Map<String, dynamic> question) {
    final keyPoints = question['keyPoints'] as List<dynamic>? ?? _getDefaultKeyPoints(question);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: keyPoints.map<Widget>((point) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: BubeiColors.surfaceDim,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            border: Border.all(color: BubeiColors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF4EC9B0)),
              const SizedBox(width: 6),
              Text(
                point.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 构建边界情况
  Widget _buildEdgeCases(Map<String, dynamic> question) {
    final edgeCases = question['edgeCases'] as List<dynamic>? ?? _getDefaultEdgeCases(question);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BubeiColors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: BubeiColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_outlined, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                '需要注意的边界情况',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...edgeCases.map((caseItem) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        caseItem.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // 紧凑版关键知识点
  Widget _buildKeyPointsCompact(Map<String, dynamic> question) {
    final keyPoints = question['keyPoints'] as List<dynamic>? ?? _getDefaultKeyPoints(question);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lightbulb_outline, size: 14, color: Color(0xFF4EC9B0)),
            SizedBox(width: 6),
            Text(
              '关键知识点',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4EC9B0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: keyPoints.take(5).map<Widget>((point) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: BubeiColors.surfaceDim,
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              child: Text(
                point.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 紧凑版边界情况
  Widget _buildEdgeCasesCompact(Map<String, dynamic> question) {
    final edgeCases = question['edgeCases'] as List<dynamic>? ?? _getDefaultEdgeCases(question);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.warning_amber_outlined, size: 14, color: Colors.orange),
            SizedBox(width: 6),
            Text(
              '边界情况',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: edgeCases.take(4).map<Widget>((caseItem) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text(
                caseItem.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.orange,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 构建题解标签页
  Widget _buildSolutionTab() {
    if (_solutions.isEmpty) {
      return const Center(
        child: Text('暂无题解', style: TextStyle(color: Colors.white54)),
      );
    }

    final currentSolution = _solutions[_selectedSolutionIndex];
    final codeVersion = currentSolution.getCodeVersion(_selectedLanguage);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 解法选择器
          if (_solutions.length > 1)
            SolutionMethodSelector(
              solutions: _solutions,
              selectedIndex: _selectedSolutionIndex,
              onMethodSelected: (index) {
                setState(() {
                  _selectedSolutionIndex = index;
                  // 更新默认语言
                  final supportedLangs = _solutions[index].supportedLanguages;
                  if (supportedLangs.isNotEmpty && !supportedLangs.contains(_selectedLanguage)) {
                    _selectedLanguage = supportedLangs.first;
                  }
                });
              },
            ),
          if (_solutions.length > 1) const SizedBox(height: 20),

          // 解题思路卡片
          _buildSolutionDetailCard(currentSolution),
          const SizedBox(height: 20),

          // 语言选择器和复杂度
          _buildLanguageAndComplexityRow(currentSolution),
          const SizedBox(height: 16),

          // 代码块
          if (codeVersion != null)
            CodeBlock(
              code: codeVersion.code,
              language: _selectedLanguage.name,
              title: 'solution${_selectedLanguage.extension}',
              showLineNumbers: true,
              showCopyButton: true,
              enableHighlight: true,
            )
          else
            _buildNoCodePlaceholder(),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // 构建解题思路详情卡片
  Widget _buildSolutionDetailCard(Solution solution) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BubeiColors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: BubeiColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BubeiColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      solution.method.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: BubeiColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (solution.isRecommended) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 10, color: Colors.amber),
                      SizedBox(width: 2),
                      Text(
                        '推荐',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            solution.approach,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // 构建语言选择器和复杂度行
  Widget _buildLanguageAndComplexityRow(Solution solution) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 语言选择器
        LanguageSelector(
          selectedLanguage: _selectedLanguage,
          availableLanguages: solution.supportedLanguages,
          onLanguageChanged: (language) {
            setState(() {
              _selectedLanguage = language;
            });
          },
        ),
        const SizedBox(height: 8),
        // 复杂度标签 - 使用 Wrap 防止溢出
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildComplexityBadge('⏱️', solution.timeComplexity, const Color(0xFF4EC9B0)),
            _buildComplexityBadge('💾', solution.spaceComplexity, const Color(0xFF569CD6)),
          ],
        ),
      ],
    );
  }

  // 构建复杂度徽章
  Widget _buildComplexityBadge(String icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  // 构建无代码占位符
  Widget _buildNoCodePlaceholder() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BubeiColors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: BubeiColors.divider),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.code_off, size: 32, color: Colors.white38),
            const SizedBox(height: 8),
            Text(
              '该解法暂无 ${_selectedLanguage.label} 代码',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // 构建相关企业标签页
  Widget _buildCompaniesTab() {
    // 根据题目特征匹配相关企业
    final companies = _getRelatedCompanies();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区域（卡片样式，与题解界面一致）
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BubeiColors.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: BubeiColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BubeiColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.business,
                            color: BubeiColors.primaryLight,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '相关企业',
                            style: TextStyle(
                              fontSize: 14,
                              color: BubeiColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.amber.shade300),
                          const SizedBox(width: 4),
                          Text(
                            '${companies.length}家企业',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.amber,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '根据题目特征智能匹配，以下企业可能考察此类题目',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 企业列表
          ...companies.map((company) => _buildCompanyCard(company)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // 构建提交记录标签页
  Widget _buildSubmissionTab() {
    final submissions = widget.question['submissions'] as List<dynamic>?;
    final mockSubmissions = submissions ?? _getMockSubmissions();

    // 计算统计数据
    final totalSubmissions = mockSubmissions.length;
    final passedCount = mockSubmissions.where((s) => (s['passed'] as bool?) == true).length;
    final passRate = totalSubmissions > 0 ? (passedCount / totalSubmissions * 100).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区域（卡片样式，与题解界面一致）
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BubeiColors.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: BubeiColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BubeiColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.send,
                            color: BubeiColors.primaryLight,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '提交记录',
                            style: TextStyle(
                              fontSize: 14,
                              color: BubeiColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BubeiColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      ),
                      child: Text(
                        '$totalSubmissions 次提交',
                        style: const TextStyle(
                          fontSize: 11,
                          color: BubeiColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 统计概览
                Row(
                  children: [
                    _buildStatItem('通过', passedCount.toString(), BubeiColors.success),
                    const SizedBox(width: 24),
                    _buildStatItem('未通过', (totalSubmissions - passedCount).toString(), Colors.red),
                    const SizedBox(width: 24),
                    _buildStatItem('通过率', '$passRate%', passRate >= 50 ? BubeiColors.success : Colors.orange),
                  ],
                ),
                const SizedBox(height: 12),
                // 通过率进度条
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalSubmissions > 0 ? passedCount / totalSubmissions : 0,
                    backgroundColor: Colors.red.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      passRate >= 50 ? BubeiColors.success : Colors.orange,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 提交记录列表
          ...mockSubmissions.map((submission) {
            final index = mockSubmissions.indexOf(submission);
            return _buildSubmissionCard(submission as Map<String, dynamic>, index + 1);
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // 构建统计项
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // 构建悬浮按钮（带脉冲动画）
  Widget _buildFloatingActionButton() {
    return _PulsingFloatingActionButton(
      onPressed: () async {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => CodeEditorPage(question: widget.question),
          ),
        );
        if (!mounted || result == null) return;
        Navigator.pop(context, result);
      },
    );
  }

  // 构建难度标签
  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty) {
      case '简单':
      case '基础':
        color = Colors.green;
        break;
      case '中等':
        color = Colors.orange;
        break;
      case '困难':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 构建示例区
  Widget _buildExamplesSection(dynamic examples) {
    // 默认示例
    final defaultExamples = [
      {'input': '[2, 7, 11, 15]', 'output': '[0, 1]'},
      {'input': '[3, 2, 4]', 'output': '[1, 2]'},
      {'input': '[3, 3]', 'output': '[0, 1]'},
    ];

    List<Map<String, dynamic>> exampleList = [];

    if (examples == null) {
      // 使用默认示例的前2个
      exampleList = defaultExamples.take(2).toList().cast<Map<String, dynamic>>();
    } else if (examples is List && examples.isNotEmpty) {
      // 取前2-3个示例
      exampleList = examples.take(3).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    if (exampleList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.code, size: 14, color: BubeiColors.primaryLight),
            SizedBox(width: 6),
            Text(
              '示例',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: BubeiColors.primaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...exampleList.asMap().entries.map((entry) {
          final index = entry.key;
          final example = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildSingleExample(
              example['input']?.toString() ?? '',
              example['output']?.toString() ?? '',
              exampleNumber: index + 1,
              explanation: example['explanation']?.toString(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSingleExample(
    String input,
    String output, {
    int exampleNumber = 1,
    String? explanation,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BubeiColors.surfaceDim,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: BubeiColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (exampleNumber > 1)
            Text(
              '示例 $exampleNumber:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          if (exampleNumber > 1) const SizedBox(height: 8),
          _buildExampleLine('nums = ', input),
          const SizedBox(height: 4),
          _buildExampleLine('输出: ', output),
          if (explanation != null && explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              explanation,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 构建约束条件区
  Widget _buildConstraintsSection(String constraints) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BubeiColors.surfaceDim,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: BubeiColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.orange),
              SizedBox(width: 6),
              Text(
                '约束条件:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            constraints,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 构建提示区
  Widget _buildHintSection(String hint) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      iconColor: Colors.amber,
      collapsedIconColor: Colors.amber,
      title: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
          SizedBox(width: 8),
          Text(
            '提示',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Text(
            hint,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.amber,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComplexityItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: BubeiColors.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: BubeiColors.primaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyCard(Map<String, dynamic> company) {
    final companyName = company['name'] as String;
    final shortName = company['shortName'] as String? ?? companyName.substring(0, 1);
    final color = company['color'] as Color;
    final frequency = company['frequency'] as String? ?? '较常考';
    final reason = company['reason'] as String? ?? '面试常见';
    final industry = company['industry'] as String? ?? '互联网';
    final logoUrl = company['logoUrl'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BubeiColors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: frequency == '高频'
              ? color.withOpacity(0.4)
              : BubeiColors.divider,
        ),
        boxShadow: frequency == '高频'
            ? [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // 企业Logo - 使用logo.dev API
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd - 1),
              child: logoUrl != null
                  ? Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      width: 44,
                      height: 44,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Logo load error for $logoUrl: $error');
                        return _buildLogoFallback(shortName, color);
                      },
                    )
                  : _buildLogoFallback(shortName, color),
            ),
          ),
          const SizedBox(width: 14),
          // 企业信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      companyName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildFrequencyBadge(frequency, color),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 12,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  industry,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // 箭头
          Icon(
            Icons.chevron_right,
            color: Colors.white38,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Logo加载失败时的备选显示
  Widget _buildLogoFallback(String shortName, Color color) {
    final displayText = shortName.length > 2 ? shortName.substring(0, 2) : shortName;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: displayText.length > 1 ? 12 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // 构建频率标签
  Widget _buildFrequencyBadge(String frequency, Color color) {
    IconData icon;
    Color badgeColor;

    switch (frequency) {
      case '高频':
        icon = Icons.local_fire_department;
        badgeColor = Colors.orange;
        break;
      case '较常考':
        icon = Icons.trending_up;
        badgeColor = Colors.blue;
        break;
      default:
        icon = Icons.check_circle_outline;
        badgeColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: badgeColor),
          const SizedBox(width: 3),
          Text(
            frequency,
            style: TextStyle(
              fontSize: 10,
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> submission, int index) {
    final bool passed = submission['passed'] ?? false;
    final String language = submission['language'] ?? 'Python';
    final String time = submission['time'] ?? '0ms';
    final String memory = submission['memory'] ?? '10MB';
    final String date = submission['date'] ?? '刚刚';

    final statusColor = passed ? BubeiColors.success : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BubeiColors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: passed
              ? BubeiColors.success.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
        boxShadow: passed
            ? [
                BoxShadow(
                  color: BubeiColors.success.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // 状态图标（渐变背景）
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: passed
                    ? [BubeiColors.success, BubeiColors.success.withOpacity(0.6)]
                    : [Colors.red, Colors.red.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              passed ? Icons.check : Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '提交 #$index',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 状态标签（渐变背景）
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: passed
                              ? [BubeiColors.success.withOpacity(0.3), BubeiColors.success.withOpacity(0.1)]
                              : [Colors.red.withOpacity(0.3), Colors.red.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                        border: Border.all(
                          color: statusColor.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            passed ? Icons.check_circle : Icons.cancel,
                            size: 12,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            passed ? '通过' : '未通过',
                            style: TextStyle(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 详情信息
                Row(
                  children: [
                    // 语言
                    _buildSubmissionDetail(Icons.code, language, BubeiColors.primaryLight),
                    const SizedBox(width: 16),
                    // 执行时间
                    _buildSubmissionDetail(Icons.timer_outlined, time, Colors.amber),
                    const SizedBox(width: 16),
                    // 内存
                    _buildSubmissionDetail(Icons.memory, memory, Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          // 时间
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建提交详情项
  Widget _buildSubmissionDetail(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withOpacity(0.8)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExampleLine(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: Color(0xFF9CDCFE),
        ),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  // 获取默认解题思路
  String _getDefaultSolutionApproach() {
    return '''本题是一道经典的算法题目。

1. 首先理解题意，分析输入输出
2. 思考可能的解题方法
3. 选择最优解法
4. 编写代码并测试

建议先尝试自己解决，如果卡住可以参考下面的代码实现。''';
  }

  // 获取默认参考代码
  String _getDefaultSolutionCode() {
    return '''class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        # 创建哈希表存储数值和索引
        num_map = {}

        for i, num in enumerate(nums):
            complement = target - num
            if complement in num_map:
                return [num_map[complement], i]
            num_map[num] = i

        return []''';
  }

  // 获取默认进阶理解
  String _getDefaultAdvancedUnderstanding(Map<String, dynamic> question) {
    return '''这道题目要求我们在一个整数数组中找到两个数，使它们的和等于目标值。

**核心要点：**
1. 需要返回两个数的索引，而不是数值本身
2. 每个输入只对应唯一答案，不能重复使用同一个元素
3. 可以按任意顺序返回答案

**问题本质：**
这是一个典型的"查找配对"问题，需要高效的查找方法来降低时间复杂度。通过哈希表可以将查找操作从O(n)降到O(1)。''';
  }

  // 获取默认解题分析
  String _getDefaultSolutionAnalysis(Map<String, dynamic> question) {
    return '''**方法一：暴力枚举**
- 使用两层循环遍历所有可能的组合
- 时间复杂度：O(n²)
- 空间复杂度：O(1)

**方法二：哈希表（推荐）**
- 使用哈希表存储已遍历的数值及其索引
- 对于每个数，检查目标值减去当前数是否在哈希表中
- 时间复杂度：O(n)
- 空间复杂度：O(n)

哈希表方法通过空间换时间，将查找操作从O(n)降到O(1)，是本题的最优解。对于这道题，哈希表方法不仅能正确解决问题，还能在一次遍历中完成。''';
  }

  // 获取默认关键知识点
  List<dynamic> _getDefaultKeyPoints(Map<String, dynamic> question) {
    return [
      '哈希表（HashMap）的使用',
      '数组遍历技巧',
      '时间复杂度与空间复杂度的权衡',
      '互补数的概念',
      '索引与数值的区别',
    ];
  }

  // 获取默认边界情况
  List<dynamic> _getDefaultEdgeCases(Map<String, dynamic> question) {
    return [
      '数组长度为2的最小情况',
      '答案包含第一个或最后一个元素',
      '存在负数的情况',
      '目标值为负数的情况',
      '存在多个相同值的情况',
      '数组中无解的情况（题目保证有解）',
    ];
  }

  // 获取相关企业列表（基于题目特征匹配）
  List<Map<String, dynamic>> _getRelatedCompanies() {
    // 获取题目标签
    final tags = widget.question['tags'] as List<dynamic>? ?? [];
    final tagStrings = tags.map((t) => t.toString()).toList();

    // 如果没有标签，根据题目内容推断
    if (tagStrings.isEmpty) {
      final questionText = (widget.question['q'] ?? '').toString().toLowerCase();
      final description = (widget.question['description'] ?? '').toString().toLowerCase();
      final combinedText = '$questionText $description';

      // 根据题目内容推断标签
      if (combinedText.contains('数组') || combinedText.contains('array')) {
        tagStrings.add('数组');
      }
      if (combinedText.contains('链表') || combinedText.contains('list')) {
        tagStrings.add('链表');
      }
      if (combinedText.contains('树') || combinedText.contains('tree')) {
        tagStrings.add('树');
      }
      if (combinedText.contains('图') || combinedText.contains('graph')) {
        tagStrings.add('图');
      }
      if (combinedText.contains('字符串') || combinedText.contains('string')) {
        tagStrings.add('字符串');
      }
      if (combinedText.contains('动态规划') || combinedText.contains('dp')) {
        tagStrings.add('动态规划');
      }

      // 默认添加一些通用标签
      if (tagStrings.isEmpty) {
        tagStrings.addAll(['算法', '数据结构']);
      }
    }

    final difficulty = widget.question['difficulty'] ?? '中等';

    return CompanyDatabase.getRelatedCompanies(tagStrings, difficulty);
  }

  // 获取模拟提交记录
  List<Map<String, dynamic>> _getMockSubmissions() {
    return [
      {
        'passed': true,
        'language': 'Python',
        'time': '52ms',
        'date': '2小时前',
      },
      {
        'passed': false,
        'language': 'Python',
        'time': '48ms',
        'date': '3小时前',
      },
      {
        'passed': false,
        'language': 'JavaScript',
        'time': '64ms',
        'date': '昨天',
      },
      {
        'passed': true,
        'language': 'Java',
        'time': '72ms',
        'date': '2天前',
      },
    ];
  }
}

// 脉冲动画悬浮按钮
class _PulsingFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PulsingFloatingActionButton({
    required this.onPressed,
  });

  @override
  State<_PulsingFloatingActionButton> createState() =>
      _PulsingFloatingActionButtonState();
}

class _PulsingFloatingActionButtonState
    extends State<_PulsingFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // 脉冲动画控制器
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);

    // 缩放动画控制器
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _scaleController.forward();
      },
      onTapUp: (_) {
        _scaleController.reverse();
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () {
        _scaleController.reverse();
        setState(() => _isPressed = false);
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _scaleController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4EC9B0),
                    BubeiColors.primary,
                  ],
                ),
                boxShadow: [
                  // 基础阴影
                  BoxShadow(
                    color: const Color(0xFF4EC9B0).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  // 脉冲发光效果
                  BoxShadow(
                    color: BubeiColors.primary.withOpacity(
                      0.3 + _pulseAnimation.value * 0.4,
                    ),
                    blurRadius: 20 + _pulseAnimation.value * 15,
                    spreadRadius: _pulseAnimation.value * 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.code,
                color: Colors.white,
                size: 28,
              ),
            ),
          );
        },
      ),
    );
  }
}
