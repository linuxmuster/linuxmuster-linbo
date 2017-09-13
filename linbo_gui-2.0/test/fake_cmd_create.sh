#!/usr/bin/env bash

# linbo_cmd create /dev/sda4 opensuse-cpqmini.cloop opensuse-cpqmini.cloop /dev/sda1 /dev/sda1 /boot/vmlinuz /boot/initrd
create()
{
    # TODO: check $baseimagefile $imagefile
    local cachedev="$1"
    local imagefile="$2"
    local baseimagefile="$3"
    local bootdev="$4"
    local rootdev="$5"
    local kernel="$6"
    local initrd="$7"
    if [[ "${cachedev}" != "/dev/sda4" ]] \
      || [[ "${imagefile}" != "opensuse-cpqmini.cloop" ]] \
      || [[ "${baseimagefile}" != "opensuse-cpqmini.cloop" ]] \
      || [[ "${bootdev}" != "/dev/sda1" ]] \
      || [[ "${rootdev}" != "/dev/sda1" ]] \
      || [[ "${kernel}" != "/boot/vmlinuz" ]] \
      || [[ "${initrd}" != "/boot/initrd" ]]; then
        echo "Wrong parameters: «$*»"
        return 1
    fi


echo 'create 1:�/dev/sda4� 2:�opensuse-cpqmini.cloop� 3:�opensuse-cpqmini.cloop� 4:�/dev/sda1� 5:�/dev/sda1� 6:�/boot/vmlinuz� 7:�/boot/initrd� '
echo 'Mounte Cachepartition /dev/sda4 ...'
echo "Erzeuge Image 'opensuse-cpqmini.cloop' von Partition '/dev/sda1'..."
echo '## Mon Apr 11 08:52:51 UTC 2016 : Starte Erstellung von opensuse-cpqmini.cloop.'
echo 'Bereite Partition /dev/sda1 (Gr��e=15728640K) f�r Komprimierung vor...'
echo 'Entferne tmp/kde-schueler.'
echo 'Entferne tmp/klassenarbeit.txt.'
echo 'Entferne tmp/resumeAus.txt.'
echo 'Entferne var/tmp/kdecache-schueler.'
echo 'Entferne var/tmp/zypp.gbsD3Q.'
echo 'Sichere Partitions-GUIDs.'
echo 'Leeren Platz auff�llen mit 0en...'
echo '1000.0M genullt... '
sleep 1
echo '2.0G genullt... '
sleep 1
echo '2.9G genullt... '
sleep 1
echo '3.5G genullt... '
sleep 1
echo 'Starte Kompression von /dev/sda1 -> opensuse-cpqmini.cloop (ganze Partition, 15728640K).'
echo 'create_compressed_fs -B 131072 -L 1 -t 2 -s 15728640K /dev/sda1 opensuse-cpqmini.cloop'
echo '2 processor core(s) detected'
echo 'Block size 131072, expected number of blocks: 122880'
echo '[ 1] Blk#     0, [ratio/avg.   2%/  2%], avg.speed: 131072 b/s, ETA: 122879s'
sleep 0.05
echo '[ 1] Blk#   100, [ratio/avg.   0%/  2%], avg.speed: 13238272 b/s, ETA: 1215s'
sleep 0.05
echo '[ 1] Blk#   200, [ratio/avg.   0%/  1%], avg.speed: 26345472 b/s, ETA: 610s'
sleep 0.05
echo '[ 1] Blk#   300, [ratio/avg.   1%/  1%], avg.speed: 39452672 b/s, ETA: 407s'
sleep 0.05
echo '[ 1] Blk#   400, [ratio/avg.   2%/  1%], avg.speed: 52559872 b/s, ETA: 305s'
sleep 0.05
echo '[ 1] Blk#   500, [ratio/avg.   0%/  1%], avg.speed: 65667072 b/s, ETA: 244s'
sleep 0.05
echo '[ 1] Blk#   600, [ratio/avg.   0%/  1%], avg.speed: 78774272 b/s, ETA: 203s'
sleep 0.05
echo '[ 1] Blk#   700, [ratio/avg.   0%/  1%], avg.speed: 91881472 b/s, ETA: 174s'
sleep 0.05
echo '[ 1] Blk#   800, [ratio/avg.   0%/  1%], avg.speed: 52494336 b/s, ETA: 304s'
sleep 0.05
echo '[ 1] Blk#   900, [ratio/avg.   0%/  1%], avg.speed: 59047936 b/s, ETA: 270s'
sleep 0.05
echo '[ 1] Blk#  1000, [ratio/avg.   0%/  0%], avg.speed: 65601536 b/s, ETA: 243s'
sleep 0.05
echo '[ 1] Blk#  1100, [ratio/avg.  56%/  4%], avg.speed: 72155136 b/s, ETA: 221s'
sleep 0.05
echo '[ 1] Blk#  1200, [ratio/avg.  85%/  9%], avg.speed: 78708736 b/s, ETA: 202s'
sleep 0.05
echo '[ 1] Blk#  1300, [ratio/avg.  32%/ 14%], avg.speed: 56841557 b/s, ETA: 280s'
sleep 0.05
echo '[ 1] Blk#  1400, [ratio/avg.  33%/ 15%], avg.speed: 61210624 b/s, ETA: 260s'
sleep 0.05
echo '[ 1] Blk#  1500, [ratio/avg. 100%/ 16%], avg.speed: 65579690 b/s, ETA: 242s'
sleep 0.05
echo '[ 1] Blk#  1600, [ratio/avg.   6%/ 21%], avg.speed: 52461568 b/s, ETA: 303s'
sleep 0.05
echo '[ 1] Blk#  1700, [ratio/avg.  62%/ 21%], avg.speed: 55738368 b/s, ETA: 284s'
sleep 0.05
echo '[ 1] Blk#  1800, [ratio/avg.  32%/ 23%], avg.speed: 59015168 b/s, ETA: 268s'
sleep 0.05
echo '[ 1] Blk#  1900, [ratio/avg.  32%/ 23%], avg.speed: 62291968 b/s, ETA: 254s'
sleep 0.05
echo '[ 1] Blk#  2000, [ratio/avg.  73%/ 25%], avg.speed: 65568768 b/s, ETA: 241s'
sleep 0.05
echo '[ 1] Blk#  2100, [ratio/avg.  52%/ 26%], avg.speed: 55076454 b/s, ETA: 287s'
sleep 0.05
echo '[ 1] Blk#  2200, [ratio/avg.  50%/ 27%], avg.speed: 57697894 b/s, ETA: 274s'
sleep 0.05
echo '[ 1] Blk#  2300, [ratio/avg.  39%/ 28%], avg.speed: 60319334 b/s, ETA: 262s'
sleep 0.05
echo '[ 1] Blk#  2400, [ratio/avg.   5%/ 29%], avg.speed: 52450645 b/s, ETA: 301s'
sleep 0.05
echo '[ 1] Blk#  2500, [ratio/avg.  33%/ 30%], avg.speed: 54635178 b/s, ETA: 288s'
sleep 0.05
echo '[ 1] Blk#  2600, [ratio/avg.  32%/ 31%], avg.speed: 56819712 b/s, ETA: 277s'
sleep 0.05
echo '[ 1] Blk#  2700, [ratio/avg.  75%/ 32%], avg.speed: 50575067 b/s, ETA: 311s'
sleep 0.05
echo '[ 1] Blk#  2800, [ratio/avg.  61%/ 33%], avg.speed: 52447524 b/s, ETA: 300s'
sleep 0.05
echo '[ 1] Blk#  2900, [ratio/avg.  46%/ 34%], avg.speed: 54319981 b/s, ETA: 289s'
sleep 0.05
echo '[ 1] Blk#  3000, [ratio/avg.   4%/ 34%], avg.speed: 49168384 b/s, ETA: 319s'
sleep 0.05
echo '[ 1] Blk#  3100, [ratio/avg. 100%/ 35%], avg.speed: 50806784 b/s, ETA: 309s'
sleep 0.05
echo '[ 1] Blk#  3200, [ratio/avg.  80%/ 36%], avg.speed: 52445184 b/s, ETA: 299s'
sleep 0.05
echo '[ 1] Blk#  3300, [ratio/avg.  47%/ 36%], avg.speed: 54083584 b/s, ETA: 289s'
sleep 0.05
echo '[ 1] Blk#  3400, [ratio/avg.  24%/ 37%], avg.speed: 49530652 b/s, ETA: 316s'
sleep 0.05
echo '[ 1] Blk#  3500, [ratio/avg.   6%/ 37%], avg.speed: 50987008 b/s, ETA: 306s'
sleep 0.05
echo '[ 1] Blk#  3600, [ratio/avg.  37%/ 37%], avg.speed: 52443363 b/s, ETA: 298s'
sleep 0.05
echo '[ 1] Blk#  3700, [ratio/avg.  28%/ 37%], avg.speed: 53899719 b/s, ETA: 289s'
sleep 0.05
echo '[ 1] Blk#  3800, [ratio/avg.  87%/ 37%], avg.speed: 49820467 b/s, ETA: 313s'
sleep 0.05
echo '[ 1] Blk#  3900, [ratio/avg.  49%/ 38%], avg.speed: 46482897 b/s, ETA: 335s'
sleep 0.05
echo '[ 1] Blk#  4000, [ratio/avg.  56%/ 38%], avg.speed: 47674461 b/s, ETA: 326s'
sleep 0.05
echo '[ 1] Blk#  4100, [ratio/avg.  57%/ 39%], avg.speed: 44793856 b/s, ETA: 347s'
sleep 0.05
echo '[ 1] Blk#  4200, [ratio/avg.  21%/ 39%], avg.speed: 45886122 b/s, ETA: 339s'
sleep 0.05
echo '[ 1] Blk#  4300, [ratio/avg.  43%/ 39%], avg.speed: 46978389 b/s, ETA: 330s'
sleep 0.05
echo '[ 1] Blk#  4400, [ratio/avg.  39%/ 39%], avg.speed: 48070656 b/s, ETA: 323s'
sleep 0.05
echo '[ 1] Blk#  4500, [ratio/avg.  77%/ 39%], avg.speed: 42139648 b/s, ETA: 368s'
sleep 0.05
echo '[ 1] Blk#  4600, [ratio/avg.  55%/ 39%], avg.speed: 37691392 b/s, ETA: 411s'
sleep 0.05
echo '[ 1] Blk#  4700, [ratio/avg.  55%/ 40%], avg.speed: 38510592 b/s, ETA: 402s'
sleep 0.05
echo '[ 1] Blk#  4800, [ratio/avg.  51%/ 40%], avg.speed: 39329792 b/s, ETA: 393s'
sleep 0.05
echo '[ 1] Blk#  4900, [ratio/avg.  56%/ 40%], avg.speed: 37787286 b/s, ETA: 409s'
sleep 0.05
echo '[ 1] Blk#  5000, [ratio/avg.  23%/ 40%], avg.speed: 38558298 b/s, ETA: 400s'
sleep 0.05
echo '[ 1] Blk#  5100, [ratio/avg.  84%/ 40%], avg.speed: 39329310 b/s, ETA: 392s'
sleep 0.05
echo '[ 1] Blk#  5200, [ratio/avg.  54%/ 41%], avg.speed: 40100321 b/s, ETA: 384s'
sleep 0.05
echo '[ 1] Blk#  5300, [ratio/avg.  36%/ 41%], avg.speed: 38600704 b/s, ETA: 399s'
sleep 0.05
echo '[ 1] Blk#  5400, [ratio/avg.  35%/ 41%], avg.speed: 39328881 b/s, ETA: 391s'
sleep 0.05
echo '[ 1] Blk#  5500, [ratio/avg.  94%/ 42%], avg.speed: 40057059 b/s, ETA: 384s'
sleep 0.05
echo '[ 1] Blk#  5600, [ratio/avg.  95%/ 43%], avg.speed: 38638645 b/s, ETA: 397s'
sleep 0.05
echo '[ 1] Blk#  5700, [ratio/avg.  96%/ 44%], avg.speed: 39328498 b/s, ETA: 390s'
sleep 0.05
echo '[ 1] Blk#  5800, [ratio/avg.  35%/ 44%], avg.speed: 38017433 b/s, ETA: 403s'
sleep 0.05
echo '[ 1] Blk#  5900, [ratio/avg.  37%/ 44%], avg.speed: 38672793 b/s, ETA: 396s'
sleep 0.05
echo '[ 1] Blk#  6000, [ratio/avg.  39%/ 44%], avg.speed: 39328153 b/s, ETA: 389s'
sleep 0.05
echo '[ 1] Blk#  6100, [ratio/avg.  40%/ 44%], avg.speed: 39983513 b/s, ETA: 382s'
sleep 0.05
echo '[ 1] Blk#  6200, [ratio/avg.  46%/ 44%], avg.speed: 38703689 b/s, ETA: 395s'
sleep 0.05
echo '[ 1] Blk#  6300, [ratio/avg.  24%/ 44%], avg.speed: 39327841 b/s, ETA: 388s'
sleep 0.05
echo '[ 1] Blk#  6400, [ratio/avg.  63%/ 44%], avg.speed: 39951993 b/s, ETA: 382s'
sleep 0.05
echo '[ 1] Blk#  6500, [ratio/avg.  30%/ 44%], avg.speed: 40576146 b/s, ETA: 375s'
sleep 0.05
echo '[ 1] Blk#  6600, [ratio/avg.  40%/ 44%], avg.speed: 39327557 b/s, ETA: 387s'
sleep 0.05
echo '[ 1] Blk#  6700, [ratio/avg.  40%/ 44%], avg.speed: 39923339 b/s, ETA: 381s'
sleep 0.05
echo '[ 1] Blk#  6800, [ratio/avg.  52%/ 44%], avg.speed: 40519121 b/s, ETA: 375s'
sleep 0.05
echo '[ 1] Blk#  6900, [ratio/avg.  52%/ 44%], avg.speed: 39327298 b/s, ETA: 386s'
sleep 0.05
echo '[ 1] Blk#  7000, [ratio/avg.  50%/ 44%], avg.speed: 39897177 b/s, ETA: 380s'
sleep 0.05
echo '[ 1] Blk#  7100, [ratio/avg.  36%/ 44%], avg.speed: 40467055 b/s, ETA: 375s'
sleep 0.05
echo '[ 1] Blk#  7200, [ratio/avg.  34%/ 44%], avg.speed: 39327061 b/s, ETA: 385s'
sleep 0.05
echo '[ 1] Blk#  7300, [ratio/avg.  51%/ 44%], avg.speed: 39873194 b/s, ETA: 379s'
sleep 0.05
echo '[ 1] Blk#  7400, [ratio/avg.  12%/ 44%], avg.speed: 40419328 b/s, ETA: 374s'
sleep 0.05
echo '[ 1] Blk#  7500, [ratio/avg.  12%/ 44%], avg.speed: 39326842 b/s, ETA: 384s'
sleep 0.05
echo '[ 1] Blk#  7600, [ratio/avg.  12%/ 43%], avg.speed: 39851130 b/s, ETA: 379s'
sleep 0.05
echo '[ 1] Blk#  7700, [ratio/avg.  17%/ 43%], avg.speed: 40375418 b/s, ETA: 373s'
sleep 0.05
echo '[ 1] Blk#  7800, [ratio/avg.  33%/ 43%], avg.speed: 40899706 b/s, ETA: 368s'
sleep 0.05
echo '[ 1] Blk#  7900, [ratio/avg.  12%/ 43%], avg.speed: 41423994 b/s, ETA: 363s'
sleep 0.05
echo '[ 1] Blk#  8000, [ratio/avg.  61%/ 43%], avg.speed: 40334887 b/s, ETA: 373s'
sleep 0.05
echo '[ 1] Blk#  8100, [ratio/avg.  12%/ 43%], avg.speed: 40839010 b/s, ETA: 368s'
sleep 0.05
echo '[ 1] Blk#  8200, [ratio/avg.   1%/ 42%], avg.speed: 41343133 b/s, ETA: 363s'
sleep 0.05
echo '[ 1] Blk#  8300, [ratio/avg.  44%/ 42%], avg.speed: 41847256 b/s, ETA: 358s'
sleep 0.05
echo '[ 1] Blk#  8400, [ratio/avg.  49%/ 42%], avg.speed: 40782810 b/s, ETA: 367s'
sleep 0.05
echo '[ 1] Blk#  8500, [ratio/avg.  47%/ 42%], avg.speed: 41268261 b/s, ETA: 363s'
sleep 0.05
echo '[ 1] Blk#  8600, [ratio/avg.  57%/ 42%], avg.speed: 41753713 b/s, ETA: 358s'
sleep 0.05
echo '[ 1] Blk#  8700, [ratio/avg.  55%/ 42%], avg.speed: 40730624 b/s, ETA: 367s'
sleep 0.05
echo '[ 1] Blk#  8800, [ratio/avg.  46%/ 42%], avg.speed: 41198738 b/s, ETA: 362s'
sleep 0.05
echo '[ 1] Blk#  8900, [ratio/avg.  50%/ 42%], avg.speed: 41666852 b/s, ETA: 358s'
sleep 0.05
echo '[ 1] Blk#  9000, [ratio/avg.  65%/ 42%], avg.speed: 40682036 b/s, ETA: 366s'
sleep 0.05
echo '[ 1] Blk#  9100, [ratio/avg.  20%/ 42%], avg.speed: 37277696 b/s, ETA: 400s'
sleep 0.05
echo '[ 1] Blk#  9200, [ratio/avg.  37%/ 42%], avg.speed: 37687296 b/s, ETA: 395s'
sleep 0.05
echo '[ 1] Blk#  9300, [ratio/avg.  41%/ 42%], avg.speed: 38096896 b/s, ETA: 390s'
sleep 0.05
echo '[ 1] Blk#  9400, [ratio/avg.  56%/ 42%], avg.speed: 38506496 b/s, ETA: 386s'
sleep 0.05
echo '[ 1] Blk#  9500, [ratio/avg.  65%/ 42%], avg.speed: 37736820 b/s, ETA: 393s'
sleep 0.05
echo '[ 1] Blk#  9600, [ratio/avg.  24%/ 42%], avg.speed: 38134008 b/s, ETA: 389s'
sleep 0.05
echo '[ 1] Blk#  9700, [ratio/avg.  47%/ 42%], avg.speed: 38531196 b/s, ETA: 385s'
sleep 0.05
echo '[ 1] Blk#  9800, [ratio/avg.  57%/ 42%], avg.speed: 38928384 b/s, ETA: 380s'
sleep 0.05
echo '[ 1] Blk#  9900, [ratio/avg.  47%/ 42%], avg.speed: 38168937 b/s, ETA: 387s'
sleep 0.05
echo '[ 1] Blk# 10000, [ratio/avg.  50%/ 42%], avg.speed: 38554443 b/s, ETA: 383s'
sleep 0.05
echo '[ 1] Blk# 10100, [ratio/avg.  49%/ 42%], avg.speed: 38939949 b/s, ETA: 379s'
sleep 0.05
echo '[ 1] Blk# 10200, [ratio/avg.  54%/ 42%], avg.speed: 38201870 b/s, ETA: 386s'
sleep 0.05
echo '[ 1] Blk# 10300, [ratio/avg.  36%/ 42%], avg.speed: 38576362 b/s, ETA: 382s'
sleep 0.05
echo '[ 1] Blk# 10400, [ratio/avg.  66%/ 42%], avg.speed: 38950853 b/s, ETA: 378s'
sleep 0.05
echo '[ 1] Blk# 10500, [ratio/avg.  45%/ 42%], avg.speed: 39325344 b/s, ETA: 374s'
sleep 0.05
echo '[ 1] Blk# 10600, [ratio/avg.   0%/ 42%], avg.speed: 39699836 b/s, ETA: 370s'
sleep 0.05
echo '[ 1] Blk# 10700, [ratio/avg.   8%/ 42%], avg.speed: 38961152 b/s, ETA: 377s'
sleep 0.05
echo '[ 1] Blk# 10800, [ratio/avg.  48%/ 42%], avg.speed: 39325240 b/s, ETA: 373s'
sleep 0.05
echo '[ 1] Blk# 10900, [ratio/avg.  52%/ 42%], avg.speed: 39689329 b/s, ETA: 369s'
sleep 0.05
echo '[ 1] Blk# 11000, [ratio/avg.  31%/ 42%], avg.speed: 38970893 b/s, ETA: 376s'
sleep 0.05
echo '[ 1] Blk# 11100, [ratio/avg.  14%/ 42%], avg.speed: 39325142 b/s, ETA: 372s'
sleep 0.05
echo '[ 1] Blk# 11200, [ratio/avg.  22%/ 42%], avg.speed: 39679391 b/s, ETA: 368s'
sleep 0.05
echo '[ 1] Blk# 11300, [ratio/avg.  24%/ 42%], avg.speed: 40033639 b/s, ETA: 365s'
sleep 0.05
echo '[ 1] Blk# 11400, [ratio/avg.  11%/ 42%], avg.speed: 40387888 b/s, ETA: 361s'
sleep 0.05
echo '[ 1] Blk# 11500, [ratio/avg.  51%/ 42%], avg.speed: 39669975 b/s, ETA: 368s'
sleep 0.05
echo '[ 1] Blk# 11600, [ratio/avg.  28%/ 42%], avg.speed: 40014901 b/s, ETA: 364s'
sleep 0.05
echo '[ 1] Blk# 11700, [ratio/avg.  53%/ 42%], avg.speed: 40359828 b/s, ETA: 361s'
sleep 0.05
echo '[ 1] Blk# 11800, [ratio/avg.  48%/ 42%], avg.speed: 39661042 b/s, ETA: 367s'
sleep 0.05
echo '[ 1] Blk# 11900, [ratio/avg.  31%/ 42%], avg.speed: 39997124 b/s, ETA: 363s'
sleep 0.05
echo '[ 1] Blk# 12000, [ratio/avg.  33%/ 42%], avg.speed: 40333206 b/s, ETA: 360s'
sleep 0.05
echo '[ 1] Blk# 12100, [ratio/avg.  98%/ 42%], avg.speed: 40669289 b/s, ETA: 357s'
sleep 0.05
echo '[ 1] Blk# 12200, [ratio/avg. 100%/ 42%], avg.speed: 39980236 b/s, ETA: 362s'
sleep 0.05
echo '[ 1] Blk# 12300, [ratio/avg.  24%/ 42%], avg.speed: 40307916 b/s, ETA: 359s'
sleep 0.05
echo '[ 1] Blk# 12400, [ratio/avg.  60%/ 42%], avg.speed: 39644484 b/s, ETA: 365s'
sleep 0.05
echo '[ 1] Blk# 12500, [ratio/avg.  35%/ 43%], avg.speed: 39964172 b/s, ETA: 362s'
sleep 0.05
echo '[ 1] Blk# 12600, [ratio/avg.  27%/ 43%], avg.speed: 39324720 b/s, ETA: 367s'
sleep 0.05
echo '[ 1] Blk# 12700, [ratio/avg.  95%/ 43%], avg.speed: 39636796 b/s, ETA: 364s'
sleep 0.05
echo '[ 1] Blk# 12800, [ratio/avg.  91%/ 43%], avg.speed: 39019829 b/s, ETA: 369s'
sleep 0.05
echo '[ 1] Blk# 12900, [ratio/avg.  49%/ 44%], avg.speed: 39324648 b/s, ETA: 366s'
sleep 0.05
echo '[ 1] Blk# 13000, [ratio/avg.  18%/ 43%], avg.speed: 39629466 b/s, ETA: 363s'
sleep 0.05
echo '[ 1] Blk# 13100, [ratio/avg.  13%/ 43%], avg.speed: 39026688 b/s, ETA: 368s'
sleep 0.05
echo '[ 1] Blk# 13200, [ratio/avg.  98%/ 44%], avg.speed: 39324578 b/s, ETA: 365s'
sleep 0.05
echo '[ 1] Blk# 13300, [ratio/avg.  97%/ 44%], avg.speed: 39622469 b/s, ETA: 362s'
sleep 0.05
echo '[ 1] Blk# 13400, [ratio/avg.  43%/ 44%], avg.speed: 37372252 b/s, ETA: 383s'
sleep 0.05
echo '[ 1] Blk# 13500, [ratio/avg.  98%/ 44%], avg.speed: 37651129 b/s, ETA: 380s'
sleep 0.05
echo '[ 1] Blk# 13600, [ratio/avg.  29%/ 44%], avg.speed: 37139797 b/s, ETA: 385s'
sleep 0.05
echo '[ 1] Blk# 13700, [ratio/avg.  16%/ 44%], avg.speed: 37412864 b/s, ETA: 382s'
sleep 0.05
echo '[ 1] Blk# 13800, [ratio/avg.  35%/ 44%], avg.speed: 37685930 b/s, ETA: 379s'
sleep 0.05
echo '[ 1] Blk# 13900, [ratio/avg.  24%/ 44%], avg.speed: 37958997 b/s, ETA: 376s'
sleep 0.05
echo '[ 1] Blk# 14000, [ratio/avg.  36%/ 44%], avg.speed: 38232064 b/s, ETA: 373s'
sleep 0.05
echo '[ 1] Blk# 14100, [ratio/avg.  30%/ 44%], avg.speed: 37719311 b/s, ETA: 377s'
sleep 0.05
echo '[ 1] Blk# 14200, [ratio/avg.  43%/ 44%], avg.speed: 37986805 b/s, ETA: 374s'
sleep 0.05
echo '[ 1] Blk# 14300, [ratio/avg.  94%/ 44%], avg.speed: 38254299 b/s, ETA: 372s'
sleep 0.05
echo '[ 1] Blk# 14400, [ratio/avg.  23%/ 44%], avg.speed: 37751357 b/s, ETA: 376s'
sleep 0.05
echo '[ 1] Blk# 14500, [ratio/avg.  39%/ 44%], avg.speed: 38013501 b/s, ETA: 373s'
sleep 0.05
echo '[ 1] Blk# 14600, [ratio/avg.  48%/ 44%], avg.speed: 38275645 b/s, ETA: 370s'
sleep 0.05
echo '[ 1] Blk# 14700, [ratio/avg.  37%/ 44%], avg.speed: 38537789 b/s, ETA: 367s'
sleep 0.05
echo '[ 1] Blk# 14800, [ratio/avg.  46%/ 44%], avg.speed: 38799933 b/s, ETA: 365s'
sleep 0.05
echo '[ 1] Blk# 14900, [ratio/avg.  30%/ 44%], avg.speed: 38296154 b/s, ETA: 369s'
sleep 0.05
echo '[ 1] Blk# 15000, [ratio/avg.  16%/ 44%], avg.speed: 38553158 b/s, ETA: 366s'
sleep 0.05
echo '[ 1] Blk# 15100, [ratio/avg.  38%/ 44%], avg.speed: 38810162 b/s, ETA: 363s'
sleep 0.05
echo '[ 1] Blk# 15200, [ratio/avg.  34%/ 44%], avg.speed: 39067166 b/s, ETA: 361s'
sleep 0.05
echo '[ 1] Blk# 15300, [ratio/avg.  44%/ 44%], avg.speed: 38567936 b/s, ETA: 365s'
sleep 0.05
echo '[ 1] Blk# 15400, [ratio/avg.  46%/ 44%], avg.speed: 38819997 b/s, ETA: 362s'
sleep 0.05
echo '[ 1] Blk# 15500, [ratio/avg.  36%/ 44%], avg.speed: 39072059 b/s, ETA: 360s'
sleep 0.05
echo '[ 1] Blk# 15600, [ratio/avg.  33%/ 44%], avg.speed: 39324120 b/s, ETA: 357s'
sleep 0.05
echo '[ 1] Blk# 15700, [ratio/avg.  96%/ 44%], avg.speed: 38829461 b/s, ETA: 361s'
sleep 0.05
echo '[ 1] Blk# 15800, [ratio/avg.  28%/ 44%], avg.speed: 39076767 b/s, ETA: 359s'
sleep 0.05
echo '[ 1] Blk# 15900, [ratio/avg.  96%/ 44%], avg.speed: 39324073 b/s, ETA: 356s'
sleep 0.05
echo '[ 1] Blk# 16000, [ratio/avg.  95%/ 44%], avg.speed: 38838575 b/s, ETA: 360s'
sleep 0.05
echo '[ 1] Blk# 16100, [ratio/avg.  23%/ 44%], avg.speed: 39081301 b/s, ETA: 358s'
sleep 0.05
echo '[ 1] Blk# 16200, [ratio/avg.  33%/ 44%], avg.speed: 39324027 b/s, ETA: 355s'
sleep 0.05
echo '[ 1] Blk# 16300, [ratio/avg.  55%/ 44%], avg.speed: 39566753 b/s, ETA: 353s'
sleep 0.05
echo '[ 1] Blk# 16400, [ratio/avg.   5%/ 44%], avg.speed: 39085670 b/s, ETA: 357s'
sleep 0.05
echo '[ 1] Blk# 16500, [ratio/avg.   5%/ 44%], avg.speed: 39323983 b/s, ETA: 354s'
sleep 0.05
echo '[ 1] Blk# 16600, [ratio/avg.   0%/ 44%], avg.speed: 39562295 b/s, ETA: 352s'
sleep 0.05
echo '[ 1] Blk# 16700, [ratio/avg.   1%/ 43%], avg.speed: 39800608 b/s, ETA: 349s'
sleep 0.05
echo '[ 1] Blk# 16800, [ratio/avg.   1%/ 43%], avg.speed: 39323940 b/s, ETA: 353s'
sleep 0.05
echo '[ 1] Blk# 16900, [ratio/avg.   8%/ 43%], avg.speed: 39557997 b/s, ETA: 351s'
sleep 0.05
echo '[ 1] Blk# 17000, [ratio/avg.   1%/ 43%], avg.speed: 39792054 b/s, ETA: 348s'
sleep 0.05
echo '[ 1] Blk# 17100, [ratio/avg.   0%/ 43%], avg.speed: 40026112 b/s, ETA: 346s'
sleep 0.05
echo '[ 1] Blk# 17200, [ratio/avg.  13%/ 43%], avg.speed: 40260169 b/s, ETA: 344s'
sleep 0.05
echo '[ 1] Blk# 17300, [ratio/avg.  91%/ 42%], avg.speed: 40494226 b/s, ETA: 341s'
sleep 0.05
echo '[ 1] Blk# 17400, [ratio/avg. 100%/ 43%], avg.speed: 40013752 b/s, ETA: 345s'
sleep 0.05
echo '[ 1] Blk# 17500, [ratio/avg. 100%/ 43%], avg.speed: 40243703 b/s, ETA: 343s'
sleep 0.05
echo '[ 1] Blk# 17600, [ratio/avg.  17%/ 43%], avg.speed: 40473653 b/s, ETA: 340s'
sleep 0.05
echo '[ 1] Blk# 17700, [ratio/avg.  19%/ 43%], avg.speed: 40001818 b/s, ETA: 344s'
sleep 0.05
echo '[ 1] Blk# 17800, [ratio/avg.  14%/ 43%], avg.speed: 40227804 b/s, ETA: 342s'
sleep 0.05
echo '[ 1] Blk# 17900, [ratio/avg.  19%/ 43%], avg.speed: 40453790 b/s, ETA: 340s'
sleep 0.05
echo '[ 1] Blk# 18000, [ratio/avg.  41%/ 43%], avg.speed: 39990289 b/s, ETA: 343s'
sleep 0.05
echo '[ 1] Blk# 18100, [ratio/avg.  25%/ 43%], avg.speed: 40212445 b/s, ETA: 341s'
sleep 0.05
echo '[ 1] Blk# 18200, [ratio/avg.  35%/ 43%], avg.speed: 40434601 b/s, ETA: 339s'
sleep 0.05
echo '[ 1] Blk# 18300, [ratio/avg.  74%/ 42%], avg.speed: 40656757 b/s, ETA: 337s'
sleep 0.05
echo '[ 1] Blk# 18400, [ratio/avg.  26%/ 42%], avg.speed: 40878913 b/s, ETA: 334s'
sleep 0.05
echo '[ 1] Blk# 18500, [ratio/avg.  82%/ 42%], avg.speed: 40416051 b/s, ETA: 338s'
sleep 0.05
echo '[ 1] Blk# 18600, [ratio/avg.  38%/ 42%], avg.speed: 40634504 b/s, ETA: 336s'
sleep 0.05
echo '[ 1] Blk# 18700, [ratio/avg.  34%/ 42%], avg.speed: 40183237 b/s, ETA: 339s'
sleep 0.05
echo '[ 1] Blk# 18800, [ratio/avg.  75%/ 42%], avg.speed: 40398109 b/s, ETA: 337s'
sleep 0.05
echo '[ 1] Blk# 18900, [ratio/avg.  97%/ 43%], avg.speed: 40612981 b/s, ETA: 335s'
sleep 0.05
echo '[ 1] Blk# 19000, [ratio/avg.  32%/ 43%], avg.speed: 40169339 b/s, ETA: 338s'
sleep 0.05
echo '[ 1] Blk# 19100, [ratio/avg.  33%/ 43%], avg.speed: 40380746 b/s, ETA: 336s'
sleep 0.05
echo '[ 1] Blk# 19200, [ratio/avg.  94%/ 43%], avg.speed: 40592152 b/s, ETA: 334s'
sleep 0.05
echo '[ 1] Blk# 19300, [ratio/avg.  60%/ 43%], avg.speed: 38920318 b/s, ETA: 348s'
sleep 0.05
echo '[ 1] Blk# 19400, [ratio/avg.  47%/ 43%], avg.speed: 39121967 b/s, ETA: 346s'
sleep 0.05
echo '[ 1] Blk# 19500, [ratio/avg.  32%/ 43%], avg.speed: 39323616 b/s, ETA: 344s'
sleep 0.05
echo '[ 1] Blk# 19600, [ratio/avg.  78%/ 43%], avg.speed: 39525265 b/s, ETA: 342s'
sleep 0.05
echo '[ 1] Blk# 19700, [ratio/avg.  25%/ 43%], avg.speed: 39124992 b/s, ETA: 345s'
sleep 0.05
echo '[ 1] Blk# 19800, [ratio/avg.  79%/ 43%], avg.speed: 39323585 b/s, ETA: 343s'
sleep 0.05
echo '[ 1] Blk# 19900, [ratio/avg.  40%/ 43%], avg.speed: 39522179 b/s, ETA: 341s'
sleep 0.05
echo '[ 1] Blk# 20000, [ratio/avg.  28%/ 43%], avg.speed: 39720773 b/s, ETA: 339s'
sleep 0.05
echo '[ 1] Blk# 20100, [ratio/avg.  17%/ 43%], avg.speed: 39323556 b/s, ETA: 342s'
sleep 0.05
echo '[ 1] Blk# 20200, [ratio/avg.  25%/ 43%], avg.speed: 39519186 b/s, ETA: 340s'
sleep 0.05
echo '[ 1] Blk# 20300, [ratio/avg.  73%/ 43%], avg.speed: 39714816 b/s, ETA: 338s'
sleep 0.05
echo '[ 1] Blk# 20400, [ratio/avg.  62%/ 43%], avg.speed: 39910445 b/s, ETA: 336s'
sleep 0.05
echo '[ 1] Blk# 20500, [ratio/avg.  69%/ 43%], avg.speed: 39516280 b/s, ETA: 339s'
sleep 0.05
echo '[ 1] Blk# 20600, [ratio/avg.  63%/ 43%], avg.speed: 39709033 b/s, ETA: 337s'
sleep 0.05
echo '[ 1] Blk# 20700, [ratio/avg.  57%/ 44%], avg.speed: 39901786 b/s, ETA: 335s'
sleep 0.05
echo '[ 1] Blk# 20800, [ratio/avg.  69%/ 44%], avg.speed: 39513459 b/s, ETA: 338s'
sleep 0.05
echo '[ 1] Blk# 20900, [ratio/avg.  72%/ 44%], avg.speed: 39703418 b/s, ETA: 336s'
sleep 0.05
echo '[ 1] Blk# 21000, [ratio/avg.  55%/ 44%], avg.speed: 39893377 b/s, ETA: 334s'
sleep 0.05
echo '[ 1] Blk# 21100, [ratio/avg.  65%/ 44%], avg.speed: 39510718 b/s, ETA: 337s'
sleep 0.05
echo '[ 1] Blk# 21200, [ratio/avg.  68%/ 44%], avg.speed: 39697963 b/s, ETA: 335s'
sleep 0.05
echo '[ 1] Blk# 21300, [ratio/avg.  98%/ 44%], avg.speed: 39885209 b/s, ETA: 333s'
sleep 0.05
echo '[ 1] Blk# 21400, [ratio/avg.  18%/ 44%], avg.speed: 40072455 b/s, ETA: 331s'
sleep 0.05
echo '[ 1] Blk# 21500, [ratio/avg.  96%/ 44%], avg.speed: 39692662 b/s, ETA: 334s'
sleep 0.05
echo '[ 1] Blk# 21600, [ratio/avg.  18%/ 44%], avg.speed: 39877271 b/s, ETA: 332s'
sleep 0.05
echo '[ 1] Blk# 21700, [ratio/avg.  59%/ 44%], avg.speed: 40061879 b/s, ETA: 331s'
sleep 0.05
echo '[ 1] Blk# 21800, [ratio/avg.  16%/ 44%], avg.speed: 39687509 b/s, ETA: 333s'
sleep 0.05
echo '[ 1] Blk# 21900, [ratio/avg.  12%/ 44%], avg.speed: 39869553 b/s, ETA: 331s'
sleep 0.05
echo '[ 1] Blk# 22000, [ratio/avg.  67%/ 44%], avg.speed: 40051598 b/s, ETA: 330s'
sleep 0.05
echo '[ 1] Blk# 22100, [ratio/avg.   8%/ 44%], avg.speed: 39682496 b/s, ETA: 332s'
sleep 0.05
echo '[ 1] Blk# 22200, [ratio/avg.  35%/ 44%], avg.speed: 39862047 b/s, ETA: 331s'
sleep 0.05
echo '[ 1] Blk# 22300, [ratio/avg.  13%/ 44%], avg.speed: 40041598 b/s, ETA: 329s'
sleep 0.05
echo '[ 1] Blk# 22400, [ratio/avg.  41%/ 44%], avg.speed: 40221148 b/s, ETA: 327s'
sleep 0.05
echo '[ 1] Blk# 22500, [ratio/avg.  12%/ 44%], avg.speed: 40400699 b/s, ETA: 325s'
sleep 0.05
echo '[ 1] Blk# 22600, [ratio/avg.  32%/ 44%], avg.speed: 40031868 b/s, ETA: 328s'
sleep 0.05
echo '[ 1] Blk# 22700, [ratio/avg.  31%/ 44%], avg.speed: 40208992 b/s, ETA: 326s'
sleep 0.05
echo '[ 1] Blk# 22800, [ratio/avg.  39%/ 44%], avg.speed: 39323324 b/s, ETA: 333s'
sleep 0.05
echo '[ 1] Blk# 22900, [ratio/avg.  40%/ 44%], avg.speed: 39495787 b/s, ETA: 331s'
sleep 0.05
echo '[ 1] Blk# 23000, [ratio/avg.  26%/ 44%], avg.speed: 39668250 b/s, ETA: 330s'
sleep 0.05
echo '[ 1] Blk# 23100, [ratio/avg.  26%/ 44%], avg.speed: 39323302 b/s, ETA: 332s'
sleep 0.05
echo '[ 1] Blk# 23200, [ratio/avg.  42%/ 44%], avg.speed: 39493525 b/s, ETA: 330s'
sleep 0.05
echo '[ 1] Blk# 23300, [ratio/avg.  42%/ 44%], avg.speed: 39663748 b/s, ETA: 329s'
sleep 0.05
echo '[ 1] Blk# 23400, [ratio/avg.  39%/ 43%], avg.speed: 39833972 b/s, ETA: 327s'
sleep 0.05
echo '[ 1] Blk# 23500, [ratio/avg.  38%/ 43%], avg.speed: 39491321 b/s, ETA: 329s'
sleep 0.05
echo '[ 1] Blk# 23600, [ratio/avg.  22%/ 43%], avg.speed: 39659362 b/s, ETA: 328s'
sleep 0.05
echo '[ 1] Blk# 23700, [ratio/avg.  36%/ 43%], avg.speed: 39827403 b/s, ETA: 326s'
sleep 0.05
echo '[ 1] Blk# 23800, [ratio/avg.  30%/ 43%], avg.speed: 39995444 b/s, ETA: 324s'
sleep 0.05
echo '[ 1] Blk# 23900, [ratio/avg.  31%/ 43%], avg.speed: 39655086 b/s, ETA: 327s'
sleep 0.05
echo '[ 1] Blk# 24000, [ratio/avg.  31%/ 43%], avg.speed: 39821000 b/s, ETA: 325s'
sleep 0.05
echo '[ 1] Blk# 24100, [ratio/avg.  44%/ 43%], avg.speed: 39986914 b/s, ETA: 323s'
sleep 0.05
echo '[ 1] Blk# 24200, [ratio/avg.  40%/ 43%], avg.speed: 40152828 b/s, ETA: 322s'
sleep 0.05
echo '[ 1] Blk# 24300, [ratio/avg.  17%/ 43%], avg.speed: 40318742 b/s, ETA: 320s'
sleep 0.05
echo '[ 1] Blk# 24400, [ratio/avg.  39%/ 43%], avg.speed: 39978598 b/s, ETA: 322s'
sleep 0.05
echo '[ 1] Blk# 24500, [ratio/avg.  69%/ 43%], avg.speed: 40142438 b/s, ETA: 321s'
sleep 0.05
echo '[ 1] Blk# 24600, [ratio/avg.  88%/ 43%], avg.speed: 40306278 b/s, ETA: 319s'
sleep 0.05
echo '[ 1] Blk# 24700, [ratio/avg.  29%/ 43%], avg.speed: 39970487 b/s, ETA: 321s'
sleep 0.05
echo '[ 1] Blk# 24800, [ratio/avg.  29%/ 43%], avg.speed: 40132304 b/s, ETA: 320s'
sleep 0.05
echo '[ 1] Blk# 24900, [ratio/avg.  26%/ 43%], avg.speed: 40294121 b/s, ETA: 318s'
sleep 0.05
echo '[ 1] Blk# 25000, [ratio/avg.  26%/ 43%], avg.speed: 40455939 b/s, ETA: 317s'
sleep 0.05
echo '[ 1] Blk# 25100, [ratio/avg.  62%/ 43%], avg.speed: 40617756 b/s, ETA: 315s'
sleep 0.05
echo '[ 1] Blk# 25200, [ratio/avg.  56%/ 43%], avg.speed: 40282261 b/s, ETA: 317s'
sleep 0.05
echo '[ 1] Blk# 25300, [ratio/avg.  43%/ 43%], avg.speed: 40442105 b/s, ETA: 316s'
sleep 0.05
echo '[ 1] Blk# 25400, [ratio/avg.  99%/ 43%], avg.speed: 40601949 b/s, ETA: 314s'
sleep 0.05
echo '[ 1] Blk# 25500, [ratio/avg.  99%/ 44%], avg.speed: 40270687 b/s, ETA: 316s'
sleep 0.05
echo '[ 1] Blk# 25600, [ratio/avg.  97%/ 44%], avg.speed: 40428605 b/s, ETA: 315s'
sleep 0.05
echo '[ 1] Blk# 25700, [ratio/avg.  99%/ 44%], avg.speed: 40103350 b/s, ETA: 317s'
sleep 0.05
echo '[ 1] Blk# 25800, [ratio/avg.  99%/ 44%], avg.speed: 39785749 b/s, ETA: 319s'
sleep 0.05
echo '[ 1] Blk# 25900, [ratio/avg.  99%/ 44%], avg.speed: 39939951 b/s, ETA: 318s'
sleep 0.05
echo '[ 1] Blk# 26000, [ratio/avg.  55%/ 44%], avg.speed: 40094153 b/s, ETA: 316s'
sleep 0.05
echo '[ 1] Blk# 26100, [ratio/avg.  46%/ 44%], avg.speed: 39780352 b/s, ETA: 318s'
sleep 0.05
echo '[ 1] Blk# 26200, [ratio/avg.  99%/ 44%], avg.speed: 39932761 b/s, ETA: 317s'
sleep 0.05
echo '[ 1] Blk# 26300, [ratio/avg.  99%/ 45%], avg.speed: 39174144 b/s, ETA: 323s'
sleep 0.05
echo '[ 1] Blk# 26400, [ratio/avg.  11%/ 45%], avg.speed: 38881256 b/s, ETA: 325s'
sleep 0.05
echo '[ 1] Blk# 26500, [ratio/avg.  46%/ 45%], avg.speed: 39028528 b/s, ETA: 323s'
sleep 0.05
echo '[ 1] Blk# 26600, [ratio/avg.  72%/ 45%], avg.speed: 39175800 b/s, ETA: 322s'
sleep 0.05
echo '[ 1] Blk# 26700, [ratio/avg.  98%/ 45%], avg.speed: 39323072 b/s, ETA: 320s'
sleep 0.05
echo '[ 1] Blk# 26800, [ratio/avg.  97%/ 45%], avg.speed: 39031785 b/s, ETA: 322s'
sleep 0.05
echo '[ 1] Blk# 26900, [ratio/avg.  96%/ 45%], avg.speed: 39177420 b/s, ETA: 321s'
sleep 0.05
echo '[ 1] Blk# 27000, [ratio/avg.  97%/ 45%], avg.speed: 38890934 b/s, ETA: 323s'
sleep 0.05
echo '[ 1] Blk# 27100, [ratio/avg.  96%/ 45%], avg.speed: 39034970 b/s, ETA: 321s'
sleep 0.05
echo '[ 1] Blk# 27200, [ratio/avg.  93%/ 46%], avg.speed: 38753146 b/s, ETA: 323s'
sleep 0.05
echo '[ 1] Blk# 27300, [ratio/avg.  97%/ 46%], avg.speed: 38895616 b/s, ETA: 322s'
sleep 0.05
echo '[ 1] Blk# 27400, [ratio/avg.  88%/ 46%], avg.speed: 39038085 b/s, ETA: 320s'
sleep 0.05
echo '[ 1] Blk# 27500, [ratio/avg.  97%/ 46%], avg.speed: 38759258 b/s, ETA: 322s'
sleep 0.05
echo '[ 1] Blk# 27600, [ratio/avg.  90%/ 46%], avg.speed: 38900196 b/s, ETA: 321s'
sleep 0.05
echo '[ 1] Blk# 27700, [ratio/avg.  17%/ 46%], avg.speed: 38625802 b/s, ETA: 322s'
sleep 0.05
echo '[ 1] Blk# 27800, [ratio/avg.  86%/ 46%], avg.speed: 38765241 b/s, ETA: 321s'
sleep 0.05
echo '[ 1] Blk# 27900, [ratio/avg.  15%/ 47%], avg.speed: 38904679 b/s, ETA: 319s'
sleep 0.05
echo '[ 1] Blk# 28000, [ratio/avg.  95%/ 47%], avg.speed: 38633127 b/s, ETA: 321s'
sleep 0.05
echo '[ 1] Blk# 28100, [ratio/avg.  88%/ 47%], avg.speed: 38367232 b/s, ETA: 323s'
sleep 0.05
echo '[ 1] Blk# 28200, [ratio/avg.  97%/ 47%], avg.speed: 38503765 b/s, ETA: 322s'
sleep 0.05
echo '[ 1] Blk# 28300, [ratio/avg.  94%/ 47%], avg.speed: 38241945 b/s, ETA: 324s'
sleep 0.05
echo '[ 1] Blk# 28400, [ratio/avg.  96%/ 47%], avg.speed: 38377070 b/s, ETA: 322s'
sleep 0.05
echo '[ 1] Blk# 28500, [ratio/avg.  87%/ 47%], avg.speed: 37356830 b/s, ETA: 331s'
sleep 0.05
echo '[ 1] Blk# 28600, [ratio/avg.  17%/ 47%], avg.speed: 37487902 b/s, ETA: 329s'
sleep 0.05
echo '[ 1] Blk# 28700, [ratio/avg.  16%/ 47%], avg.speed: 37618974 b/s, ETA: 328s'
sleep 0.05
echo '[ 1] Blk# 28800, [ratio/avg.  18%/ 47%], avg.speed: 37750046 b/s, ETA: 326s'
sleep 0.05
echo '[ 1] Blk# 28900, [ratio/avg.  24%/ 47%], avg.speed: 37506058 b/s, ETA: 328s'
sleep 0.05
echo '[ 1] Blk# 29000, [ratio/avg.  99%/ 47%], avg.speed: 37635832 b/s, ETA: 326s'
sleep 0.05
echo '[ 1] Blk# 29100, [ratio/avg.  99%/ 48%], avg.speed: 37765606 b/s, ETA: 325s'
sleep 0.05
echo '[ 1] Blk# 29200, [ratio/avg.  23%/ 48%], avg.speed: 37523857 b/s, ETA: 327s'
sleep 0.05
echo '[ 1] Blk# 29300, [ratio/avg.  99%/ 48%], avg.speed: 37652359 b/s, ETA: 325s'
sleep 0.05
echo '[ 1] Blk# 29400, [ratio/avg.  99%/ 48%], avg.speed: 37414057 b/s, ETA: 327s'
sleep 0.05
echo '[ 1] Blk# 29500, [ratio/avg.  99%/ 48%], avg.speed: 37541311 b/s, ETA: 326s'
sleep 0.05
echo '[ 1] Blk# 29600, [ratio/avg.  99%/ 48%], avg.speed: 37668565 b/s, ETA: 324s'
sleep 0.05
echo '[ 1] Blk# 29700, [ratio/avg.  90%/ 49%], avg.speed: 37432398 b/s, ETA: 326s'
sleep 0.05
echo '[ 1] Blk# 29800, [ratio/avg.  97%/ 49%], avg.speed: 37558429 b/s, ETA: 324s'
sleep 0.05
echo '[ 1] Blk# 29900, [ratio/avg.  99%/ 49%], avg.speed: 37325560 b/s, ETA: 326s'
sleep 0.05
echo '[ 1] Blk# 30000, [ratio/avg.  98%/ 49%], avg.speed: 37450391 b/s, ETA: 325s'
sleep 0.05
echo '[ 1] Blk# 30100, [ratio/avg.  96%/ 49%], avg.speed: 37220738 b/s, ETA: 326s'
sleep 0.05
echo '[ 1] Blk# 30200, [ratio/avg.  99%/ 49%], avg.speed: 37344391 b/s, ETA: 325s'
sleep 0.05
echo '[ 1] Blk# 30300, [ratio/avg.  99%/ 50%], avg.speed: 37117875 b/s, ETA: 326s'
sleep 0.05
echo '[ 1] Blk# 30400, [ratio/avg.  90%/ 50%], avg.speed: 37240372 b/s, ETA: 325s'
sleep 0.05
echo '[ 1] Blk# 30500, [ratio/avg.  88%/ 50%], avg.speed: 37016917 b/s, ETA: 327s'
sleep 0.05
echo '[ 1] Blk# 30600, [ratio/avg.  97%/ 50%], avg.speed: 36797562 b/s, ETA: 328s'
sleep 0.05
echo '[ 1] Blk# 30700, [ratio/avg.  73%/ 50%], avg.speed: 36917811 b/s, ETA: 327s'
sleep 0.05
echo '[ 1] Blk# 30800, [ratio/avg.  98%/ 50%], avg.speed: 36045970 b/s, ETA: 334s'
sleep 0.05
echo '[ 1] Blk# 30900, [ratio/avg.  63%/ 50%], avg.speed: 36162998 b/s, ETA: 333s'
sleep 0.05
echo '[ 1] Blk# 31000, [ratio/avg.  92%/ 50%], avg.speed: 35958965 b/s, ETA: 334s'
sleep 0.05
echo '[ 1] Blk# 31100, [ratio/avg.  19%/ 50%], avg.speed: 36074958 b/s, ETA: 333s'
sleep 0.05
echo '[ 1] Blk# 31200, [ratio/avg. 100%/ 51%], avg.speed: 36190951 b/s, ETA: 332s'
sleep 0.05
echo '[ 1] Blk# 31300, [ratio/avg.  40%/ 51%], avg.speed: 35988462 b/s, ETA: 333s'
sleep 0.05
echo '[ 1] Blk# 31400, [ratio/avg.  41%/ 50%], avg.speed: 36103437 b/s, ETA: 332s'
sleep 0.05
echo '[ 1] Blk# 31500, [ratio/avg.  40%/ 50%], avg.speed: 36218412 b/s, ETA: 330s'
sleep 0.05
echo '[ 1] Blk# 31600, [ratio/avg.  40%/ 50%], avg.speed: 36333388 b/s, ETA: 329s'
sleep 0.05
echo '[ 1] Blk# 31700, [ratio/avg.  40%/ 50%], avg.speed: 36131421 b/s, ETA: 330s'
sleep 0.05
echo '[ 1] Blk# 31800, [ratio/avg.  19%/ 50%], avg.speed: 36245397 b/s, ETA: 329s'
sleep 0.05
echo '[ 1] Blk# 31900, [ratio/avg.  32%/ 50%], avg.speed: 36359372 b/s, ETA: 327s'
sleep 0.05
echo '[ 1] Blk# 32000, [ratio/avg.  27%/ 50%], avg.speed: 36473348 b/s, ETA: 326s'
sleep 0.05
echo '[ 1] Blk# 32100, [ratio/avg.  33%/ 50%], avg.speed: 36587324 b/s, ETA: 325s'
sleep 0.05
echo '[ 1] Blk# 32200, [ratio/avg.   8%/ 50%], avg.speed: 36384909 b/s, ETA: 326s'
sleep 0.05
echo '[ 1] Blk# 32300, [ratio/avg.   9%/ 50%], avg.speed: 36497902 b/s, ETA: 325s'
sleep 0.05
echo '[ 1] Blk# 32400, [ratio/avg.   4%/ 50%], avg.speed: 36610895 b/s, ETA: 323s'
sleep 0.05
echo '[ 1] Blk# 32500, [ratio/avg.   0%/ 50%], avg.speed: 36723888 b/s, ETA: 322s'
sleep 0.05
echo '[ 1] Blk# 32600, [ratio/avg.   0%/ 50%], avg.speed: 36836881 b/s, ETA: 321s'
sleep 0.05
echo '[ 1] Blk# 32700, [ratio/avg.  20%/ 49%], avg.speed: 36949874 b/s, ETA: 319s'
sleep 0.05
echo '[ 1] Blk# 32800, [ratio/avg.   5%/ 49%], avg.speed: 37062867 b/s, ETA: 318s'
sleep 0.05
echo '[ 1] Blk# 32900, [ratio/avg.   0%/ 49%], avg.speed: 37175860 b/s, ETA: 317s'
sleep 0.05
echo '[ 1] Blk# 33000, [ratio/avg.   0%/ 49%], avg.speed: 36970145 b/s, ETA: 318s'
sleep 0.05
echo '[ 1] Blk# 33100, [ratio/avg.  17%/ 49%], avg.speed: 37082173 b/s, ETA: 317s'
sleep 0.05
echo '[ 1] Blk# 33200, [ratio/avg.   0%/ 49%], avg.speed: 37194200 b/s, ETA: 316s'
sleep 0.05
echo '[ 1] Blk# 33300, [ratio/avg.   0%/ 49%], avg.speed: 37306227 b/s, ETA: 314s'
sleep 0.05
echo '[ 1] Blk# 33400, [ratio/avg.   0%/ 48%], avg.speed: 37418255 b/s, ETA: 313s'
sleep 0.05
echo '[ 1] Blk# 33500, [ratio/avg.   0%/ 48%], avg.speed: 37530282 b/s, ETA: 312s'
sleep 0.05
echo '[ 1] Blk# 33600, [ratio/avg.   0%/ 48%], avg.speed: 37642310 b/s, ETA: 310s'
sleep 0.05
echo '[ 1] Blk# 33700, [ratio/avg.   0%/ 48%], avg.speed: 37754337 b/s, ETA: 309s'
sleep 0.05
echo '[ 1] Blk# 33800, [ratio/avg.  17%/ 48%], avg.speed: 37545463 b/s, ETA: 310s'
sleep 0.05
echo '[ 1] Blk# 33900, [ratio/avg.  31%/ 48%], avg.speed: 37656541 b/s, ETA: 309s'
sleep 0.05
echo '[ 1] Blk# 34000, [ratio/avg.  26%/ 48%], avg.speed: 37767619 b/s, ETA: 308s'
sleep 0.05
echo '[ 1] Blk# 34100, [ratio/avg.  35%/ 48%], avg.speed: 37878697 b/s, ETA: 307s'
sleep 0.05
echo '[ 1] Blk# 34200, [ratio/avg.  16%/ 48%], avg.speed: 37989775 b/s, ETA: 305s'
sleep 0.05
echo '[ 1] Blk# 34300, [ratio/avg.  47%/ 48%], avg.speed: 37780677 b/s, ETA: 307s'
sleep 0.05
echo '[ 1] Blk# 34400, [ratio/avg.  11%/ 47%], avg.speed: 37890822 b/s, ETA: 306s'
sleep 0.05
echo '[ 1] Blk# 34500, [ratio/avg.  10%/ 47%], avg.speed: 38000966 b/s, ETA: 304s'
sleep 0.05
echo '[ 1] Blk# 34600, [ratio/avg.  32%/ 47%], avg.speed: 38111111 b/s, ETA: 303s'
sleep 0.05
echo '[ 1] Blk# 34700, [ratio/avg.  22%/ 47%], avg.speed: 38221256 b/s, ETA: 302s'
sleep 0.05
echo '[ 1] Blk# 34800, [ratio/avg.  21%/ 47%], avg.speed: 38011972 b/s, ETA: 303s'
sleep 0.05
echo '[ 1] Blk# 34900, [ratio/avg.  19%/ 47%], avg.speed: 38121198 b/s, ETA: 302s'
sleep 0.05
echo '[ 1] Blk# 35000, [ratio/avg.  99%/ 47%], avg.speed: 38230425 b/s, ETA: 301s'
sleep 0.05
echo '[ 1] Blk# 35100, [ratio/avg. 100%/ 47%], avg.speed: 38339652 b/s, ETA: 300s'
sleep 0.05
echo '[ 1] Blk# 35200, [ratio/avg.  51%/ 47%], avg.speed: 38131119 b/s, ETA: 301s'
sleep 0.05
echo '[ 1] Blk# 35300, [ratio/avg.   6%/ 47%], avg.speed: 38239443 b/s, ETA: 300s'
sleep 0.05
echo '[ 1] Blk# 35400, [ratio/avg.  83%/ 47%], avg.speed: 38347767 b/s, ETA: 299s'
sleep 0.05
echo '[ 1] Blk# 35500, [ratio/avg.  89%/ 47%], avg.speed: 38456091 b/s, ETA: 297s'
sleep 0.05
echo '[ 1] Blk# 35600, [ratio/avg.  15%/ 47%], avg.speed: 38248313 b/s, ETA: 299s'
sleep 0.05
echo '[ 1] Blk# 35700, [ratio/avg.  97%/ 47%], avg.speed: 38355749 b/s, ETA: 297s'
sleep 0.05
echo '[ 1] Blk# 35800, [ratio/avg.  23%/ 47%], avg.speed: 38150477 b/s, ETA: 299s'
sleep 0.05
echo '[ 1] Blk# 35900, [ratio/avg.  13%/ 47%], avg.speed: 38257039 b/s, ETA: 297s'
sleep 0.05
echo '[ 1] Blk# 36000, [ratio/avg.  14%/ 47%], avg.speed: 38363602 b/s, ETA: 296s'
sleep 0.05
echo '[ 1] Blk# 36100, [ratio/avg.  14%/ 47%], avg.speed: 38470164 b/s, ETA: 295s'
sleep 0.05
echo '[ 1] Blk# 36200, [ratio/avg.  15%/ 47%], avg.speed: 38576727 b/s, ETA: 294s'
sleep 0.05
echo '[ 1] Blk# 36300, [ratio/avg.   8%/ 47%], avg.speed: 38683290 b/s, ETA: 293s'
sleep 0.05
echo '[ 1] Blk# 36400, [ratio/avg.  10%/ 47%], avg.speed: 38477031 b/s, ETA: 294s'
sleep 0.05
echo '[ 1] Blk# 36500, [ratio/avg.   8%/ 47%], avg.speed: 38582734 b/s, ETA: 293s'
sleep 0.05
echo '[ 1] Blk# 36600, [ratio/avg.  15%/ 47%], avg.speed: 38688437 b/s, ETA: 292s'
sleep 0.05
echo '[ 1] Blk# 36700, [ratio/avg.  18%/ 46%], avg.speed: 38794140 b/s, ETA: 291s'
sleep 0.05
echo '[ 1] Blk# 36800, [ratio/avg.  15%/ 46%], avg.speed: 38899844 b/s, ETA: 290s'
sleep 0.05
echo '[ 1] Blk# 36900, [ratio/avg.  10%/ 46%], avg.speed: 39005547 b/s, ETA: 288s'
sleep 0.05
echo '[ 1] Blk# 37000, [ratio/avg.  11%/ 46%], avg.speed: 39111250 b/s, ETA: 287s'
sleep 0.05
echo '[ 1] Blk# 37100, [ratio/avg.  18%/ 46%], avg.speed: 38903218 b/s, ETA: 289s'
sleep 0.05
echo '[ 1] Blk# 37200, [ratio/avg.  13%/ 46%], avg.speed: 39008075 b/s, ETA: 287s'
sleep 0.05
echo '[ 1] Blk# 37300, [ratio/avg.  14%/ 46%], avg.speed: 39112933 b/s, ETA: 286s'
sleep 0.05
echo '[ 1] Blk# 37400, [ratio/avg.  14%/ 46%], avg.speed: 39217790 b/s, ETA: 285s'
sleep 0.05
echo '[ 1] Blk# 37500, [ratio/avg.   8%/ 46%], avg.speed: 39322648 b/s, ETA: 284s'
sleep 0.05
echo '[ 1] Blk# 37600, [ratio/avg.  14%/ 46%], avg.speed: 39114589 b/s, ETA: 285s'
sleep 0.05
echo '[ 1] Blk# 37700, [ratio/avg.   9%/ 46%], avg.speed: 39218614 b/s, ETA: 284s'
sleep 0.05
echo '[ 1] Blk# 37800, [ratio/avg.  98%/ 46%], avg.speed: 39322640 b/s, ETA: 283s'
sleep 0.05
echo '[ 1] Blk# 37900, [ratio/avg.  16%/ 46%], avg.speed: 39426665 b/s, ETA: 282s'
sleep 0.05
echo '[ 1] Blk# 38000, [ratio/avg.  41%/ 46%], avg.speed: 39219425 b/s, ETA: 283s'
sleep 0.05
echo '[ 1] Blk# 38100, [ratio/avg.  18%/ 46%], avg.speed: 39322632 b/s, ETA: 282s'
sleep 0.05
echo '[ 1] Blk# 38200, [ratio/avg.  95%/ 46%], avg.speed: 39425838 b/s, ETA: 281s'
sleep 0.05
echo '[ 1] Blk# 38300, [ratio/avg.  69%/ 46%], avg.speed: 38916191 b/s, ETA: 284s'
sleep 0.05
echo '[ 1] Blk# 38400, [ratio/avg.  63%/ 46%], avg.speed: 38717660 b/s, ETA: 285s'
sleep 0.05
echo '[ 1] Blk# 38500, [ratio/avg.  96%/ 46%], avg.speed: 38818485 b/s, ETA: 284s'
sleep 0.05
echo '[ 1] Blk# 38600, [ratio/avg.  96%/ 46%], avg.speed: 38919309 b/s, ETA: 283s'
sleep 0.05
echo '[ 1] Blk# 38700, [ratio/avg.  78%/ 46%], avg.speed: 38722270 b/s, ETA: 284s'
sleep 0.05
echo '[ 1] Blk# 38800, [ratio/avg.  22%/ 46%], avg.speed: 38822325 b/s, ETA: 283s'
sleep 0.05
echo '[ 1] Blk# 38900, [ratio/avg.  98%/ 46%], avg.speed: 38922380 b/s, ETA: 282s'
sleep 0.05
echo '[ 1] Blk# 39000, [ratio/avg.  92%/ 46%], avg.speed: 38726811 b/s, ETA: 283s'
sleep 0.05
echo '[ 1] Blk# 39100, [ratio/avg.  97%/ 46%], avg.speed: 38826108 b/s, ETA: 282s'
sleep 0.05
echo '[ 1] Blk# 39200, [ratio/avg.  88%/ 46%], avg.speed: 38925405 b/s, ETA: 281s'
sleep 0.05
echo '[ 1] Blk# 39300, [ratio/avg.  54%/ 46%], avg.speed: 38731283 b/s, ETA: 282s'
sleep 0.05
echo '[ 1] Blk# 39400, [ratio/avg.  98%/ 47%], avg.speed: 38829833 b/s, ETA: 281s'
sleep 0.05
echo '[ 1] Blk# 39500, [ratio/avg.  95%/ 47%], avg.speed: 38637873 b/s, ETA: 282s'
sleep 0.05
echo '[ 1] Blk# 39600, [ratio/avg.  90%/ 47%], avg.speed: 38735688 b/s, ETA: 281s'
sleep 0.05
echo '[ 1] Blk# 39700, [ratio/avg.  93%/ 47%], avg.speed: 38833503 b/s, ETA: 280s'
sleep 0.05
echo '[ 1] Blk# 39800, [ratio/avg.  99%/ 47%], avg.speed: 38642938 b/s, ETA: 281s'
sleep 0.05
echo '[ 1] Blk# 39900, [ratio/avg.  88%/ 47%], avg.speed: 38740028 b/s, ETA: 280s'
sleep 0.05
echo '[ 1] Blk# 40000, [ratio/avg.  97%/ 47%], avg.speed: 38551552 b/s, ETA: 281s'
sleep 0.05
echo '[ 1] Blk# 40100, [ratio/avg.  76%/ 47%], avg.speed: 38647928 b/s, ETA: 280s'
sleep 0.05
echo '[ 1] Blk# 40200, [ratio/avg.  97%/ 47%], avg.speed: 38461499 b/s, ETA: 281s'
sleep 0.05
echo '[ 1] Blk# 40300, [ratio/avg.  94%/ 47%], avg.speed: 38557172 b/s, ETA: 280s'
sleep 0.05
echo '[ 1] Blk# 40400, [ratio/avg.  85%/ 47%], avg.speed: 38652845 b/s, ETA: 279s'
sleep 0.05
echo '[ 1] Blk# 40500, [ratio/avg.  30%/ 48%], avg.speed: 38467732 b/s, ETA: 280s'
sleep 0.05
echo '[ 1] Blk# 40600, [ratio/avg.  99%/ 48%], avg.speed: 38285282 b/s, ETA: 281s'
sleep 0.05
echo '[ 1] Blk# 40700, [ratio/avg.  97%/ 48%], avg.speed: 38379578 b/s, ETA: 280s'
sleep 0.05
echo '[ 1] Blk# 40800, [ratio/avg.  80%/ 48%], avg.speed: 38473875 b/s, ETA: 279s'
sleep 0.05
echo '[ 1] Blk# 40900, [ratio/avg.   3%/ 48%], avg.speed: 37753351 b/s, ETA: 284s'
sleep 0.05
echo '[ 1] Blk# 41000, [ratio/avg.  99%/ 48%], avg.speed: 37845655 b/s, ETA: 283s'
sleep 0.05
echo '[ 1] Blk# 41100, [ratio/avg.  34%/ 48%], avg.speed: 37937959 b/s, ETA: 282s'
sleep 0.05
echo '[ 1] Blk# 41200, [ratio/avg.  41%/ 48%], avg.speed: 37764317 b/s, ETA: 283s'
sleep 0.05
echo '[ 1] Blk# 41300, [ratio/avg.  97%/ 48%], avg.speed: 37855976 b/s, ETA: 282s'
sleep 0.05
echo '[ 1] Blk# 41400, [ratio/avg. 100%/ 48%], avg.speed: 37947635 b/s, ETA: 281s'
sleep 0.05
echo '[ 1] Blk# 41500, [ratio/avg.  47%/ 48%], avg.speed: 37775132 b/s, ETA: 282s'
sleep 0.05
echo '[ 1] Blk# 41600, [ratio/avg.  96%/ 48%], avg.speed: 37866154 b/s, ETA: 281s'
sleep 0.05
echo '[ 1] Blk# 41700, [ratio/avg.  98%/ 48%], avg.speed: 37695403 b/s, ETA: 282s'
sleep 0.05
echo '[ 1] Blk# 41800, [ratio/avg.  93%/ 49%], avg.speed: 37785797 b/s, ETA: 281s'
sleep 0.05
echo '[ 1] Blk# 41900, [ratio/avg.  99%/ 49%], avg.speed: 37616766 b/s, ETA: 282s'
sleep 0.05
echo '[ 1] Blk# 42000, [ratio/avg.  17%/ 49%], avg.speed: 37706541 b/s, ETA: 281s'
sleep 0.05
echo '[ 1] Blk# 42100, [ratio/avg.  17%/ 49%], avg.speed: 37796316 b/s, ETA: 280s'
sleep 0.05
echo '[ 1] Blk# 42200, [ratio/avg.  20%/ 48%], avg.speed: 37886092 b/s, ETA: 279s'
sleep 0.05
echo '[ 1] Blk# 42300, [ratio/avg.   0%/ 48%], avg.speed: 37975867 b/s, ETA: 278s'
sleep 0.05
echo '[ 1] Blk# 42400, [ratio/avg.   0%/ 48%], avg.speed: 38065642 b/s, ETA: 277s'
sleep 0.05
echo '[ 1] Blk# 42500, [ratio/avg.  11%/ 48%], avg.speed: 38155418 b/s, ETA: 276s'
sleep 0.05
echo '[ 1] Blk# 42600, [ratio/avg.   0%/ 48%], avg.speed: 37985022 b/s, ETA: 277s'
sleep 0.05
echo '[ 1] Blk# 42700, [ratio/avg.   0%/ 48%], avg.speed: 38074186 b/s, ETA: 276s'
sleep 0.05
echo '[ 1] Blk# 42800, [ratio/avg.   0%/ 48%], avg.speed: 38163351 b/s, ETA: 275s'
sleep 0.05
echo '[ 1] Blk# 42900, [ratio/avg.   0%/ 48%], avg.speed: 38252516 b/s, ETA: 274s'
sleep 0.05
echo '[ 1] Blk# 43000, [ratio/avg.   0%/ 48%], avg.speed: 38341680 b/s, ETA: 273s'
sleep 0.05
echo '[ 1] Blk# 43100, [ratio/avg.   0%/ 48%], avg.speed: 38430845 b/s, ETA: 272s'
sleep 0.05
echo '[ 1] Blk# 43200, [ratio/avg.   0%/ 48%], avg.speed: 38259739 b/s, ETA: 272s'
sleep 0.05
echo '[ 1] Blk# 43300, [ratio/avg.   0%/ 47%], avg.speed: 38348301 b/s, ETA: 271s'
sleep 0.05
echo '[ 1] Blk# 43400, [ratio/avg.   0%/ 47%], avg.speed: 38436864 b/s, ETA: 271s'
sleep 0.05
echo '[ 1] Blk# 43500, [ratio/avg.   0%/ 47%], avg.speed: 38525426 b/s, ETA: 270s'
sleep 0.05
echo '[ 1] Blk# 43600, [ratio/avg.   0%/ 47%], avg.speed: 38613988 b/s, ETA: 269s'
sleep 0.05
echo '[ 1] Blk# 43700, [ratio/avg.   0%/ 47%], avg.speed: 38702550 b/s, ETA: 268s'
sleep 0.05
echo '[ 1] Blk# 43800, [ratio/avg.   0%/ 47%], avg.speed: 38791112 b/s, ETA: 267s'
sleep 0.05
echo '[ 1] Blk# 43900, [ratio/avg.   0%/ 47%], avg.speed: 38879674 b/s, ETA: 266s'
sleep 0.05
echo '[ 1] Blk# 44000, [ratio/avg.   0%/ 47%], avg.speed: 38706705 b/s, ETA: 267s'
sleep 0.05
echo '[ 1] Blk# 44100, [ratio/avg.   0%/ 47%], avg.speed: 38794672 b/s, ETA: 266s'
sleep 0.05
echo '[ 1] Blk# 44200, [ratio/avg.   0%/ 47%], avg.speed: 38882640 b/s, ETA: 265s'
sleep 0.05
echo '[ 1] Blk# 44300, [ratio/avg.   0%/ 46%], avg.speed: 38970608 b/s, ETA: 264s'
sleep 0.05
echo '[ 1] Blk# 44400, [ratio/avg.   0%/ 46%], avg.speed: 39058576 b/s, ETA: 263s'
sleep 0.05
echo '[ 1] Blk# 44500, [ratio/avg.   0%/ 46%], avg.speed: 39146544 b/s, ETA: 262s'
sleep 0.05
echo '[ 1] Blk# 44600, [ratio/avg.   0%/ 46%], avg.speed: 39234511 b/s, ETA: 261s'
sleep 0.05
echo '[ 1] Blk# 44700, [ratio/avg.   0%/ 46%], avg.speed: 39060329 b/s, ETA: 262s'
sleep 0.05
echo '[ 1] Blk# 44800, [ratio/avg.   0%/ 46%], avg.speed: 39147711 b/s, ETA: 261s'
sleep 0.05
echo '[ 1] Blk# 44900, [ratio/avg.   0%/ 46%], avg.speed: 39235092 b/s, ETA: 260s'
sleep 0.05
echo '[ 1] Blk# 45000, [ratio/avg.   0%/ 46%], avg.speed: 39322473 b/s, ETA: 259s'
sleep 0.05
echo '[ 1] Blk# 45100, [ratio/avg.   0%/ 46%], avg.speed: 39409855 b/s, ETA: 258s'
sleep 0.05
echo '[ 1] Blk# 45200, [ratio/avg.   0%/ 45%], avg.speed: 39497236 b/s, ETA: 257s'
sleep 0.05
echo '[ 1] Blk# 45300, [ratio/avg.   0%/ 45%], avg.speed: 39584617 b/s, ETA: 256s'
sleep 0.05
echo '[ 1] Blk# 45400, [ratio/avg.   0%/ 45%], avg.speed: 39671999 b/s, ETA: 255s'
sleep 0.05
echo '[ 1] Blk# 45500, [ratio/avg.   0%/ 45%], avg.speed: 39496073 b/s, ETA: 256s'
sleep 0.05
echo '[ 1] Blk# 45600, [ratio/avg.   0%/ 45%], avg.speed: 39582875 b/s, ETA: 255s'
sleep 0.05
echo '[ 1] Blk# 45700, [ratio/avg.   0%/ 45%], avg.speed: 39669678 b/s, ETA: 255s'
sleep 0.05
echo '[ 1] Blk# 45800, [ratio/avg.  97%/ 45%], avg.speed: 39756481 b/s, ETA: 254s'
sleep 0.05
echo '[ 1] Blk# 45900, [ratio/avg.   0%/ 45%], avg.speed: 39843283 b/s, ETA: 253s'
sleep 0.05
echo '[ 1] Blk# 46000, [ratio/avg.   0%/ 45%], avg.speed: 39930086 b/s, ETA: 252s'
sleep 0.05
echo '[ 1] Blk# 46100, [ratio/avg.   0%/ 45%], avg.speed: 39753620 b/s, ETA: 253s'
sleep 0.05
echo '[ 1] Blk# 46200, [ratio/avg.   0%/ 45%], avg.speed: 39839851 b/s, ETA: 252s'
sleep 0.05
echo '[ 1] Blk# 46300, [ratio/avg.   0%/ 45%], avg.speed: 39926083 b/s, ETA: 251s'
sleep 0.05
echo '[ 1] Blk# 46400, [ratio/avg.   0%/ 44%], avg.speed: 40012314 b/s, ETA: 250s'
sleep 0.05
echo '[ 1] Blk# 46500, [ratio/avg.   0%/ 44%], avg.speed: 40098546 b/s, ETA: 249s'
sleep 0.05
echo '[ 1] Blk# 46600, [ratio/avg.   0%/ 44%], avg.speed: 40184778 b/s, ETA: 248s'
sleep 0.05
echo '[ 1] Blk# 46700, [ratio/avg.   0%/ 44%], avg.speed: 40271009 b/s, ETA: 247s'
sleep 0.05
echo '[ 1] Blk# 46800, [ratio/avg.   0%/ 44%], avg.speed: 40357241 b/s, ETA: 247s'
sleep 0.05
echo '[ 1] Blk# 46900, [ratio/avg.   0%/ 44%], avg.speed: 40179136 b/s, ETA: 247s'
sleep 0.05
echo '[ 1] Blk# 47000, [ratio/avg.   0%/ 44%], avg.speed: 40264804 b/s, ETA: 247s'
sleep 0.05
echo '[ 1] Blk# 47100, [ratio/avg.   0%/ 44%], avg.speed: 40350472 b/s, ETA: 246s'
sleep 0.05
echo '[ 1] Blk# 47200, [ratio/avg.   0%/ 44%], avg.speed: 40436140 b/s, ETA: 245s'
sleep 0.05
echo '[ 1] Blk# 47300, [ratio/avg.   0%/ 44%], avg.speed: 40521808 b/s, ETA: 244s'
sleep 0.05
echo '[ 1] Blk# 47400, [ratio/avg.   0%/ 44%], avg.speed: 40607476 b/s, ETA: 243s'
sleep 0.05
echo '[ 1] Blk# 47500, [ratio/avg.   0%/ 43%], avg.speed: 40693144 b/s, ETA: 242s'
sleep 0.05
echo '[ 1] Blk# 47600, [ratio/avg.   0%/ 43%], avg.speed: 40778812 b/s, ETA: 241s'
sleep 0.05
echo '[ 1] Blk# 47700, [ratio/avg.   0%/ 43%], avg.speed: 40599126 b/s, ETA: 242s'
sleep 0.05
echo '[ 1] Blk# 47800, [ratio/avg.   0%/ 43%], avg.speed: 40684238 b/s, ETA: 241s'
sleep 0.05
echo '[ 1] Blk# 47900, [ratio/avg.   0%/ 43%], avg.speed: 40769349 b/s, ETA: 241s'
sleep 0.05
echo '[ 1] Blk# 48000, [ratio/avg.   0%/ 43%], avg.speed: 40854461 b/s, ETA: 240s'
sleep 0.05
echo '[ 1] Blk# 48100, [ratio/avg.   0%/ 43%], avg.speed: 40939573 b/s, ETA: 239s'
sleep 0.05
echo '[ 1] Blk# 48200, [ratio/avg.   0%/ 43%], avg.speed: 41024684 b/s, ETA: 238s'
sleep 0.05
echo '[ 1] Blk# 48300, [ratio/avg.   0%/ 43%], avg.speed: 41109796 b/s, ETA: 237s'
sleep 0.05
echo '[ 1] Blk# 48400, [ratio/avg.   0%/ 43%], avg.speed: 41194908 b/s, ETA: 236s'
sleep 0.05
echo '[ 1] Blk# 48500, [ratio/avg.   0%/ 43%], avg.speed: 41280019 b/s, ETA: 236s'
sleep 0.05
echo '[ 1] Blk# 48600, [ratio/avg.   0%/ 42%], avg.speed: 41098259 b/s, ETA: 236s'
sleep 0.05
echo '[ 1] Blk# 48700, [ratio/avg.   0%/ 42%], avg.speed: 41182822 b/s, ETA: 236s'
sleep 0.05
echo '[ 1] Blk# 48800, [ratio/avg.   0%/ 42%], avg.speed: 41267384 b/s, ETA: 235s'
sleep 0.05
echo '[ 1] Blk# 48900, [ratio/avg.   0%/ 42%], avg.speed: 41351947 b/s, ETA: 234s'
sleep 0.05
echo '[ 1] Blk# 49000, [ratio/avg.   0%/ 42%], avg.speed: 41436510 b/s, ETA: 233s'
sleep 0.05
echo '[ 1] Blk# 49100, [ratio/avg.   0%/ 42%], avg.speed: 41521072 b/s, ETA: 232s'
sleep 0.05
echo '[ 1] Blk# 49200, [ratio/avg.   4%/ 42%], avg.speed: 41338932 b/s, ETA: 233s'
sleep 0.05
echo '[ 1] Blk# 49300, [ratio/avg.   0%/ 42%], avg.speed: 41422953 b/s, ETA: 232s'
sleep 0.05
echo '[ 1] Blk# 49400, [ratio/avg.   0%/ 42%], avg.speed: 41506973 b/s, ETA: 232s'
sleep 0.05
echo '[ 1] Blk# 49500, [ratio/avg.   3%/ 42%], avg.speed: 41590994 b/s, ETA: 231s'
sleep 0.05
echo '[ 1] Blk# 49600, [ratio/avg.   0%/ 42%], avg.speed: 41675014 b/s, ETA: 230s'
sleep 0.05
echo '[ 1] Blk# 49700, [ratio/avg.   0%/ 42%], avg.speed: 41759035 b/s, ETA: 229s'
sleep 0.05
echo '[ 1] Blk# 49800, [ratio/avg.   0%/ 41%], avg.speed: 41843055 b/s, ETA: 228s'
sleep 0.05
echo '[ 1] Blk# 49900, [ratio/avg.   0%/ 41%], avg.speed: 41927076 b/s, ETA: 228s'
sleep 0.05
echo '[ 1] Blk# 50000, [ratio/avg.   0%/ 41%], avg.speed: 41743510 b/s, ETA: 228s'
sleep 0.05
echo '[ 1] Blk# 50100, [ratio/avg.   0%/ 41%], avg.speed: 41826995 b/s, ETA: 228s'
sleep 0.05
echo '[ 1] Blk# 50200, [ratio/avg. 100%/ 41%], avg.speed: 41910480 b/s, ETA: 227s'
sleep 0.05
echo '[ 1] Blk# 50300, [ratio/avg.   6%/ 41%], avg.speed: 41993966 b/s, ETA: 226s'
sleep 0.05
echo '[ 1] Blk# 50400, [ratio/avg.   1%/ 41%], avg.speed: 42077451 b/s, ETA: 225s'
sleep 0.05
echo '[ 1] Blk# 50500, [ratio/avg.   4%/ 41%], avg.speed: 42160936 b/s, ETA: 225s'
sleep 0.05
echo '[ 1] Blk# 50600, [ratio/avg.   2%/ 41%], avg.speed: 42244422 b/s, ETA: 224s'
sleep 0.05
echo '[ 1] Blk# 50700, [ratio/avg.   1%/ 41%], avg.speed: 42327907 b/s, ETA: 223s'
sleep 0.05
echo '[ 1] Blk# 50800, [ratio/avg.   3%/ 41%], avg.speed: 42142966 b/s, ETA: 224s'
sleep 0.05
echo '[ 1] Blk# 50900, [ratio/avg.   2%/ 41%], avg.speed: 42225923 b/s, ETA: 223s'
sleep 0.05
echo '[ 1] Blk# 51000, [ratio/avg.   3%/ 41%], avg.speed: 42308880 b/s, ETA: 222s'
sleep 0.05
echo '[ 1] Blk# 51100, [ratio/avg.   3%/ 41%], avg.speed: 42391837 b/s, ETA: 221s'
sleep 0.05
echo '[ 1] Blk# 51200, [ratio/avg.   3%/ 40%], avg.speed: 42474794 b/s, ETA: 221s'
sleep 0.05
echo '[ 1] Blk# 51300, [ratio/avg.  70%/ 40%], avg.speed: 42557751 b/s, ETA: 220s'
sleep 0.05
echo '[ 1] Blk# 51400, [ratio/avg.   9%/ 40%], avg.speed: 42640708 b/s, ETA: 219s'
sleep 0.05
echo '[ 1] Blk# 51500, [ratio/avg.  48%/ 40%], avg.speed: 42454962 b/s, ETA: 220s'
sleep 0.05
echo '[ 1] Blk# 51600, [ratio/avg.  52%/ 40%], avg.speed: 42537397 b/s, ETA: 219s'
sleep 0.05
echo '[ 1] Blk# 51700, [ratio/avg.  14%/ 40%], avg.speed: 42353459 b/s, ETA: 220s'
sleep 0.05
echo '[ 1] Blk# 51800, [ratio/avg.  53%/ 40%], avg.speed: 42435379 b/s, ETA: 219s'
sleep 0.05
echo '[ 1] Blk# 51900, [ratio/avg.  45%/ 40%], avg.speed: 42517299 b/s, ETA: 218s'
sleep 0.05
echo '[ 1] Blk# 52000, [ratio/avg.  54%/ 40%], avg.speed: 42334627 b/s, ETA: 219s'
sleep 0.05
echo '[ 1] Blk# 52100, [ratio/avg.  40%/ 40%], avg.speed: 42416038 b/s, ETA: 218s'
sleep 0.05
echo '[ 1] Blk# 52200, [ratio/avg.  47%/ 40%], avg.speed: 42497450 b/s, ETA: 217s'
sleep 0.05
echo '[ 1] Blk# 52300, [ratio/avg.  47%/ 40%], avg.speed: 42578861 b/s, ETA: 217s'
sleep 0.05
echo '[ 1] Blk# 52400, [ratio/avg.  34%/ 40%], avg.speed: 41879901 b/s, ETA: 220s'
sleep 0.05
echo '[ 1] Blk# 52500, [ratio/avg.  40%/ 40%], avg.speed: 41959823 b/s, ETA: 219s'
sleep 0.05
echo '[ 1] Blk# 52600, [ratio/avg.  38%/ 40%], avg.speed: 42039745 b/s, ETA: 219s'
sleep 0.05
echo '[ 1] Blk# 52700, [ratio/avg.  35%/ 40%], avg.speed: 42119667 b/s, ETA: 218s'
sleep 0.05
echo '[ 1] Blk# 52800, [ratio/avg.  51%/ 40%], avg.speed: 41943834 b/s, ETA: 218s'
sleep 0.05
echo '[ 1] Blk# 52900, [ratio/avg.  52%/ 40%], avg.speed: 42023271 b/s, ETA: 218s'
sleep 0.05
echo '[ 1] Blk# 53000, [ratio/avg.  50%/ 40%], avg.speed: 42102709 b/s, ETA: 217s'
sleep 0.05
echo '[ 1] Blk# 53100, [ratio/avg.  46%/ 40%], avg.speed: 41928037 b/s, ETA: 218s'
sleep 0.05
echo '[ 1] Blk# 53200, [ratio/avg.  49%/ 40%], avg.speed: 42006996 b/s, ETA: 217s'
sleep 0.05
echo '[ 1] Blk# 53300, [ratio/avg.  47%/ 40%], avg.speed: 42085955 b/s, ETA: 216s'
sleep 0.05
echo '[ 1] Blk# 53400, [ratio/avg.  30%/ 40%], avg.speed: 42164914 b/s, ETA: 215s'
sleep 0.05
echo '[ 1] Blk# 53500, [ratio/avg.  33%/ 40%], avg.speed: 41990916 b/s, ETA: 216s'
sleep 0.05
echo '[ 1] Blk# 53600, [ratio/avg.  39%/ 40%], avg.speed: 42069402 b/s, ETA: 215s'
sleep 0.05
echo '[ 1] Blk# 53700, [ratio/avg.  27%/ 40%], avg.speed: 42147889 b/s, ETA: 215s'
sleep 0.05
echo '[ 1] Blk# 53800, [ratio/avg.  26%/ 40%], avg.speed: 42226375 b/s, ETA: 214s'
sleep 0.05
echo '[ 1] Blk# 53900, [ratio/avg.   2%/ 40%], avg.speed: 42304861 b/s, ETA: 213s'
sleep 0.05
echo '[ 1] Blk# 54000, [ratio/avg.  43%/ 40%], avg.speed: 42131065 b/s, ETA: 214s'
sleep 0.05
echo '[ 1] Blk# 54100, [ratio/avg.  35%/ 40%], avg.speed: 42209084 b/s, ETA: 213s'
sleep 0.05
echo '[ 1] Blk# 54200, [ratio/avg.  41%/ 40%], avg.speed: 42287104 b/s, ETA: 212s'
sleep 0.05
echo '[ 1] Blk# 54300, [ratio/avg.  39%/ 40%], avg.speed: 42365123 b/s, ETA: 212s'
sleep 0.05
echo '[ 1] Blk# 54400, [ratio/avg.  27%/ 40%], avg.speed: 42191999 b/s, ETA: 212s'
sleep 0.05
echo '[ 1] Blk# 54500, [ratio/avg.  44%/ 40%], avg.speed: 42269556 b/s, ETA: 212s'
sleep 0.05
echo '[ 1] Blk# 54600, [ratio/avg.  40%/ 40%], avg.speed: 42347114 b/s, ETA: 211s'
sleep 0.05
echo '[ 1] Blk# 54700, [ratio/avg.  49%/ 40%], avg.speed: 42424671 b/s, ETA: 210s'
sleep 0.05
echo '[ 1] Blk# 54800, [ratio/avg.  37%/ 40%], avg.speed: 42252215 b/s, ETA: 211s'
sleep 0.05
echo '[ 1] Blk# 54900, [ratio/avg.  41%/ 40%], avg.speed: 42329316 b/s, ETA: 210s'
sleep 0.05
echo '[ 1] Blk# 55000, [ratio/avg.  50%/ 40%], avg.speed: 42406418 b/s, ETA: 209s'
sleep 0.05
echo '[ 1] Blk# 55100, [ratio/avg.  44%/ 40%], avg.speed: 42235077 b/s, ETA: 210s'
sleep 0.05
echo '[ 1] Blk# 55200, [ratio/avg.  39%/ 40%], avg.speed: 42311727 b/s, ETA: 209s'
sleep 0.05
echo '[ 1] Blk# 55300, [ratio/avg.  49%/ 40%], avg.speed: 42388378 b/s, ETA: 208s'
sleep 0.05
echo '[ 1] Blk# 55400, [ratio/avg.  48%/ 40%], avg.speed: 42465028 b/s, ETA: 208s'
sleep 0.05
echo '[ 1] Blk# 55500, [ratio/avg.  49%/ 40%], avg.speed: 42294343 b/s, ETA: 208s'
sleep 0.05
echo '[ 1] Blk# 55600, [ratio/avg.  77%/ 40%], avg.speed: 42370548 b/s, ETA: 208s'
sleep 0.05
echo '[ 1] Blk# 55700, [ratio/avg.  52%/ 40%], avg.speed: 42446752 b/s, ETA: 207s'
sleep 0.05
echo '[ 1] Blk# 55800, [ratio/avg.  40%/ 40%], avg.speed: 42522957 b/s, ETA: 206s'
sleep 0.05
echo '[ 1] Blk# 55900, [ratio/avg.  22%/ 40%], avg.speed: 42352924 b/s, ETA: 207s'
sleep 0.05
echo '[ 1] Blk# 56000, [ratio/avg.  57%/ 40%], avg.speed: 42428688 b/s, ETA: 206s'
sleep 0.05
echo '[ 1] Blk# 56100, [ratio/avg.  54%/ 40%], avg.speed: 42260173 b/s, ETA: 207s'
sleep 0.05
echo '[ 1] Blk# 56200, [ratio/avg.  48%/ 40%], avg.speed: 42335502 b/s, ETA: 206s'
sleep 0.05
echo '[ 1] Blk# 56300, [ratio/avg.  50%/ 40%], avg.speed: 42410831 b/s, ETA: 205s'
sleep 0.05
echo '[ 1] Blk# 56400, [ratio/avg.  40%/ 40%], avg.speed: 42486160 b/s, ETA: 205s'
sleep 0.05
echo '[ 1] Blk# 56500, [ratio/avg.  62%/ 40%], avg.speed: 42318280 b/s, ETA: 205s'
sleep 0.05
echo '[ 1] Blk# 56600, [ratio/avg.  48%/ 40%], avg.speed: 42393178 b/s, ETA: 204s'
sleep 0.05
echo '[ 1] Blk# 56700, [ratio/avg.  41%/ 40%], avg.speed: 42226781 b/s, ETA: 205s'
sleep 0.05
echo '[ 1] Blk# 56800, [ratio/avg.  31%/ 40%], avg.speed: 42301253 b/s, ETA: 204s'
sleep 0.05
echo '[ 1] Blk# 56900, [ratio/avg.  42%/ 40%], avg.speed: 42375726 b/s, ETA: 204s'
sleep 0.05
echo '[ 1] Blk# 57000, [ratio/avg.  10%/ 40%], avg.speed: 42450199 b/s, ETA: 203s'
sleep 0.05
echo '[ 1] Blk# 57100, [ratio/avg.  42%/ 40%], avg.speed: 42284419 b/s, ETA: 203s'
sleep 0.05
echo '[ 1] Blk# 57200, [ratio/avg.  45%/ 40%], avg.speed: 42358471 b/s, ETA: 203s'
sleep 0.05
echo '[ 1] Blk# 57300, [ratio/avg.  43%/ 40%], avg.speed: 42432523 b/s, ETA: 202s'
sleep 0.05
echo '[ 1] Blk# 57400, [ratio/avg.  52%/ 40%], avg.speed: 42031641 b/s, ETA: 204s'
sleep 0.05
echo '[ 1] Blk# 57500, [ratio/avg.  34%/ 40%], avg.speed: 41870950 b/s, ETA: 204s'
sleep 0.05
echo '[ 1] Blk# 57600, [ratio/avg.  41%/ 40%], avg.speed: 41943768 b/s, ETA: 203s'
sleep 0.05
echo '[ 1] Blk# 57700, [ratio/avg.  36%/ 40%], avg.speed: 42016585 b/s, ETA: 203s'
sleep 0.05
echo '[ 1] Blk# 57800, [ratio/avg.  31%/ 40%], avg.speed: 42089403 b/s, ETA: 202s'
sleep 0.05
echo '[ 1] Blk# 57900, [ratio/avg.  48%/ 40%], avg.speed: 41929281 b/s, ETA: 203s'
sleep 0.05
echo '[ 1] Blk# 58000, [ratio/avg.  46%/ 40%], avg.speed: 42001696 b/s, ETA: 202s'
sleep 0.05
echo '[ 1] Blk# 58100, [ratio/avg.  50%/ 40%], avg.speed: 42074112 b/s, ETA: 201s'
sleep 0.05
echo '[ 1] Blk# 58200, [ratio/avg.  41%/ 40%], avg.speed: 42146527 b/s, ETA: 201s'
sleep 0.05
echo '[ 1] Blk# 58300, [ratio/avg.  42%/ 40%], avg.speed: 41986970 b/s, ETA: 201s'
sleep 0.05
echo '[ 1] Blk# 58400, [ratio/avg.  48%/ 40%], avg.speed: 42058988 b/s, ETA: 200s'
sleep 0.05
echo '[ 1] Blk# 58500, [ratio/avg.  29%/ 40%], avg.speed: 42131005 b/s, ETA: 200s'
sleep 0.05
echo '[ 1] Blk# 58600, [ratio/avg.  41%/ 40%], avg.speed: 42203023 b/s, ETA: 199s'
sleep 0.05
echo '[ 1] Blk# 58700, [ratio/avg.  39%/ 40%], avg.speed: 42044029 b/s, ETA: 200s'
sleep 0.05
echo '[ 1] Blk# 58800, [ratio/avg.  37%/ 40%], avg.speed: 42115653 b/s, ETA: 199s'
sleep 0.05
echo '[ 1] Blk# 58900, [ratio/avg.  34%/ 40%], avg.speed: 42187277 b/s, ETA: 198s'
sleep 0.05
echo '[ 1] Blk# 59000, [ratio/avg.  39%/ 40%], avg.speed: 42258902 b/s, ETA: 198s'
sleep 0.05
echo '[ 1] Blk# 59100, [ratio/avg.  45%/ 40%], avg.speed: 42100468 b/s, ETA: 198s'
sleep 0.05
echo '[ 1] Blk# 59200, [ratio/avg.  42%/ 40%], avg.speed: 42171703 b/s, ETA: 197s'
sleep 0.05
echo '[ 1] Blk# 59300, [ratio/avg.  45%/ 40%], avg.speed: 42242938 b/s, ETA: 197s'
sleep 0.05
echo '[ 1] Blk# 59400, [ratio/avg.  42%/ 40%], avg.speed: 42085447 b/s, ETA: 197s'
sleep 0.05
echo '[ 1] Blk# 59500, [ratio/avg.  48%/ 40%], avg.speed: 42156297 b/s, ETA: 197s'
sleep 0.05
echo '[ 1] Blk# 59600, [ratio/avg.  55%/ 40%], avg.speed: 42227147 b/s, ETA: 196s'
sleep 0.05
echo '[ 1] Blk# 59700, [ratio/avg.  49%/ 40%], avg.speed: 42297997 b/s, ETA: 195s'
sleep 0.05
echo '[ 1] Blk# 59800, [ratio/avg.  20%/ 40%], avg.speed: 42141057 b/s, ETA: 196s'
sleep 0.05
echo '[ 1] Blk# 59900, [ratio/avg.  37%/ 40%], avg.speed: 42211526 b/s, ETA: 195s'
sleep 0.05
echo '[ 1] Blk# 60000, [ratio/avg.  33%/ 40%], avg.speed: 42281995 b/s, ETA: 194s'
sleep 0.05
echo '[ 1] Blk# 60100, [ratio/avg.   5%/ 40%], avg.speed: 42352463 b/s, ETA: 194s'
sleep 0.05
echo '[ 1] Blk# 60200, [ratio/avg.  56%/ 40%], avg.speed: 42196072 b/s, ETA: 194s'
sleep 0.05
echo '[ 1] Blk# 60300, [ratio/avg.  29%/ 40%], avg.speed: 42266164 b/s, ETA: 194s'
sleep 0.05
echo '[ 1] Blk# 60400, [ratio/avg.  39%/ 40%], avg.speed: 42336256 b/s, ETA: 193s'
sleep 0.05
echo '[ 1] Blk# 60500, [ratio/avg.  37%/ 40%], avg.speed: 42406347 b/s, ETA: 192s'
sleep 0.05
echo '[ 1] Blk# 60600, [ratio/avg.  42%/ 40%], avg.speed: 42250501 b/s, ETA: 193s'
sleep 0.05
echo '[ 1] Blk# 60700, [ratio/avg.   9%/ 40%], avg.speed: 42320220 b/s, ETA: 192s'
sleep 0.05
echo '[ 1] Blk# 60800, [ratio/avg.  22%/ 40%], avg.speed: 42165654 b/s, ETA: 192s'
sleep 0.05
echo '[ 1] Blk# 60900, [ratio/avg.  45%/ 40%], avg.speed: 42235004 b/s, ETA: 192s'
sleep 0.05
echo '[ 1] Blk# 61000, [ratio/avg.  39%/ 40%], avg.speed: 42304354 b/s, ETA: 191s'
sleep 0.05
echo '[ 1] Blk# 61100, [ratio/avg.  37%/ 40%], avg.speed: 42373705 b/s, ETA: 191s'
sleep 0.05
echo '[ 1] Blk# 61200, [ratio/avg.  39%/ 40%], avg.speed: 42219670 b/s, ETA: 191s'
sleep 0.05
echo '[ 1] Blk# 61300, [ratio/avg.  41%/ 40%], avg.speed: 42288656 b/s, ETA: 190s'
sleep 0.05
echo '[ 1] Blk# 61400, [ratio/avg.  27%/ 40%], avg.speed: 42357641 b/s, ETA: 190s'
sleep 0.05
echo '[ 1] Blk# 61500, [ratio/avg.  35%/ 40%], avg.speed: 42426626 b/s, ETA: 189s'
sleep 0.05
echo '[ 1] Blk# 61600, [ratio/avg.  47%/ 40%], avg.speed: 42052949 b/s, ETA: 190s'
sleep 0.05
echo '[ 1] Blk# 61700, [ratio/avg.   9%/ 40%], avg.speed: 41902971 b/s, ETA: 191s'
sleep 0.05
echo '[ 1] Blk# 61800, [ratio/avg.  38%/ 40%], avg.speed: 41970884 b/s, ETA: 190s'
sleep 0.05
echo '[ 1] Blk# 61900, [ratio/avg.  15%/ 40%], avg.speed: 42038797 b/s, ETA: 190s'
sleep 0.05
echo '[ 1] Blk# 62000, [ratio/avg.  35%/ 40%], avg.speed: 42106710 b/s, ETA: 189s'
sleep 0.05
echo '[ 1] Blk# 62100, [ratio/avg.  29%/ 40%], avg.speed: 42174623 b/s, ETA: 188s'
sleep 0.05
echo '[ 1] Blk# 62200, [ratio/avg.  27%/ 40%], avg.speed: 42024791 b/s, ETA: 189s'
sleep 0.05
echo '[ 1] Blk# 62300, [ratio/avg.  31%/ 40%], avg.speed: 42092353 b/s, ETA: 188s'
sleep 0.05
echo '[ 1] Blk# 62400, [ratio/avg.  21%/ 40%], avg.speed: 42159916 b/s, ETA: 188s'
sleep 0.05
echo '[ 1] Blk# 62500, [ratio/avg.  23%/ 40%], avg.speed: 42227479 b/s, ETA: 187s'
sleep 0.05
echo '[ 1] Blk# 62600, [ratio/avg.  23%/ 40%], avg.speed: 42295042 b/s, ETA: 186s'
sleep 0.05
echo '[ 1] Blk# 62700, [ratio/avg.  30%/ 40%], avg.speed: 42145361 b/s, ETA: 187s'
sleep 0.05
echo '[ 1] Blk# 62800, [ratio/avg.  52%/ 40%], avg.speed: 42212577 b/s, ETA: 186s'
sleep 0.05
echo '[ 1] Blk# 62900, [ratio/avg.  45%/ 40%], avg.speed: 42279794 b/s, ETA: 185s'
sleep 0.05
echo '[ 1] Blk# 63000, [ratio/avg.  22%/ 40%], avg.speed: 42347010 b/s, ETA: 185s'
sleep 0.05
echo '[ 1] Blk# 63100, [ratio/avg.  16%/ 40%], avg.speed: 42197827 b/s, ETA: 185s'
sleep 0.05
echo '[ 1] Blk# 63200, [ratio/avg.  25%/ 40%], avg.speed: 42264701 b/s, ETA: 185s'
sleep 0.05
echo '[ 1] Blk# 63300, [ratio/avg.  51%/ 40%], avg.speed: 42331574 b/s, ETA: 184s'
sleep 0.05
echo '[ 1] Blk# 63400, [ratio/avg.   8%/ 40%], avg.speed: 42398448 b/s, ETA: 183s'
sleep 0.05
echo '[ 1] Blk# 63500, [ratio/avg.  49%/ 40%], avg.speed: 42465321 b/s, ETA: 183s'
sleep 0.05
echo '[ 1] Blk# 63600, [ratio/avg.  35%/ 40%], avg.speed: 42316295 b/s, ETA: 183s'
sleep 0.05
echo '[ 1] Blk# 63700, [ratio/avg.  27%/ 40%], avg.speed: 42382829 b/s, ETA: 183s'
sleep 0.05
echo '[ 1] Blk# 63800, [ratio/avg.  22%/ 40%], avg.speed: 42449363 b/s, ETA: 182s'
sleep 0.05
echo '[ 1] Blk# 63900, [ratio/avg.  13%/ 40%], avg.speed: 42515897 b/s, ETA: 181s'
sleep 0.05
echo '[ 1] Blk# 64000, [ratio/avg.  20%/ 40%], avg.speed: 42582431 b/s, ETA: 181s'
sleep 0.05
echo '[ 1] Blk# 64100, [ratio/avg.   7%/ 40%], avg.speed: 42433567 b/s, ETA: 181s'
sleep 0.05
echo '[ 1] Blk# 64200, [ratio/avg.  21%/ 40%], avg.speed: 42499765 b/s, ETA: 180s'
sleep 0.05
echo '[ 1] Blk# 64300, [ratio/avg.  18%/ 40%], avg.speed: 42565962 b/s, ETA: 180s'
sleep 0.05
echo '[ 1] Blk# 64400, [ratio/avg.   5%/ 40%], avg.speed: 42632160 b/s, ETA: 179s'
sleep 0.05
echo '[ 1] Blk# 64500, [ratio/avg.  38%/ 40%], avg.speed: 42698358 b/s, ETA: 179s'
sleep 0.05
echo '[ 1] Blk# 64600, [ratio/avg.  54%/ 40%], avg.speed: 42549659 b/s, ETA: 179s'
sleep 0.05
echo '[ 1] Blk# 64700, [ratio/avg.  50%/ 40%], avg.speed: 42615524 b/s, ETA: 178s'
sleep 0.05
echo '[ 1] Blk# 64800, [ratio/avg.  31%/ 40%], avg.speed: 42681390 b/s, ETA: 178s'
sleep 0.05
echo '[ 1] Blk# 64900, [ratio/avg.  40%/ 40%], avg.speed: 42533519 b/s, ETA: 178s'
sleep 0.05
echo '[ 1] Blk# 65000, [ratio/avg.  48%/ 40%], avg.speed: 42599055 b/s, ETA: 178s'
sleep 0.05
echo '[ 1] Blk# 65100, [ratio/avg.  72%/ 40%], avg.speed: 42664591 b/s, ETA: 177s'
sleep 0.05
echo '[ 1] Blk# 65200, [ratio/avg.  70%/ 40%], avg.speed: 42730127 b/s, ETA: 176s'
sleep 0.05
echo '[ 1] Blk# 65300, [ratio/avg.  43%/ 40%], avg.speed: 42582749 b/s, ETA: 177s'
sleep 0.05
echo '[ 1] Blk# 65400, [ratio/avg.  13%/ 40%], avg.speed: 42647959 b/s, ETA: 176s'
sleep 0.05
echo '[ 1] Blk# 65500, [ratio/avg.  72%/ 40%], avg.speed: 42501718 b/s, ETA: 176s'
sleep 0.05
echo '[ 1] Blk# 65600, [ratio/avg.   5%/ 40%], avg.speed: 42566605 b/s, ETA: 176s'
sleep 0.05
echo '[ 1] Blk# 65700, [ratio/avg.   0%/ 40%], avg.speed: 42631492 b/s, ETA: 175s'
sleep 0.05
echo '[ 1] Blk# 65800, [ratio/avg.   1%/ 40%], avg.speed: 42696379 b/s, ETA: 175s'
sleep 0.05
echo '[ 1] Blk# 65900, [ratio/avg.  45%/ 40%], avg.speed: 42761266 b/s, ETA: 174s'
sleep 0.05
echo '[ 1] Blk# 66000, [ratio/avg.  95%/ 40%], avg.speed: 42615187 b/s, ETA: 174s'
sleep 0.05
echo '[ 1] Blk# 66100, [ratio/avg.  97%/ 40%], avg.speed: 42679755 b/s, ETA: 174s'
sleep 0.05
echo '[ 1] Blk# 66200, [ratio/avg.  97%/ 40%], avg.speed: 42534791 b/s, ETA: 174s'
sleep 0.05
echo '[ 1] Blk# 66300, [ratio/avg.  97%/ 40%], avg.speed: 42185459 b/s, ETA: 175s'
sleep 0.05
echo '[ 1] Blk# 66400, [ratio/avg.  93%/ 40%], avg.speed: 42249086 b/s, ETA: 175s'
sleep 0.05
echo '[ 1] Blk# 66500, [ratio/avg.  96%/ 40%], avg.speed: 42312713 b/s, ETA: 174s'
sleep 0.05
echo '[ 1] Blk# 66600, [ratio/avg.   0%/ 40%], avg.speed: 42171624 b/s, ETA: 174s'
sleep 0.05
echo '[ 1] Blk# 66700, [ratio/avg.  15%/ 40%], avg.speed: 42234944 b/s, ETA: 174s'
sleep 0.05
echo '[ 1] Blk# 66800, [ratio/avg.  32%/ 40%], avg.speed: 42298264 b/s, ETA: 173s'
sleep 0.05
echo '[ 1] Blk# 66900, [ratio/avg.  93%/ 40%], avg.speed: 42157922 b/s, ETA: 174s'
sleep 0.05
echo '[ 1] Blk# 67000, [ratio/avg. 100%/ 41%], avg.speed: 42220937 b/s, ETA: 173s'
sleep 0.05
echo '[ 1] Blk# 67100, [ratio/avg.  40%/ 41%], avg.speed: 42283953 b/s, ETA: 172s'
sleep 0.05
echo '[ 1] Blk# 67200, [ratio/avg.  76%/ 41%], avg.speed: 42144351 b/s, ETA: 173s'
sleep 0.05
echo '[ 1] Blk# 67300, [ratio/avg.  88%/ 41%], avg.speed: 42207065 b/s, ETA: 172s'
sleep 0.05
echo '[ 1] Blk# 67400, [ratio/avg. 100%/ 41%], avg.speed: 42269779 b/s, ETA: 172s'
sleep 0.05
echo '[ 1] Blk# 67500, [ratio/avg.  98%/ 41%], avg.speed: 42130909 b/s, ETA: 172s'
sleep 0.05
echo '[ 1] Blk# 67600, [ratio/avg.  99%/ 41%], avg.speed: 42193325 b/s, ETA: 171s'
sleep 0.05
echo '[ 1] Blk# 67700, [ratio/avg.  12%/ 41%], avg.speed: 42255740 b/s, ETA: 171s'
sleep 0.05
echo '[ 1] Blk# 67800, [ratio/avg.  22%/ 41%], avg.speed: 42117595 b/s, ETA: 171s'
sleep 0.05
echo '[ 1] Blk# 67900, [ratio/avg.  54%/ 41%], avg.speed: 42179715 b/s, ETA: 170s'
sleep 0.05
echo '[ 1] Blk# 68000, [ratio/avg.  50%/ 41%], avg.speed: 42241834 b/s, ETA: 170s'
sleep 0.05
echo '[ 1] Blk# 68100, [ratio/avg.  25%/ 41%], avg.speed: 42303953 b/s, ETA: 169s'
sleep 0.05
echo '[ 1] Blk# 68200, [ratio/avg.  45%/ 41%], avg.speed: 42166233 b/s, ETA: 169s'
sleep 0.05
echo '[ 1] Blk# 68300, [ratio/avg.  32%/ 41%], avg.speed: 42228059 b/s, ETA: 169s'
sleep 0.05
echo '[ 1] Blk# 68400, [ratio/avg.  42%/ 41%], avg.speed: 42091342 b/s, ETA: 169s'
sleep 0.05
echo '[ 1] Blk# 68500, [ratio/avg.  38%/ 41%], avg.speed: 42152878 b/s, ETA: 169s'
sleep 0.05
echo '[ 1] Blk# 68600, [ratio/avg.  42%/ 41%], avg.speed: 42214414 b/s, ETA: 168s'
sleep 0.05
echo '[ 1] Blk# 68700, [ratio/avg.  44%/ 41%], avg.speed: 42078399 b/s, ETA: 168s'
sleep 0.05
echo '[ 1] Blk# 68800, [ratio/avg.  90%/ 41%], avg.speed: 42139648 b/s, ETA: 168s'
sleep 0.05
echo '[ 1] Blk# 68900, [ratio/avg.  31%/ 41%], avg.speed: 42200896 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 69000, [ratio/avg.  41%/ 41%], avg.speed: 42262145 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 69100, [ratio/avg.  40%/ 41%], avg.speed: 42126540 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 69200, [ratio/avg.  34%/ 41%], avg.speed: 41798679 b/s, ETA: 168s'
sleep 0.05
echo '[ 1] Blk# 69300, [ratio/avg.  35%/ 41%], avg.speed: 41859081 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 69400, [ratio/avg.  31%/ 41%], avg.speed: 41919483 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 69500, [ratio/avg.  40%/ 41%], avg.speed: 41787316 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 69600, [ratio/avg.  17%/ 41%], avg.speed: 41847441 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 69700, [ratio/avg.  96%/ 41%], avg.speed: 41907566 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 69800, [ratio/avg.  11%/ 41%], avg.speed: 41967691 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 69900, [ratio/avg.  38%/ 41%], avg.speed: 41835908 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 70000, [ratio/avg.  29%/ 41%], avg.speed: 41895758 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 70100, [ratio/avg.  73%/ 41%], avg.speed: 41955608 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 70200, [ratio/avg.  25%/ 41%], avg.speed: 42015458 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 70300, [ratio/avg.  23%/ 41%], avg.speed: 42075309 b/s, ETA: 163s'
sleep 0.05
echo '[ 1] Blk# 70400, [ratio/avg.  74%/ 41%], avg.speed: 41943635 b/s, ETA: 163s'
sleep 0.05
echo '[ 1] Blk# 70500, [ratio/avg.  88%/ 41%], avg.speed: 42003213 b/s, ETA: 163s'
sleep 0.05
echo '[ 1] Blk# 70600, [ratio/avg.  24%/ 41%], avg.speed: 42062792 b/s, ETA: 162s'
sleep 0.05
echo '[ 1] Blk# 70700, [ratio/avg.  40%/ 41%], avg.speed: 42122370 b/s, ETA: 162s'
sleep 0.05
echo '[ 1] Blk# 70800, [ratio/avg.  35%/ 41%], avg.speed: 41991079 b/s, ETA: 162s'
sleep 0.05
echo '[ 1] Blk# 70900, [ratio/avg.  34%/ 41%], avg.speed: 42050388 b/s, ETA: 162s'
sleep 0.05
echo '[ 1] Blk# 71000, [ratio/avg.  37%/ 41%], avg.speed: 42109697 b/s, ETA: 161s'
sleep 0.05
echo '[ 1] Blk# 71100, [ratio/avg.  16%/ 41%], avg.speed: 42169005 b/s, ETA: 160s'
sleep 0.05
echo '[ 1] Blk# 71200, [ratio/avg.  37%/ 41%], avg.speed: 42038096 b/s, ETA: 161s'
sleep 0.05
echo '[ 1] Blk# 71300, [ratio/avg.  32%/ 41%], avg.speed: 42097138 b/s, ETA: 160s'
sleep 0.05
echo '[ 1] Blk# 71400, [ratio/avg.  35%/ 41%], avg.speed: 42156179 b/s, ETA: 160s'
sleep 0.05
echo '[ 1] Blk# 71500, [ratio/avg.   9%/ 41%], avg.speed: 42215221 b/s, ETA: 159s'
sleep 0.05
echo '[ 1] Blk# 71600, [ratio/avg.  22%/ 41%], avg.speed: 42274262 b/s, ETA: 158s'
sleep 0.05
echo '[ 1] Blk# 71700, [ratio/avg.  37%/ 41%], avg.speed: 42143468 b/s, ETA: 159s'
sleep 0.05
echo '[ 1] Blk# 71800, [ratio/avg.  35%/ 41%], avg.speed: 42202245 b/s, ETA: 158s'
sleep 0.05
echo '[ 1] Blk# 71900, [ratio/avg.  81%/ 41%], avg.speed: 42261021 b/s, ETA: 158s'
sleep 0.05
echo '[ 1] Blk# 72000, [ratio/avg.  87%/ 41%], avg.speed: 42319798 b/s, ETA: 157s'
sleep 0.05
echo '[ 1] Blk# 72100, [ratio/avg.  99%/ 41%], avg.speed: 42001876 b/s, ETA: 158s'
sleep 0.05
echo '[ 1] Blk# 72200, [ratio/avg.  68%/ 41%], avg.speed: 41689557 b/s, ETA: 159s'
sleep 0.05
echo '[ 1] Blk# 72300, [ratio/avg.  88%/ 41%], avg.speed: 41382692 b/s, ETA: 160s'
sleep 0.05
echo '[ 1] Blk# 72400, [ratio/avg.  77%/ 41%], avg.speed: 41081142 b/s, ETA: 161s'
sleep 0.05
echo '[ 1] Blk# 72500, [ratio/avg.  98%/ 41%], avg.speed: 40784768 b/s, ETA: 161s'
sleep 0.05
echo '[ 1] Blk# 72600, [ratio/avg.  91%/ 41%], avg.speed: 40666488 b/s, ETA: 162s'
sleep 0.05
echo '[ 1] Blk# 72700, [ratio/avg.  85%/ 41%], avg.speed: 40377396 b/s, ETA: 162s'
sleep 0.05
echo '[ 1] Blk# 72800, [ratio/avg.  85%/ 41%], avg.speed: 40262331 b/s, ETA: 163s'
sleep 0.05
echo '[ 1] Blk# 72900, [ratio/avg.  96%/ 41%], avg.speed: 39980250 b/s, ETA: 163s'
sleep 0.05
echo '[ 1] Blk# 73000, [ratio/avg.  43%/ 41%], avg.speed: 39868279 b/s, ETA: 163s'
sleep 0.05
echo '[ 1] Blk# 73100, [ratio/avg.  19%/ 41%], avg.speed: 39757237 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 73200, [ratio/avg.  16%/ 41%], avg.speed: 39811624 b/s, ETA: 163s'
sleep 0.05
echo '[ 1] Blk# 73300, [ratio/avg.  46%/ 41%], avg.speed: 39537895 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 73400, [ratio/avg.  61%/ 41%], avg.speed: 39429573 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 73500, [ratio/avg.  20%/ 41%], avg.speed: 39162288 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 73600, [ratio/avg.  11%/ 41%], avg.speed: 39215570 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 73700, [ratio/avg.  23%/ 41%], avg.speed: 39109868 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 73800, [ratio/avg.   7%/ 41%], avg.speed: 39162933 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 73900, [ratio/avg.   4%/ 41%], avg.speed: 39215999 b/s, ETA: 163s'
sleep 0.05
echo '[ 1] Blk# 74000, [ratio/avg.   9%/ 41%], avg.speed: 39110722 b/s, ETA: 163s'
sleep 0.05
echo '[ 1] Blk# 74100, [ratio/avg.  90%/ 41%], avg.speed: 39163573 b/s, ETA: 163s'
sleep 0.05
echo '[ 1] Blk# 74200, [ratio/avg. 100%/ 41%], avg.speed: 38902693 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 74300, [ratio/avg.  50%/ 41%], avg.speed: 38645955 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 74400, [ratio/avg.  54%/ 41%], avg.speed: 38545011 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 74500, [ratio/avg.  92%/ 41%], avg.speed: 38444862 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 74600, [ratio/avg.   3%/ 41%], avg.speed: 38345499 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 74700, [ratio/avg.  23%/ 41%], avg.speed: 38098091 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 74800, [ratio/avg.  86%/ 41%], avg.speed: 38001227 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 74900, [ratio/avg.  85%/ 41%], avg.speed: 37905111 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 75000, [ratio/avg.  15%/ 41%], avg.speed: 37809734 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 75100, [ratio/avg.  10%/ 41%], avg.speed: 37860147 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 75200, [ratio/avg.  25%/ 41%], avg.speed: 37765308 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 75300, [ratio/avg.  97%/ 41%], avg.speed: 37671193 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 75400, [ratio/avg.  41%/ 41%], avg.speed: 37435454 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 75500, [ratio/avg.  38%/ 41%], avg.speed: 37343649 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 75600, [ratio/avg.  91%/ 41%], avg.speed: 37252534 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 75700, [ratio/avg.  37%/ 41%], avg.speed: 37162102 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 75800, [ratio/avg.  37%/ 41%], avg.speed: 36934530 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 75900, [ratio/avg.  48%/ 41%], avg.speed: 36846281 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 76000, [ratio/avg.  19%/ 41%], avg.speed: 36758682 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 76100, [ratio/avg.   4%/ 41%], avg.speed: 36807048 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 76200, [ratio/avg.  24%/ 41%], avg.speed: 36719917 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 76300, [ratio/avg.  19%/ 41%], avg.speed: 36499725 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 76400, [ratio/avg.   8%/ 41%], avg.speed: 36414661 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 76500, [ratio/avg.  15%/ 41%], avg.speed: 36462323 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 76600, [ratio/avg.  19%/ 41%], avg.speed: 36377703 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 76700, [ratio/avg.  34%/ 41%], avg.speed: 36293694 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 76800, [ratio/avg.  41%/ 41%], avg.speed: 36210290 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 76900, [ratio/avg.  35%/ 41%], avg.speed: 36127483 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 77000, [ratio/avg.  23%/ 41%], avg.speed: 35916993 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 77100, [ratio/avg.  99%/ 41%], avg.speed: 35836107 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 77200, [ratio/avg. 100%/ 41%], avg.speed: 35629892 b/s, ETA: 168s'
sleep 0.05
echo '[ 1] Blk# 77300, [ratio/avg.  53%/ 41%], avg.speed: 35426561 b/s, ETA: 168s'
sleep 0.05
echo '[ 1] Blk# 77400, [ratio/avg. 100%/ 41%], avg.speed: 35226055 b/s, ETA: 169s'
sleep 0.05
echo '[ 1] Blk# 77500, [ratio/avg.  98%/ 41%], avg.speed: 35028314 b/s, ETA: 169s'
sleep 0.05
echo '[ 1] Blk# 77600, [ratio/avg.  98%/ 42%], avg.speed: 34833281 b/s, ETA: 170s'
sleep 0.05
echo '[ 1] Blk# 77700, [ratio/avg.  32%/ 42%], avg.speed: 34759131 b/s, ETA: 170s'
sleep 0.05
echo '[ 1] Blk# 77800, [ratio/avg.  77%/ 42%], avg.speed: 34567907 b/s, ETA: 170s'
sleep 0.05
echo '[ 1] Blk# 77900, [ratio/avg.  94%/ 42%], avg.speed: 34379258 b/s, ETA: 171s'
sleep 0.05
echo '[ 1] Blk# 78000, [ratio/avg.  89%/ 42%], avg.speed: 34307876 b/s, ETA: 171s'
sleep 0.05
echo '[ 1] Blk# 78100, [ratio/avg.  85%/ 42%], avg.speed: 34122847 b/s, ETA: 172s'
sleep 0.05
echo '[ 1] Blk# 78200, [ratio/avg.  94%/ 42%], avg.speed: 34053028 b/s, ETA: 171s'
sleep 0.05
echo '[ 1] Blk# 78300, [ratio/avg.  99%/ 42%], avg.speed: 33871513 b/s, ETA: 172s'
sleep 0.05
echo '[ 1] Blk# 78400, [ratio/avg.  98%/ 42%], avg.speed: 33692379 b/s, ETA: 173s'
sleep 0.05
echo '[ 1] Blk# 78500, [ratio/avg.   4%/ 42%], avg.speed: 33735354 b/s, ETA: 172s'
sleep 0.05
echo '[ 1] Blk# 78600, [ratio/avg.  97%/ 42%], avg.speed: 33667942 b/s, ETA: 172s'
sleep 0.05
echo '[ 1] Blk# 78700, [ratio/avg.  99%/ 42%], avg.speed: 33600968 b/s, ETA: 172s'
sleep 0.05
echo '[ 1] Blk# 78800, [ratio/avg.  58%/ 42%], avg.speed: 33425905 b/s, ETA: 172s'
sleep 0.05
echo '[ 1] Blk# 78900, [ratio/avg.  25%/ 42%], avg.speed: 33253092 b/s, ETA: 173s'
sleep 0.05
echo '[ 1] Blk# 79000, [ratio/avg.  11%/ 42%], avg.speed: 33188522 b/s, ETA: 173s'
sleep 0.05
echo '[ 1] Blk# 79100, [ratio/avg.  20%/ 42%], avg.speed: 33124365 b/s, ETA: 173s'
sleep 0.05
echo '[ 1] Blk# 79200, [ratio/avg.  17%/ 42%], avg.speed: 33060616 b/s, ETA: 173s'
sleep 0.05
echo '[ 1] Blk# 79300, [ratio/avg.   0%/ 42%], avg.speed: 33102358 b/s, ETA: 172s'
sleep 0.05
echo '[ 1] Blk# 79400, [ratio/avg.   0%/ 42%], avg.speed: 33144101 b/s, ETA: 171s'
sleep 0.05
echo '[ 1] Blk# 79500, [ratio/avg.   0%/ 42%], avg.speed: 33080492 b/s, ETA: 171s'
sleep 0.05
echo '[ 1] Blk# 79600, [ratio/avg.   0%/ 42%], avg.speed: 33122102 b/s, ETA: 171s'
sleep 0.05
echo '[ 1] Blk# 79700, [ratio/avg.   0%/ 42%], avg.speed: 33163712 b/s, ETA: 170s'
sleep 0.05
echo '[ 1] Blk# 79800, [ratio/avg.   0%/ 42%], avg.speed: 33205322 b/s, ETA: 170s'
sleep 0.05
echo '[ 1] Blk# 79900, [ratio/avg.   0%/ 42%], avg.speed: 33141721 b/s, ETA: 169s'
sleep 0.05
echo '[ 1] Blk# 80000, [ratio/avg.   0%/ 41%], avg.speed: 33183199 b/s, ETA: 169s'
sleep 0.05
echo '[ 1] Blk# 80100, [ratio/avg.   0%/ 41%], avg.speed: 33224678 b/s, ETA: 168s'
sleep 0.05
echo '[ 1] Blk# 80200, [ratio/avg.   0%/ 41%], avg.speed: 33266156 b/s, ETA: 168s'
sleep 0.05
echo '[ 1] Blk# 80300, [ratio/avg.   0%/ 41%], avg.speed: 33202563 b/s, ETA: 168s'
sleep 0.05
echo '[ 1] Blk# 80400, [ratio/avg.   0%/ 41%], avg.speed: 33243911 b/s, ETA: 167s'
sleep 0.05
echo '[ 1] Blk# 80500, [ratio/avg.   0%/ 41%], avg.speed: 33285258 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 80600, [ratio/avg.   0%/ 41%], avg.speed: 33221805 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 80700, [ratio/avg.   0%/ 41%], avg.speed: 33263023 b/s, ETA: 166s'
sleep 0.05
echo '[ 1] Blk# 80800, [ratio/avg.   0%/ 41%], avg.speed: 33304241 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 80900, [ratio/avg.   0%/ 41%], avg.speed: 33345458 b/s, ETA: 165s'
sleep 0.05
echo '[ 1] Blk# 81000, [ratio/avg.   0%/ 41%], avg.speed: 33282015 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 81100, [ratio/avg.   0%/ 41%], avg.speed: 33323104 b/s, ETA: 164s'
sleep 0.05
echo '[ 1] Blk# 81200, [ratio/avg.   0%/ 41%], avg.speed: 33364192 b/s, ETA: 163s'
sleep 0.05
echo '[ 1] Blk# 81300, [ratio/avg.   0%/ 41%], avg.speed: 33405281 b/s, ETA: 163s'
sleep 0.05
echo '[ 1] Blk# 81400, [ratio/avg.   0%/ 41%], avg.speed: 33341849 b/s, ETA: 163s'
sleep 0.05
echo '[ 1] Blk# 81500, [ratio/avg.   0%/ 41%], avg.speed: 33382809 b/s, ETA: 162s'
sleep 0.05
echo '[ 1] Blk# 81600, [ratio/avg.   0%/ 41%], avg.speed: 33423769 b/s, ETA: 161s'
sleep 0.05
echo '[ 1] Blk# 81700, [ratio/avg.   0%/ 41%], avg.speed: 33464729 b/s, ETA: 161s'
sleep 0.05
echo '[ 1] Blk# 81800, [ratio/avg.   0%/ 41%], avg.speed: 33401310 b/s, ETA: 161s'
sleep 0.05
echo '[ 1] Blk# 81900, [ratio/avg.   0%/ 41%], avg.speed: 33442142 b/s, ETA: 160s'
sleep 0.05
echo '[ 1] Blk# 82000, [ratio/avg.   4%/ 40%], avg.speed: 33482975 b/s, ETA: 160s'
sleep 0.05
echo '[ 1] Blk# 82100, [ratio/avg.   0%/ 40%], avg.speed: 33523807 b/s, ETA: 159s'
sleep 0.05
echo '[ 1] Blk# 82200, [ratio/avg.   2%/ 40%], avg.speed: 33460402 b/s, ETA: 159s'
sleep 0.05
echo '[ 1] Blk# 82300, [ratio/avg.   1%/ 40%], avg.speed: 33501107 b/s, ETA: 158s'
sleep 0.05
echo '[ 1] Blk# 82400, [ratio/avg.   0%/ 40%], avg.speed: 33541813 b/s, ETA: 158s'
sleep 0.05
echo '[ 1] Blk# 82500, [ratio/avg.   0%/ 40%], avg.speed: 33478548 b/s, ETA: 158s'
sleep 0.05
echo '[ 1] Blk# 82600, [ratio/avg.   0%/ 40%], avg.speed: 33519127 b/s, ETA: 157s'
sleep 0.05
echo '[ 1] Blk# 82700, [ratio/avg.   0%/ 40%], avg.speed: 33559707 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 82800, [ratio/avg.   0%/ 40%], avg.speed: 33496582 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 82900, [ratio/avg.   0%/ 40%], avg.speed: 33537036 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 83000, [ratio/avg.  48%/ 40%], avg.speed: 33474175 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 83100, [ratio/avg.  72%/ 40%], avg.speed: 33411700 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 83200, [ratio/avg.  76%/ 40%], avg.speed: 33349606 b/s, ETA: 155s'
sleep 0.05
echo '[ 1] Blk# 83300, [ratio/avg.  35%/ 40%], avg.speed: 33186713 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 83400, [ratio/avg.  74%/ 40%], avg.speed: 33025788 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 83500, [ratio/avg.  33%/ 40%], avg.speed: 32965792 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 83600, [ratio/avg.  57%/ 40%], avg.speed: 32906156 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 83700, [ratio/avg.  75%/ 40%], avg.speed: 32748828 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 83800, [ratio/avg.  25%/ 40%], avg.speed: 32690371 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 83900, [ratio/avg.  35%/ 40%], avg.speed: 32632260 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 84000, [ratio/avg.  33%/ 40%], avg.speed: 32574494 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 84100, [ratio/avg.  42%/ 40%], avg.speed: 32517068 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 84200, [ratio/avg.  35%/ 40%], avg.speed: 32459980 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 84300, [ratio/avg.  44%/ 40%], avg.speed: 32308481 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 84400, [ratio/avg.  32%/ 40%], avg.speed: 32158743 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 84500, [ratio/avg.  49%/ 40%], avg.speed: 32103521 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 84600, [ratio/avg.  39%/ 40%], avg.speed: 32048619 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 84700, [ratio/avg.  70%/ 40%], avg.speed: 31994033 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 84800, [ratio/avg.  56%/ 40%], avg.speed: 31848242 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 84900, [ratio/avg.  28%/ 40%], avg.speed: 31794696 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 85000, [ratio/avg.  89%/ 40%], avg.speed: 31741456 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 85100, [ratio/avg.   5%/ 40%], avg.speed: 31688517 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 85200, [ratio/avg.  95%/ 40%], avg.speed: 31635879 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 85300, [ratio/avg.  39%/ 40%], avg.speed: 31494570 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 85400, [ratio/avg.  93%/ 40%], avg.speed: 31442920 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 85500, [ratio/avg.  33%/ 40%], avg.speed: 31391560 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 85600, [ratio/avg.  91%/ 40%], avg.speed: 31253187 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 85700, [ratio/avg.  34%/ 40%], avg.speed: 31202781 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 85800, [ratio/avg.  34%/ 40%], avg.speed: 31152655 b/s, ETA: 156s'
sleep 0.05
echo '[ 1] Blk# 85900, [ratio/avg.  22%/ 40%], avg.speed: 31102806 b/s, ETA: 155s'
sleep 0.05
echo '[ 1] Blk# 86000, [ratio/avg.  30%/ 40%], avg.speed: 31053231 b/s, ETA: 155s'
sleep 0.05
echo '[ 1] Blk# 86100, [ratio/avg.  35%/ 40%], avg.speed: 31003929 b/s, ETA: 155s'
sleep 0.05
echo '[ 1] Blk# 86200, [ratio/avg.  36%/ 40%], avg.speed: 30954897 b/s, ETA: 155s'
sleep 0.05
echo '[ 1] Blk# 86300, [ratio/avg.  92%/ 40%], avg.speed: 30906132 b/s, ETA: 155s'
sleep 0.05
echo '[ 1] Blk# 86400, [ratio/avg.  98%/ 40%], avg.speed: 30773782 b/s, ETA: 155s'
sleep 0.05
echo '[ 1] Blk# 86500, [ratio/avg.  52%/ 40%], avg.speed: 30642862 b/s, ETA: 155s'
sleep 0.05
echo '[ 1] Blk# 86600, [ratio/avg.  25%/ 40%], avg.speed: 30595596 b/s, ETA: 155s'
sleep 0.05
echo '[ 1] Blk# 86700, [ratio/avg.  24%/ 40%], avg.speed: 30466684 b/s, ETA: 155s'
sleep 0.05
echo '[ 1] Blk# 86800, [ratio/avg.  99%/ 40%], avg.speed: 30501824 b/s, ETA: 155s'
sleep 0.05
echo '[ 1] Blk# 86900, [ratio/avg.  25%/ 40%], avg.speed: 30536964 b/s, ETA: 154s'
sleep 0.05
echo '[ 1] Blk# 87000, [ratio/avg.  23%/ 40%], avg.speed: 30572104 b/s, ETA: 153s'
sleep 0.05
echo '[ 1] Blk# 87100, [ratio/avg.  31%/ 40%], avg.speed: 30525407 b/s, ETA: 153s'
sleep 0.05
echo '[ 1] Blk# 87200, [ratio/avg.  84%/ 40%], avg.speed: 30560453 b/s, ETA: 153s'
sleep 0.05
echo '[ 1] Blk# 87300, [ratio/avg.  10%/ 40%], avg.speed: 30513911 b/s, ETA: 152s'
sleep 0.05
echo '[ 1] Blk# 87400, [ratio/avg.  12%/ 40%], avg.speed: 30467616 b/s, ETA: 152s'
sleep 0.05
echo '[ 1] Blk# 87500, [ratio/avg.  55%/ 40%], avg.speed: 30502476 b/s, ETA: 152s'
sleep 0.05
echo '[ 1] Blk# 87600, [ratio/avg.  32%/ 40%], avg.speed: 30456334 b/s, ETA: 151s'
sleep 0.05
echo '[ 1] Blk# 87700, [ratio/avg.  26%/ 40%], avg.speed: 30410437 b/s, ETA: 151s'
sleep 0.05
echo '[ 1] Blk# 87800, [ratio/avg.  72%/ 40%], avg.speed: 30284875 b/s, ETA: 151s'
sleep 0.05
echo '[ 1] Blk# 87900, [ratio/avg.  17%/ 40%], avg.speed: 30319368 b/s, ETA: 151s'
sleep 0.05
echo '[ 1] Blk# 88000, [ratio/avg.  99%/ 40%], avg.speed: 30194939 b/s, ETA: 151s'
sleep 0.05
echo '[ 1] Blk# 88100, [ratio/avg.  25%/ 40%], avg.speed: 30229252 b/s, ETA: 150s'
sleep 0.05
echo '[ 1] Blk# 88200, [ratio/avg.  87%/ 40%], avg.speed: 30184546 b/s, ETA: 150s'
sleep 0.05
echo '[ 1] Blk# 88300, [ratio/avg.  26%/ 40%], avg.speed: 30140074 b/s, ETA: 150s'
sleep 0.05
echo '[ 1] Blk# 88400, [ratio/avg.  67%/ 40%], avg.speed: 30095833 b/s, ETA: 150s'
sleep 0.05
echo '[ 1] Blk# 88500, [ratio/avg.  33%/ 40%], avg.speed: 30051821 b/s, ETA: 149s'
sleep 0.05
echo '[ 1] Blk# 88600, [ratio/avg.  18%/ 40%], avg.speed: 30008036 b/s, ETA: 149s'
sleep 0.05
echo '[ 1] Blk# 88700, [ratio/avg.  81%/ 40%], avg.speed: 29964478 b/s, ETA: 149s'
sleep 0.05
echo '[ 1] Blk# 88800, [ratio/avg.  69%/ 40%], avg.speed: 29921143 b/s, ETA: 149s'
sleep 0.05
echo '[ 1] Blk# 88900, [ratio/avg.   3%/ 40%], avg.speed: 29878030 b/s, ETA: 149s'
sleep 0.05
echo '[ 1] Blk# 89000, [ratio/avg.  78%/ 40%], avg.speed: 29835138 b/s, ETA: 148s'
sleep 0.05
echo '[ 1] Blk# 89100, [ratio/avg.  31%/ 40%], avg.speed: 29792464 b/s, ETA: 148s'
sleep 0.05
echo '[ 1] Blk# 89200, [ratio/avg.  98%/ 40%], avg.speed: 29750008 b/s, ETA: 148s'
sleep 0.05
echo '[ 1] Blk# 89300, [ratio/avg.  18%/ 40%], avg.speed: 29707768 b/s, ETA: 148s'
sleep 0.05
echo '[ 1] Blk# 89400, [ratio/avg.  53%/ 40%], avg.speed: 29590827 b/s, ETA: 148s'
sleep 0.05
echo '[ 1] Blk# 89500, [ratio/avg.  12%/ 40%], avg.speed: 29549307 b/s, ETA: 148s'
sleep 0.05
echo '[ 1] Blk# 89600, [ratio/avg. 100%/ 40%], avg.speed: 29507995 b/s, ETA: 147s'
sleep 0.05
echo '[ 1] Blk# 89700, [ratio/avg.   8%/ 40%], avg.speed: 29466890 b/s, ETA: 147s'
sleep 0.05
echo '[ 1] Blk# 89800, [ratio/avg.  80%/ 40%], avg.speed: 29425991 b/s, ETA: 147s'
sleep 0.05
echo '[ 1] Blk# 89900, [ratio/avg.  22%/ 40%], avg.speed: 29385296 b/s, ETA: 147s'
sleep 0.05
echo '[ 1] Blk# 90000, [ratio/avg.   9%/ 40%], avg.speed: 29199532 b/s, ETA: 147s'
sleep 0.05
echo '[ 1] Blk# 90100, [ratio/avg.   0%/ 40%], avg.speed: 29231975 b/s, ETA: 146s'
sleep 0.05
echo '[ 1] Blk# 90200, [ratio/avg.  11%/ 40%], avg.speed: 29264419 b/s, ETA: 146s'
sleep 0.05
echo '[ 1] Blk# 90300, [ratio/avg.  17%/ 40%], avg.speed: 29224525 b/s, ETA: 146s'
sleep 0.05
echo '[ 1] Blk# 90400, [ratio/avg.   0%/ 40%], avg.speed: 29256888 b/s, ETA: 145s'
sleep 0.05
echo '[ 1] Blk# 90500, [ratio/avg.   0%/ 40%], avg.speed: 29217111 b/s, ETA: 145s'
sleep 0.05
echo '[ 1] Blk# 90600, [ratio/avg.   0%/ 40%], avg.speed: 29249394 b/s, ETA: 144s'
sleep 0.05
echo '[ 1] Blk# 90700, [ratio/avg.  28%/ 40%], avg.speed: 29209733 b/s, ETA: 144s'
sleep 0.05
echo '[ 1] Blk# 90800, [ratio/avg.   4%/ 40%], avg.speed: 29241937 b/s, ETA: 143s'
sleep 0.05
echo '[ 1] Blk# 90900, [ratio/avg.   0%/ 40%], avg.speed: 29202391 b/s, ETA: 143s'
sleep 0.05
echo '[ 1] Blk# 91000, [ratio/avg.   0%/ 40%], avg.speed: 29234517 b/s, ETA: 142s'
sleep 0.05
echo '[ 1] Blk# 91100, [ratio/avg.   0%/ 40%], avg.speed: 29266642 b/s, ETA: 142s'
sleep 0.05
echo '[ 1] Blk# 91200, [ratio/avg.   0%/ 40%], avg.speed: 29298768 b/s, ETA: 141s'
sleep 0.05
echo '[ 1] Blk# 91300, [ratio/avg.   0%/ 40%], avg.speed: 29259180 b/s, ETA: 141s'
sleep 0.05
echo '[ 1] Blk# 91400, [ratio/avg.   0%/ 40%], avg.speed: 29291227 b/s, ETA: 140s'
sleep 0.05
echo '[ 1] Blk# 91500, [ratio/avg.   0%/ 40%], avg.speed: 29323274 b/s, ETA: 140s'
sleep 0.05
echo '[ 1] Blk# 91600, [ratio/avg.   0%/ 40%], avg.speed: 29355320 b/s, ETA: 139s'
sleep 0.05
echo '[ 1] Blk# 91700, [ratio/avg.   0%/ 40%], avg.speed: 29315691 b/s, ETA: 139s'
sleep 0.05
echo '[ 1] Blk# 91800, [ratio/avg.   0%/ 40%], avg.speed: 29347660 b/s, ETA: 138s'
sleep 0.05
echo '[ 1] Blk# 91900, [ratio/avg.   0%/ 40%], avg.speed: 29379628 b/s, ETA: 138s'
sleep 0.05
echo '[ 1] Blk# 92000, [ratio/avg.   0%/ 40%], avg.speed: 29411597 b/s, ETA: 137s'
sleep 0.05
echo '[ 1] Blk# 92100, [ratio/avg.   0%/ 40%], avg.speed: 29371927 b/s, ETA: 137s'
sleep 0.05
echo '[ 1] Blk# 92200, [ratio/avg.   0%/ 39%], avg.speed: 29403818 b/s, ETA: 136s'
sleep 0.05
echo '[ 1] Blk# 92300, [ratio/avg.   0%/ 39%], avg.speed: 29435709 b/s, ETA: 136s'
sleep 0.05
echo '[ 1] Blk# 92400, [ratio/avg.   0%/ 39%], avg.speed: 29467600 b/s, ETA: 135s'
sleep 0.05
echo '[ 1] Blk# 92500, [ratio/avg.   0%/ 39%], avg.speed: 29427890 b/s, ETA: 135s'
sleep 0.05
echo '[ 1] Blk# 92600, [ratio/avg.   0%/ 39%], avg.speed: 29459704 b/s, ETA: 134s'
sleep 0.05
echo '[ 1] Blk# 92700, [ratio/avg.   0%/ 39%], avg.speed: 29491518 b/s, ETA: 134s'
sleep 0.05
echo '[ 1] Blk# 92800, [ratio/avg.   0%/ 39%], avg.speed: 29523331 b/s, ETA: 133s'
sleep 0.05
echo '[ 1] Blk# 92900, [ratio/avg.   0%/ 39%], avg.speed: 29483583 b/s, ETA: 133s'
sleep 0.05
echo '[ 1] Blk# 93000, [ratio/avg.   0%/ 39%], avg.speed: 29515319 b/s, ETA: 132s'
sleep 0.05
echo '[ 1] Blk# 93100, [ratio/avg.   0%/ 39%], avg.speed: 29547056 b/s, ETA: 132s'
sleep 0.05
echo '[ 1] Blk# 93200, [ratio/avg.   0%/ 39%], avg.speed: 29507346 b/s, ETA: 131s'
sleep 0.05
echo '[ 1] Blk# 93300, [ratio/avg.   0%/ 39%], avg.speed: 29539006 b/s, ETA: 131s'
sleep 0.05
echo '[ 1] Blk# 93400, [ratio/avg.   0%/ 39%], avg.speed: 29570666 b/s, ETA: 130s'
sleep 0.05
echo '[ 1] Blk# 93500, [ratio/avg.   0%/ 39%], avg.speed: 29602326 b/s, ETA: 130s'
sleep 0.05
echo '[ 1] Blk# 93600, [ratio/avg.   0%/ 39%], avg.speed: 29562578 b/s, ETA: 129s'
sleep 0.05
echo '[ 1] Blk# 93700, [ratio/avg.   0%/ 39%], avg.speed: 29594162 b/s, ETA: 129s'
sleep 0.05
echo '[ 1] Blk# 93800, [ratio/avg.   0%/ 39%], avg.speed: 29625746 b/s, ETA: 128s'
sleep 0.05
echo '[ 1] Blk# 93900, [ratio/avg.   0%/ 39%], avg.speed: 29657329 b/s, ETA: 128s'
sleep 0.05
echo '[ 1] Blk# 94000, [ratio/avg.   0%/ 39%], avg.speed: 29617545 b/s, ETA: 127s'
sleep 0.05
echo '[ 1] Blk# 94100, [ratio/avg.   0%/ 39%], avg.speed: 29649053 b/s, ETA: 127s'
sleep 0.05
echo '[ 1] Blk# 94200, [ratio/avg.   0%/ 39%], avg.speed: 29680561 b/s, ETA: 126s'
sleep 0.05
echo '[ 1] Blk# 94300, [ratio/avg.   0%/ 39%], avg.speed: 29712068 b/s, ETA: 126s'
sleep 0.05
echo '[ 1] Blk# 94400, [ratio/avg.   0%/ 39%], avg.speed: 29672249 b/s, ETA: 125s'
sleep 0.05
echo '[ 1] Blk# 94500, [ratio/avg.   0%/ 39%], avg.speed: 29703681 b/s, ETA: 125s'
sleep 0.05
echo '[ 1] Blk# 94600, [ratio/avg.   0%/ 38%], avg.speed: 29735113 b/s, ETA: 124s'
sleep 0.05
echo '[ 1] Blk# 94700, [ratio/avg.   0%/ 38%], avg.speed: 29766545 b/s, ETA: 124s'
sleep 0.05
echo '[ 1] Blk# 94800, [ratio/avg.   0%/ 38%], avg.speed: 29726690 b/s, ETA: 123s'
sleep 0.05
echo '[ 1] Blk# 94900, [ratio/avg.   0%/ 38%], avg.speed: 29758047 b/s, ETA: 123s'
sleep 0.05
echo '[ 1] Blk# 95000, [ratio/avg.   0%/ 38%], avg.speed: 29789404 b/s, ETA: 122s'
sleep 0.05
echo '[ 1] Blk# 95100, [ratio/avg.   0%/ 38%], avg.speed: 29820761 b/s, ETA: 122s'
sleep 0.05
echo '[ 1] Blk# 95200, [ratio/avg.   0%/ 38%], avg.speed: 29780872 b/s, ETA: 121s'
sleep 0.05
echo '[ 1] Blk# 95300, [ratio/avg.   0%/ 38%], avg.speed: 29812154 b/s, ETA: 121s'
sleep 0.05
echo '[ 1] Blk# 95400, [ratio/avg.   0%/ 38%], avg.speed: 29843436 b/s, ETA: 120s'
sleep 0.05
echo '[ 1] Blk# 95500, [ratio/avg.   0%/ 38%], avg.speed: 29803588 b/s, ETA: 120s'
sleep 0.05
echo '[ 1] Blk# 95600, [ratio/avg.   0%/ 38%], avg.speed: 29834795 b/s, ETA: 119s'
sleep 0.05
echo '[ 1] Blk# 95700, [ratio/avg.   0%/ 38%], avg.speed: 29866003 b/s, ETA: 119s'
sleep 0.05
echo '[ 1] Blk# 95800, [ratio/avg.   0%/ 38%], avg.speed: 29897211 b/s, ETA: 118s'
sleep 0.05
echo '[ 1] Blk# 95900, [ratio/avg.   0%/ 38%], avg.speed: 29857329 b/s, ETA: 118s'
sleep 0.05
echo '[ 1] Blk# 96000, [ratio/avg.   0%/ 38%], avg.speed: 29888463 b/s, ETA: 117s'
sleep 0.05
echo '[ 1] Blk# 96100, [ratio/avg.   0%/ 38%], avg.speed: 29919596 b/s, ETA: 117s'
sleep 0.05
echo '[ 1] Blk# 96200, [ratio/avg.   0%/ 38%], avg.speed: 29950730 b/s, ETA: 116s'
sleep 0.05
echo '[ 1] Blk# 96300, [ratio/avg.   0%/ 38%], avg.speed: 29910816 b/s, ETA: 116s'
sleep 0.05
echo '[ 1] Blk# 96400, [ratio/avg.   0%/ 38%], avg.speed: 29941876 b/s, ETA: 115s'
sleep 0.05
echo '[ 1] Blk# 96500, [ratio/avg.   0%/ 38%], avg.speed: 29972936 b/s, ETA: 115s'
sleep 0.05
echo '[ 1] Blk# 96600, [ratio/avg.   0%/ 38%], avg.speed: 30003995 b/s, ETA: 114s'
sleep 0.05
echo '[ 1] Blk# 96700, [ratio/avg.   0%/ 38%], avg.speed: 29964050 b/s, ETA: 114s'
sleep 0.05
echo '[ 1] Blk# 96800, [ratio/avg.   0%/ 38%], avg.speed: 29995037 b/s, ETA: 113s'
sleep 0.05
echo '[ 1] Blk# 96900, [ratio/avg.   0%/ 38%], avg.speed: 30026023 b/s, ETA: 113s'
sleep 0.05
echo '[ 1] Blk# 97000, [ratio/avg.   0%/ 38%], avg.speed: 30057009 b/s, ETA: 112s'
sleep 0.05
echo '[ 1] Blk# 97100, [ratio/avg.   0%/ 37%], avg.speed: 30017033 b/s, ETA: 112s'
sleep 0.05
echo '[ 1] Blk# 97200, [ratio/avg.   0%/ 37%], avg.speed: 30047946 b/s, ETA: 112s'
sleep 0.05
echo '[ 1] Blk# 97300, [ratio/avg.   0%/ 37%], avg.speed: 30078860 b/s, ETA: 111s'
sleep 0.05
echo '[ 1] Blk# 97400, [ratio/avg.   0%/ 37%], avg.speed: 30109773 b/s, ETA: 110s'
sleep 0.05
echo '[ 1] Blk# 97500, [ratio/avg.   0%/ 37%], avg.speed: 30069767 b/s, ETA: 110s'
sleep 0.05
echo '[ 1] Blk# 97600, [ratio/avg.   0%/ 37%], avg.speed: 30100607 b/s, ETA: 110s'
sleep 0.05
echo '[ 1] Blk# 97700, [ratio/avg.   0%/ 37%], avg.speed: 30131448 b/s, ETA: 109s'
sleep 0.05
echo '[ 1] Blk# 97800, [ratio/avg.   0%/ 37%], avg.speed: 30091485 b/s, ETA: 109s'
sleep 0.05
echo '[ 1] Blk# 97900, [ratio/avg.   0%/ 37%], avg.speed: 30122253 b/s, ETA: 108s'
sleep 0.05
echo '[ 1] Blk# 98000, [ratio/avg.   0%/ 37%], avg.speed: 30153021 b/s, ETA: 108s'
sleep 0.05
echo '[ 1] Blk# 98100, [ratio/avg.   0%/ 37%], avg.speed: 30183789 b/s, ETA: 107s'
sleep 0.05
echo '[ 1] Blk# 98200, [ratio/avg.   0%/ 37%], avg.speed: 30143797 b/s, ETA: 107s'
sleep 0.05
echo '[ 1] Blk# 98300, [ratio/avg.   0%/ 37%], avg.speed: 30174493 b/s, ETA: 106s'
sleep 0.05
echo '[ 1] Blk# 98400, [ratio/avg.   0%/ 37%], avg.speed: 30205189 b/s, ETA: 106s'
sleep 0.05
echo '[ 1] Blk# 98500, [ratio/avg.   0%/ 37%], avg.speed: 30235885 b/s, ETA: 105s'
sleep 0.05
echo '[ 1] Blk# 98600, [ratio/avg.   2%/ 37%], avg.speed: 30195865 b/s, ETA: 105s'
sleep 0.05
echo '[ 1] Blk# 98700, [ratio/avg.   2%/ 37%], avg.speed: 30226489 b/s, ETA: 104s'
sleep 0.05
echo '[ 1] Blk# 98800, [ratio/avg.   0%/ 37%], avg.speed: 30257113 b/s, ETA: 104s'
sleep 0.05
echo '[ 1] Blk# 98900, [ratio/avg.   0%/ 37%], avg.speed: 30217137 b/s, ETA: 104s'
sleep 0.05
echo '[ 1] Blk# 99000, [ratio/avg.   0%/ 37%], avg.speed: 30247690 b/s, ETA: 103s'
sleep 0.05
echo '[ 1] Blk# 99100, [ratio/avg.   0%/ 37%], avg.speed: 30278243 b/s, ETA: 102s'
sleep 0.05
echo '[ 1] Blk# 99200, [ratio/avg.   0%/ 37%], avg.speed: 30308795 b/s, ETA: 102s'
sleep 0.05
echo '[ 1] Blk# 99300, [ratio/avg.   0%/ 37%], avg.speed: 30268792 b/s, ETA: 102s'
sleep 0.05
echo '[ 1] Blk# 99400, [ratio/avg.  18%/ 37%], avg.speed: 30228974 b/s, ETA: 101s'
sleep 0.05
echo '[ 1] Blk# 99500, [ratio/avg.  50%/ 37%], avg.speed: 30189340 b/s, ETA: 101s'
sleep 0.05
echo '[ 1] Blk# 99600, [ratio/avg.  28%/ 37%], avg.speed: 30149889 b/s, ETA: 101s'
sleep 0.05
echo '[ 1] Blk# 99700, [ratio/avg.  45%/ 37%], avg.speed: 30110620 b/s, ETA: 100s'
sleep 0.05
echo '[ 1] Blk# 99800, [ratio/avg.  28%/ 37%], avg.speed: 30071532 b/s, ETA: 100s'
sleep 0.05
echo '[ 1] Blk# 99900, [ratio/avg.  19%/ 37%], avg.speed: 30032623 b/s, ETA: 100s'
sleep 0.05
echo '[ 1] Blk# 100000, [ratio/avg.  22%/ 37%], avg.speed: 30062685 b/s, ETA: 99s'
sleep 0.05
echo '[ 1] Blk# 100100, [ratio/avg.  24%/ 37%], avg.speed: 30023886 b/s, ETA: 99s'
sleep 0.05
echo '[ 1] Blk# 100200, [ratio/avg.  40%/ 37%], avg.speed: 29916960 b/s, ETA: 99s'
sleep 0.05
echo '[ 1] Blk# 100300, [ratio/avg.  41%/ 37%], avg.speed: 29878756 b/s, ETA: 99s'
sleep 0.05
echo '[ 1] Blk# 100400, [ratio/avg.  94%/ 37%], avg.speed: 29773212 b/s, ETA: 98s'
sleep 0.05
echo '[ 1] Blk# 100500, [ratio/avg.  12%/ 37%], avg.speed: 29735591 b/s, ETA: 98s'
sleep 0.05
echo '[ 1] Blk# 100600, [ratio/avg.  14%/ 37%], avg.speed: 29698140 b/s, ETA: 98s'
sleep 0.05
echo '[ 1] Blk# 100700, [ratio/avg.   9%/ 37%], avg.speed: 29727660 b/s, ETA: 97s'
sleep 0.05
echo '[ 1] Blk# 100800, [ratio/avg.   0%/ 37%], avg.speed: 29690311 b/s, ETA: 97s'
sleep 0.05
echo '[ 1] Blk# 100900, [ratio/avg.  12%/ 37%], avg.speed: 29653129 b/s, ETA: 97s'
sleep 0.05
echo '[ 1] Blk# 101000, [ratio/avg.  13%/ 37%], avg.speed: 29616114 b/s, ETA: 96s'
sleep 0.05
echo '[ 1] Blk# 101100, [ratio/avg.  26%/ 37%], avg.speed: 29579264 b/s, ETA: 96s'
sleep 0.05
echo '[ 1] Blk# 101200, [ratio/avg.  66%/ 37%], avg.speed: 29542577 b/s, ETA: 96s'
sleep 0.05
echo '[ 1] Blk# 101300, [ratio/avg.  43%/ 37%], avg.speed: 29506054 b/s, ETA: 95s'
sleep 0.05
echo '[ 1] Blk# 101400, [ratio/avg.  72%/ 37%], avg.speed: 29404495 b/s, ETA: 95s'
sleep 0.05
echo '[ 1] Blk# 101500, [ratio/avg.  41%/ 37%], avg.speed: 29368518 b/s, ETA: 95s'
sleep 0.05
echo '[ 1] Blk# 101600, [ratio/avg.  44%/ 37%], avg.speed: 29332701 b/s, ETA: 95s'
sleep 0.05
echo '[ 1] Blk# 101700, [ratio/avg.  38%/ 37%], avg.speed: 29297040 b/s, ETA: 94s'
sleep 0.05
echo '[ 1] Blk# 101800, [ratio/avg.  67%/ 37%], avg.speed: 29197506 b/s, ETA: 94s'
sleep 0.05
echo '[ 1] Blk# 101900, [ratio/avg.  92%/ 37%], avg.speed: 29162375 b/s, ETA: 94s'
sleep 0.05
echo '[ 1] Blk# 102000, [ratio/avg.  44%/ 37%], avg.speed: 29127396 b/s, ETA: 93s'
sleep 0.05
echo '[ 1] Blk# 102100, [ratio/avg.  44%/ 37%], avg.speed: 29092570 b/s, ETA: 93s'
sleep 0.05
echo '[ 1] Blk# 102200, [ratio/avg.  53%/ 37%], avg.speed: 29057894 b/s, ETA: 93s'
sleep 0.05
echo '[ 1] Blk# 102300, [ratio/avg.  37%/ 37%], avg.speed: 29023369 b/s, ETA: 92s'
sleep 0.05
echo '[ 1] Blk# 102400, [ratio/avg.  35%/ 37%], avg.speed: 28926516 b/s, ETA: 92s'
sleep 0.05
echo '[ 1] Blk# 102500, [ratio/avg.  49%/ 37%], avg.speed: 28892496 b/s, ETA: 92s'
sleep 0.05
echo '[ 1] Blk# 102600, [ratio/avg.  47%/ 37%], avg.speed: 28858622 b/s, ETA: 92s'
sleep 0.05
echo '[ 1] Blk# 102700, [ratio/avg.  45%/ 37%], avg.speed: 28824893 b/s, ETA: 91s'
sleep 0.05
echo '[ 1] Blk# 102800, [ratio/avg.   7%/ 37%], avg.speed: 28668792 b/s, ETA: 91s'
sleep 0.05
echo '[ 1] Blk# 102900, [ratio/avg.  59%/ 37%], avg.speed: 28635753 b/s, ETA: 91s'
sleep 0.05
echo '[ 1] Blk# 103000, [ratio/avg.  31%/ 37%], avg.speed: 28602853 b/s, ETA: 91s'
sleep 0.05
echo '[ 1] Blk# 103100, [ratio/avg.  25%/ 37%], avg.speed: 28570093 b/s, ETA: 90s'
sleep 0.05
echo '[ 1] Blk# 103200, [ratio/avg.  95%/ 37%], avg.speed: 28477392 b/s, ETA: 90s'
sleep 0.05
echo '[ 1] Blk# 103300, [ratio/avg.  22%/ 37%], avg.speed: 28445102 b/s, ETA: 90s'
sleep 0.05
echo '[ 1] Blk# 103400, [ratio/avg.  28%/ 37%], avg.speed: 28412947 b/s, ETA: 89s'
sleep 0.05
echo '[ 1] Blk# 103500, [ratio/avg.  95%/ 37%], avg.speed: 28380926 b/s, ETA: 89s'
sleep 0.05
echo '[ 1] Blk# 103600, [ratio/avg.  38%/ 37%], avg.speed: 28289979 b/s, ETA: 89s'
sleep 0.05
echo '[ 1] Blk# 103700, [ratio/avg.  40%/ 37%], avg.speed: 28258414 b/s, ETA: 88s'
sleep 0.05
echo '[ 1] Blk# 103800, [ratio/avg.  34%/ 37%], avg.speed: 28226980 b/s, ETA: 88s'
sleep 0.05
echo '[ 1] Blk# 103900, [ratio/avg.  18%/ 37%], avg.speed: 28195676 b/s, ETA: 88s'
sleep 0.05
echo '[ 1] Blk# 104000, [ratio/avg.  96%/ 37%], avg.speed: 28164502 b/s, ETA: 87s'
sleep 0.05
echo '[ 1] Blk# 104100, [ratio/avg.  59%/ 37%], avg.speed: 28075568 b/s, ETA: 87s'
sleep 0.05
echo '[ 1] Blk# 104200, [ratio/avg.  33%/ 37%], avg.speed: 28044832 b/s, ETA: 87s'
sleep 0.05
echo '[ 1] Blk# 104300, [ratio/avg.  99%/ 37%], avg.speed: 28014222 b/s, ETA: 86s'
sleep 0.05
echo '[ 1] Blk# 104400, [ratio/avg.  99%/ 37%], avg.speed: 27926628 b/s, ETA: 86s'
sleep 0.05
echo '[ 1] Blk# 104500, [ratio/avg.  99%/ 37%], avg.speed: 27839746 b/s, ETA: 86s'
sleep 0.05
echo '[ 1] Blk# 104600, [ratio/avg.  92%/ 37%], avg.speed: 27753567 b/s, ETA: 86s'
sleep 0.05
echo '[ 1] Blk# 104700, [ratio/avg.   7%/ 37%], avg.speed: 27780100 b/s, ETA: 85s'
sleep 0.05
echo '[ 1] Blk# 104800, [ratio/avg.  19%/ 37%], avg.speed: 27750457 b/s, ETA: 85s'
sleep 0.05
echo '[ 1] Blk# 104900, [ratio/avg.  18%/ 37%], avg.speed: 27720935 b/s, ETA: 85s'
sleep 0.05
echo '[ 1] Blk# 105000, [ratio/avg.  17%/ 37%], avg.speed: 27747361 b/s, ETA: 84s'
sleep 0.05
echo '[ 1] Blk# 105100, [ratio/avg.  87%/ 37%], avg.speed: 27662245 b/s, ETA: 84s'
sleep 0.05
echo '[ 1] Blk# 105200, [ratio/avg.  81%/ 37%], avg.speed: 27467939 b/s, ETA: 84s'
sleep 0.05
echo '[ 1] Blk# 105300, [ratio/avg.  90%/ 37%], avg.speed: 27439389 b/s, ETA: 83s'
sleep 0.05
echo '[ 1] Blk# 105400, [ratio/avg.  95%/ 37%], avg.speed: 27356673 b/s, ETA: 83s'
sleep 0.05
echo '[ 1] Blk# 105500, [ratio/avg.  67%/ 37%], avg.speed: 27274609 b/s, ETA: 83s'
sleep 0.05
echo '[ 1] Blk# 105600, [ratio/avg.  27%/ 37%], avg.speed: 27246721 b/s, ETA: 83s'
sleep 0.05
echo '[ 1] Blk# 105700, [ratio/avg.  33%/ 37%], avg.speed: 27218941 b/s, ETA: 82s'
sleep 0.05
echo '[ 1] Blk# 105800, [ratio/avg.  51%/ 37%], avg.speed: 27191271 b/s, ETA: 82s'
sleep 0.05
echo '[ 1] Blk# 105900, [ratio/avg.  16%/ 37%], avg.speed: 27163710 b/s, ETA: 81s'
sleep 0.05
echo '[ 1] Blk# 106000, [ratio/avg.  25%/ 37%], avg.speed: 27189360 b/s, ETA: 81s'
sleep 0.05
echo '[ 1] Blk# 106100, [ratio/avg.  22%/ 37%], avg.speed: 27161856 b/s, ETA: 80s'
sleep 0.05
echo '[ 1] Blk# 106200, [ratio/avg.  74%/ 37%], avg.speed: 27134459 b/s, ETA: 80s'
sleep 0.05
echo '[ 1] Blk# 106300, [ratio/avg.  79%/ 37%], avg.speed: 27107168 b/s, ETA: 80s'
sleep 0.05
echo '[ 1] Blk# 106400, [ratio/avg.  42%/ 37%], avg.speed: 27079984 b/s, ETA: 79s'
sleep 0.05
echo '[ 1] Blk# 106500, [ratio/avg.  99%/ 37%], avg.speed: 27000578 b/s, ETA: 79s'
sleep 0.05
echo '[ 1] Blk# 106600, [ratio/avg.   7%/ 37%], avg.speed: 26973757 b/s, ETA: 79s'
sleep 0.05
echo '[ 1] Blk# 106700, [ratio/avg.  88%/ 37%], avg.speed: 26947039 b/s, ETA: 78s'
sleep 0.05
echo '[ 1] Blk# 106800, [ratio/avg.  16%/ 37%], avg.speed: 26868753 b/s, ETA: 78s'
sleep 0.05
echo '[ 1] Blk# 106900, [ratio/avg.  18%/ 37%], avg.speed: 26893911 b/s, ETA: 77s'
sleep 0.05
echo '[ 1] Blk# 107000, [ratio/avg.  89%/ 37%], avg.speed: 26816128 b/s, ETA: 77s'
sleep 0.05
echo '[ 1] Blk# 107100, [ratio/avg.  44%/ 37%], avg.speed: 26789966 b/s, ETA: 77s'
sleep 0.05
echo '[ 1] Blk# 107200, [ratio/avg.  47%/ 37%], avg.speed: 26763903 b/s, ETA: 76s'
sleep 0.05
echo '[ 1] Blk# 107300, [ratio/avg.  98%/ 37%], avg.speed: 26737940 b/s, ETA: 76s'
sleep 0.05
echo '[ 1] Blk# 107400, [ratio/avg.  99%/ 37%], avg.speed: 26712075 b/s, ETA: 75s'
sleep 0.05
echo '[ 1] Blk# 107500, [ratio/avg.  96%/ 37%], avg.speed: 26635862 b/s, ETA: 75s'
sleep 0.05
echo '[ 1] Blk# 107600, [ratio/avg. 100%/ 37%], avg.speed: 26560222 b/s, ETA: 75s'
sleep 0.05
echo '[ 1] Blk# 107700, [ratio/avg. 100%/ 38%], avg.speed: 26534935 b/s, ETA: 74s'
sleep 0.05
echo '[ 1] Blk# 107800, [ratio/avg.  24%/ 38%], avg.speed: 26509742 b/s, ETA: 74s'
sleep 0.05
echo '[ 1] Blk# 107900, [ratio/avg.  43%/ 38%], avg.speed: 26534333 b/s, ETA: 73s'
sleep 0.05
echo '[ 1] Blk# 108000, [ratio/avg.  24%/ 38%], avg.speed: 26558925 b/s, ETA: 73s'
sleep 0.05
echo '[ 1] Blk# 108100, [ratio/avg.  53%/ 38%], avg.speed: 26533734 b/s, ETA: 73s'
sleep 0.05
echo '[ 1] Blk# 108200, [ratio/avg.  16%/ 38%], avg.speed: 26558279 b/s, ETA: 72s'
sleep 0.05
echo '[ 1] Blk# 108300, [ratio/avg.  28%/ 38%], avg.speed: 26582825 b/s, ETA: 71s'
sleep 0.05
echo '[ 1] Blk# 108400, [ratio/avg.  37%/ 38%], avg.speed: 26458726 b/s, ETA: 71s'
sleep 0.05
echo '[ 1] Blk# 108500, [ratio/avg.  40%/ 38%], avg.speed: 26433909 b/s, ETA: 71s'
sleep 0.05
echo '[ 1] Blk# 108600, [ratio/avg.  27%/ 38%], avg.speed: 26409184 b/s, ETA: 70s'
sleep 0.05
echo '[ 1] Blk# 108700, [ratio/avg.  39%/ 38%], avg.speed: 26384550 b/s, ETA: 70s'
sleep 0.05
echo '[ 1] Blk# 108800, [ratio/avg.  97%/ 38%], avg.speed: 26360008 b/s, ETA: 70s'
sleep 0.05
echo '[ 1] Blk# 108900, [ratio/avg.  11%/ 38%], avg.speed: 26335556 b/s, ETA: 69s'
sleep 0.05
echo '[ 1] Blk# 109000, [ratio/avg.   2%/ 38%], avg.speed: 26311195 b/s, ETA: 69s'
sleep 0.05
echo '[ 1] Blk# 109100, [ratio/avg.  39%/ 38%], avg.speed: 26335333 b/s, ETA: 68s'
sleep 0.05
echo '[ 1] Blk# 109200, [ratio/avg.  52%/ 38%], avg.speed: 26262740 b/s, ETA: 68s'
sleep 0.05
echo '[ 1] Blk# 109300, [ratio/avg.  26%/ 38%], avg.speed: 26238645 b/s, ETA: 67s'
sleep 0.05
echo '[ 1] Blk# 109400, [ratio/avg.   8%/ 38%], avg.speed: 26214639 b/s, ETA: 67s'
sleep 0.05
echo '[ 1] Blk# 109500, [ratio/avg.   0%/ 38%], avg.speed: 26238601 b/s, ETA: 66s'
sleep 0.05
echo '[ 1] Blk# 109600, [ratio/avg.   0%/ 38%], avg.speed: 26214639 b/s, ETA: 66s'
sleep 0.05
echo '[ 1] Blk# 109700, [ratio/avg.   0%/ 37%], avg.speed: 26238557 b/s, ETA: 65s'
sleep 0.05
echo '[ 1] Blk# 109800, [ratio/avg.   0%/ 37%], avg.speed: 26262475 b/s, ETA: 65s'
sleep 0.05
echo '[ 1] Blk# 109900, [ratio/avg.   0%/ 37%], avg.speed: 26286393 b/s, ETA: 64s'
sleep 0.05
echo '[ 1] Blk# 110000, [ratio/avg.   0%/ 37%], avg.speed: 26262388 b/s, ETA: 64s'
sleep 0.05
echo '[ 1] Blk# 110100, [ratio/avg.   0%/ 37%], avg.speed: 26286262 b/s, ETA: 63s'
sleep 0.05
echo '[ 1] Blk# 110200, [ratio/avg.   0%/ 37%], avg.speed: 26310137 b/s, ETA: 63s'
sleep 0.05
echo '[ 1] Blk# 110300, [ratio/avg.   0%/ 37%], avg.speed: 26334012 b/s, ETA: 62s'
sleep 0.05
echo '[ 1] Blk# 110400, [ratio/avg.   0%/ 37%], avg.speed: 26309963 b/s, ETA: 62s'
sleep 0.05
echo '[ 1] Blk# 110500, [ratio/avg.   0%/ 37%], avg.speed: 26333794 b/s, ETA: 61s'
sleep 0.05
echo '[ 1] Blk# 110600, [ratio/avg.   0%/ 37%], avg.speed: 26357625 b/s, ETA: 61s'
sleep 0.05
echo '[ 1] Blk# 110700, [ratio/avg.   0%/ 37%], avg.speed: 26381457 b/s, ETA: 60s'
sleep 0.05
echo '[ 1] Blk# 110800, [ratio/avg.   0%/ 37%], avg.speed: 26357366 b/s, ETA: 60s'
sleep 0.05
echo '[ 1] Blk# 110900, [ratio/avg.   0%/ 37%], avg.speed: 26381154 b/s, ETA: 59s'
sleep 0.05
echo '[ 1] Blk# 111000, [ratio/avg.   0%/ 37%], avg.speed: 26404942 b/s, ETA: 58s'
sleep 0.05
echo '[ 1] Blk# 111100, [ratio/avg.   0%/ 37%], avg.speed: 26428730 b/s, ETA: 58s'
sleep 0.05
echo '[ 1] Blk# 111200, [ratio/avg.   0%/ 37%], avg.speed: 26404596 b/s, ETA: 57s'
sleep 0.05
echo '[ 1] Blk# 111300, [ratio/avg.   0%/ 37%], avg.speed: 26428341 b/s, ETA: 57s'
sleep 0.05
echo '[ 1] Blk# 111400, [ratio/avg.   0%/ 37%], avg.speed: 26452086 b/s, ETA: 56s'
sleep 0.05
echo '[ 1] Blk# 111500, [ratio/avg.   0%/ 37%], avg.speed: 26475831 b/s, ETA: 56s'
sleep 0.05
echo '[ 1] Blk# 111600, [ratio/avg.   0%/ 37%], avg.speed: 26451656 b/s, ETA: 55s'
sleep 0.05
echo '[ 1] Blk# 111700, [ratio/avg.   0%/ 37%], avg.speed: 26475358 b/s, ETA: 55s'
sleep 0.05
echo '[ 1] Blk# 111800, [ratio/avg.   0%/ 37%], avg.speed: 26499060 b/s, ETA: 54s'
sleep 0.05
echo '[ 1] Blk# 111900, [ratio/avg.   0%/ 37%], avg.speed: 26522762 b/s, ETA: 54s'
sleep 0.05
echo '[ 1] Blk# 112000, [ratio/avg.   0%/ 37%], avg.speed: 26498547 b/s, ETA: 53s'
sleep 0.05
echo '[ 1] Blk# 112100, [ratio/avg.   0%/ 37%], avg.speed: 26522206 b/s, ETA: 53s'
sleep 0.05
echo '[ 1] Blk# 112200, [ratio/avg.   0%/ 37%], avg.speed: 26545865 b/s, ETA: 52s'
sleep 0.05
echo '[ 1] Blk# 112300, [ratio/avg.   0%/ 37%], avg.speed: 26569524 b/s, ETA: 52s'
sleep 0.05
echo '[ 1] Blk# 112400, [ratio/avg.   0%/ 37%], avg.speed: 26545268 b/s, ETA: 51s'
sleep 0.05
echo '[ 1] Blk# 112500, [ratio/avg.   0%/ 37%], avg.speed: 26568884 b/s, ETA: 51s'
sleep 0.05
echo '[ 1] Blk# 112600, [ratio/avg.   0%/ 37%], avg.speed: 26592501 b/s, ETA: 50s'
sleep 0.05
echo '[ 1] Blk# 112700, [ratio/avg.   0%/ 36%], avg.speed: 26616117 b/s, ETA: 50s'
sleep 0.05
echo '[ 1] Blk# 112800, [ratio/avg.   0%/ 36%], avg.speed: 26591821 b/s, ETA: 49s'
sleep 0.05
echo '[ 1] Blk# 112900, [ratio/avg.   0%/ 36%], avg.speed: 26615395 b/s, ETA: 49s'
sleep 0.05
echo '[ 1] Blk# 113000, [ratio/avg.   0%/ 36%], avg.speed: 26638969 b/s, ETA: 48s'
sleep 0.05
echo '[ 1] Blk# 113100, [ratio/avg.   0%/ 36%], avg.speed: 26614675 b/s, ETA: 48s'
sleep 0.05
echo '[ 1] Blk# 113200, [ratio/avg.   0%/ 36%], avg.speed: 26638207 b/s, ETA: 47s'
sleep 0.05
echo '[ 1] Blk# 113300, [ratio/avg.   0%/ 36%], avg.speed: 26661739 b/s, ETA: 47s'
sleep 0.05
echo '[ 1] Blk# 113400, [ratio/avg.   0%/ 36%], avg.speed: 26685270 b/s, ETA: 46s'
sleep 0.05
echo '[ 1] Blk# 113500, [ratio/avg.   0%/ 36%], avg.speed: 26660937 b/s, ETA: 46s'
sleep 0.05
echo '[ 1] Blk# 113600, [ratio/avg.   0%/ 36%], avg.speed: 26684427 b/s, ETA: 45s'
sleep 0.05
echo '[ 1] Blk# 113700, [ratio/avg.   0%/ 36%], avg.speed: 26707916 b/s, ETA: 45s'
sleep 0.05
echo '[ 1] Blk# 113800, [ratio/avg.   0%/ 36%], avg.speed: 26731406 b/s, ETA: 44s'
sleep 0.05
echo '[ 1] Blk# 113900, [ratio/avg.   0%/ 36%], avg.speed: 26707033 b/s, ETA: 44s'
sleep 0.05
echo '[ 1] Blk# 114000, [ratio/avg.   0%/ 36%], avg.speed: 26730481 b/s, ETA: 43s'
sleep 0.05
echo '[ 1] Blk# 114100, [ratio/avg.   0%/ 36%], avg.speed: 26753928 b/s, ETA: 43s'
sleep 0.05
echo '[ 1] Blk# 114200, [ratio/avg.   0%/ 36%], avg.speed: 26777376 b/s, ETA: 42s'
sleep 0.05
echo '[ 1] Blk# 114300, [ratio/avg.   0%/ 36%], avg.speed: 26752965 b/s, ETA: 42s'
sleep 0.05
echo '[ 1] Blk# 114400, [ratio/avg.   0%/ 36%], avg.speed: 26776371 b/s, ETA: 41s'
sleep 0.05
echo '[ 1] Blk# 114500, [ratio/avg.   0%/ 36%], avg.speed: 26799776 b/s, ETA: 40s'
sleep 0.05
echo '[ 1] Blk# 114600, [ratio/avg.   0%/ 36%], avg.speed: 26823182 b/s, ETA: 40s'
sleep 0.05
echo '[ 1] Blk# 114700, [ratio/avg.   6%/ 36%], avg.speed: 26798733 b/s, ETA: 40s'
sleep 0.05
echo '[ 1] Blk# 114800, [ratio/avg.   0%/ 36%], avg.speed: 26822097 b/s, ETA: 39s'
sleep 0.05
echo '[ 1] Blk# 114900, [ratio/avg.   1%/ 36%], avg.speed: 26845461 b/s, ETA: 38s'
sleep 0.05
echo '[ 1] Blk# 115000, [ratio/avg.   0%/ 36%], avg.speed: 26821016 b/s, ETA: 38s'
sleep 0.05
echo '[ 1] Blk# 115100, [ratio/avg.   0%/ 36%], avg.speed: 26844338 b/s, ETA: 37s'
sleep 0.05
echo '[ 1] Blk# 115200, [ratio/avg.   0%/ 36%], avg.speed: 26867660 b/s, ETA: 37s'
sleep 0.05
echo '[ 1] Blk# 115300, [ratio/avg.   0%/ 36%], avg.speed: 26890983 b/s, ETA: 36s'
sleep 0.05
echo '[ 1] Blk# 115400, [ratio/avg.   0%/ 36%], avg.speed: 26866500 b/s, ETA: 36s'
sleep 0.05
echo '[ 1] Blk# 115500, [ratio/avg.   0%/ 36%], avg.speed: 26889781 b/s, ETA: 35s'
sleep 0.05
echo '[ 1] Blk# 115600, [ratio/avg.   0%/ 36%], avg.speed: 26913062 b/s, ETA: 35s'
sleep 0.05
echo '[ 1] Blk# 115700, [ratio/avg.   0%/ 36%], avg.speed: 26936343 b/s, ETA: 34s'
sleep 0.05
echo '[ 1] Blk# 115800, [ratio/avg.  21%/ 36%], avg.speed: 26911823 b/s, ETA: 34s'
sleep 0.05
echo '[ 1] Blk# 115900, [ratio/avg.  75%/ 36%], avg.speed: 26887390 b/s, ETA: 34s'
sleep 0.05
echo '[ 1] Blk# 116000, [ratio/avg.  16%/ 36%], avg.speed: 26815666 b/s, ETA: 33s'
sleep 0.05
echo '[ 1] Blk# 116100, [ratio/avg.  83%/ 36%], avg.speed: 26791532 b/s, ETA: 33s'
sleep 0.05
echo '[ 1] Blk# 116200, [ratio/avg.  23%/ 36%], avg.speed: 26767482 b/s, ETA: 32s'
sleep 0.05
echo '[ 1] Blk# 116300, [ratio/avg.  40%/ 36%], avg.speed: 26696680 b/s, ETA: 32s'
sleep 0.05
echo '[ 1] Blk# 116400, [ratio/avg.  38%/ 36%], avg.speed: 26672922 b/s, ETA: 31s'
sleep 0.05
echo '[ 1] Blk# 116500, [ratio/avg.  96%/ 36%], avg.speed: 26649247 b/s, ETA: 31s'
sleep 0.05
echo '[ 1] Blk# 116600, [ratio/avg.  30%/ 36%], avg.speed: 26579350 b/s, ETA: 30s'
sleep 0.05
echo '[ 1] Blk# 116700, [ratio/avg.  31%/ 36%], avg.speed: 26555960 b/s, ETA: 30s'
sleep 0.05
echo '[ 1] Blk# 116800, [ratio/avg.  97%/ 36%], avg.speed: 26486748 b/s, ETA: 30s'
sleep 0.05
echo '[ 1] Blk# 116900, [ratio/avg.  74%/ 36%], avg.speed: 26418013 b/s, ETA: 29s'
sleep 0.05
echo '[ 1] Blk# 117000, [ratio/avg.  73%/ 36%], avg.speed: 26395103 b/s, ETA: 29s'
sleep 0.05
echo '[ 1] Blk# 117100, [ratio/avg.  99%/ 36%], avg.speed: 26372271 b/s, ETA: 28s'
sleep 0.05
echo '[ 1] Blk# 117200, [ratio/avg.  96%/ 36%], avg.speed: 26304399 b/s, ETA: 28s'
sleep 0.05
echo '[ 1] Blk# 117300, [ratio/avg.  27%/ 36%], avg.speed: 26281840 b/s, ETA: 27s'
sleep 0.05
echo '[ 1] Blk# 117400, [ratio/avg.  39%/ 36%], avg.speed: 26259358 b/s, ETA: 27s'
sleep 0.05
echo '[ 1] Blk# 117500, [ratio/avg.  14%/ 36%], avg.speed: 26236952 b/s, ETA: 26s'
sleep 0.05
echo '[ 1] Blk# 117600, [ratio/avg.  99%/ 36%], avg.speed: 26214622 b/s, ETA: 26s'
sleep 0.05
echo '[ 1] Blk# 117700, [ratio/avg.  36%/ 36%], avg.speed: 26147975 b/s, ETA: 25s'
sleep 0.05
echo '[ 1] Blk# 117800, [ratio/avg.  28%/ 36%], avg.speed: 26125909 b/s, ETA: 25s'
sleep 0.05
echo '[ 1] Blk# 117900, [ratio/avg.  19%/ 36%], avg.speed: 26148087 b/s, ETA: 24s'
sleep 0.05
echo '[ 1] Blk# 118000, [ratio/avg.  42%/ 36%], avg.speed: 26126059 b/s, ETA: 24s'
sleep 0.05
echo '[ 1] Blk# 118100, [ratio/avg.  43%/ 36%], avg.speed: 26104105 b/s, ETA: 23s'
sleep 0.05
echo '[ 1] Blk# 118200, [ratio/avg.  27%/ 36%], avg.speed: 26082224 b/s, ETA: 23s'
sleep 0.05
echo '[ 1] Blk# 118300, [ratio/avg.  84%/ 36%], avg.speed: 26016692 b/s, ETA: 23s'
sleep 0.05
echo '[ 1] Blk# 118400, [ratio/avg.  43%/ 36%], avg.speed: 25951598 b/s, ETA: 22s'
sleep 0.05
echo '[ 1] Blk# 118500, [ratio/avg.  37%/ 36%], avg.speed: 25973516 b/s, ETA: 22s'
sleep 0.05
echo '[ 1] Blk# 118600, [ratio/avg.  42%/ 36%], avg.speed: 25995435 b/s, ETA: 21s'
sleep 0.05
echo '[ 1] Blk# 118700, [ratio/avg.  44%/ 36%], avg.speed: 25973918 b/s, ETA: 21s'
sleep 0.05
echo '[ 1] Blk# 118800, [ratio/avg.  31%/ 36%], avg.speed: 25995800 b/s, ETA: 20s'
sleep 0.05
echo '[ 1] Blk# 118900, [ratio/avg.   0%/ 36%], avg.speed: 25974319 b/s, ETA: 20s'
sleep 0.05
echo '[ 1] Blk# 119000, [ratio/avg.   1%/ 36%], avg.speed: 25996165 b/s, ETA: 19s'
sleep 0.05
echo '[ 1] Blk# 119100, [ratio/avg.   0%/ 36%], avg.speed: 25974719 b/s, ETA: 19s'
sleep 0.05
echo '[ 1] Blk# 119200, [ratio/avg.   0%/ 36%], avg.speed: 25996528 b/s, ETA: 18s'
sleep 0.05
echo '[ 1] Blk# 119300, [ratio/avg.   2%/ 36%], avg.speed: 26018337 b/s, ETA: 18s'
sleep 0.05
echo '[ 1] Blk# 119400, [ratio/avg.   0%/ 36%], avg.speed: 25996890 b/s, ETA: 17s'
sleep 0.05
echo '[ 1] Blk# 119500, [ratio/avg.   1%/ 36%], avg.speed: 26018662 b/s, ETA: 17s'
sleep 0.05
echo '[ 1] Blk# 119600, [ratio/avg.   0%/ 36%], avg.speed: 26040435 b/s, ETA: 16s'
sleep 0.05
echo '[ 1] Blk# 119700, [ratio/avg.   0%/ 36%], avg.speed: 26018987 b/s, ETA: 16s'
sleep 0.05
echo '[ 1] Blk# 119800, [ratio/avg.   0%/ 36%], avg.speed: 26040724 b/s, ETA: 15s'
sleep 0.05
echo '[ 1] Blk# 119900, [ratio/avg.   7%/ 36%], avg.speed: 26062460 b/s, ETA: 14s'
sleep 0.05
echo '[ 1] Blk# 120000, [ratio/avg.   0%/ 36%], avg.speed: 26084197 b/s, ETA: 14s'
sleep 0.05
echo '[ 1] Blk# 120100, [ratio/avg.   0%/ 35%], avg.speed: 26062712 b/s, ETA: 13s'
sleep 0.05
echo '[ 1] Blk# 120200, [ratio/avg.   0%/ 35%], avg.speed: 26084413 b/s, ETA: 13s'
sleep 0.05
echo '[ 1] Blk# 120300, [ratio/avg.   0%/ 35%], avg.speed: 26106113 b/s, ETA: 12s'
sleep 0.05
echo '[ 1] Blk# 120400, [ratio/avg.   0%/ 35%], avg.speed: 26084627 b/s, ETA: 12s'
sleep 0.05
echo '[ 1] Blk# 120500, [ratio/avg.   0%/ 35%], avg.speed: 26106292 b/s, ETA: 11s'
sleep 0.05
echo '[ 1] Blk# 120600, [ratio/avg.   0%/ 35%], avg.speed: 26127957 b/s, ETA: 11s'
sleep 0.05
echo '[ 1] Blk# 120700, [ratio/avg.   0%/ 35%], avg.speed: 26149622 b/s, ETA: 10s'
sleep 0.05
echo '[ 1] Blk# 120800, [ratio/avg.   0%/ 35%], avg.speed: 26128100 b/s, ETA: 10s'
sleep 0.05
echo '[ 1] Blk# 120900, [ratio/avg.   0%/ 35%], avg.speed: 26149729 b/s, ETA: 9s'
sleep 0.05
echo '[ 1] Blk# 121000, [ratio/avg.   0%/ 35%], avg.speed: 26171358 b/s, ETA: 9s'
sleep 0.05
echo '[ 1] Blk# 121100, [ratio/avg.   0%/ 35%], avg.speed: 26192987 b/s, ETA: 8s'
sleep 0.05
echo '[ 1] Blk# 121200, [ratio/avg.   0%/ 35%], avg.speed: 26171429 b/s, ETA: 8s'
sleep 0.05
echo '[ 1] Blk# 121300, [ratio/avg.   0%/ 35%], avg.speed: 26193022 b/s, ETA: 7s'
sleep 0.05
echo '[ 1] Blk# 121400, [ratio/avg.   0%/ 35%], avg.speed: 26214615 b/s, ETA: 7s'
sleep 0.05
echo '[ 1] Blk# 121500, [ratio/avg.   0%/ 35%], avg.speed: 26236209 b/s, ETA: 6s'
sleep 0.05
echo '[ 1] Blk# 121600, [ratio/avg.   0%/ 35%], avg.speed: 26214615 b/s, ETA: 6s'
sleep 0.05
echo '[ 1] Blk# 121700, [ratio/avg.   0%/ 35%], avg.speed: 26236173 b/s, ETA: 5s'
sleep 0.05
echo '[ 1] Blk# 121800, [ratio/avg.   0%/ 35%], avg.speed: 26257731 b/s, ETA: 5s'
sleep 0.05
echo '[ 1] Blk# 121900, [ratio/avg.   0%/ 35%], avg.speed: 26279289 b/s, ETA: 4s'
sleep 0.05
echo '[ 1] Blk# 122000, [ratio/avg.   0%/ 35%], avg.speed: 26257660 b/s, ETA: 4s'
sleep 0.05
echo '[ 1] Blk# 122100, [ratio/avg.   0%/ 35%], avg.speed: 26279182 b/s, ETA: 3s'
sleep 0.05
echo '[ 1] Blk# 122200, [ratio/avg.   0%/ 35%], avg.speed: 26300705 b/s, ETA: 3s'
sleep 0.05
echo '[ 1] Blk# 122300, [ratio/avg.   0%/ 35%], avg.speed: 26322227 b/s, ETA: 2s'
sleep 0.05
echo '[ 1] Blk# 122400, [ratio/avg.   0%/ 35%], avg.speed: 26300563 b/s, ETA: 2s'
sleep 0.05
echo '[ 1] Blk# 122500, [ratio/avg.   0%/ 35%], avg.speed: 26322050 b/s, ETA: 1s'
sleep 0.05
echo '[ 1] Blk# 122600, [ratio/avg.   0%/ 35%], avg.speed: 26343538 b/s, ETA: 1s'
sleep 0.05
echo '[ 1] Blk# 122700, [ratio/avg.   0%/ 35%], avg.speed: 26365025 b/s, ETA: 0s'
sleep 0.05
echo '[ 1] Blk# 122800, [ratio/avg.   0%/ 35%], avg.speed: 26343326 b/s, ETA: 0s'
sleep 0.05
echo '[ 1] Blk# 122879, [ratio/avg.   0%/ 35%], avg.speed: 26360273 b/s, ETA: 0s'
sleep 0.05
echo ''
echo 'Statistics:'
echo 'gzip(0):     0 (    0%)'
echo 'gzip(1): 122880 (1e+02%)'
echo 'gzip(2):     0 (    0%)'
echo 'gzip(3):     0 (    0%)'
echo 'gzip(4):     0 (    0%)'
echo 'gzip(5):     0 (    0%)'
echo 'gzip(6):     0 (    0%)'
echo 'gzip(7):     0 (    0%)'
echo 'gzip(8):     0 (    0%)'
echo 'gzip(9):     0 (    0%)'
echo '7zip:     0 (    0%)'
echo 'Writing index for 122880 block(s)...'
echo 'Writing compressed data...'
echo 'Fertig.'
echo '-rw-rw-r--    1 root     root     5668275056 Apr 11 09:03 opensuse-cpqmini.cloop'
echo 'Erstelle torrent Dateien ...'
sleep 0.05
echo 'Create hash table: 1/21623'
sleep 0.05
echo 'Create hash table: 217/21623'
sleep 0.05
echo 'Create hash table: 433/21623'
sleep 0.05
echo 'Create hash table: 649/21623'
sleep 0.05
echo 'Create hash table: 865/21623'
sleep 0.05
echo 'Create hash table: 1081/21623'
sleep 0.05
echo 'Create hash table: 1297/21623'
sleep 0.05
echo 'Create hash table: 1513/21623'
sleep 0.05
echo 'Create hash table: 1729/21623'
sleep 0.05
echo 'Create hash table: 1945/21623'
sleep 0.05
echo 'Create hash table: 2161/21623'
sleep 0.05
echo 'Create hash table: 2377/21623'
sleep 0.05
echo 'Create hash table: 2593/21623'
sleep 0.05
echo 'Create hash table: 2809/21623'
sleep 0.05
echo 'Create hash table: 3025/21623'
sleep 0.05
echo 'Create hash table: 3241/21623'
sleep 0.05
echo 'Create hash table: 3457/21623'
sleep 0.05
echo 'Create hash table: 3673/21623'
sleep 0.05
echo 'Create hash table: 3889/21623'
sleep 0.05
echo 'Create hash table: 4105/21623'
sleep 0.05
echo 'Create hash table: 4321/21623'
sleep 0.05
echo 'Create hash table: 4537/21623'
sleep 0.05
echo 'Create hash table: 4753/21623'
sleep 0.05
echo 'Create hash table: 4969/21623'
sleep 0.05
echo 'Create hash table: 5185/21623'
sleep 0.05
echo 'Create hash table: 5401/21623'
sleep 0.05
echo 'Create hash table: 5617/21623'
sleep 0.05
echo 'Create hash table: 5833/21623'
sleep 0.05
echo 'Create hash table: 6049/21623'
sleep 0.05
echo 'Create hash table: 6265/21623'
sleep 0.05
echo 'Create hash table: 6481/21623'
sleep 0.05
echo 'Create hash table: 6697/21623'
sleep 0.05
echo 'Create hash table: 6913/21623'
sleep 0.05
echo 'Create hash table: 7129/21623'
sleep 0.05
echo 'Create hash table: 7345/21623'
sleep 0.05
echo 'Create hash table: 7561/21623'
sleep 0.05
echo 'Create hash table: 7777/21623'
sleep 0.05
echo 'Create hash table: 7993/21623'
sleep 0.05
echo 'Create hash table: 8209/21623'
sleep 0.05
echo 'Create hash table: 8425/21623'
sleep 0.05
echo 'Create hash table: 8641/21623'
sleep 0.05
echo 'Create hash table: 8857/21623'
sleep 0.05
echo 'Create hash table: 9073/21623'
sleep 0.05
echo 'Create hash table: 9289/21623'
sleep 0.05
echo 'Create hash table: 9505/21623'
sleep 0.05
echo 'Create hash table: 9721/21623'
sleep 0.05
echo 'Create hash table: 9937/21623'
sleep 0.05
echo 'Create hash table: 10153/21623'
sleep 0.05
echo 'Create hash table: 10369/21623'
sleep 0.05
echo 'Create hash table: 10585/21623'
sleep 0.05
echo 'Create hash table: 10801/21623'
sleep 0.05
echo 'Create hash table: 11017/21623'
sleep 0.05
echo 'Create hash table: 11233/21623'
sleep 0.05
echo 'Create hash table: 11449/21623'
sleep 0.05
echo 'Create hash table: 11665/21623'
sleep 0.05
echo 'Create hash table: 11881/21623'
sleep 0.05
echo 'Create hash table: 12097/21623'
sleep 0.05
echo 'Create hash table: 12313/21623'
sleep 0.05
echo 'Create hash table: 12529/21623'
sleep 0.05
echo 'Create hash table: 12745/21623'
sleep 0.05
echo 'Create hash table: 12961/21623'
sleep 0.05
echo 'Create hash table: 13177/21623'
sleep 0.05
echo 'Create hash table: 13393/21623'
sleep 0.05
echo 'Create hash table: 13609/21623'
sleep 0.05
echo 'Create hash table: 13825/21623'
sleep 0.05
echo 'Create hash table: 14041/21623'
sleep 0.05
echo 'Create hash table: 14257/21623'
sleep 0.05
echo 'Create hash table: 14473/21623'
sleep 0.05
echo 'Create hash table: 14689/21623'
sleep 0.05
echo 'Create hash table: 14905/21623'
sleep 0.05
echo 'Create hash table: 15121/21623'
sleep 0.05
echo 'Create hash table: 15337/21623'
sleep 0.05
echo 'Create hash table: 15553/21623'
sleep 0.05
echo 'Create hash table: 15769/21623'
sleep 0.05
echo 'Create hash table: 15985/21623'
sleep 0.05
echo 'Create hash table: 16201/21623'
sleep 0.05
echo 'Create hash table: 16417/21623'
sleep 0.05
echo 'Create hash table: 16633/21623'
sleep 0.05
echo 'Create hash table: 16849/21623'
sleep 0.05
echo 'Create hash table: 17065/21623'
sleep 0.05
echo 'Create hash table: 17281/21623'
sleep 0.05
echo 'Create hash table: 17497/21623'
sleep 0.05
echo 'Create hash table: 17713/21623'
sleep 0.05
echo 'Create hash table: 17929/21623'
sleep 0.05
echo 'Create hash table: 18145/21623'
sleep 0.05
echo 'Create hash table: 18361/21623'
sleep 0.05
echo 'Create hash table: 18577/21623'
sleep 0.05
echo 'Create hash table: 18793/21623'
sleep 0.05
echo 'Create hash table: 19009/21623'
sleep 0.05
echo 'Create hash table: 19225/21623'
sleep 0.05
echo 'Create hash table: 19441/21623'
sleep 0.05
echo 'Create hash table: 19657/21623'
sleep 0.05
echo 'Create hash table: 19873/21623'
sleep 0.05
echo 'Create hash table: 20089/21623'
sleep 0.05
echo 'Create hash table: 20305/21623'
sleep 0.05
echo 'Create hash table: 20521/21623'
sleep 0.05
echo 'Create hash table: 20737/21623'
sleep 0.05
echo 'Create hash table: 20953/21623'
sleep 0.05
echo 'Create hash table: 21169/21623'
sleep 0.05
echo 'Create hash table: 21385/21623'
sleep 0.05
echo 'Create hash table: 21601/21623'
sleep 0.05
echo 'Create hash table: 21623/21623'
echo 'Create metainfo file opensuse-cpqmini.cloop.torrent successful.'
echo '## Mon Apr 11 09:07:13 UTC 2016 : Beende Erstellung von opensuse-cpqmini.cloop.'
echo 'Fertig.'
echo 'Veranlasse Upload von image.log.'
echo 'Veranlasse Upload von linbo.log.'
}
