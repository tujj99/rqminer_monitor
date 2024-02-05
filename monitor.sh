#!/bin/bash
# Set the hashrate threshold
threshold=1000 # Replace with your desired hashrate threshold
check_interval=60 # Check the hashrate every 60 seconds, adjust according to your needs

echo "Hashrate Threshold: $threshold it/s"
echo "Check Interval: $check_interval seconds"
echo "rqiner is running in the background..."

# Run the mining program in the background and redirect the output to a log file
# Replace with your Payout ID
./rqiner-cuda-runner -i DFAYFKNRNVWWBCTPMLKCHBRFVUVAJIIYEADQZMVMWAFSIUVGGPAGTZAAVIUD --label 4080 > mining.log 2>&1 &

start_timestamp=$(date +%s)
echo "Waiting for 10 seconds to stabilize the hashrate..."
sleep 10

# Initialize the restart count
restart_count=0

while true; do
    # Record the current time
    current_time=$(date "+%Y-%m-%d %H:%M:%S")

    # Get the current hashrate
    mylog="$(tail -n 9 mining.log)"
    current_hashrate=$(echo "$mylog" | grep "GPU" | sed -n 's/.* \([0-9.]*\) it\/s.*/\1/p;q')
    solutions_count=$(echo "$mylog" | grep "Solutions" | sed -n 's/.*Solutions: \([0-9]*\).*/\1/p;q') 
    
    current_timestamp=$(date +%s)
    elapsed_time=$((current_timestamp - start_timestamp))
    elapsed_days=$((elapsed_time / 86400))
    elapsed_hours=$((elapsed_time / 3600 % 24))
    elapsed_minutes=$((elapsed_time / 60 % 60))
    elapsed_seconds=$((elapsed_time % 60))

    # Output the current time, elapsed time, restart count, current hashrate, and solutions count
    echo "---------------------------------------------------------------"
    echo "Current Time: $current_time"
    echo "Elapsed Time: $elapsed_days day $elapsed_hours hour $elapsed_minutes min $elapsed_seconds sec"
    echo "Restart Count: $restart_count"
    echo "Current Hashrate: $current_hashrate it/s"
    echo "Current Solutions: $solutions_count"

    # Check if the hashrate is below the threshold
    if (( $(echo "$current_hashrate < $threshold" | bc -l) )); then 
        echo "Hashrate is below the threshold, restarting the mining program..."

        # Replace with the stop command for your mining program
        pkill -f "rqiner-cuda-runner"

        # Sleep for a while, adjust as needed
        sleep 5 
        restart_count=$((restart_count + 1))

        # Replace with the start command for your mining program
        ./rqiner-cuda-runner -i DFAYFKNRNVWWBCTPMLKCHBRFVUVAJIIYEADQZMVMWAFSIUVGGPAGTZAAVIUD --label 4080 > mining.log 2>&1 &
        echo "rqiner-cuda-runner is running"
    fi
    
    # Sleep for a while, adjust as needed
    sleep $check_interval
done
