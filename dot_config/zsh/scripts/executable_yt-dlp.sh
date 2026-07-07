#!/usr/bin/env bash

RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'

time_to_seconds() {
    local t="$1"
    if [[ "$t" == "inf" ]]; then
        echo 999999999
        return
    fi
    local sign=1
    if [[ "$t" == -* ]]; then
        sign=-1
        t="${t#-}"
    fi
    if [[ "$t" =~ ^[0-9]+$ ]]; then
        echo $(( sign * t ))
        return
    fi
    IFS=: read -ra parts <<< "$t"
    local secs=0
    local n=${#parts[@]}
    if [ $n -eq 3 ]; then
        secs=$(( ${parts[0]}*3600 + ${parts[1]}*60 + ${parts[2]} ))
    elif [ $n -eq 2 ]; then
        secs=$(( ${parts[0]}*60 + ${parts[1]} ))
    else
        secs=0
    fi
    echo $(( sign * secs ))
}

is_valid_time_format() {
    local t="$1"
    if [[ "$t" == "inf" || "$t" =~ ^-?[0-9]+$ || "$t" =~ ^-?[0-9]+(:[0-9]+)+$ ]]; then
        return 0
    fi
    return 1
}

validate_merge_format() {
    local fmt="$1"
    local allowed="avi flv mkv mov mp4 webm"
    for a in $allowed; do
        if [[ "$fmt" == "$a" ]]; then
            return 0
        fi
    done
    return 1
}

colored_read() {
    local prompt="$1"
    local default="$2"
    local val
    if [ -n "$default" ]; then
        echo -e "${prompt} ${YELLOW}(current: $default)${RESET}" >&2
        read -p "New value (empty = keep): " val
        if [ -z "$val" ]; then
            val="$default"
        fi
    else
        echo -e "$prompt" >&2
        read -p "> " val
    fi
    echo "$val"
}

# Helper for cookies selection (1-3 presets or direct custom value)
select_cookies() {
    # If current cookies looks like an old choice number, upgrade it to value
    case "$cookies" in
        1) cookies="firefox:~/.config/librewolf/librewolf" ;;
        2) cookies="firefox" ;;
        3) cookies="chrome" ;;
    esac

    echo -e "\n${MAGENTA}Browser cookies:${RESET}"
    echo "  1) Librewolf  (firefox:~/.config/librewolf/librewolf)"
    echo "  2) Firefox    (firefox)"
    echo "  3) Chrome     (chrome)"
    echo "  (or type a full custom value directly, e.g. firefox:Profile 1)"
    echo "  (empty = none / keep current)"

    local prompt="Select 1-3 or enter custom"
    if [ -n "$cookies" ]; then
        echo -e "${BLUE}${prompt}:${RESET} ${YELLOW}(current: $cookies)${RESET}" >&2
    else
        echo -e "${BLUE}${prompt}:${RESET}" >&2
    fi

    local cinput
    read -r cinput

    if [ -n "$cinput" ]; then
        case "$cinput" in
            1) cookies="firefox:~/.config/librewolf/librewolf" ;;
            2) cookies="firefox" ;;
            3) cookies="chrome" ;;
            0|none|clear)
                cookies=""
                ;;
            *)
                # anything else is treated as a full custom cookies value
                cookies="$cinput"
                ;;
        esac
    fi
}

