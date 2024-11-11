gcc -O2 -fopenmp -o build/numa_benchmark numa_benchmark.c -lnuma
numactl --cpunodebind=0 --membind=0 ./build/numa_benchmark
rm -f cxl_output.txt
rm -f host_output.txt
# for i in 1 2 3; 
# do
#     block=$((10 * i))
#     sudo ./build/numa_benchmark 1 100000 $block >> output.txt
# done

blocksize_init=8
blocksize_upper=$(echo "2 * 1024" | bc)
arraysize_init=$(echo "16 * 1024" | bc)
arraysize_upper=$(echo "16 * 1024^2" | bc)
# arraysize_init=$(echo "64 * 1024^2" | bc)
# arraysize_upper=$(echo "4 * 1024^3" | bc)



blocksize=$blocksize_init
while [ $blocksize -le $blocksize_upper ]; do
    arraysize=$arraysize_init
    while [ $arraysize -le $arraysize_upper ]; do
        # arraysize=$((arraysize / blocksize))
        # echo $blocksize $arraysize $arraysize
        # sudo numactl --cpunodebind=0 
        sudo numactl --cpunodebind=0 --membind=2 ./build/numa_benchmark 2 $arraysize $blocksize >> cxl_output.txt
        arraysize=$((arraysize * 2))
    done
    blocksize=$((blocksize * 2))
done

blocksize=$blocksize_init
while [ $blocksize -le $blocksize_upper ]; do
    arraysize=$arraysize_init
    while [ $arraysize -le $arraysize_upper ]; do
        # arraysize=$((arraysize / blocksize))
        # echo $blocksize $arraysize $arraysize
        # sudo numactl --cpunodebind=0 
        sudo numactl --cpunodebind=0 --membind=0 ./build/numa_benchmark 0 $arraysize $blocksize >> host_output.txt
        arraysize=$((arraysize * 2))
    done
    blocksize=$((blocksize * 2))
done

rm -f ./build/numa_benchmark
