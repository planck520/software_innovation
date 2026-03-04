import '../models/solution.dart';

/// 题解示例数据
/// 为11道算法题目提供多解法、多语言支持

// ==================== 1. 两数之和 ====================

final Solution twoSumHashMapSolution = Solution(
  method: SolutionMethod.hashMap,
  approach: '''使用哈希表在 O(n) 时间复杂度内解决问题。

**核心思路：**
1. 遍历数组，对于每个元素 nums[i]
2. 计算 complement = target - nums[i]
3. 检查 complement 是否已在哈希表中
4. 如果存在，返回两个索引；否则将当前元素加入哈希表

**为什么哈希表快？**
- 哈希表的查找时间复杂度为 O(1)
- 只需一次遍历即可找到答案

**适用场景：**
- 需要快速查找元素是否存在于集合中''',
  timeComplexity: 'O(n)',
  spaceComplexity: 'O(n)',
  isRecommended: true,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        num_map = {}
        for i, num in enumerate(nums):
            complement = target - num
            if complement in num_map:
                return [num_map[complement], i]
            num_map[num] = i
        return []''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
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
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var twoSum = function(nums, target) {
    const numMap = new Map();
    for (let i = 0; i < nums.length; i++) {
        const complement = target - nums[i];
        if (numMap.has(complement)) {
            return [numMap.get(complement), i];
        }
        numMap.set(nums[i], i);
    }
    return [];
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
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
};''',
    ),
  ],
);

final Solution twoSumBruteForceSolution = Solution(
  method: SolutionMethod.bruteForce,
  approach: '''暴力枚举所有可能的数对。

**核心思路：**
1. 使用两层循环遍历数组
2. 检查每对元素的和是否等于 target
3. 返回满足条件的两个索引

**复杂度分析：**
- 时间复杂度 O(n²)，需要遍历所有可能的组合
- 空间复杂度 O(1)，只使用常量额外空间

**适用场景：**
- 数据量较小时
- 面试中快速实现方案''',
  timeComplexity: 'O(n²)',
  spaceComplexity: 'O(1)',
  isRecommended: false,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        n = len(nums)
        for i in range(n):
            for j in range(i + 1, n):
                if nums[i] + nums[j] == target:
                    return [i, j]
        return []''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public int[] twoSum(int[] nums, int target) {
        for (int i = 0; i < nums.length; i++) {
            for (int j = i + 1; j < nums.length; j++) {
                if (nums[i] + nums[j] == target) {
                    return new int[] {i, j};
                }
            }
        }
        return new int[] {};
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var twoSum = function(nums, target) {
    for (let i = 0; i < nums.length; i++) {
        for (let j = i + 1; j < nums.length; j++) {
            if (nums[i] + nums[j] === target) {
                return [i, j];
            }
        }
    }
    return [];
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        for (int i = 0; i < nums.size(); i++) {
            for (int j = i + 1; j < nums.size(); j++) {
                if (nums[i] + nums[j] == target) {
                    return {i, j};
                }
            }
        }
        return {};
    }
};''',
    ),
  ],
);

final ProblemSolutions twoSumSolutions = ProblemSolutions(
  problemId: 'two-sum',
  solutions: [twoSumHashMapSolution, twoSumBruteForceSolution],
);

// ==================== 2. 反转字符串 ====================

final Solution reverseStringTwoPointersSolution = Solution(
  method: SolutionMethod.twoPointers,
  approach: '''使用双指针原地反转字符串。

**核心思路：**
1. 设置左指针指向开头，右指针指向末尾
2. 交换左右指针指向的字符
3. 左指针右移，右指针左移
4. 重复直到两指针相遇

**复杂度分析：**
- 时间复杂度 O(n)，只需遍历半个数组
- 空间复杂度 O(1)，原地交换''',
  timeComplexity: 'O(n)',
  spaceComplexity: 'O(1)',
  isRecommended: true,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''def reverseString(s: List[str]) -> None:
    left, right = 0, len(s) - 1
    while left < right:
        s[left], s[right] = s[right], s[left]
        left += 1
        right -= 1''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public void reverseString(char[] s) {
        int left = 0, right = s.length - 1;
        while (left < right) {
            char temp = s[left];
            s[left++] = s[right];
            s[right--] = temp;
        }
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''/**
 * @param {character[]} s
 * @return {void} Do not return anything, modify s in-place instead.
 */
var reverseString = function(s) {
    let left = 0, right = s.length - 1;
    while (left < right) {
        [s[left], s[right]] = [s[right], s[left]];
        left++;
        right--;
    }
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    void reverseString(vector<char>& s) {
        int left = 0, right = s.size() - 1;
        while (left < right) {
            swap(s[left++], s[right--]);
        }
    }
};''',
    ),
  ],
);

final Solution reverseStringBuiltInSolution = Solution(
  method: SolutionMethod.bruteForce,
  approach: '''使用语言内置函数反转。

**核心思路：**
- Python: 使用切片 [::-1]
- 直接调用内置的 reverse 函数

**注意：**
- 这种方法会创建新字符串，不是原地操作
- 面试中如果要求原地反转，不建议使用''',
  timeComplexity: 'O(n)',
  spaceComplexity: 'O(n)',
  isRecommended: false,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''def reverseString(s: List[str]) -> None:
    s[:] = s[::-1]''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public void reverseString(char[] s) {
        int left = 0, right = s.length - 1;
        while (left < right) {
            char tmp = s[left];
            s[left] = s[right];
            s[right] = tmp;
            left++;
            right--;
        }
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var reverseString = function(s) {
    s.reverse();
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    void reverseString(vector<char>& s) {
        reverse(s.begin(), s.end());
    }
};''',
    ),
  ],
);

