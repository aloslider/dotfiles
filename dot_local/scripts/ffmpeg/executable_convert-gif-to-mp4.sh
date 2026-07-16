#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

if ! command -v ffmpeg &> /dev/null; then
  echo -e "${RED}Error: ffmpeg is not installed.${RESET}"
  exit 1
fi

input="$1"
if [[ -z "$input" ]]; then
  echo -e "${RED}Usage: $0 /path/to/video.mp4 [optional_output.gif]${RESET}"
  exit 1
fi
if [[ ! -f "$input" ]]; then
  echo -e "${RED}Error: Input file not found: $input${RESET}"
  exit 1
fi

if [[ -n "$2" ]]; then
  output_file="$2"
  if [[ "$output_file" != *.gif ]]; then
    output_file="${output_file}.gif"
  fi
  auto_index=false
else
  base=$(basename "$input" | sed 's/\.[^.]*$//')
  i=0
  while [[ -f "${base}-${i}.gif" ]]; do
    ((i++))
  done
  output_file="${base}-${i}.gif"
  auto_index=true
fi

fps=25
width=""
start_time=""
dur=""
loop_infinite=true
dither="bayer"
bayer_scale=3
stats_mode="full"

function show_current_settings() {
  echo -e "${CYAN}Current Settings=${RESET}"
  echo -e "FPS: ${GREEN}${fps}${RESET}"
  echo -e "Scale width: ${GREEN}${width:-keep original}${RESET}"
  echo -e "Start time: ${GREEN}${start_time:-from beginning}${RESET}"
  echo -e "Duration: ${GREEN}${dur:-to end}${RESET}"
  echo -e "Loop: ${GREEN}$(if $loop_infinite; then echo 'infinite (-loop 0)'; else echo 'once (-loop 1)'; fi)${RESET}"
  echo -e "Dither: ${GREEN}${dither}${RESET}"
  if [[ "$dither" == "bayer" ]]; then
    echo -e "Bayer scale: ${GREEN}${bayer_scale}${RESET}"
  fi
  echo -e "Output file: ${GREEN}${output_file}${RESET}"
}

function build_vf() {
  vf="fps=${fps}"
  if [[ -n "$width" ]]; then
    vf+=",scale=${width}:-1:flags=lanczos"
  fi
  vf+=",split[s0][s1];[s0]palettegen=stats_mode=${stats_mode}[p];[s1][p]paletteuse=dither=${dither}"
  if [[ "$dither" == "bayer" ]]; then
    vf+=":bayer_scale=${bayer_scale}"
  fi
  echo "$vf"
}

function build_command_string() {
  cmd="ffmpeg -y"
  if [[ -n "$start_time" ]]; then
    cmd+=" -ss ${start_time}"
  fi
  cmd+=" -i \"${input}\""
  if [[ -n "$dur" ]]; then
    cmd+=" -t ${dur}"
  fi
  cmd+=" -vf \"$(build_vf)\""
  if $loop_infinite; then
    cmd+=" -loop 0"
  else
    cmd+=" -loop 1"
  fi
  cmd+=" \"${output_file}\""
  echo "$cmd"
}

function configure_settings() {
  while true; do
    echo -e "\n${YELLOW}Press Enter to keep default shown in [brackets]. Type new value to change.${RESET}"
    echo -e "${CYAN}Configuration:${RESET}"

    read -p "FPS [${fps}]: " val
    if [[ -n "$val" ]]; then fps="$val"; fi

    read -p "Scale width in px (e.g. 640 or 800, empty=keep original): " val
    if [[ -n "$val" ]]; then width="$val"; fi

    read -p "Start time (e.g. 00:00:05 or 5, empty=from start): " val
    start_time="$val"

    read -p "Duration in sec or HH:MM:SS (empty=to end): " val
    dur="$val"

    read -p "Loop infinitely? (y/n) [y]: " val
    if [[ "$val" == "n" || "$val" == "N" ]]; then
      loop_infinite=false
    else
      loop_infinite=true
    fi

    read -p "Dither method (bayer / floyd_steinberg / none) [bayer]: " val
    if [[ -n "$val" ]]; then dither="$val"; fi

    if [[ "$dither" == "bayer" ]]; then
      read -p "Bayer scale 1-5 (higher=more dither pattern) [${bayer_scale}]: " val
      if [[ -n "$val" ]]; then bayer_scale="$val"; fi
    fi

    echo ""
    show_current_settings
    echo -e "\n${YELLOW}Preview command:${RESET}"
    build_command_string

    echo -e "\n${CYAN}Options now:${RESET}"
    echo "1) Execute with these settings"
    echo "2) Restart configuration from defaults"
    echo "3) Change one specific setting"
    echo "4) Exit without converting"
    read -p "Your choice [1]: " choice
    choice=${choice:-1}

    case $choice in
      1) return 0 ;;
      2)
        fps=25
        width=""
        start_time=""
        dur=""
        loop_infinite=true
        dither="bayer"
        bayer_scale=3
        ;;
      3)
        echo -e "${CYAN}Which setting to change?${RESET}"
        echo "a) FPS"
        echo "b) Scale width"
        echo "c) Start time"
        echo "d) Duration"
        echo "e) Loop"
        echo "f) Dither method"
        echo "g) Bayer scale (if bayer)"
        read -p "Letter: " letter
        case $letter in
          a) read -p "New FPS: " val; [[ -n "$val" ]] && fps="$val" ;;
          b) read -p "New width (empty to keep original): " val; width="$val" ;;
          c) read -p "New start time: " val; start_time="$val" ;;
          d) read -p "New duration: " val; dur="$val" ;;
          e) if $loop_infinite; then loop_infinite=false; else loop_infinite=true; fi ;;
          f) read -p "New dither (bayer/floyd_steinberg/none): " val; [[ -n "$val" ]] && dither="$val" ;;
          g) if [[ "$dither" == "bayer" ]]; then read -p "New bayer scale: " val; [[ -n "$val" ]] && bayer_scale="$val"; fi ;;
        esac
        ;;
      4) echo -e "${YELLOW}Exiting.${RESET}"; exit 0 ;;
      *) ;;
    esac
  done
}

