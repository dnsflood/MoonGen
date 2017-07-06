# Так DPDK собираем с поддержкой pcap 
[root@dpdk]# yum install libpcap-devel.x86_64 
# Jemalloc зависимость MoonGen
[root@dpdk]# yum install jemalloc.x86_64

#Поддержка NUMA 
[root@dpdk]# yum install numad.x86_64 numactl.x86_64 numactl-libs.x86_64 numactl-devel.x86_64

#Включаем поддержку hugepage
[root@dpdk]# mkdir -p /mnt/huge
[root@dpdk]# mount -t hugetlbfs nodev /mnt/huge

[root@dpdk MoonGen]# echo 64 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages

#Проверяем, что включили hugepage
[root@dpdk]# grep -i Huge* /proc/meminfo
AnonHugePages:    491520 kB
HugePages_Total:      64
HugePages_Free:       64
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB

# Инсталируем MoonGen network packet generator framework и Intell DPDK SDK

[john@dpdk ~]$ git clone https://github.com/dnsflood/MoonGen
[john@dpdk ~]$ cd MoonGen/
[john@dpdk MoonGen]$ ./build.sh

#Подгружаем требуемые модули 
[root@dpdk MoonGen]# modprobe uio
[root@dpdk MoonGen]# insmod /home/john/MoonGen/libmoon/deps/dpdk/x86_64-native-linuxapp-gcc/kmod/igb_uio.ko 
[root@dpdk MoonGen]# lsmod  | grep uio
igb_uio                13224  0 
uio                    19259  1 igb_uio


#Настраиваем сетевой интерфейс 
[root@dpdk MoonGen]# cd libmoon/deps/dpdk/tools/


#Настраиваем сетевой интерфейс 

##Текущий статус
 
[root@dpdk tools]# ./dpdk-devbind.py --status net 

Network devices using DPDK-compatible driver
============================================
<none>

Network devices using kernel driver
===================================
0000:00:03.0 '82540EM Gigabit Ethernet Controller 100e' if=enp0s3 drv=e1000 unused=igb_uio 
0000:00:08.0 '82540EM Gigabit Ethernet Controller 100e' if=enp0s8 drv=e1000 unused=igb_uio 
0000:00:09.0 '82540EM Gigabit Ethernet Controller 100e' if=enp0s9 drv=e1000 unused=igb_uio 
0000:00:0a.0 '82540EM Gigabit Ethernet Controller 100e' if=enp0s10 drv=e1000 unused=igb_uio *Active*
----------

## Переключаем сетевой интефей enp0s3 на использование драйвера igb_uio    

[root@dpdk tools]# ./dpdk-devbind.py --bind=igb_uio enp0s3

## Проверяем статус 

[root@dpdk tools]# ./dpdk-devbind.py --status-dev net 

Network devices using DPDK-compatible driver
============================================
0000:00:03.0 '82540EM Gigabit Ethernet Controller 100e' drv=igb_uio unused=



# Конфигуруем DPDK библиотеки libmoon  ( Обыно хвататет сконфигурировать исрользуемые сетевые интерфейсы в файле libmoon/dpdk-conf.lua

 --pciBlacklist = {"0000:81:00.3","0000:81:00.1"},
 --pciWhitelist = {"0000:81:00.3","0000:81:00.1"},
В нашем случае добавлю инитерфейс enp0s3 в  pciWhitelist 
pciWhitelist = {"0000:00:03.0"},


Все можно запускать скрипты synflod dnsflood