final ProblemSolutions reverseStringSolutions = ProblemSolutions(
  problemId: 'reverse-string',
  solutions: [reverseStringTwoPointersSolution, reverseStringBuiltInSolution],
);

// ==================== 3. 斐波那契数列 ====================

final Solution fibonacciDPSolution = Solution(
  method: SolutionMethod.dynamicProgramming,
  approach: '''动态规划解法 - 自底向上计算。

**核心思路：**
1. 状态定义：dp[i] 表示第 i 个斐波那契数
2. 状态转移：dp[i] = dp[i-1] + dp[i-2]
3. 初始化：dp[0] = 0, dp[1] = 1
4. 迭代计算到第 n 个

**空间优化：**
- 只需保存前两个数，无需整个数组
- 空间复杂度降为 O(1)''',
  timeComplexity: 'O(n)',
  spaceComplexity: 'O(1)',
  isRecommended: true,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''def fib(n: int) -> int:
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public int fib(int n) {
        if (n <= 1) return n;
        int a = 0, b = 1;
        for (int i = 2; i <= n; i++) {
            int sum = a + b;
            a = b;
            b = sum;
        }
        return b;
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var fib = function(n) {
    if (n <= 1) return n;
    let a = 0, b = 1;
    for (let i = 2; i <= n; i++) {
        [a, b] = [b, a + b];
    }
    return b;
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    int fib(int n) {
        if (n <= 1) return n;
        int a = 0, b = 1;
        for (int i = 2; i <= n; i++) {
            int sum = a + b;
            a = b;
            b = sum;
        }
        return b;
    }
};''',
    ),
  ],
);

final Solution fibonacciMatrixSolution = Solution(
  method: SolutionMethod.binarySearch,
  approach: '''矩阵快速幂解法 - O(log n) 复杂度。

**核心思路：**
- 斐波那契数列可用矩阵乘法表示
- [F(n+1), F(n)] = [[1,1],[1,0]]^n * [1,0]
- 使用快速幂将复杂度降到 O(log n)

**适用场景：**
- 大数计算
- 对性能要求极高的场景''',
  timeComplexity: 'O(log n)',
  spaceComplexity: 'O(log n)',
  isRecommended: false,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''def fib(n: int) -> int:
    if n <= 1:
        return n

    def matrix_multiply(A, B):
        return [
            [A[0][0]*B[0][0] + A[0][1]*B[1][0], A[0][0]*B[0][1] + A[0][1]*B[1][1]],
            [A[1][0]*B[0][0] + A[1][1]*B[1][0], A[1][0]*B[0][1] + A[1][1]*B[1][1]]
        ]

    def matrix_power(M, p):
        result = [[1, 0], [0, 1]]
        while p:
            if p & 1:
                result = matrix_multiply(result, M)
            M = matrix_multiply(M, M)
            p >>= 1
        return result

    F = matrix_power([[1, 1], [1, 0]], n)
    return F[0][1]''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public int fib(int n) {
        if (n <= 1) return n;
        long[][] matrix = {{1, 1}, {1, 0}};
        long[][] result = matrixPower(matrix, n);
        return (int) result[0][1];
    }

    long[][] matrixPower(long[][] m, int p) {
        long[][] res = {{1, 0}, {0, 1}};
        while (p > 0) {
            if ((p & 1) == 1) res = multiply(res, m);
            m = multiply(m, m);
            p >>= 1;
        }
        return res;
    }

    long[][] multiply(long[][] a, long[][] b) {
        long[][] c = new long[2][2];
        for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 2; j++) {
                c[i][j] = a[i][0] * b[0][j] + a[i][1] * b[1][j];
            }
        }
        return c;
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var fib = function(n) {
    if (n <= 1) return n;
    const matrix = [[1,1],[1,0]];
    const result = matrixPower(matrix, n);
    return result[0][1];
};

function matrixPower(m, p) {
    let res = [[1,0],[0,1]];
    while (p > 0) {
        if (p & 1) res = multiply(res, m);
        m = multiply(m, m);
        p >>= 1;
    }
    return res;
}

function multiply(a, b) {
    return [
        [a[0][0]*b[0][0]+a[0][1]*b[1][0], a[0][0]*b[0][1]+a[0][1]*b[1][1]],
        [a[1][0]*b[0][0]+a[1][1]*b[1][0], a[1][0]*b[0][1]+a[1][1]*b[1][1]]
    ];
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    int fib(int n) {
        if (n <= 1) return n;
        vector<vector<long>> matrix = {{1,1},{1,0}};
        vector<vector<long>> result = matrixPower(matrix, n);
        return result[0][1];
    }

    vector<vector<long>> matrixPower(vector<vector<long>> m, int p) {
        vector<vector<long>> res = {{1,0},{0,1}};
        while (p > 0) {
            if (p & 1) res = multiply(res, m);
            m = multiply(m, m);
            p >>= 1;
        }
        return res;
    }

    vector<vector<long>> multiply(vector<vector<long>> a, vector<vector<long>> b) {
        vector<vector<long>> c(2, vector<long>(2));
        for(int i=0;i<2;i++) {
            for(int j=0;j<2;j++) {
                c[i][j] = a[i][0]*b[0][j] + a[i][1]*b[1][j];
            }
        }
        return c;
    }
};''',
    ),
  ],
);

