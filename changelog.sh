#!/bin/bash
# Generate a changelog from git history

out=""

while getopts "o:" opt; do 
    case "$opt" in 
        o) out="$OPTARG" ;;
        *) echo "Usage: bash changelog.sh [-o file] [repo]"; exit 1 ;;
    esac 
done 
shift $((OPTIND - 1))

repo="${1:-.}"

if ! git -C "$repo" rev-parse HEAD > /dev/null 2>&1; then 
    echo "Error: '$repo' is not a git repository with commits"
    exit 1
fi 

sections=(Added Changed Fixed Removed Documentation Maintenance Other)
conv_re='^([A-Za-z]+)(\([^)]*\))?!?:[[:space:]]*(.*)$'

section=""
message=""

classify() {
    local subject="$1" word

    if [[ "$subject" =~ $conv_re ]]; then 
        word="${BASH_REMATCH[1],,}"
        message="${BASH_REMATCH[3]}"
    else 
        word="${subject%% *}"
        word="${word,,}"
        message="$subject"
    fi 

    case "$word" in 
        feat|add|added|create|implement)                             section="Added" ;;
        fix|fixed|bugfix|hotfix)                                     section="Fixed" ;;
        update|updated|change|changed|refactor|improve|perf|style)   section="Changed" ;;
        remove|removed|delete)                                       section="Removed" ;;
        docs|doc)                                                    section="Documentation" ;;
        test|tests|chore|build|ci)                                   section="Maintenance" ;;
        *)                                                           section="Other" ;;
    esac 
}

emit_release() {
    local title="$1" range="$2" hash subject line s count=0
    local -A entries=()

    while IFS=$'\t' read -r hash subject; do 
        [ -z "$hash" ] && continue 
        classify "$subject"
        printf -v line -- '- %s ('%s')\n' "$message" "$hash"
        entries["$section"]+="$line"
        count=$((count + 1))
    done < <(git -C "$repo" log --no-merges --format='%h%x09%s' "$range")

    [ "$count" -eq 0 ] && return 

    echo "## $title"
    echo 
    for s in "${sections[@]}"; do 
        if [ -n "${entries[$s]}" ]; then 
            echo "### $s"
            printf '%s\n' "${entries[$s]}"
        fi 
    done 
}

generate() {
    local tags i newer older date
    mapfile -t tags < <(git -C "$repo" tag --sort=-version:refname)

    echo "# Changelog"
    echo 

    if [ "${#tags[@]}" -eq 0 ]; then 
        emit_release "Unreleased" "HEAD"
        return 
    fi 

    emit_release "Unreleased" "${tags[0]}..HEAD"

    for i in "${!tags[@]}"; do 
        newer="${tags[$i]}"
        older="${tags[$((i + 1))]}"
        date=$(git -C "$repo" log -1 --format=%ad --date=short "$newer")

        if [ -n "$older" ]; then 
            emit_release "$newer - $date" "$older..$older"
        else 
            emit_release "$newer - $date" "$newer"
        fi 
    done 
}

if [ -n "$out" ]; then 
    generate > "$out"
    echo "Created $out"
else 
    generate 
fi 