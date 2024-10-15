gcc -O2 -fopenmp -o build/numa_benchmark numa_benchmark.c -lnuma
numactl --cpunodebind=0 --membind=0 ./build/numa_benchmark
rm -f cxl_output.txt
rm -f host_output.txt
# for i in 1 2 3; 
# do
#     block=$((10 * i))
#     sudo ./build/numa_benchmark 1 100000 $block >> output.txt
# done

# blocksize_init=64
# blocksize_upper=$(echo "64 * 1024^2" | bc)
# totaldata_init=$(echo "64 * 1024^2" | bc)
# totaldata_upper=$(echo "4 * 1024^3" | bc)

blocksize_init=64
blocksize_upper=$(echo "128" | bc)
totaldata_init=$(echo "64 * 1024^2" | bc)
totaldata_upper=$(echo "128 * 1024^2" | bc)


blocksize=$blocksize_init
while [ $blocksize -le $blocksize_upper ]; do

    totaldata=$totaldata_init
    while [ $totaldata -le $totaldata_upper ]; do
        arraysize=$((totaldata / blocksize))
        # echo $blocksize $totaldata $arraysize
        numactl --cpunodebind=0 --membind=0 
        sudo ./build/numa_benchmark 2 $arraysize $blocksize >> cxl_output.txt
        totaldata=$((totaldata * 2))
    done
    blocksize=$((blocksize * 2))
done

blocksize=$blocksize_init
while [ $blocksize -le $blocksize_upper ]; do

    totaldata=$totaldata_init
    while [ $totaldata -le $totaldata_upper ]; do
        arraysize=$((totaldata / blocksize))
        # echo $blocksize $totaldata $arraysize
        numactl --cpunodebind=0 --membind=0 
        sudo ./build/numa_benchmark 0 $arraysize $blocksize >> host_output.txt
        totaldata=$((totaldata * 2))
    done
    blocksize=$((blocksize * 2))
done

rm -f ./build/numa_benchmark