final ProblemSolutions fibonacciSolutions = ProblemSolutions(
  problemId: 'fibonacci',
  solutions: [fibonacciDPSolution, fibonacciMatrixSolution],
);

// ==================== 4. 回文数 ====================

final Solution palindromeReverseSolution = Solution(
  method: SolutionMethod.bruteForce,
  approach: '''反转数字法判断回文。

**核心思路：**
1. 负数不是回文数
2. 末尾为0的非零数不是回文数
3. 反转数字一半，与前半部分比较

**优化点：**
- 只需反转一半数字，避免溢出
- 时间复杂度 O(log n)''',
  timeComplexity: 'O(log n)',
  spaceComplexity: 'O(1)',
  isRecommended: true,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''def isPalindrome(x: int) -> bool:
    if x < 0 or (x % 10 == 0 and x != 0):
        return False
    reversed_num = 0
    while x > reversed_num:
        reversed_num = reversed_num * 10 + x % 10
        x //= 10
    return x == reversed_num or x == reversed_num // 10''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public boolean isPalindrome(int x) {
        if (x < 0 || (x % 10 == 0 && x != 0)) {
            return false;
        }
        int reversed = 0;
        while (x > reversed) {
            reversed = reversed * 10 + x % 10;
            x /= 10;
        }
        return x == reversed || x == reversed / 10;
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var isPalindrome = function(x) {
    if (x < 0 || (x % 10 === 0 && x !== 0)) {
        return false;
    }
    let reversed = 0;
    while (x > reversed) {
        reversed = reversed * 10 + x % 10;
        x = Math.floor(x / 10);
    }
    return x === reversed || x === Math.floor(reversed / 10);
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    bool isPalindrome(int x) {
        if (x < 0 || (x % 10 == 0 && x != 0)) {
            return false;
        }
        int reversed = 0;
        while (x > reversed) {
            reversed = reversed * 10 + x % 10;
            x /= 10;
        }
        return x == reversed || x == reversed / 10;
    }
};''',
    ),
  ],
);

final Solution palindromeStringSolution = Solution(
  method: SolutionMethod.twoPointers,
  approach: '''转换为字符串双指针法。

**核心思路：**
1. 将整数转换为字符串
2. 使用双指针从两端向中间比较
3. 如果有任何字符不匹配，返回 false''',
  timeComplexity: 'O(n)',
  spaceComplexity: 'O(n)',
  isRecommended: false,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''def isPalindrome(x: int) -> bool:
    s = str(x)
    left, right = 0, len(s) - 1
    while left < right:
        if s[left] != s[right]:
            return False
        left += 1
        right -= 1
    return True''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public boolean isPalindrome(int x) {
        String s = Integer.toString(x);
        int left = 0, right = s.length() - 1;
        while (left < right) {
            if (s.charAt(left) != s.charAt(right)) {
                return false;
            }
            left++;
            right--;
        }
        return true;
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var isPalindrome = function(x) {
    const s = x.toString();
    let left = 0, right = s.length - 1;
    while (left < right) {
        if (s[left] !== s[right]) return false;
        left++;
        right--;
    }
    return true;
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    bool isPalindrome(int x) {
        string s = to_string(x);
        int left = 0, right = s.size() - 1;
        while (left < right) {
            if (s[left] != s[right]) return false;
            left++;
            right--;
        }
        return true;
    }
};''',
    ),
  ],
);

final ProblemSolutions palindromeSolutions = ProblemSolutions(
  problemId: 'palindrome-number',
  solutions: [palindromeReverseSolution, palindromeStringSolution],
);

// ==================== 5. 最大子数组和 ====================

