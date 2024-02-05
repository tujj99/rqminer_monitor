#!/bin/bash
# 设置算力阈值
threshold=1000 # 替换为您期望的算力阈值 
check_interval=60 # 每60秒检查一次算力，根据情况调整

echo "算力阈值: $threshold it/s"
echo "等待时间: $check_interval"
echo "rqiner后台启动..."

# 后台运行挖矿程序，并将输出重定向到日志文件
# -i 后面替换成自己的Payout ID
./rqiner-cuda-runner -i DFAYFKNRNVWWBCTPMLKCHBRFVUVAJIIYEADQZMVMWAFSIUVGGPAGTZAAVIUD --label 4080 > mining.log 2>&1 &

start_timestamp=$(date +%s)
echo "等待10秒，等算力稳定"
sleep 10

# 初始化程序重启次数
restart_count=0

while true; do
    # 记录当前时间
    current_time=$(date "+%Y-%m-%d %H:%M:%S")

    # 获取当前算力值
    mylog="$(tail -n 9 mining.log)"
    # current_hashrate=$(echo "$mylog" | sed -n '/GPU/s/.* \([0-9.]*\) it\/s.*/\1/p;q')
    current_hashrate=$(echo "$mylog" | grep "GPU" | sed -n 's/.* \([0-9.]*\) it\/s.*/\1/p;q')
    solutions_count=$(echo "$mylog" | grep "Solutions" | sed -n 's/.*Solutions: \([0-9]*\).*/\1/p;q') 
    
    current_timestamp=$(date +%s)
    elapsed_time=$((current_timestamp - start_timestamp))
    elapsed_days=$((elapsed_time / 86400))
    elapsed_hours=$((elapsed_time / 3600 % 24))
    elapsed_minutes=$((elapsed_time / 60 % 60))
    elapsed_seconds=$((elapsed_time % 60))

    # 输出当前时间、程序已运行时间、程序重启次数和当前算力
    echo "---------------------------------------------------------------"
    echo "当前时间: $current_time"
    echo "程序已运行时间: $elapsed_days day $elapsed_hours hour $elapsed_minutes min $elapsed_seconds sec"
    #echo "程序已运行时间: $(($(date +%s) - $(date -d "$(ps -p $PPID -o lstart=)" +%s))) 秒"
    echo "程序重启次数: $restart_count"
    echo "当前算力：$current_hashrate it/s"
    echo "当前Solutions: $solutions_count"

    # 检查算力是否小于阈值
    if (( $(echo "$current_hashrate < $threshold" | bc -l) )); then 
	echo "算力低于阈值，重启挖矿程序..."

        # 替换为您的挖矿程序的停止命令
        pkill -f "rqiner-cuda-runner"

        # 休眠一段时间，可根据实际情况调整
        sleep 5 
	restart_count=$((restart_count + 1))

        # 替换为您的挖矿程序的启动命令
	./rqiner-cuda-runner -i DFAYFKNRNVWWBCTPMLKCHBRFVUVAJIIYEADQZMVMWAFSIUVGGPAGTZAAVIUD --label 4080 > mining.log 2>&1 &
	echo "rqiner-cuda-runner运行中"
    fi
    
    # 休眠一段时间，可根据实际情况调整
    sleep $check_interval
done
