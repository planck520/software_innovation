import 'package:flutter/material.dart';
import '../config/env_config.dart';

/// 企业数据模型
class Company {
  final String name;
  final String shortName;
  final String? logoName;        // 用于logo API的公司名称(英文)
  final Color color;
  final List<String> tagPreferences;
  final Map<String, int> difficultyWeight;
  final String industry;

  const Company({
    required this.name,
    required this.shortName,
    this.logoName,
    required this.color,
    required this.tagPreferences,
    required this.difficultyWeight,
    required this.industry,
  });

  /// 获取logo URL (使用logo.dev图片CDN，需要域名格式)
  String? get logoUrl {
    if (logoName == null) return null;
    final apiKey = EnvConfig.getOrNull('LOGO_DEV_API_KEY') ?? 'pk_fbuqzGWbTui-LzrxeLxFrA';
    return 'https://img.logo.dev/${logoName}?token=$apiKey';
  }

  /// 计算与题目的匹配分数
  int calculateMatchScore(List<String> questionTags, String difficulty) {
    int score = 0;

    // 标签匹配
    for (final tag in questionTags) {
      if (tagPreferences.any((pref) =>
          pref.toLowerCase() == tag.toLowerCase() ||
          tag.toLowerCase().contains(pref.toLowerCase()) ||
          pref.toLowerCase().contains(tag.toLowerCase()))) {
        score += 10;
      }
    }

    // 难度权重
    score += difficultyWeight[difficulty] ?? 5;

    return score;
  }

  /// 获取匹配理由
  String getMatchReason(List<String> questionTags, String difficulty) {
    final matchedTags = <String>[];

    for (final tag in questionTags) {
      if (tagPreferences.any((pref) =>
          pref.toLowerCase() == tag.toLowerCase() ||
          tag.toLowerCase().contains(pref.toLowerCase()) ||
          pref.toLowerCase().contains(tag.toLowerCase()))) {
        matchedTags.add(tag);
      }
    }

    if (matchedTags.isNotEmpty) {
      return '偏好${matchedTags.take(2).join('、')}题目';
    }

    if (difficulty == '困难' && (difficultyWeight['困难'] ?? 0) >= 8) {
      return '常考难题';
    } else if (difficulty == '基础' && (difficultyWeight['基础'] ?? 0) >= 8) {
      return '基础题偏多';
    } else if (difficulty == '中等' && (difficultyWeight['中等'] ?? 0) >= 8) {
      return '中等难度高频';
    }

    return '面试常见';
  }
}