final Solution maxSubarrayKadaneSolution = Solution(
  method: SolutionMethod.greedy,
  approach: '''贪心算法 - Kadane's Algorithm。

**核心思路：**
1. 遍历数组，维护当前最大和
2. 如果当前和为负数，丢弃之前的结果，从新开始
3. 记录出现过的最大和

**为什么贪心可行？**
- 负数和只会降低总和，遇到负数应重新开始
- 局部最优能导致全局最优''',
  timeComplexity: 'O(n)',
  spaceComplexity: 'O(1)',
  isRecommended: true,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''def maxSubArray(nums: List[int]) -> int:
    max_sum = nums[0]
    current_sum = nums[0]
    for num in nums[1:]:
        current_sum = max(num, current_sum + num)
        max_sum = max(max_sum, current_sum)
    return max_sum''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public int maxSubArray(int[] nums) {
        int maxSum = nums[0];
        int currentSum = nums[0];
        for (int i = 1; i < nums.length; i++) {
            currentSum = Math.max(nums[i], currentSum + nums[i]);
            maxSum = Math.max(maxSum, currentSum);
        }
        return maxSum;
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var maxSubArray = function(nums) {
    let maxSum = nums[0];
    let currentSum = nums[0];
    for (let i = 1; i < nums.length; i++) {
        currentSum = Math.max(nums[i], currentSum + nums[i]);
        maxSum = Math.max(maxSum, currentSum);
    }
    return maxSum;
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    int maxSubArray(vector<int>& nums) {
        int maxSum = nums[0];
        int currentSum = nums[0];
        for (int i = 1; i < nums.size(); i++) {
            currentSum = max(nums[i], currentSum + nums[i]);
            maxSum = max(maxSum, currentSum);
        }
        return maxSum;
    }
};''',
    ),
  ],
);

final Solution maxSubarrayDPSolution = Solution(
  method: SolutionMethod.dynamicProgramming,
  approach: '''动态规划解法。

**核心思路：**
1. dp[i] 表示以第 i 个元素结尾的最大子数组和
2. dp[i] = max(nums[i], dp[i-1] + nums[i])
3. 结果为所有 dp 中的最大值

**与贪心的关系：**
- 贪心是 DP 的空间优化版本
- DP 更直观，便于理解''',
  timeComplexity: 'O(n)',
  spaceComplexity: 'O(n)',
  isRecommended: false,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''def maxSubArray(nums: List[int]) -> int:
    n = len(nums)
    dp = [0] * n
    dp[0] = nums[0]
    max_sum = dp[0]
    for i in range(1, n):
        dp[i] = max(nums[i], dp[i-1] + nums[i])
        max_sum = max(max_sum, dp[i])
    return max_sum''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public int maxSubArray(int[] nums) {
        int n = nums.length;
        int[] dp = new int[n];
        dp[0] = nums[0];
        int maxSum = dp[0];
        for (int i = 1; i < n; i++) {
            dp[i] = Math.max(nums[i], dp[i-1] + nums[i]);
            maxSum = Math.max(maxSum, dp[i]);
        }
        return maxSum;
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var maxSubArray = function(nums) {
    const n = nums.length;
    const dp = new Array(n);
    dp[0] = nums[0];
    let maxSum = dp[0];
    for (let i = 1; i < n; i++) {
        dp[i] = Math.max(nums[i], dp[i-1] + nums[i]);
        maxSum = Math.max(maxSum, dp[i]);
    }
    return maxSum;
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    int maxSubArray(vector<int>& nums) {
        int n = nums.size();
        vector<int> dp(n);
        dp[0] = nums[0];
        int maxSum = dp[0];
        for (int i = 1; i < n; i++) {
            dp[i] = max(nums[i], dp[i-1] + nums[i]);
            maxSum = max(maxSum, dp[i]);
        }
        return maxSum;
    }
};''',
    ),
  ],
);

final ProblemSolutions maxSubarraySolutions = ProblemSolutions(
  problemId: 'maximum-subarray',
  solutions: [maxSubarrayKadaneSolution, maxSubarrayDPSolution],
);

// ==================== 6. 两数相加 ====================