collect_inputs() {
    url=$(colored_read "${BLUE}Enter video URL:${RESET}" "$url")

    select_cookies

    echo -e "\n${MAGENTA}Clip / Download sections:${RESET}"
    echo "Use *START-END  (e.g. *0:21-1:27 or *83-296)"
    echo "End can be 'inf' for to the end. Negative = from end of video."
    echo "*from-url also supported to use times from video URL."
    echo "Leave start/end empty to download full video."
    start_time=$(colored_read "${BLUE}Start time (e.g. 0:21 or 83, empty=skip):${RESET}" "$start_time")
    end_time=$(colored_read "${BLUE}End time (e.g. 1:27 or inf, empty=skip):${RESET}" "$end_time")

    if [ -n "$start_time" ] || [ -n "$end_time" ]; then
        if [ -n "$start_time" ] && ! is_valid_time_format "$start_time"; then
            echo -e "${RED}Invalid start time format. Use number, MM:SS or HH:MM:SS${RESET}"
            start_time=""
        fi
        if [ -n "$end_time" ] && ! is_valid_time_format "$end_time"; then
            echo -e "${RED}Invalid end time format. Use number, MM:SS, HH:MM:SS or inf${RESET}"
            end_time=""
        fi
        if [ -n "$start_time" ] && [ -n "$end_time" ]; then
            ssec=$(time_to_seconds "$start_time")
            esec=$(time_to_seconds "$end_time")
            if [ "$ssec" -ge "$esec" ]; then
                echo -e "${RED}Start time must be strictly before end time.${RESET}"
                start_time=""
                end_time=""
            fi
        fi
    fi

    echo -e "\n${MAGENTA}Format selection:${RESET}"
    echo "Common presets:"
    echo "1) Best video+audio merged (bv+ba/b)"
    echo "2) Best MP4 video + best m4a audio"
    echo "3) Best video (any) + best audio (bv*+ba/b)"
    echo "4) Best video only + best audio only (separate files, no merge)"
    echo "5) Custom full -f string (advanced)"
    echo "6) Audio only as MP3 (bestaudio/best + extract to mp3)"
    format_choice=$(colored_read "${BLUE}Choose 1-6 or enter custom -f value directly:${RESET}" "$format_choice")

    mp3_only=""
    case "$format_choice" in
        1) format_selector='bv+ba/b' ;;
        2) format_selector='bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]' ;;
        3) format_selector='bv*+ba/b' ;;
        4) format_selector='bv,ba' ;;
        5) 
            echo "Examples:"
            echo '  bv+ba/b'
            echo '  bestvideo[ext=mp4]+bestaudio[ext=m4a]/best'
            echo '  bv[height<=720]+ba'
            echo '  ba[ext=m4a]/b'
            custom_f=$(colored_read "${BLUE}Enter full -f string:${RESET}" "")
            format_selector="$custom_f"
            ;;
        6)
            format_selector='bestaudio/best'
            mp3_only="yes"
            ;;
        *) 
            if [ -n "$format_choice" ]; then
                format_selector="$format_choice"
            else
                format_selector=""
            fi
            ;;
    esac

    if [ "$mp3_only" = "yes" ]; then
        echo -e "\n${YELLOW}MP3 audio only selected — merge format is not applicable.${RESET}"
        merge_format=""
    else
        echo -e "\n${MAGENTA}Merge output format:${RESET}"
        echo "Supported containers: avi, flv, mkv, mov, mp4, webm"
        echo "Ignored if no merge is needed (single format or separate files)."
        echo "Requires ffmpeg for merging."
        merge_format=$(colored_read "${BLUE}Merge format (e.g. mp4 or mkv, empty=skip):${RESET}" "$merge_format")

        if [ -n "$merge_format" ] && ! validate_merge_format "$merge_format"; then
            echo -e "${RED}Invalid merge format. Allowed: avi flv mkv mov mp4 webm${RESET}"
            merge_format=""
        fi
    fi

    echo -e "\n${MAGENTA}Extra option:${RESET}"
    force_key=$(colored_read "${BLUE}Add --force-keyframes-at-cuts for exact cuts? (y/n):${RESET}" "$force_key")
    if [[ "$force_key" =~ ^[Yy] ]]; then
        force_key="y"
        force="--force-keyframes-at-cuts"
    else
        force_key="n"
        force=""
    fi
}

build_command() {
    cmd_args=()
    [ -n "$cookies" ] && cmd_args+=("--cookies-from-browser" "$cookies")
    
    if [ -n "$start_time" ] || [ -n "$end_time" ]; then
        section="*${start_time}-${end_time}"
        cmd_args+=("--download-sections" "$section")
    fi
    
    if [ -n "$format_selector" ]; then
        cmd_args+=("-f" "$format_selector")
    fi
    
    if [ "$mp3_only" = "yes" ]; then
        cmd_args+=(--extract-audio --audio-format mp3)
    elif [ -n "$merge_format" ]; then
        cmd_args+=("--merge-output-format" "$merge_format")
    fi
    
    [ -n "$force" ] && cmd_args+=("$force")
    
    [ -n "$url" ] && cmd_args+=("$url")
}

