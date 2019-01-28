#!/bin/bash

# Shell函数返回值，常用的两种方式： return, echo

# 1） return 语句
# shell函数的返回值，可以和其他语言的返回值一样，通过return语句返回
# 注意 !!! return只能用来返回整数值

function test_return_method()
{
    echo "The input parameter:$1"   # It's better to delete this line.
    if [ "$1"x = "return_1"x ] ;then
        return 1
    else
        return 0
    fi
}

echo "test_return_method"
test_return_method "return_1"
return_value=$(test_return_method "return_1")
echo $?        # print return result
# echo "The return value:$return_value" # This is NOT right due to the echo line in above function.

# 2） echo 返回值
# 在shell中，函数的返回值有一个非常安全的返回方式，即通过输出到标准输出返回.
# 因为子进程会继承父进程的标准输出，因此，子进程的输出也就直接反应到父进程.

function test_echo_method()
{
    if [ "$1"x = "return_1"x ] ;then
        echo "match return_1"
    else
        echo "match other"
    fi
}

echo -e "\n test_echo_method"
return_value=$(test_echo_method "return_1")
echo "The return value:$return_value"        # print return result

#注意!!! 不能向标准输出一些不是结果的东西（也就是说，不能随便echo一些不需要的信息），比如调试信息，这些信息可以重定向到一个文件中解决.
# 特别要注意的是，脚本中用到其它类似grep这样的命令的时候，一定要记得1>/dev/null 2>&1来空这些输出信息输出到空设备，避免这些命令的输出.