final Solution addTwoNumbersSolution = Solution(
  method: SolutionMethod.twoPointers,
  approach: '''模拟链表数字相加。

**核心思路：**
1. 同时遍历两个链表
2. 相加对应节点和进位值
3. 创建新节点存储结果
4. 处理最后的进位

**注意：**
- 链表是逆序存储的，直接按位相加即可
- 需要处理进位（carry）
- 虚拟头节点简化操作''',
  timeComplexity: 'O(max(m,n))',
  spaceComplexity: 'O(max(m,n))',
  isRecommended: true,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next

def addTwoNumbers(l1: Optional[ListNode], l2: Optional[ListNode]) -> Optional[ListNode]:
    dummy = ListNode(0)
    cur = dummy
    carry = 0
    while l1 or l2 or carry:
        val = carry
        if l1:
            val += l1.val
            l1 = l1.next
        if l2:
            val += l2.val
            l2 = l2.next
        carry = val // 10
        cur.next = ListNode(val % 10)
        cur = cur.next
    return dummy.next''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''/**
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
        ListNode dummy = new ListNode(0);
        ListNode cur = dummy;
        int carry = 0;
        while (l1 != null || l2 != null || carry != 0) {
            int val = carry;
            if (l1 != null) {
                val += l1.val;
                l1 = l1.next;
            }
            if (l2 != null) {
                val += l2.val;
                l2 = l2.next;
            }
            carry = val / 10;
            cur.next = new ListNode(val % 10);
            cur = cur.next;
        }
        return dummy.next;
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''/**
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
    const dummy = new ListNode(0);
    let cur = dummy;
    let carry = 0;
    while (l1 || l2 || carry) {
        let val = carry;
        if (l1) {
            val += l1.val;
            l1 = l1.next;
        }
        if (l2) {
            val += l2.val;
            l2 = l2.next;
        }
        carry = Math.floor(val / 10);
        cur.next = new ListNode(val % 10);
        cur = cur.next;
    }
    return dummy.next;
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''/**
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
        ListNode* dummy = new ListNode(0);
        ListNode* cur = dummy;
        int carry = 0;
        while (l1 || l2 || carry) {
            int val = carry;
            if (l1) {
                val += l1->val;
                l1 = l1->next;
            }
            if (l2) {
                val += l2->val;
                l2 = l2->next;
            }
            carry = val / 10;
            cur->next = new ListNode(val % 10);
            cur = cur->next;
        }
        return dummy->next;
    }
};''',
    ),
  ],
);

final ProblemSolutions addTwoNumbersSolutions = ProblemSolutions(
  problemId: 'add-two-numbers',
  solutions: [addTwoNumbersSolution],
);

// ==================== 7. 无重复字符的最长子串 ====================

final Solution longestSubstringSlideWindowSolution = Solution(
  method: SolutionMethod.slidingWindow,
  approach: '''滑动窗口法。

**核心思路：**
1. 使用左右指针维护一个无重复字符的窗口
2. 右指针不断右移，添加字符
3. 如果遇到重复字符，左指针右移直到窗口内无重复
4. 记录最大窗口长度

**哈希表优化：**
- 使用哈希表/集合快速判断字符是否存在
- 左指针直接跳到重复字符的位置''',
  timeComplexity: 'O(n)',
  spaceComplexity: 'O(min(m,n))',
  isRecommended: true,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''def lengthOfLongestSubstring(s: str) -> int:
    char_set = set()
    left = 0
    max_len = 0
    for right in range(len(s)):
        while s[right] in char_set:
            char_set.remove(s[left])
            left += 1
        char_set.add(s[right])
        max_len = max(max_len, right - left + 1)
    return max_len''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public int lengthOfLongestSubstring(String s) {
        Set<Character> set = new HashSet<>();
        int left = 0, maxLen = 0;
        for (int right = 0; right < s.length(); right++) {
            while (set.contains(s.charAt(right))) {
                set.remove(s.charAt(left));
                left++;
            }
            set.add(s.charAt(right));
            maxLen = Math.max(maxLen, right - left + 1);
        }
        return maxLen;
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var lengthOfLongestSubstring = function(s) {
    const set = new Set();
    let left = 0, maxLen = 0;
    for (let right = 0; right < s.length; right++) {
        while (set.has(s[right])) {
            set.delete(s[left]);
            left++;
        }
        set.add(s[right]);
        maxLen = Math.max(maxLen, right - left + 1);
    }
    return maxLen;
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    int lengthOfLongestSubstring(string s) {
        unordered_set<char> set;
        int left = 0, maxLen = 0;
        for (int right = 0; right < s.size(); right++) {
            while (set.count(s[right])) {
                set.erase(s[left]);
                left++;
            }
            set.insert(s[right]);
            maxLen = max(maxLen, right - left + 1);
        }
        return maxLen;
    }
};''',
    ),
  ],
);

final ProblemSolutions longestSubstringSolutions = ProblemSolutions(
  problemId: 'longest-substring',
  solutions: [longestSubstringSlideWindowSolution],
);

// ==================== 8. LRU缓存机制 ====================

final Solution lruCacheSolution = Solution(
  method: SolutionMethod.hashMap,
  approach: '''使用哈希表 + 双向链表实现 LRU。

**核心思路：**
1. 哈希表：O(1) 查找缓存
2. 双向链表：维护访问顺序，最近使用的在头部
3. get 操作：将访问的节点移到头部
4. put 操作：超过容量时删除尾部节点

**为什么需要两者结合？**
- 哈希表提供 O(1) 查找
- 双向链表提供 O(1) 的插入/删除''',
  timeComplexity: 'O(1)',
  spaceComplexity: 'O(capacity)',
  isRecommended: true,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''from collections import OrderedDict

class LRUCache:
    def __init__(self, capacity: int):
        self.capacity = capacity
        self.cache = OrderedDict()

    def get(self, key: int) -> int:
        if key not in self.cache:
            return -1
        self.cache.move_to_end(key)
        return self.cache[key]

    def put(self, key: int, value: int) -> None:
        if key in self.cache:
            self.cache.move_to_end(key)
        self.cache[key] = value
        if len(self.cache) > self.capacity:
            self.cache.popitem(last=False)''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class LRUCache {
    private int capacity;
    private LinkedHashMap<Integer, Integer> cache;

    public LRUCache(int capacity) {
        this.capacity = capacity;
        this.cache = new LinkedHashMap<>(capacity, 0.75f, true) {
            protected boolean removeEldestEntry(Map.Entry eldest) {
                return size() > LRUCache.this.capacity;
            }
        };
    }

    public int get(int key) {
        return cache.getOrDefault(key, -1);
    }

    public void put(int key, int value) {
        cache.put(key, value);
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''class LRUCache {
    constructor(capacity) {
        this.capacity = capacity;
        this.cache = new Map();
    }

    get(key) {
        if (!this.cache.has(key)) return -1;
        const value = this.cache.get(key);
        this.cache.delete(key);
        this.cache.set(key, value);
        return value;
    }

    put(key, value) {
        if (this.cache.has(key)) {
            this.cache.delete(key);
        } else if (this.cache.size >= this.capacity) {
            const firstKey = this.cache.keys().next().value;
            this.cache.delete(firstKey);
        }
        this.cache.set(key, value);
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class LRUCache {
    int capacity;
    list<pair<int,int>> lst;
    unordered_map<int, list<pair<int,int>>::iterator> mp;
public:
    LRUCache(int capacity): capacity(capacity) {}

    int get(int key) {
        if (mp.find(key) == mp.end()) return -1;
        lst.splice(lst.begin(), lst, mp[key]);
        return mp[key]->second;
    }

    void put(int key, int value) {
        if (mp.find(key) != mp.end()) {
            lst.erase(mp[key]);
        }
        lst.emplace_front(key, value);
        mp[key] = lst.begin();
        if (lst.size() > capacity) {
            mp.erase(lst.back().first);
            lst.pop_back();
        }
    }
};''',
    ),
  ],
);

final ProblemSolutions lruCacheSolutions = ProblemSolutions(
  problemId: 'lru-cache',
  solutions: [lruCacheSolution],
);

// ==================== 9. 有效括号 ====================

final Solution validParenthesesStackSolution = Solution(
  method: SolutionMethod.stack,
  approach: '''使用栈匹配括号。

**核心思路：**
1. 遍历字符串中的每个字符
2. 如果是左括号，入栈
3. 如果是右括号，检查栈顶是否匹配
4. 遍历结束后，栈为空则有效

**为什么栈适合？**
- 栈是后进先出的数据结构
- 最近的一个左括号应该最先被匹配''',
  timeComplexity: 'O(n)',
  spaceComplexity: 'O(n)',
  isRecommended: true,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''def isValid(s: str) -> bool:
    stack = []
    mapping = {')': '(', ']': '[', '}': '{'}
    for char in s:
        if char in mapping:
            if not stack or stack.pop() != mapping[char]:
                return False
        else:
            stack.append(char)
    return not stack''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public boolean isValid(String s) {
        Stack<Character> stack = new Stack<>();
        Map<Character, Character> mapping = new HashMap<>();
        mapping.put(')', '(');
        mapping.put(']', '[');
        mapping.put('}', '{');

        for (char c : s.toCharArray()) {
            if (mapping.containsKey(c)) {
                if (stack.isEmpty() || stack.pop() != mapping.get(c)) {
                    return false;
                }
            } else {
                stack.push(c);
            }
        }
        return stack.isEmpty();
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var isValid = function(s) {
    const stack = [];
    const mapping = {')': '(', ']': '[', '}': '{'};
    for (const c of s) {
        if (c in mapping) {
            if (!stack.length || stack.pop() !== mapping[c]) {
                return false;
            }
        } else {
            stack.push(c);
        }
    }
    return !stack.length;
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    bool isValid(string s) {
        stack<char> st;
        unordered_map<char, char> mapping = {{')','('}, {']','['}, {'}','{'}};
        for (char c : s) {
            if (mapping.count(c)) {
                if (st.empty() || st.top() != mapping[c]) return false;
                st.pop();
            } else {
                st.push(c);
            }
        }
        return st.empty();
    }
};''',
    ),
  ],
);

final ProblemSolutions validParenthesesSolutions = ProblemSolutions(
  problemId: 'valid-parentheses',
  solutions: [validParenthesesStackSolution],
);

// ==================== 10. 合并两个有序链表 ====================

final Solution mergeTwoListsIterativeSolution = Solution(
  method: SolutionMethod.twoPointers,
  approach: '''迭代合并两个有序链表。

**核心思路：**
1. 创建虚拟头节点简化操作
2. 比较两个链表的头节点
3. 将较小的节点接到结果链表后
4. 重复直到某个链表为空
5. 接上剩余部分

**为什么这样可行？**
- 两个链表都是有序的
- 每次选择最小的头部，最终结果也是有序的''',
  timeComplexity: 'O(m+n)',
  spaceComplexity: 'O(1)',
  isRecommended: true,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next

def mergeTwoLists(l1: Optional[ListNode], l2: Optional[ListNode]) -> Optional[ListNode]:
    dummy = ListNode(0)
    cur = dummy
    while l1 and l2:
        if l1.val <= l2.val:
            cur.next = l1
            l1 = l1.next
        else:
            cur.next = l2
            l2 = l2.next
        cur = cur.next
    cur.next = l1 or l2
    return dummy.next''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
        ListNode dummy = new ListNode(0);
        ListNode cur = dummy;
        while (l1 != null && l2 != null) {
            if (l1.val <= l2.val) {
                cur.next = l1;
                l1 = l1.next;
            } else {
                cur.next = l2;
                l2 = l2.next;
            }
            cur = cur.next;
        }
        cur.next = l1 != null ? l1 : l2;
        return dummy.next;
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var mergeTwoLists = function(l1, l2) {
    const dummy = new ListNode(0);
    let cur = dummy;
    while (l1 && l2) {
        if (l1.val <= l2.val) {
            cur.next = l1;
            l1 = l1.next;
        } else {
            cur.next = l2;
            l2 = l2.next;
        }
        cur = cur.next;
    }
    cur.next = l1 || l2;
    return dummy.next;
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    ListNode* mergeTwoLists(ListNode* l1, ListNode* l2) {
        ListNode* dummy = new ListNode(0);
        ListNode* cur = dummy;
        while (l1 && l2) {
            if (l1->val <= l2->val) {
                cur->next = l1;
                l1 = l1->next;
            } else {
                cur->next = l2;
                l2 = l2->next;
            }
            cur = cur->next;
        }
        cur->next = l1 ? l1 : l2;
        return dummy->next;
    }
};''',
    ),
  ],
);

final Solution mergeTwoListsRecursiveSolution = Solution(
  method: SolutionMethod.recursion,
  approach: '''递归解法。

**核心思路：**
1. 选择两个链表头中较小的作为新头
2. 递归合并剩余部分
3. 递归出口：某个链表为空

**注意：**
- 递归深度可能很大，不适合很长的链表
- 空间复杂度 O(m+n)''',
  timeComplexity: 'O(m+n)',
  spaceComplexity: 'O(m+n)',
  isRecommended: false,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''def mergeTwoLists(l1: Optional[ListNode], l2: Optional[ListNode]) -> Optional[ListNode]:
    if not l1 or not l2:
        return l1 or l2
    if l1.val <= l2.val:
        l1.next = mergeTwoLists(l1.next, l2)
        return l1
    else:
        l2.next = mergeTwoLists(l1, l2.next)
        return l2''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
        if (l1 == null || l2 == null) {
            return l1 != null ? l1 : l2;
        }
        if (l1.val <= l2.val) {
            l1.next = mergeTwoLists(l1.next, l2);
            return l1;
        } else {
            l2.next = mergeTwoLists(l1, l2.next);
            return l2;
        }
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var mergeTwoLists = function(l1, l2) {
    if (!l1 || !l2) return l1 || l2;
    if (l1.val <= l2.val) {
        l1.next = mergeTwoLists(l1.next, l2);
        return l1;
    } else {
        l2.next = mergeTwoLists(l1, l2.next);
        return l2;
    }
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    ListNode* mergeTwoLists(ListNode* l1, ListNode* l2) {
        if (!l1 || !l2) return l1 ? l1 : l2;
        if (l1->val <= l2->val) {
            l1->next = mergeTwoLists(l1->next, l2);
            return l1;
        } else {
            l2->next = mergeTwoLists(l1, l2->next);
            return l2;
        }
    }
};''',
    ),
  ],
);

final ProblemSolutions mergeTwoListsSolutions = ProblemSolutions(
  problemId: 'merge-two-sorted-lists',
  solutions: [mergeTwoListsIterativeSolution, mergeTwoListsRecursiveSolution],
);

// ==================== 11. 买卖股票最佳时机 ====================

final Solution bestTimeToBuyStockSolution = Solution(
  method: SolutionMethod.greedy,
  approach: '''一次遍历贪心算法。

**核心思路：**
1. 记录最低价格和最大利润
2. 遍历数组，更新最低价格
3. 计算当前价格与最低价格的差值作为潜在利润
4. 更新最大利润

**为什么贪心可行？**
- 只要找到最低价格之后的最高价格
- 只需一次遍历即可找到最优解''',
  timeComplexity: 'O(n)',
  spaceComplexity: 'O(1)',
  isRecommended: true,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''def maxProfit(prices: List[int]) -> int:
    min_price = float('inf')
    max_profit = 0
    for price in prices:
        min_price = min(min_price, price)
        max_profit = max(max_profit, price - min_price)
    return max_profit''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public int maxProfit(int[] prices) {
        int minPrice = Integer.MAX_VALUE;
        int maxProfit = 0;
        for (int price : prices) {
            minPrice = Math.min(minPrice, price);
            maxProfit = Math.max(maxProfit, price - minPrice);
        }
        return maxProfit;
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var maxProfit = function(prices) {
    let minPrice = Infinity;
    let maxProfit = 0;
    for (const price of prices) {
        minPrice = Math.min(minPrice, price);
        maxProfit = Math.max(maxProfit, price - minPrice);
    }
    return maxProfit;
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    int maxProfit(vector<int>& prices) {
        int minPrice = INT_MAX;
        int maxProfit = 0;
        for (int price : prices) {
            minPrice = min(minPrice, price);
            maxProfit = max(maxProfit, price - minPrice);
        }
        return maxProfit;
    }
};''',
    ),
  ],
);

final Solution bestTimeToBuyStockDPSolution = Solution(
  method: SolutionMethod.dynamicProgramming,
  approach: '''动态规划解法（可扩展到多次交易）。

**核心思路：**
1. dp[i][0] = 第 i 天不持有股票的最大利润
2. dp[i][1] = 第 i 天持有股票的最大利润
3. 状态转移方程
4. 最终结果是不持有股票的最大利润

**扩展性：**
- 可以轻松扩展到多次交易、冷冻期等变体''',
  timeComplexity: 'O(n)',
  spaceComplexity: 'O(1)',
  isRecommended: false,
  codeVersions: [
    CodeVersion(
      language: ProgrammingLanguage.python,
      code: '''def maxProfit(prices: List[int]) -> int:
    if not prices:
        return 0
    n = len(prices)
    # dp[i][0]: 第i天不持有股票的最大利润
    # dp[i][1]: 第i天持有股票的最大利润
    dp0, dp1 = 0, -prices[0]
    for i in range(1, n):
        dp0 = max(dp0, dp1 + prices[i])
        dp1 = max(dp1, -prices[i])
    return dp0''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.java,
      code: '''class Solution {
    public int maxProfit(int[] prices) {
        if (prices.length == 0) return 0;
        int dp0 = 0, dp1 = -prices[0];
        for (int i = 1; i < prices.length; i++) {
            dp0 = Math.max(dp0, dp1 + prices[i]);
            dp1 = Math.max(dp1, -prices[i]);
        }
        return dp0;
    }
}''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.javascript,
      code: '''var maxProfit = function(prices) {
    if (!prices.length) return 0;
    let dp0 = 0, dp1 = -prices[0];
    for (let i = 1; i < prices.length; i++) {
        dp0 = Math.max(dp0, dp1 + prices[i]);
        dp1 = Math.max(dp1, -prices[i]);
    }
    return dp0;
};''',
    ),
    CodeVersion(
      language: ProgrammingLanguage.cpp,
      code: '''class Solution {
public:
    int maxProfit(vector<int>& prices) {
        if (prices.empty()) return 0;
        int dp0 = 0, dp1 = -prices[0];
        for (int i = 1; i < prices.size(); i++) {
            dp0 = max(dp0, dp1 + prices[i]);
            dp1 = max(dp1, -prices[i]);
        }
        return dp0;
    }
};''',
    ),
  ],
);

final ProblemSolutions bestTimeToBuyStockSolutions = ProblemSolutions(
  problemId: 'best-time-to-buy-and-sell-stock',
  solutions: [bestTimeToBuyStockSolution, bestTimeToBuyStockDPSolution],
);

// ==================== 题解数据映射表 ====================

final Map<String, ProblemSolutions> solutionDataMap = {
  // 英文ID
  'two-sum': twoSumSolutions,
  '1': twoSumSolutions,
  'reverse-string': reverseStringSolutions,
  'fibonacci': fibonacciSolutions,
  'palindrome-number': palindromeSolutions,
  '9': palindromeSolutions,
  'maximum-subarray': maxSubarraySolutions,
  '53': maxSubarraySolutions,
  'add-two-numbers': addTwoNumbersSolutions,
  '2': addTwoNumbersSolutions,
  'longest-substring': longestSubstringSolutions,
  '3': longestSubstringSolutions,
  'lru-cache': lruCacheSolutions,
  '146': lruCacheSolutions,
  'valid-parentheses': validParenthesesSolutions,
  '20': validParenthesesSolutions,
  'merge-two-sorted-lists': mergeTwoListsSolutions,
  '21': mergeTwoListsSolutions,
  'best-time-to-buy-and-sell-stock': bestTimeToBuyStockSolutions,
  '121': bestTimeToBuyStockSolutions,
  // 中文题目名称映射
  '两数之和': twoSumSolutions,
  '反转字符串': reverseStringSolutions,
  '斐波那契数列': fibonacciSolutions,
  '回文数': palindromeSolutions,
  '最大子数组和': maxSubarraySolutions,
  '两数相加': addTwoNumbersSolutions,
  '无重复字符的最长子串': longestSubstringSolutions,
  'LRU缓存机制': lruCacheSolutions,
  '有效括号': validParenthesesSolutions,
  '合并两个有序链表': mergeTwoListsSolutions,
  '买卖股票最佳时机': bestTimeToBuyStockSolutions,
};

/// 获取题目的题解数据
ProblemSolutions? getProblemSolutions(String problemId) {
  return solutionDataMap[problemId];
}

/// 获取题目的默认题解（向后兼容）
Solution getDefaultSolution(String problemId) {
  final solutions = solutionDataMap[problemId];
  if (solutions != null && solutions.solutions.isNotEmpty) {
    return solutions.recommendedSolution ?? solutions.solutions.first;
  }
  // 返回默认的两数之和哈希表解法
  return twoSumHashMapSolution;
}
