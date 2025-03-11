#!/bin/bash
#Program:
#download file use curl
#History:
#2024/10/18

TODAY=`date "+%Y%m%d"`
# 下載路徑
URL="your_downloadFile_url"

DOWNLOAD_PATH="/your_file_save_path"

LOG_PATH="$DOWNLOAD_PATH/log"
OUTPUT_FILE="your_file_name"
LOG_FILE="$LOG_PATH/${OUTPUT_FILE}_${TODAY}.log"

# -p = 沒有資料夾的話才建立
mkdir -p "$LOG_PATH"

# >> append ， > 覆蓋
# 計算原始檔案大小
checkOrigin(){
    echo "開始檢查原檔大小..."
    FONT_SIZE=$(stat -c%s "$OUTPUT_FILE")
    echo "原始檔案大小為：$FONT_SIZE bytes"
    echo "原始檔案大小為：$FONT_SIZE bytes" >> $LOG_FILE 
    echo "原檔案大小已記錄在$LOG_FILE"
}

# 下載網址的文件
function download(){
    echo "==================執行curl下載指令結果如下==================" >> $LOG_FILE 
    # 0-o 下載 -v 執行過程詳細資訊
    # 輸出、錯誤訊息 寫進log
    # 自定義檔名=OUTPUT_FILE
    curl -o "$OUTPUT_FILE" "$URL" -v >> $LOG_FILE 2>&1
    # 前面指令成功
    if [ $? -eq 0 ]; then
        echo "開始檢查下載檔案大小..."
        # 計算下載檔案大小
        FILE_SIZE=$(stat -c%s "$DOWNLOAD_PATH/$OUTPUT_FILE")
        # 下載檔案 > 0 且 > 原始檔案 大小
        if [ $FILE_SIZE -gt 0 ] && [ $FILE_SIZE -gt $FONT_SIZE ]; then
            echo "==================檔案下載成功==================" >> $LOG_FILE
            echo "下載檔案${OUTPUT_FILE}大小為：$FILE_SIZE bytes" >> $LOG_FILE
            echo "${OUTPUT_FILE}已下載完成\OwO/"
        # 下載檔案 = 原始檔案 大小
        elif [ $FILE_SIZE -eq $FONT_SIZE ]; then
            echo "==================檔案下載成功==================" >> $LOG_FILE
            echo "下載檔案${OUTPUT_FILE}大小為：$FILE_SIZE bytes"
            echo "下載檔案${OUTPUT_FILE}大小為：$FILE_SIZE bytes" >> $LOG_FILE
            echo "下載檔案大小不變，請檢查${LOG_FILE}的紀錄"
        else
            echo "下載檔案大小為 $FILE_SIZE，請檢查${LOG_FILE}的紀錄"
            exit 1
        fi
    else
        echo "下載失敗"
        exit 1
    fi
}

# 網址有效(ex:200，不紀錄執行過程)，才開始下載檔案
HTTP_STATUS=$(curl --head --silent --write-out "%{HTTP_CODE}" --output /dev/null "$URL")
if [ "$HTTP_STATUS" -eq 200 ]; then
    # 到指定下載路徑(放置位置)
    cd $DOWNLOAD_PATH
    # 確認原始檔大小
    checkOrigin
    echo "URL連接成功，開始下載..."
    # 下載並更名
    download
 else
     echo "[$HTTP_STATUS]URL連接失敗，無法下載。" >> $LOG_FILE
 fi