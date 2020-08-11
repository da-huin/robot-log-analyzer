#!/bin/bash
# 매개변수 및 사용할 변수 선언

mkdir -p data

base_log_path=""

# base_log_path="/home/pwc/CodeIgniter/application/logs"
# log_filename_suffix="-application-development.log"
log_filename_suffix=""
empty=""

arg_filename=""
arg_search=""
arg_time="00-23"
# log / stat
arg_type="stat"
# asce, desc
arg_sort="asce"
# 0, 1
arg_quiet="0"
arg_short="0"
arg_current="0"
arg_log_type="error"
arg_help="0"




function get_log_piece(){
	inner_process_log="$1"
	regex="$2"
	
	process_log_length=`expr length "$inner_process_log"`
	value=`echo $inner_process_log | grep -o -P "$regex" | head -1`
	echo $value
}

function get_process_log(){
	inner_process_log="$1"
	value="$2"
	add_sub_length="$3"
	process_log_length=`expr length "$inner_process_log"`	

	sub_length=`expr length "$value"`
	sub_length=`expr $sub_length + $add_sub_length`
	inner_process_log=`expr substr "$inner_process_log" "$sub_length" "$process_log_length"`

	echo $inner_process_log
}

function removebracket(){
	str=$1
	str_length=`expr length "$str"`
	str_length=`expr $str_length - 2`

	result=`expr substr "$str" 2 "$str_length"`
	echo $result
}

function get_name_from_log(){
    process_log=$1

    count=`get_log_piece "$process_log" "\d+ "`
    process_log=`get_process_log "$process_log" "$count" 1`
    time=`get_log_piece "$process_log" "\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]"`
    process_log=`get_process_log "$process_log" "$time" 1`
    kind=`get_log_piece "$process_log" "\[.+?\]"`
    process_log=`get_process_log "$process_log" "$kind" 1`
    type=`get_log_piece "$process_log" "\[.+?\]"`
    process_log=`get_process_log "$process_log" "$type" 2`
    name=$process_log

    echo $name
}



# -


# 사용자 매개변수를 받아서 shell의 변수에 입력한다.
i=0
before_arg=0

for arg in "$@";do
    if [[ $i == 0 ]]; then
        arg_filename="$arg"	
    fi
    next_i=`expr $i + 1`
    
    # 이전 매개변수가 a 일 때 현재 매개변수 입력
    case $before_arg in
        "-n") arg_search="$arg" ;;
        "-p") arg_type="$arg" ;;
        "-H") arg_time="$arg" ;;
        "-l") arg_log_type="$arg" ;;
        
    esac


    # 현재 매개변수가 존재 할 때 자동 입력
	case $arg in
        "-q") arg_quiet="1" ;;
        "-d") arg_sort="desc" ;;
        "-s") arg_short="1" ;;
        "-c") arg_current="1" ;;
        "-h") arg_help="1" ;;   
           
	esac

    ((i++))
	before_arg=$arg

done


# Help가 존재 할 때 help 메세지 출력
IFS=""
if [[ $arg_help == "1" ]]; then
help_message=$(cat <<EOF

============================== ROBOT LOG ANALYSIS ============================== 

Email:
  dahuin000@gmail.com

Usage: 
        
  robot_log_analysis [log_file_name] [options]
  robot_log_analysis -c [options]
  robot_log_analysis [log_date] -s [options]
           
Arguments:

  * no additional parameters required
  -c        Specify the file name as the current date(No file name required).
  -d        Sort in reverse order.
  -h        Print Help and exit.  
  -q        Do not print the result.
  
  * additional parameters required  
  -s        Specify the file name as the date (example: -s 190531).
  -n        Search by string.
  -H        Filter by start hour and end hour (example: 05-09).    
  -p        Set the log print type. ('log' or 'stat').
  -l        Set the log type. ('error' or 'warning').    

================================================================================
EOF
)
    echo $help_message
    exit
fi

IFS=$'\n'


# short 옵션이 있을 때 날짜 + suffix로 파일명 입력
if [[ $arg_short == "1" ]]; then
    arg_filename="$arg_filename$log_filename_suffix"
fi


# current 옵션이 있을 때 현재 날짜로 파일명 입력
if [[ $arg_current == "1" ]]; then
    ymd=`date +%y%m%d`
    arg_filename="$ymd$log_filename_suffix"
fi

# 아무 옵션이 없을 때 현재 날짜로 파일명 입력
if [[ $arg_filename == "" && $arg_current == "0" ]]; then
    ymd=`date +%y%m%d`
    arg_filename="$ymd$log_filename_suffix"
#    echo "filename is not exists"
#    exit
fi



#기본 경로 + 파일명으로 파일경로 입력, 기본경로를 사용하지 않을 옵션도 넣어야 할 듯
# arg_filename=$base_log_path/$arg_filename


# 날짜에서 시작날짜, 종료날짜 분리
start_hour="${arg_time:0:2}"
end_hour="${arg_time:3}"


