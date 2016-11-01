#!/bin/bash
# skonci s chybou pri pouziti neinicializovane promenne
set -o nounset
# neuspech prikazu zpusobi neuspech pipeline
set -o pipefail
# skonci s chybou v pripade, ze nejaky neodchyceny prikaz skonci s chybou
#set -o errexit

readonly SCRIPTNAME=${0##*/}
readonly SCRIPTDIR=${0%/*}

# recursive a zachova: links permission and time
readonly rsync_parameters="-rlpt"

readonly TIMEFORMAT="%m-%d-%Y"
readonly DELIMITER="_"

readonly                  settings_dir="/etc/opt/rsync-machine"
readonly                  include_file="$settings_dir/include.txt"
readonly                  exclude_file="$settings_dir/exclude.txt"
readonly            current_count_file="$settings_dir/count"
readonly                 last_run_file="$settings_dir/last_run"
readonly         last_full_backup_file="$settings_dir/last_full_backup"
readonly    last_increment_backup_file="$settings_dir/last_increment_backup"

readonly                    backup_dir="/media/nas/vojta/tuxbook"
readonly                    dir_prefix="$HOSTNAME"
readonly                    target_dir="$backup_dir/$dir_prefix"

# count urcuje stav zaloh
# stavy:
#       0       pripraveno k archivaci
#       1       provadi se full backup
#       n       inkrementalni zaloha n-1
# tato vychozi hodnota bude prepsana
current_count=0
# increment count nastavuje pocet moznych stavu.
# !!! musi byt minimalne 2 !!! viz vyse mozne stavy !!!!!!!!!!!!!!!!!!!!
readonly               increment_count=14
readonly             full_backup_count=4

readonly USAGE="USAGE

    $SCRIPTNAME

    Provede zalohu souboru urcenych souborem include_file a vynecha
    soubory exclude_file do ciloveho adresare backup_dir.
    Provadi $increment_count krat inkrementalni zalohu a zachova $full_backup_count plne zalohy.

        include_file    $include_file
        exclude_file    $exclude_file
        backup_dir      $backup_dir
"

# obecne funkce ======================================
# hlasky ----------------------------------------
general_message() {
    echo "$SCRIPTNAME[$1]	$2" >&2
}

error_message() {
    general_message "err" "$*"
}

warning_message() {
    general_message "warn" "$*"
}

information_message() {
    general_message "info" "$*"
}

# kontroly --------------------------------------
is_readable_file() {
    local file=$1
    [ -f "$file" -a -r "$file" ]
}

is_writable_file() {
    local file=$1
    [ -f "$file" -a -w "$file" ]
}

is_writable_dir() {
    local dir=$1
    [ -d "$dir" -a -w "$dir" ]
}

# ====================================================

# funkce skriptu =====================================
# USAGE -----------------------------------------
# kontroluje pouziti skriptu
# 'exitable'
usage() {
    [ $# -eq 1 ] && {
        [ "$1" == "-h" -o "$1" == "--help" -o "$1" == "help" ] && {
            echo "$USAGE"
            exit 0
        }
    }

    [ $# -eq 0 ] || {
        echo "$USAGE" >&2
        exit 1
    }
}
# -----------------------------------------------

# files -----------------------------------------
# kontroluje opravneni backup_dir
check_backup_dir() {
    local dir=$backup_dir
    is_writable_dir "$dir" || {
        error_message "Adresar '$dir' neexistuje nebo neni zapisovatelny."
        exit 2
    }
}

# zkontroluje, zda je soubor $1 obycejny a citelny
# 'exitable'
check_readable_file() {
    local file=$1
    is_readable_file "$file" || {
        error_message "Soubor '$file' neexistuje ci neni citelny."
        exit 2
    }
}

# zkontroluje zapisovatelnost obycejneho souboru current_count_file
# 'exitable'
check_current_count_file() {
    local file=$current_count_file

    # pokud current_count_file neexistuje, vytvori ho s nulou
    is_readable_file "$file" || {
        echo 0 > "$file" 2>/dev/null
    }
    is_writable_file "$file" || {
        error_message "Soubor '$file' neni zapisovatelny."
        exit 2
    }

}

# kontroluje opravneni vstupnich souboru
# 'exitable'
check_files() {
    check_backup_dir
    check_readable_file "$include_file"
    check_readable_file "$exclude_file"
    check_current_count_file
}

# kontroluje a pripadne nastavi -- dle increment_count -- current_count
# 'exitable'
load_current_count() {
    local    file=$current_count_file
    # globalni current_count
    current_count=$( cat "$file" )

    [[ "$current_count" =~ ^[0-9]+$ ]] || {
        error_message "Hodnota '$current_count' v souboru '$current_count_file' neni celociselna."
        exit 3
    }

    # vynulovani v pripade dostatecneho poctu inkrementalnich zaloh
    [ "$current_count" -ge "$increment_count" ] \
        && current_count=0

}

# zapise current_count + 1 do current_count_file
# 'exitable'
write_current_count() {
    echo $(( ( current_count + 1) % increment_count )) > "$current_count_file" 2>/dev/null || {
        error_message "Nelze zapsat cislo zalohy do souboru '$current_count_file'."
        exit 2
    }
}

# zapise cas aktualni zalohy target_dir do souboru $1
write_timestamp_to_file() {
    local file=$1
    local time=$( date )

    echo "$time" > "$file" 2>/dev/null || {
        warning_message "Nelze zapsat timestamp do souboru '$file'."
    }
}

write_run_timestamp() {
    write_timestamp_to_file "$last_run_file"
}

write_full_backup_timestamp() {
    write_timestamp_to_file "$last_full_backup_file"
}

write_increment_backup_timestamp() {
    write_timestamp_to_file "$last_increment_backup_file"
}

# vrati prvni neexistujici mozne jmeno souboru '$1' s pripadnou prirazenou cislovkou
available_file_name() {
    local file=$1
    local list=""
    local    n=1
    if ! [ -e "$file" ]; then
        echo "$file"
        return 0
    else
        list=$( ls "$file"_* 2>/dev/null )
        # nejvetsi cislo z posledniho sloupce dle _
        n=$( echo "$list" \
                | awk -F "_" 'BEGIN { max=0 }; $NF > max { max=$NF }; END { print max }')
        echo "${file}_$((n+1))"
    fi
}

# archivuje aktualni zalohu (dir_prefix), pokud existuje
# 'exitable'
archive_old_backup() {
    local dir=$target_dir
    local dir_new=""

    [ -d "$dir" ] && {
        local     mtime=$( stat -c '%Y' "$dir" )
        local timestamp=$( date -d "@$mtime" "+$TIMEFORMAT" )

        # vytvoreni noveho jmena
        dir_new=$( available_file_name "${dir}${DELIMITER}${timestamp}"  )
        if mv "$dir" "$dir_new"; then
            information_message "Adresar '$dir' archivovan."
        else
            error_message "Nelze archivovat adresar '$dir'."
            exit 4
        fi
    }
}

remove_old_backup() {
    local dir=""

    # vypise adresare s delimiterem
    #   a pote vyfiltruje 'full_backup_count-1' archivovanych zaloh
    ls -dt "${backup_dir}/${dir_prefix}${DELIMITER}"* 2> /dev/null \
        | tail -n +"$full_backup_count" \
        | while read dir; do
            rm -rf "$dir" || {
                warning_message "Nelze odstranit starou zalohu '$dir'"
            }
        done
}

do_rsync() {
    local file=""
    local ret_val=0
    while read file; do
        rsync "$rsync_parameters" --exclude-from="$exclude_file" "$file" "$target_dir" || {
            warning_message "Zaloha pro soubor '$file' skoncila s chybou"
            ret_val=1
        }
    done < "$include_file"
    return "$ret_val"
}

# -----------------------------------------------

# main ------------------------------------------
main() {
    usage "$@"
    write_run_timestamp
    check_files
    load_current_count

    # pokud je current_count 0, vytvari se plna zaloha -- archivuje
    [ "$current_count" -eq 0 ] && {
        archive_old_backup
        # je nutne hned zmenit current count v souboru, jinak by po selhani
        #    teto iterace znovu doslo k archivaci
        write_current_count
        # nastavi count na 1 -- provadi se full backup
        count=1
    }

    # vytvori adresar pro zalohu, bude-li treba
    mkdir -p "$target_dir" || {
        error_message "Nelze vytvorit adresar pro zalohu '$dir'."
        exit 5
    }

    do_rsync && {
        write_current_count

        # pokud je current_count 1, provedla se uspesne prvni full backup
        if [ "$current_count" -eq 1 ]; then
            write_full_backup_timestamp
            remove_old_backup
        else
            write_increment_backup_timestamp
        fi
    }
}
# -----------------------------------------------

# ====================================================

main "$@"
