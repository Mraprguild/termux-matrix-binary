#!/data/data/com.termux/files/usr/bin/bash

# Termux Matrix Binary Rain
# Author: Mraprguild

set -u

ALT_SCREEN=1
SPEED="${MATRIX_SPEED:-0.045}"
DENSITY="${MATRIX_DENSITY:-2}"
DIRECTION="${MATRIX_DIRECTION:-up}"
SHOW_TITLE="${MATRIX_SHOW_TITLE:-1}"

cleanup() {
    printf '\033[0m\033[?25h'
    if [[ "$ALT_SCREEN" == "1" ]]; then
        printf '\033[?1049l'
    fi
    exit 0
}

resize() {
    COLS=$(tput cols 2>/dev/null || echo 80)
    ROWS=$(tput lines 2>/dev/null || echo 24)
    (( COLS < 10 )) && COLS=10
    (( ROWS < 5 )) && ROWS=5
    STREAM_COUNT=$((COLS / DENSITY))

    stream_y=()
    stream_speed=()
    stream_length=()

    for ((i=0; i<STREAM_COUNT; i++)); do
        stream_y[$i]=$((RANDOM % ROWS + 1))
        stream_speed[$i]=$((RANDOM % 3 + 1))
        stream_length[$i]=$((RANDOM % 14 + 6))
    done
}

trap cleanup INT TERM EXIT
trap resize WINCH

printf '\033[?1049h\033[?25l\033[2J\033[H'
resize

while true; do
    for ((i=0; i<STREAM_COUNT; i++)); do
        x=$((i * DENSITY + 1))
        y=${stream_y[$i]}
        speed=${stream_speed[$i]}
        length=${stream_length[$i]}

        for ((j=0; j<length; j++)); do
            if [[ "$DIRECTION" == "down" ]]; then
                draw_y=$((y - j))
            else
                draw_y=$((y + j))
            fi

            while ((draw_y > ROWS)); do draw_y=$((draw_y - ROWS)); done
            while ((draw_y < 1)); do draw_y=$((draw_y + ROWS)); done

            bit=$((RANDOM % 2))

            if ((j == 0)); then
                printf '\033[%d;%dH\033[1;97m%d' "$draw_y" "$x" "$bit"
            elif ((j < 3)); then
                printf '\033[%d;%dH\033[1;92m%d' "$draw_y" "$x" "$bit"
            else
                printf '\033[%d;%dH\033[0;32m%d' "$draw_y" "$x" "$bit"
            fi
        done

        if [[ "$DIRECTION" == "down" ]]; then
            erase_y=$((y - length - 1))
        else
            erase_y=$((y + length + 1))
        fi

        while ((erase_y > ROWS)); do erase_y=$((erase_y - ROWS)); done
        while ((erase_y < 1)); do erase_y=$((erase_y + ROWS)); done
        printf '\033[%d;%dH ' "$erase_y" "$x"

        if ((RANDOM % speed == 0)); then
            if [[ "$DIRECTION" == "down" ]]; then
                stream_y[$i]=$((y + 1))
            else
                stream_y[$i]=$((y - 1))
            fi
        fi

        if ((stream_y[$i] < 1)); then
            stream_y[$i]=$ROWS
            stream_speed[$i]=$((RANDOM % 3 + 1))
            stream_length[$i]=$((RANDOM % 14 + 6))
        elif ((stream_y[$i] > ROWS)); then
            stream_y[$i]=1
            stream_speed[$i]=$((RANDOM % 3 + 1))
            stream_length[$i]=$((RANDOM % 14 + 6))
        fi
    done

    if [[ "$SHOW_TITLE" == "1" && $ROWS -gt 7 ]]; then
        title=' MRAPRGUILD MATRIX '
        tx=$(((COLS - ${#title}) / 2))
        ((tx < 1)) && tx=1
        printf '\033[%d;%dH\033[1;32m%s' 2 "$tx" "$title"
    fi

    sleep "$SPEED"
done
