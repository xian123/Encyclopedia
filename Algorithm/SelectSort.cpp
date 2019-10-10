
/*
算法名称： 选择排序

原理：每次从待排序的数据中选出最小(或者最大)的一个，存放在已排好序列的起始位置(或者末尾位置)，直到全部待排序的数据排完。
思路：
    (1)第一趟排序，在待排序数据arr[0],arr[1],arr[2]...arr[SIZE-1]中选出最小的数据，将其与arr[0]进行交换。
    (2)第二趟排序：在待排序数据arr[1],arr[2],arr[3]...arr[SIZE-1]中选出最小的数据，将其与arr[1]进行交换。
    ......
    (3)如此继续。第i趟在待排序数据arr[i],arr[i+1]....arr[SIZE-1]中选出最小的元素与其进行交换，直至全部完成。

时间复杂度： O(n^2)
虽然时间复杂度和冒泡排序一样，但选择排序在性能上面要略优于冒泡排序。

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

void Swap (int &a, int &b) {
    int temp;

    temp = a;
    a = b;
    b = temp;
}

void SelectSort(int *p, const int size) {
    int i, j, minPos;

    if (p == NULL || size < 0)
        return;

    for (i = 0; i < size; i++) {
        minPos = i; //假设当前位置为最小值下标
        for (j = i + 1; j < size; j++) {
            if (p[j] < p[minPos]) {
                minPos = j; //如果有更小的值，更新标识
            }
        }

        if (minPos != i) { //若minPos不等于i，说明找到最小值，交换
            Swap(p[i], p[minPos]);
        }
    }
}

/*
双向选择排序（每次循环，同时选出最大值放在末尾，最小值放在前面）
这个有点像调鸡尾酒，左右各一下，所以也被称为鸡尾酒排序法。
*/
void BiSelectSort(int *p, const int size) {
    int i, j, minPos, maxPos;

    if (p == NULL || size < 0)
        return;

    for (i = 0; i < (size - 1)/2; i++) { //注意这里外循环次数减半了，原因就是在每次的循环中找到一个最小和一个最大值
        minPos = i;
        maxPos = size -i -1; 
        for (j = i + 1; j < size - i; j++) {
            if (p[j] < p[minPos]) {
                minPos = j;
            }
            if (p[j] > p[maxPos]) {
                maxPos = j;
            }
        }

        if (minPos != i) {
            Swap(p[i], p[minPos]);
            if (p[minPos] > p[maxPos]) { //一定要注意这种情况
                Swap(p[size -i -1], p[minPos]);
            } else {
                Swap(p[size -i -1], p[maxPos]);
            }
        } else if (maxPos != (size -i -1) ) {
            Swap(p[size -i -1], p[maxPos]);
        }
    }
}

int main() {
    int list[10] = {4,6,5,10,3,7,9,2,8,1};
    cout << "The order before sort:" << endl;
    PrintArray(list, 10);
    SelectSort(list, 10);
    cout << "The order after sort:" << endl;
    PrintArray(list, 10);
    cout << "----------------------------------" << endl;
    SelectSort(NULL, 10);
    int list2[1] = {4};
    SelectSort(list2, 1);
    cout << "----------------------------------" << endl;
    int list3[10] = {4,6,5,10,3,7,9,2,8,1};
    cout << "The order before sort:" << endl;
    PrintArray(list3, 10);
    BiSelectSort(list3, 10);
    cout << "The order after sort:" << endl;
    PrintArray(list3, 10);
    cout << "----------------------------------" << endl;
    int list4[10] = {100,6,5,10,3,7,9,2,8,2};
    cout << "The order before sort:" << endl;
    PrintArray(list4, 10);
    BiSelectSort(list4, 10);
    cout << "The order after sort:" << endl;
    PrintArray(list4, 10);
    cout << "----------------------------------" << endl;
    int list5[9] = {1,6,5,200,5,7,9,2,100};
    cout << "The order before sort:" << endl;
    PrintArray(list5, 9);
    BiSelectSort(list5, 9);
    cout << "The order after sort:" << endl;
    PrintArray(list5, 9);
}
