#!/bin/bash
#Program:
#import image restore table
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
DataBase="testDB"
ListTablesFile=""
path=/your_db2_path/testDB/
dataPath=${path}data
logPath=${path}log
backuppath=${path}backup
today=`date "+%Y%m%d"`
year=$(date +"%Y" -d "last year")
tableName="IMAGE"
restoreTable="IMAGECOPY"

# 連接資料庫指令的方法
function dbconnect(){
	db2 connect to ${DataBase}
}

# 斷開資料庫連接的方法
function dbdisconnect(){
	db2 connect reset
}

function createTable(){
  db2 drop table ${restoreTable}
  if [ $? -eq 0 ]; then
    db2 create table ${restoreTable}\( UUID VARCHAR\(36\) not null,IMAGE BLOB\(20971520\) not null,SIZE INTEGER,CATEGORY VARCHAR\(50\) not null,primary key \(UUID, KIND\)\)
      if [ $? -eq 0 ]; then
        echo "建立 $restoreTable 成功"
      fi
  fi
 
}

function importTable(){
  # for ((i=1;i<=12;i++)); do
  # 0~9前面補0
  month=$(printf "%02d" $i)
  importFile=${dataPath}/${DataBase}_${tableName}_${year}_${month}.csv
  logFile=$logPath/${DataBase}_${tableName}_${year}_${month}_import.log
    # db2 "IMPORT FROM ${importFile} OF DEL LOBS FROM ${dataPath}/ MODIFIED BY LOBSINFILE  messages $logFile INSERT INTO IMAGECOPY"

    # 資料大的情況會比import指令快
    # db2 "LOAD FROM ${importFile} OF DEL LOBS FROM ${dataPath}/ MODIFIED BY LOBSINFILE  messages $logFile INSERT INTO ${restoreTable}"
    db2 "LOAD FROM ${dataPath}/${DataBase}_${tableName}_${year}_01.csv OF DEL LOBS FROM ${dataPath}/ MODIFIED BY LOBSINFILE  messages $logFile INSERT INTO ${restoreTable}"

    echo "***************************${today}*****************************" >> $logFile
		echo "Table: ${tableName} , 資料年份: ${year}, 資料月份: ${month}" >> $logFile
		echo -e "\n" >> $logFile
  # done
}

# 檢查用戶和執行備份的shell檔
user=`whoami`
# 首先檢查當前執行此腳本的使用者是否為 root。如果是 root，則切換至 instance 並執行備份腳本。
if [ "$user" == "root" ]; then
  #注意跑的shell Name
  su ${instance} ${path}importImage.sh
fi
# 如果是instance，則進行備份操作
if [ "$user" == ${instance} ]; then
  echo StartTime : `date +"%Y-%m-%d %H:%M:%S"`
  cd ${path}
  #設定DataBase
 # 依次對資料庫 testDB 進行備份操作:
  for database in "testDB"
  do 
  # 連接資料庫
	dbconnect

  # 刪除並建立table
  # createTable

  # 還原table
  importTable

  # 斷開連接
	dbdisconnect
  done

   echo EndTime : `date +"%Y-%m-%d %H:%M:%S"`
fi