/// 企业数据库
class CompanyDatabase {
  static const List<Company> companies = [
    // 国内大厂
    Company(
      name: '字节跳动',
      shortName: '字节',
      logoName: 'bytedance.com',
      color: Color(0xFF325AB4),
      tagPreferences: ['数组', '双指针', '动态规划', '字符串', '滑动窗口', '哈希表'],
      difficultyWeight: {'基础': 5, '中等': 8, '困难': 10},
      industry: '互联网',
    ),
    Company(
      name: '腾讯',
      shortName: '腾讯',
      logoName: 'tencent.com',
      color: Color(0xFF00A4FF),
      tagPreferences: ['链表', '二叉树', 'SQL', '设计', '贪心', '堆'],
      difficultyWeight: {'基础': 6, '中等': 10, '困难': 7},
      industry: '互联网',
    ),
    Company(
      name: '阿里巴巴',
      shortName: '阿里',
      logoName: 'alibaba.com',
      color: Color(0xFFFF6A00),
      tagPreferences: ['系统设计', '并发', '动态规划', '树', '图', '分布式'],
      difficultyWeight: {'基础': 4, '中等': 8, '困难': 10},
      industry: '电商',
    ),
    Company(
      name: '美团',
      shortName: '美团',
      logoName: 'meituan.com',
      color: Color(0xFFFFC300),
      tagPreferences: ['贪心', '回溯', '动态规划', '图', '最短路径', '模拟'],
      difficultyWeight: {'基础': 5, '中等': 10, '困难': 7},
      industry: '生活服务',
    ),
    Company(
      name: '华为',
      shortName: '华为',
      logoName: 'huawei.com',
      color: Color(0xFFCF0A2C),
      tagPreferences: ['图论', 'DFS', 'BFS', '动态规划', '字符串', '数学'],
      difficultyWeight: {'基础': 4, '中等': 7, '困难': 10},
      industry: '通信',
    ),
    Company(
      name: '百度',
      shortName: '百度',
      logoName: 'baidu.com',
      color: Color(0xFF2932E1),
      tagPreferences: ['字符串', '滑动窗口', '正则', 'NLP', '搜索', '数组'],
      difficultyWeight: {'基础': 8, '中等': 9, '困难': 5},
      industry: '互联网',
    ),
    Company(
      name: '快手',
      shortName: '快手',
      logoName: 'kuaishou.com',
      color: Color(0xFFFF4906),
      tagPreferences: ['堆', '优先队列', '双指针', '滑动窗口', '动态规划'],
      difficultyWeight: {'基础': 5, '中等': 10, '困难': 8},
      industry: '短视频',
    ),
    Company(
      name: '京东',
      shortName: '京东',
      logoName: 'jd.com',
      color: Color(0xFFE1251B),
      tagPreferences: ['设计模式', '系统设计', '树', '链表', '排序', '搜索'],
      difficultyWeight: {'基础': 6, '中等': 9, '困难': 6},
      industry: '电商',
    ),
    Company(
      name: '小红书',
      shortName: '红书',
      logoName: 'xiaohongshu.com',
      color: Color(0xFFFF2442),
      tagPreferences: ['推荐系统', '图', '哈希表', '字符串', '动态规划'],
      difficultyWeight: {'基础': 6, '中等': 9, '困难': 7},
      industry: '社交',
    ),
    Company(
      name: '滴滴',
      shortName: '滴滴',
      logoName: 'didiglobal.com',
      color: Color(0xFFFF7E00),
      tagPreferences: ['图', '最短路径', '几何', '动态规划', '贪心'],
      difficultyWeight: {'基础': 5, '中等': 10, '困难': 8},
      industry: '出行',
    ),
    Company(
      name: '网易',
      shortName: '网易',
      logoName: '163.com',
      color: Color(0xFFD43C33),
      tagPreferences: ['游戏', '算法', '数学', '概率', '动态规划'],
      difficultyWeight: {'基础': 5, '中等': 9, '困难': 8},
      industry: '游戏',
    ),
    Company(
      name: '小米',
      shortName: '小米',
      logoName: 'xiaomi.com',
      color: Color(0xFFFF6900),
      tagPreferences: ['嵌入式', 'Android', 'UI', '性能优化', '设计'],
      difficultyWeight: {'基础': 6, '中等': 9, '困难': 6},
      industry: '硬件',
    ),

    // 外企
    Company(
      name: 'Google',
      shortName: 'Google',
      logoName: 'google.com',
      color: Color(0xFF4285F4),
      tagPreferences: ['动态规划', '图论', '数学', '设计', '递归', '分治'],
      difficultyWeight: {'基础': 3, '中等': 7, '困难': 10},
      industry: '科技',
    ),
    Company(
      name: 'Microsoft',
      shortName: 'MS',
      logoName: 'microsoft.com',
      color: Color(0xFF00A4EF),
      tagPreferences: ['设计模式', '面向对象', '树', '链表', '字符串', '动态规划'],
      difficultyWeight: {'基础': 6, '中等': 10, '困难': 7},
      industry: '科技',
    ),
    Company(
      name: 'Amazon',
      shortName: 'Amazon',
      logoName: 'amazon.com',
      color: Color(0xFFFF9900),
      tagPreferences: ['贪心', '模拟', '设计', '树', '数组', '排序'],
      difficultyWeight: {'基础': 5, '中等': 10, '困难': 6},
      industry: '电商',
    ),
    Company(
      name: 'Apple',
      shortName: 'Apple',
      logoName: 'apple.com',
      color: Color(0xFF555555),
      tagPreferences: ['UI设计', '动画', '链表', '树', '双指针', '字符串'],
      difficultyWeight: {'基础': 5, '中等': 9, '困难': 8},
      industry: '科技',
    ),
    Company(
      name: 'Meta',
      shortName: 'Meta',
      logoName: 'meta.com',
      color: Color(0xFF0668E1),
      tagPreferences: ['图', '动态规划', '双指针', '滑动窗口', '设计'],
      difficultyWeight: {'基础': 4, '中等': 9, '困难': 9},
      industry: '社交',
    ),

    // 金融科技
    Company(
      name: '蚂蚁集团',
      shortName: '蚂蚁',
      logoName: 'antgroup.com',
      color: Color(0xFF1677FF),
      tagPreferences: ['并发', '分布式', '设计', '动态规划', '安全'],
      difficultyWeight: {'基础': 4, '中等': 8, '困难': 10},
      industry: '金融科技',
    ),
    Company(
      name: '招商银行',
      shortName: '招行',
      logoName: 'cmbchina.com',
      color: Color(0xFFE60012),
      tagPreferences: ['SQL', '数据处理', '数学', '字符串', '设计'],
      difficultyWeight: {'基础': 7, '中等': 9, '困难': 5},
      industry: '银行',
    ),
  ];

  /// 根据题目特征获取相关企业
  static List<Map<String, dynamic>> getRelatedCompanies(
    List<String> questionTags,
    String difficulty,
  ) {
    final scoredCompanies = <Map<String, dynamic>>[];

    for (final company in companies) {
      final score = company.calculateMatchScore(questionTags, difficulty);
      final reason = company.getMatchReason(questionTags, difficulty);

      // 添加少量随机因子
      final randomBonus = (company.name.hashCode % 5);
      final finalScore = score + randomBonus;

      scoredCompanies.add({
        'name': company.name,
        'shortName': company.shortName,
        'logoUrl': company.logoUrl,
        'color': company.color,
        'score': finalScore,
        'reason': reason,
        'industry': company.industry,
      });
    }

    // 按分数排序
    scoredCompanies.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    // 确保多样性：同一行业最多2个
    final selectedCompanies = <Map<String, dynamic>>[];
    final industryCount = <String, int>{};

    for (final company in scoredCompanies) {
      final industry = company['industry'] as String;
      final count = industryCount[industry] ?? 0;

      if (count < 2 && selectedCompanies.length < 5) {
        selectedCompanies.add(company);
        industryCount[industry] = count + 1;
      }
    }

    // 补充剩余
    if (selectedCompanies.length < 5) {
      for (final company in scoredCompanies) {
        if (!selectedCompanies.any((c) => c['name'] == company['name'])) {
          selectedCompanies.add(company);
          if (selectedCompanies.length >= 5) break;
        }
      }
    }

    // 添加频率标签
    for (int i = 0; i < selectedCompanies.length; i++) {
      final score = selectedCompanies[i]['score'] as int;
      if (i == 0 || score >= 15) {
        selectedCompanies[i]['frequency'] = '高频';
      } else if (score >= 10) {
        selectedCompanies[i]['frequency'] = '较常考';
      } else {
        selectedCompanies[i]['frequency'] = '偶考';
      }
    }

    return selectedCompanies;
  }
}