review_and_confirm() {
    while true; do
        echo -e "\n${GREEN}${BOLD}Current Settings${RESET}"
        echo -e "${BLUE}URL:${RESET}          ${url:-<not set>}"
        echo -e "${BLUE}Cookies:${RESET}      ${cookies:-<none>}"
        echo -e "${BLUE}Start time:${RESET}   ${start_time:-<full video>}"
        echo -e "${BLUE}End time:${RESET}     ${end_time:-<full video>}"
        if [ "$mp3_only" = "yes" ]; then
            echo -e "${BLUE}Format:${RESET}       MP3 audio only"
            echo -e "${BLUE}Merge format:${RESET} N/A (audio only)"
        else
            echo -e "${BLUE}Format:${RESET}       ${format_selector:-<default>}"
            echo -e "${BLUE}Merge format:${RESET} ${merge_format:-<auto>}"
        fi
        echo -e "${BLUE}Force keyframes:${RESET} ${force_key:-n}"

        echo -e "\n${YELLOW}Options:${RESET}"
        echo "1) Edit URL"
        echo "2) Edit cookies"
        echo "3) Edit start/end times"
        echo "4) Edit format"
        echo "5) Edit merge format"
        echo "6) Toggle force-keyframes"
        echo "r) Re-run all prompts with current values pre-filled"
        echo "run) Proceed to download   (or just press Enter)"
        echo "q) Quit without running"
        read -p "Choose option: " review_opt

        review_opt="${review_opt#"${review_opt%%[![:space:]]*}"}"
        review_opt="${review_opt%"${review_opt##*[![:space:]]}"}"

        case "$review_opt" in
            1) url=$(colored_read "${BLUE}New URL:${RESET}" "$url") ;;
            2) 
                select_cookies
                ;;
            3) 
                start_time=$(colored_read "${BLUE}New start time (empty=keep):${RESET}" "$start_time")
                end_time=$(colored_read "${BLUE}New end time (empty=keep):${RESET}" "$end_time")
                if [ -n "$start_time" ] && ! is_valid_time_format "$start_time"; then start_time=""; fi
                if [ -n "$end_time" ] && ! is_valid_time_format "$end_time"; then end_time=""; fi
                if [ -n "$start_time" ] && [ -n "$end_time" ]; then
                    ssec=$(time_to_seconds "$start_time")
                    esec=$(time_to_seconds "$end_time")
                    if [ "$ssec" -ge "$esec" ]; then
                        echo -e "${RED}Start must be before end. Cleared.${RESET}"
                        start_time=""; end_time=""
                    fi
                fi
                ;;
            4) 
                echo "Format presets (same as before)..."
                format_choice=$(colored_read "${BLUE}New format choice 1-6 or custom:${RESET}" "")
                mp3_only=""
                case "$format_choice" in
                    1) format_selector='bv+ba/b' ;;
                    2) format_selector='bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]' ;;
                    3) format_selector='bv*+ba/b' ;;
                    4) format_selector='bv,ba' ;;
                    5) 
                        custom_f=$(colored_read "${BLUE}Enter full -f string:${RESET}" "")
                        format_selector="$custom_f"
                        ;;
                    6)
                        format_selector='bestaudio/best'
                        mp3_only="yes"
                        ;;
                    *) if [ -n "$format_choice" ]; then format_selector="$format_choice"; fi ;;
                esac
                if [ "$mp3_only" = "yes" ]; then
                    merge_format=""
                fi
                ;;
            5) 
                if [ "$mp3_only" = "yes" ]; then
                    echo -e "${YELLOW}Merge format not applicable for MP3 audio only.${RESET}"
                else
                    merge_format=$(colored_read "${BLUE}New merge format (avi/flv/mkv/mov/mp4/webm):${RESET}" "$merge_format")
                    if [ -n "$merge_format" ] && ! validate_merge_format "$merge_format"; then
                        echo -e "${RED}Invalid. Cleared.${RESET}"
                        merge_format=""
                    fi
                fi
                ;;
            6) 
                if [[ "$force_key" =~ ^[Yy]$ ]]; then
                    force_key="n"; force=""
                else
                    force_key="y"; force="--force-keyframes-at-cuts"
                fi
                ;;
            r) 
                echo -e "${YELLOW}Re-running all questions with current values...${RESET}"
                collect_inputs
                ;;
            run|"") 
                return 0
                ;;
            q) 
                echo -e "${RED}Aborted.${RESET}"
                exit 0
                ;;
            *) echo -e "${RED}Invalid choice.${RESET}" ;;
        esac
    done
}

main() {
    # Initialize to avoid pollution from previous runs / sourcing
    url=""
    cookies=""
    start_time=""
    end_time=""
    format_selector=""
    mp3_only=""
    merge_format=""
    force=""
    force_key="n"

    collect_inputs
    review_and_confirm
    build_command

    echo -e "\n${GREEN}${BOLD}Final command:${RESET}"
    echo -e "${CYAN}yt-dlp${RESET} \c"
    printf '%q ' "${cmd_args[@]}"
    echo -e "${RESET}\n"

    if ! command -v yt-dlp >/dev/null 2>&1; then
        echo -e "${RED}Error: yt-dlp not found in PATH.${RESET}"
        exit 1
    fi

    read -p "Run now? (y/n): " confirm_run
    confirm_run="${confirm_run//[[:space:]]/}"
    if [[ "$confirm_run" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Starting download...${RESET}"
        yt-dlp "${cmd_args[@]}"
    else
        echo -e "${YELLOW}Command prepared but not executed.${RESET}"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
