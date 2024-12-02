#!bin/bash
#program: 
#test mv & cp diff
#history:
#2024/10/24 QuL

TODAY=`date "+%Y%m%d"`
path="C:/Desktop/test"
dataPath="D:/"
testFile="your_test_file"
mv_logFile="${path}/testMVLog.log"
cp_logFile="${path}/testCPLog.log"

# 測試 copy
# echo "開始測試 copy執行時間:"
# start_time=$(date +%s%3N)
# cp -r ${dataPath}/$testFile $path -v >> $cp_logFile 2>&1
# if [ $? -eq 0 ]; then
#     rm -r ${dataPath}/$testFile -v >> $cp_logFile 2>&1
# else    
#     echo "複製失敗，原檔尚未刪除"
# fi
# end_time=$(date +%s%3N)
# copy_time=$((end_time-start_time))
# echo "copy執行時間: $copy_time ms" >> $cp_logFile 2>&1


# cp -r ${path}/$testFile $dataPath
# if [ $? -eq 0 ]; then
#     rm -r ${path}/$testFile
# else    
#     echo "複製失敗，原檔尚未刪除"
# fi

# 測試move
echo "開始測試 move執行時間:"
start_time=$(date +%s%3N)
mv ${dataPath}/$testFile $path -v >> $mv_logFile 2>&1
end_time=$(date +%s%3N)
copy_time=$((end_time-start_time))
echo "mv執行時間: $copy_time ms" >> $mv_logFile 2>&1