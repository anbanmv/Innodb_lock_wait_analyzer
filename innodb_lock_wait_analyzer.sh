#!/bin/bash
## This script is designed to detect and pinpoint the SQL statements that are causing lock waits within the InnoDB storage engine.
## Author: Anban Malarvendan
## License: GNU GENERAL PUBLIC LICENSE Version 3 + 
##          Section 7: Redistribution/Reuse of this code is permitted under the 
##          GNU v3 license, as an additional term ALL code must carry the 
##          original Author(s) credit in comment form.


PAUSE=5
REPORT_DIR=/root/lockwait/

create_report_dir() {
    [ -d "$REPORT_DIR" ] || mkdir -p "$REPORT_DIR"
}

get_lock_wait_queries() {
    mysql -A -Bse 'SELECT THREAD_ID, EVENT_ID, EVENT_NAME, CURRENT_SCHEMA, SQL_TEXT FROM events_statements_history_long WHERE THREAD_ID IN (SELECT BLOCKING_THREAD_ID FROM data_lock_waits) ORDER BY EVENT_ID'
}

save_report() {
    local check_query="$1"
    local timestamp=$(date +%s)
    if [[ -n "$check_query" ]]; then
        echo "$check_query" > "$REPORT_DIR/innodb_lockwait_report_${timestamp}"
    fi
}

main() {
    create_report_dir

    while true; do
        check_query=$(get_lock_wait_queries)
        save_report "$check_query"

        sleep "$PAUSE"
    done
}

main
