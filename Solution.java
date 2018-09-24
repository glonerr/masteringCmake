import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.HashSet;
import java.util.TreeMap;

public class Solution {
    public int[] twoSum(int[] nums, int target) {
        java.util.HashMap<Integer, Integer> m = new java.util.HashMap<Integer, Integer>();
        int[] res = new int[2];
        for (int i = 0; i < nums.length; ++i) {
            if (m.containsKey(target - nums[i])) {
                res[0] = i;
                res[1] = m.get(target - nums[i]);
                break;
            }
            m.put(nums[i], i);
        }
        return res;
    }

    public java.util.List<java.util.List<Integer>> threeSum01(int[] nums) {
        java.util.List<java.util.List<Integer>> res = new java.util.ArrayList();
        java.util.Arrays.sort(nums);
        for (int k = 0; k < nums.length - 2 && nums[k] <= 0; k++) {// target
            if (k > 0 && nums[k] == nums[k - 1]) {
                k++;
                continue;
            }
            int target = 0 - nums[k];
            int i = k + 1;
            int j = nums.length - 1;
            while (i < j) {
                if (target == nums[i] + nums[j]) {
                    res.add(java.util.Arrays.asList(new Integer[] { -target, nums[i], target - nums[i] }));
                    while (i < j && nums[i] == nums[i + 1]) {
                        i++;
                    }
                    while (i < j && nums[j] == nums[j - 1]) {
                        j--;
                    }
                    i++;
                    j--;
                } else if (target > nums[i] + nums[j]) {
                    i++;
                } else {
                    j--;
                }

            }
        }
        return res;
    }

    public java.util.List<java.util.List<Integer>> threeSum02(int[] nums) {
        java.util.List<java.util.List<Integer>> res = new java.util.ArrayList();
        java.util.Arrays.sort(nums);
        for (int i = 0; i < nums.length && nums[i] <= 0; i++) {// target
            if (i > 0 && nums[i] == nums[i - 1])
                continue;
            int target = 0 - nums[i];
            for (int j = i + 1; j < nums.length; j++) {
                if (j > i + 1 && nums[j] == nums[j - 1])
                    continue;
                for (int k = j + 1; k < nums.length; k++) {
                    if (target == nums[j] + nums[k]) {
                        res.add(java.util.Arrays.asList(new Integer[] { -target, nums[j], nums[k] }));
                        break;
                    }
                }
            }
        }
        return res;
    }

    public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
        int carry = 0;
        ListNode head = null;
        ListNode tail = null;
        while (l1 != null || l2 != null || carry > 0) {
            int res = (carry + (l1 == null ? 0 : l1.val) + (l2 == null ? 0 : l2.val));
            int val = res % 10;
            carry = res / 10;
            l1 = l1 == null ? null : l1.next;
            l2 = l2 == null ? null : l2.next;
            if (tail == null) {
                head = tail = new ListNode(val);
            } else {
                tail.next = new ListNode(val);
                tail = tail.next;
            }
        }
        return head;
    }

    public int lengthOfLongestSubstring(String s) {
        char[] cs = s.toCharArray();
        int max = 0;
        int start = 0;
        for (int i = 1; i < cs.length; i++) {
            for (int j = start; j < i; j++) {
                // System.out.printf("start:%d,j:%d,max:%d,i:%d,string:%s,cs[i]:%c,cs[j]:%c\n",start,j,max,i,s,cs[i],cs[j]);
                if (cs[j] == cs[i]) {
                    max = Math.max(max, i - start);
                    // System.out.printf("start:%d,end:%d,max:%d,i:%d\n",start,j,max,i);
                    start = j + 1;
                    break;
                }
            }
        }
        max = Math.max(max, cs.length - start);
        return max;
    }

    public double findMedianSortedArrays(int[] nums1, int[] nums2) {
        if (nums1.length > nums2.length) {
            int[] tmp = nums2;
            nums2 = nums1;
            nums1 = tmp;
        }
        for (int i = 0; i < nums1.length; i++) {
            // if(nums1[i])
        }
        return 0;
    }

    public string longestPalindrome(String s) {
        char[] cs = s.toCharArray();
        int maxEven = 0;
        int maxOdd = 0;
        for (int i = 1; i < cs.length; i++) {
            
        }
        return null;
    }

}