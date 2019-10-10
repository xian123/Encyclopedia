
/*
算法名称： 冒泡排序

前提：假定从小到大排序。
算法： 从最后开始，两两相邻的值进行比较，如后面的数小于前面的数则交换，这样较小的数字
就如同气泡一样慢慢浮到上面，因此称为冒泡法。

时间复杂度：
两层循环，第1次遍历n次(n个元素)，第二次遍历n-1次，... 依次类推。因此，表达式如下：
n + (n - 1) + (n - 2) + ... + 1 = n*(n + 1)/2 = O(n^2)

空间复杂度：
没有利用新的数组来帮助完成排序算法，我们认为其空间复杂度为O(1)

下面是以4,6,5,10,3,7,9,2,8,1为例，说明第一轮循环后，最小的1从最后“浮”到第一个位置，
其余循环以此类推。
4   4    4    4             1
6   6    6    6             4
5   5    5    5             6
10  10   10   10            5
3   3    3    3             10
7   7    7    7             3
9   9    9    1             7
2   2    1    9             9
8   1    2    2             2
1   8    8    8             8

由此可见：
N个数字要排序完成，总共进行N-1趟排序，第i趟的排序次数为(N-i)次，所以可以用双重循环语句，
外层控制循环多少趟，内层控制每一趟的循环次数。

冒泡排序有多种实现，可以从前开始比较也可以从后开始比较，这里选择后者。

测试环境： Ubuntu 5.4.0
gcc version 5.4.0 20160609
*/


#include<iostream>
using namespace std;

void PrintArray(const int *p, const int size ) {
    for (int i = 0; i < size; i++) {
        cout << *p << endl;
        p++;
    }
}

void BubbleSort(int *p, int size) {
    int i, j,tmp;
    for (i = 0; i < size; i++) {
        for (j = size - 1; j > i; j--) { // Note: j > i, not j > 0
            if (p[j] < p[j-1]) {
                tmp = p[j-1];
                p[j-1] = p[j];
                p[j] = tmp;
            }
        }
    }
}

/*
    BubbleSort()已经实现了冒泡算法，这里是对其进行优化。
    假如待排序的序列为{4,3,2,1,5,6,7,8,9,10}，这个序列有个特点就是只需要对前半部分排序，而后
    5，6，7，8，9，10已经排好了，无须再排，但是按照BubbleSort()仍然会进行多余而无用的循环。
    改进： 当没有任何数据交换时，这就说明序列已经有序了，不需要再继续后面的无用循环了。可以增加
    一个标记来实现这一算法的改进。
*/
void BubbleSortRefine(int *p, int size) {
    int i, j, tmp;
    int totalLoopCount = 0; //设此变量的目的仅仅是为了查看改进后的效果对比，实际排序中不需要
    bool isNotInOrder = true;
    for (i = 0; i < size && isNotInOrder; i++) {
        isNotInOrder = false;
        for (j = size - 1; j > i; j--) { // Note: j > i, not j > 0
            if (p[j] < p[j-1]) {
                tmp = p[j-1];
                p[j-1] = p[j];
                p[j] = tmp;
                isNotInOrder = true;
            }
            totalLoopCount++;
        }
    }
    cout << "In " << __func__ << ":" << endl;
    cout << "   Total loop count: " << totalLoopCount << endl;
}

int main() {
    int list[10] = {4,6,5,10,3,7,9,2,8,1};
    cout << "The order before sort:" << endl;
    PrintArray(list, 10);
    BubbleSort(list, 10);
    cout << "The order after sort:" << endl;
    PrintArray(list, 10);

    int list2[10] = {4,6,5,10,3,7,9,2,8,1};
    BubbleSortRefine(list2, 10);
    cout << "The order after sort:" << endl;
    PrintArray(list2, 10);

    int list3[10] = {4,3,2,1,5,6,7,8,9,10};
    BubbleSortRefine(list3, 10);
    cout << "The order after sort:" << endl;
    PrintArray(list3, 10);
}
