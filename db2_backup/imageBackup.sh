#!/bin/bash
#Program:
#export db table IMAGE for previous year
#History:
#2024/09/25 QuL

#設定db2環境變數
export PATH=$PATH:/your_db2_path/sqllib/bin

# 如果db2profile檔案存在，則作為環境設定檔案載入
if [ -f /your_db2_path/sqllib/db2profile ]; then
        . /your_db2_path/sqllib/db2profile
fi

#參數設定
instance=your_db2_instance
DataBaseShema=your_db2_instance
DataBase=""
ListTablesFile=""
path=/your_db_path/testDB/
dataPath=${path}data
logPath=${path}log
backuppath=${path}backup
today=`date "+%Y%m%d"`
# 取得去年的年份
year=$(date +"%Y" -d "last year") 
# lob切成10份
lobfileNo=10

# 設定當前資料庫名稱，生成與該資料庫對應的檔案名稱
function SetDataBase(){
	DataBase=$1
	ListTablesFile=${DataBase}_ListTables.txt
}

# 連接資料庫指令的方法
function dbconnect(){
	db2 connect to ${DataBase}
}

# 斷開資料庫連接的方法
function dbdisconnect(){
	db2 connect reset
}

# 備份方法，根據去年的每個月進行備份
function Backup(){
	# 列出所有table， 結果複寫寫入ListTablesFile
	db2 list tables > ${ListTablesFile}
	tableName="IMAGE"
	#判斷是否有BLOB格式
	db2 describe table ${tableName}|awk '{print $3}'|grep -q BLOB
	# 上一行指令成功，才執行
	if [ $? -eq 0 ]; then
		# 圖片檔拆成1-12月備份，一個月再拆成10份檔案(因圖片檔較大)
		for month in {01..12}
		do
			start_date=`date -d "${year}-${month}-01" "+%Y-%m-%d"`
			end_date=`date -d "${start_date} +1 month -1 day" "+%Y-%m-%d"`
			backupFile=${dataPath}/${DataBase}_${tableName}_${year}_${month}.csv
			lobFilePath=""
			for ((i=1;i<=${lobfileNo};i++))
			do
				lobFilePath=${lobFilePath},${dataPath}
			done
		logFile=${logPath}/${DataBase}_${tableName}_${year}_${month}.log
		echo "${tableName}: "
		echo "開始日期: $start_date 結束日期: $end_date"
		# 執行DB2匯出指令，備份一整年的資料
		db2 -m "export to $backupFile of del lobs to ${lobFilePath:1} lobfile ${DataBase}_${tableName}_${year}_${month} modified by lobsinfile messages ${logPath}/${DataBase}_${tableName}_${year}_${month}.log SELECT image.uuid, image.image, image.size, image.category FROM ${DataBaseShema}.${tableName} JOIN ${DataBaseShema}.CASE ON ${tableName}.UUID = CASE.UUID WHERE CREATEDATE BETWEEN '$start_date' AND '$end_date'"
		# 寫log
		echo "***************************${today}*****************************" >> $logFile
		echo "Table: ${tableName} , 資料年份: ${year}, 資料月份: ${month}" >> $logFile
		echo -e "\n" >> $logFile
		done
	fi
}

# 檢查用戶
user=`whoami`

# 首先檢查當前執行此腳本的使用者是否為 root。如果是 root，則切換至 instance 並執行備份腳本。
if [ "$user" == "root" ]; then
  su ${instance} ${path}imageBackup.sh
fi

# 如果是instance，則進行備份操作
if [ "$user" == ${instance} ]; then
  echo "StartTime : `date +"%Y-%m-%d %H:%M:%S"`"
  cd ${path}

  # 設定DataBase，依次對資料庫 testDB 進行備份操作
  for database in "testDB"
  do 
	SetDataBase ${database} # 這個未來可以再寫個sql指令備份整個DB
	dbconnect
	Backup
	dbdisconnect
  done

  echo "EndTime : `date +"%Y-%m-%d %H:%M:%S"`"
fi