configure_settings

echo -e "\n${GREEN}Starting conversion...${RESET}"
echo -e "${YELLOW}Command: $(build_command_string)${RESET}\n"

cmd_array=(ffmpeg -y)
if [[ -n "$start_time" ]]; then
  cmd_array+=(-ss "$start_time")
fi
cmd_array+=(-i "$input")
if [[ -n "$dur" ]]; then
  cmd_array+=(-t "$dur")
fi
vf="$(build_vf)"
cmd_array+=(-vf "$vf")
if $loop_infinite; then
  cmd_array+=(-loop 0)
else
  cmd_array+=(-loop 1)
fi
cmd_array+=("$output_file")

"${cmd_array[@]}"

if [[ -f "$output_file" ]]; then
  size=$(du -h "$output_file" | awk '{print $1}')
  echo -e "\n${GREEN}✓ Conversion finished!${RESET}"
  echo -e "File: ${GREEN}${output_file}${RESET}"
  echo -e "Size: ${GREEN}${size}${RESET}"
else
  echo -e "${RED}Error: Output file was not created.${RESET}"
  exit 1
fi

while true; do
  echo -e "\n${CYAN}Select option:${RESET}"
  echo "1) Change settings and create a NEW file (next available index)"
  echo "2) Redo with current settings (will overwrite ${output_file})"
  echo "q) Exit"
  read -p "Choice: " post_choice

  case $post_choice in
    1)
      if $auto_index; then
        base=$(basename "$output_file" | sed 's/-[0-9]*\.gif$//')
        i=0
        while [[ -f "${base}-${i}.gif" ]]; do
          ((i++))
        done
        output_file="${base}-${i}.gif"
      else
        base=$(basename "$output_file" | sed 's/\.gif$//')
        i=0
        while [[ -f "${base}-${i}.gif" ]]; do
          ((i++))
        done
        output_file="${base}-${i}.gif"
      fi
      echo -e "New output file will be: ${YELLOW}${output_file}${RESET}"
      configure_settings
      echo -e "\n${GREEN}Starting new conversion...${RESET}"
      cmd_array=(ffmpeg -y)
      if [[ -n "$start_time" ]]; then cmd_array+=(-ss "$start_time"); fi
      cmd_array+=(-i "$input")
      if [[ -n "$dur" ]]; then cmd_array+=(-t "$dur"); fi
      vf="$(build_vf)"
      cmd_array+=(-vf "$vf")
      if $loop_infinite; then cmd_array+=(-loop 0); else cmd_array+=(-loop 1); fi
      cmd_array+=("$output_file")
      "${cmd_array[@]}"
      if [[ -f "$output_file" ]]; then
        size=$(du -h "$output_file" | awk '{print $1}')
        echo -e "\n${GREEN}New file created!${RESET} File: ${GREEN}${output_file}${RESET} Size: ${GREEN}${size}${RESET}"
      fi
      ;;
    2)
      echo -e "${YELLOW}Will overwrite ${output_file} on next run.${RESET}"
      configure_settings
      echo -e "\n${GREEN}Starting conversion (overwrite mode)...${RESET}"
      cmd_array=(ffmpeg -y)

      if [[ -n "$start_time" ]]; then cmd_array+=(-ss "$start_time"); fi
      cmd_array+=(-i "$input")

      if [[ -n "$dur" ]]; then cmd_array+=(-t "$dur"); fi
      vf="$(build_vf)"
      cmd_array+=(-vf "$vf")

      if $loop_infinite; then cmd_array+=(-loop 0); else cmd_array+=(-loop 1); fi
      cmd_array+=("$output_file")
      "${cmd_array[@]}"

      if [[ -f "$output_file" ]]; then
        size=$(du -h "$output_file" | awk '{print $1}')
        echo -e "\n${GREEN}Overwritten!${RESET} File: ${GREEN}${output_file}${RESET} Size: ${GREEN}${size}${RESET}"
      fi
      ;;
    q)
      echo -e "${GREEN}Done.${RESET}"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid choice.${RESET}"
      ;;
  esac
done
