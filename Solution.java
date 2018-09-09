import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;

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
                } else if(target > nums[i] + nums[j]){
                    i++;
                } else{
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
}