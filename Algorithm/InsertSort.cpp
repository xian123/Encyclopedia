
/*
算法名称： 插入排序

假设:从小到大排序
插入排序法的原理:每插入一个数都要将它和之前的已经完成排序的序列进行比较并重新排序，
也就是要找到新插入的数对应原序列中的位置。
时间复杂度：O（n^2）

例子：
初始化：    9 8 7 6 5
第1次插入： 8 9 7 6 5
第2次插入： 7 8 9 6 5
第3次插入： 6 7 8 9 5
第4次插入： 5 6 7 8 9

重点：将一个数插到已排好序中；使用哨兵用于临时存储和判断

测试环境： Ubuntu 5.4.0
gcc version 5.4.0 20160609
*/


#include<iostream>
using namespace std;

void PrintArray(const int *p, const int size ) {
    if (p == NULL || size < 0)
        return;

    for (int i = 0; i < size; i++) {
        cout << *p << endl;
        p++;
    }
}

void InsertSort(int *p, const int size) {
    int i, j, temp;

    if (p == NULL || size < 0)
        return;

    for (i = 1; i < size; i++) { //初始假设p[0]是已经拍好的序列，所以i从1开始循环
        if (p[i] < p[i -1]) { //后一个数比前一个数小则需要移动
            temp = p[i];
            for (j = i - 1; p[j] > temp && j >= 0; j--) { //只要比i所在位置大的数就要右（后）移，大数总是在后面
                p[j + 1] = p[j]; //右移
            }
            p[j + 1] = temp; //因为上面循环做了j--，所以这里需要加1
        }
    }
}

int main() {
    int list[10] = {4,6,5,10,3,7,9,2,8,1};
    cout << "The order before sort:" << endl;
    PrintArray(list, 10);
    InsertSort(list, 10);
    cout << "The order after sort:" << endl;
    PrintArray(list, 10);

    int list2[10] = {100,6,500,10,3,8,9,2,8,1};
    cout << "The order before sort:" << endl;
    PrintArray(list2, 10);
    InsertSort(list2, 10);
    cout << "The order after sort:" << endl;
    PrintArray(list2, 10);
}