# 사용자가 입력한 값 프린트
echo "================================================"
echo "FILENAME: $arg_filename"
echo "SEARCH: $arg_search"
echo "TIME: $arg_time"
echo "START_HOUR: $start_hour"
echo "END_HOUR: $end_hour"
echo "TYPE: $arg_type"
echo "SORT: $arg_sort"
echo "QUIET: $arg_quiet"
echo "CURRENT: $arg_current"
echo "SHORT: $arg_short"
echo "LOG_TYPE: $arg_log_type"
echo "================================================"


# 정규식에서 arg_log_type으로 찾기 때문에 대문자로 변경
# arg_log_type 필터
if [[ $arg_log_type == "error" ]]; then
    arg_log_type="ERROR"

elif [[ $arg_log_type == "warning" ]]; then
    arg_log_type="WARNING"
else
    echo "[ERROR] log type is not error or warning"
    exit
fi


# 시작시간, 종료시간 필터
if [[ $start_hour > 23 || $start_hour < 0 ]]; then
    echo "[ERROR] Start time is not between 00 and 23."
    exit
fi

if [[ $end_hour > 23 || $end_hour < 0 ]]; then
    echo "[ERROR] End time is not between 00 and 23."
    exit
fi

# 파일이 존재하는지 확인
if [[ -f "$arg_filename" ]]; then
    echo "[INFO] file is exists"
else
    echo "[ERROR] file is not exists($arg_filename)"
    exit
fi


# 입력받은 파일에서 arg_log_type에 따른 로그 분리
echo "[INFO] seperating"
grep -o -P "^\[[^\]]+\] \[[^\]]+\]\[$arg_log_type\](.*?\t)" $arg_filename > ./data/error_log.data


# 검색 옵션이 있을 경우 검색어를 찾는다.
if [[ $arg_search != "" ]]; then
    echo "[INFO] find by $arg_search"
	grep -P ".*\[$arg_log_type\].*$arg_search.*" ./data/error_log.data > ./data/temp_error_log.data
    mv ./data/temp_error_log.data ./data/error_log.data
fi


# 정렬 옵션이 desc일 경우 역순 정렬
# tac는 cat의 역순
echo "[INFO] SORTING BY $arg_sort"
if [[ $arg_sort == "desc" ]]; then

    tac ./data/error_log.data > ./data/temp_error_log.data
    mv ./data/temp_error_log.data ./data/error_log.data

fi

# 시간에 따라 분리한다.
# 빈 임시로그 파일을 생성한다.
$empty > ./data/temp_error_log.data
counts=[]


echo "[INFO] FILTER BY TIME $start_hour ~ $end_hour"
for i in $(seq -f "%02g" $start_hour $end_hour)
do

IFS=$'\n'
    # 현재HOUR로 grep (log용)
	grep -P "\[\d{4}-\d{2}-\d{2} $i:\d{2}:\d{2}\]" ./data/error_log.data >> ./data/temp_error_log.data
	
	
    $empty > "./data/hour_$i.data"
    
    # error_log에서 현재 HOUR 로 grep 후 정렬을 위해 시간 값은 버리고 hour_$i.data에 입력한다. (stat용)
    read_logs=`grep -P "\[\d{4}-\d{2}-\d{2} $i:\d{2}:\d{2}\]" ./data/error_log.data`
    for log_piece in ${read_logs[@]}
    do
        echo ${log_piece:22} >> "./data/hour_$i.data"
    done

IFS=""

done

mv ./data/temp_error_log.data ./data/error_log.data

# 통계 문자열을 만든다.
statistics_string=""

echo "[INFO] CREATE STATISTICS"
IFS=$'\n'
for i in $(seq -f "%02g" $start_hour $end_hour)
do

    # desc일 경우 역순 정렬
    # uniq는 인접한 문장끼리 uniq되기 때문에 정렬을 먼저 시켜줘야 한다.
    if [[ $arg_sort == "desc" ]];then
        uniq_result=`cat "./data/hour_$i.data" | sort | uniq -c | sort -r`
    else
        uniq_result=`cat "./data/hour_$i.data" | sort | uniq -c | sort`
    fi


    statistics_log_string=""
    log_exists=0
    for log_piece in ${uniq_result[@]}; do
        count=`echo "$log_piece" | grep -o -P "\d+" | head -1`
        statistics_log_string+="$log_piece"$'\n'
        log_exists=1
    done
    
    if [[ $log_exists == 1 ]];then
        statistics_string+="[ HOUR $i ]"$'\n'
        statistics_string+=$statistics_log_string
        statistics_string+=$'\n'
        
#    else

#           statistics_string+="[ HOUR $i ] log is not exists."$'\n\n'
    fi
 
done
IFS=""


# print type에 따라 결과값 표출
echo $statistics_string > ./data/statistics.data
echo "[INFO] file created: error_log.data, statistics.data"
echo "[INFO] COMPLETE"
if [[ $arg_quiet == 0 ]]; then

    if [[ $arg_type == "stat" ]];then
        echo $statistics_string
    elif [[ $arg_type == "log" ]];then
        cat ./data/error_log.data
    else
        echo $'\n'"=========================== LOG ==========================="$'\n'
        
        cat ./data/error_log.data
        echo $'\n'"=========================== STATISTICS ==========================="$'\n'
        echo $statistics_string
    fi
fi

