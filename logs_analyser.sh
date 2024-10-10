#!/bin/bash
<< readme
this project for logs analyser
usage:

readme
usage(){

    echo "Usage: $0 /root/logs.log"
    exit 1
}
if [ $# -ne 1 ]; then
    usage
fi
LOG_FILE=$1

if [ ! -f "$LOG_FILE" ]; then
    echo "Error : log File $LOG_FILE not found"
    exit 1
fi

ERROR_KEYWORD="ERROR"
CRITICAL_KEYWORD="CRITICAL"
DATE=$(date +"%Y-%m-%d")
SUMMARY_REPORT="summary_report_$DATE.txt"
ARCHIVE_DIR="processed_logs"

{
       echo "date of analysis : $DATE"
    echo "log file name : $LOG_FILE"

} > "$SUMMARY_REPORT"

TOTTAL_LINES=$(wc -l < "$LOG_FILE")
echo "Total lines in log file : $TOTTAL_LINES" >> "$SUMMARY_REPORT"

ERROR_COUNT=$(grep -c "$ERROR_KEYWORD" "$LOG_FILE")
echo "Total ERROR count : $ERROR_COUNT" >> "$SUMMARY_REPORT"

echo "List of critical events with lline numbers: " >> "$SUMMARY_REPORT"
grep -n "$CRITICAL_KEYWORD" "$LOG_FILE" >> "$SUMMARY_REPORT"

declare -A error_message
while IFS= read -r line;
do
if [[ $line == *"$ERROR_KEYWORD"* ]]; then
    message=$(echo "$line" | awk -F"$ERROR_KEYWORD" '{print $2}')
    ((error_message["$message"]++))
fi
done < "$LOG_FILE"

echo "Top 5 error message with their occurence count : " >> "$SUMMARY_REPORT"
for message in "${!error_message[@]}";
do
        echo "${error_message[$message]} $message"

done | sort -rn | head -n 5 >> "$SUMMARY_REPORT"

if [ ! -d "$ARCHIVE_DIR" ]; then
    mkdir -p "$ARCHIVE_DIR"
fi

mv "$LOG_FILE" "$ARCHIVE_DIR/"

echo "LoG file has been moved to $ARCHIVE_DIR."

cat "$SUMMARY_REPORT"