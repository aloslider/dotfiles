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
  echo -e "${RED}Usage: $0 /path/to/video.mp4 [optional_output.mp4_or_.gif]${RESET}"
  exit 1
fi
if [[ ! -f "$input" ]]; then
  echo -e "${RED}Error: Input file not found: $input${RESET}"
  exit 1
fi

is_gif=false
if [[ "$input" == *.gif ]]; then
  is_gif=true
fi

if [[ -n "$2" ]]; then
  output_file="$2"
  if $is_gif; then
    if [[ "$output_file" != *.gif ]]; then output_file="${output_file}.gif"; fi
  else
    if [[ "$output_file" != *.mp4 ]]; then output_file="${output_file}.mp4"; fi
  fi
  auto_index=false
else
  base=$(basename "$input" | sed 's/\.[^.]*$//')
  if $is_gif; then
    ext="gif"
  else
    ext="mp4"
  fi
  i=0
  while [[ -f "${base}-${i}.${ext}" ]]; do
    ((i++))
  done
  output_file="${base}-${i}.${ext}"
  auto_index=true
fi

if $is_gif; then
  fps=15
  width=""
  start_time=""
  dur=""
  loop_infinite=true
  dither="bayer"
  bayer_scale=3
  stats_mode="full"
else
  codec="libx264"
  crf=26
  preset="medium"
  audio_bitrate="96k"
  fps=""
  width=""
  start_time=""
  dur=""
  faststart=true
fi

function show_current_settings() {
  echo -e "${CYAN}Current Settings${RESET}"
  if $is_gif; then
    echo -e "Input type: ${GREEN}GIF (re-encoding)${RESET}"
    echo -e "FPS: ${GREEN}${fps}${RESET}"
    echo -e "Scale width: ${GREEN}${width:-keep original}${RESET}"
    echo -e "Start time: ${GREEN}${start_time:-from beginning}${RESET}"
    echo -e "Duration: ${GREEN}${dur:-to end}${RESET}"
    echo -e "Loop: ${GREEN}$(if $loop_infinite; then echo 'infinite'; else echo 'once'; fi)${RESET}"
    echo -e "Dither: ${GREEN}${dither}${RESET}"
    if [[ "$dither" == "bayer" ]]; then
      echo -e "Bayer scale: ${GREEN}${bayer_scale}${RESET}"
    fi
  else
    echo -e "Input type: ${GREEN}Video${RESET}"
    echo -e "Codec: ${GREEN}${codec}${RESET}"
    echo -e "CRF (quality): ${GREEN}${crf}${RESET}   (lower = better quality, bigger file)"
    echo -e "Preset (speed): ${GREEN}${preset}${RESET}   (slow = better compression)"
    echo -e "Audio bitrate: ${GREEN}${audio_bitrate}${RESET}   (or 'copy' to keep original)"
    echo -e "FPS: ${GREEN}${fps:-keep original}${RESET}"
    echo -e "Scale width: ${GREEN}${width:-keep original}${RESET}"
    echo -e "Start time: ${GREEN}${start_time:-from beginning}${RESET}"
    echo -e "Duration: ${GREEN}${dur:-to end}${RESET}"
    echo -e "Faststart: ${GREEN}$(if $faststart; then echo 'yes (-movflags +faststart)'; else echo 'no'; fi)${RESET}"
  fi
  echo -e "Output file: ${GREEN}${output_file}${RESET}"
}

function build_vf() {
  vf=""
  if [[ -n "$fps" ]]; then
    vf="fps=${fps}"
  fi
  if [[ -n "$width" ]]; then
    if [[ -n "$vf" ]]; then vf+=","; fi
    vf+="scale=${width}:-1:flags=lanczos"
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

  if $is_gif; then
    vf="$(build_vf)"
    if [[ -n "$vf" ]]; then
      cmd+=" -vf \"${vf},split[s0][s1];[s0]palettegen=stats_mode=${stats_mode}[p];[s1][p]paletteuse=dither=${dither}"
      if [[ "$dither" == "bayer" ]]; then
        cmd+=":bayer_scale=${bayer_scale}"
      fi
      cmd+="\""
    else
      cmd+=" -vf \"split[s0][s1];[s0]palettegen=stats_mode=${stats_mode}[p];[s1][p]paletteuse=dither=${dither}"
      if [[ "$dither" == "bayer" ]]; then
        cmd+=":bayer_scale=${bayer_scale}"
      fi
      cmd+="\""
    fi
    if $loop_infinite; then
      cmd+=" -loop 0"
    else
      cmd+=" -loop 1"
    fi
  else
    vf="$(build_vf)"
    if [[ -n "$vf" ]]; then
      cmd+=" -vf \"$vf\""
    fi
    cmd+=" -c:v ${codec} -crf ${crf} -preset ${preset}"
    if [[ "$audio_bitrate" == "copy" ]]; then
      cmd+=" -c:a copy"
    else
      cmd+=" -c:a aac -b:a ${audio_bitrate}"
    fi
    if $faststart; then
      cmd+=" -movflags +faststart"
    fi
  fi
  cmd+=" \"${output_file}\""
  echo "$cmd"
}

function configure_settings() {
  while true; do
    echo -e "\n${YELLOW}Press Enter to keep default shown in [brackets]. Type new value to change.${RESET}"
    echo -e "${CYAN}Configuration${RESET}"

    if $is_gif; then
      read -p "FPS [${fps}]: " val
      if [[ -n "$val" ]]; then fps="$val"; fi

      read -p "Scale width in px (e.g. 480 or 640, empty=keep): " val
      if [[ -n "$val" ]]; then width="$val"; fi

      read -p "Start time (e.g. 00:00:05 or 5, empty=from start): " val
      start_time="$val"

      read -p "Duration in sec or HH:MM:SS (empty=to end): " val
      dur="$val"

      read -p "Loop infinitely? (y/n) [y]: " val
      if [[ "$val" == "n" || "$val" == "N" ]]; then loop_infinite=false; else loop_infinite=true; fi

      read -p "Dither (bayer / floyd_steinberg / none) [bayer]: " val
      if [[ -n "$val" ]]; then dither="$val"; fi

      if [[ "$dither" == "bayer" ]]; then
        read -p "Bayer scale 1-5 [${bayer_scale}]: " val
        if [[ -n "$val" ]]; then bayer_scale="$val"; fi
      fi
    else
      read -p "Codec (libx265 or libx264) [${codec}]: " val
      if [[ -n "$val" ]]; then codec="$val"; fi

      read -p "CRF quality [${crf}]: " val
      if [[ -n "$val" ]]; then crf="$val"; fi

      read -p "Preset (ultrafast|superfast|veryfast|fast|medium|slow|veryslow) [${preset}]: " val
      if [[ -n "$val" ]]; then preset="$val"; fi

      read -p "Audio bitrate in k (e.g. 96k or 128k, or 'copy') [${audio_bitrate}]: " val
      if [[ -n "$val" ]]; then audio_bitrate="$val"; fi

      read -p "Target FPS (empty=keep original, e.g. 30): " val
      fps="$val"

      read -p "Scale width in px (e.g. 1280, empty=keep original): " val
      width="$val"

      read -p "Start time (e.g. 00:00:05 or 5, empty=from start): " val
      start_time="$val"

      read -p "Duration in sec or HH:MM:SS (empty=to end): " val
      dur="$val"

      read -p "Enable faststart? (y/n) [y]: " val
      if [[ "$val" == "n" || "$val" == "N" ]]; then
        faststart=false
      else
        faststart=true
      fi
    fi

    echo ""
    show_current_settings
    echo -e "\n${YELLOW}Preview command:${RESET}"
    build_command_string

    echo -e "\n${CYAN}Options now:${RESET}"
    echo "1) Execute with these settings"
    echo "2) Restart configuration from defaults"
    echo "3) Change one specific setting"
    echo "4) Exit without compressing"
    read -p "Your choice [1]: " choice
    choice=${choice:-1}

    case $choice in
      1) return 0 ;;
      2)
        if $is_gif; then
          fps=15
          width=""
          start_time=""
          dur=""
          loop_infinite=true
          dither="bayer"
          bayer_scale=3
        else
          codec="libx264"
          crf=26
          preset="medium"
          audio_bitrate="96k"
          fps=""
          width=""
          start_time=""
          dur=""
          faststart=true
        fi
        ;;
      3)
        echo -e "${CYAN}Which setting to change?${RESET}"
        if $is_gif; then
          echo "a) FPS   b) Scale width   c) Start time   d) Duration   e) Loop   f) Dither   g) Bayer scale"
        else
          echo "a) Codec   b) CRF   c) Preset   d) Audio bitrate   e) FPS   f) Scale width"
          echo "g) Start time   h) Duration   i) Faststart (movflags)"
        fi
        read -p "Letter: " letter
        if $is_gif; then
          case $letter in
            a) read -p "New FPS: " val; [[ -n "$val" ]] && fps="$val" ;;
            b) read -p "New width: " val; width="$val" ;;
            c) read -p "New start time: " val; start_time="$val" ;;
            d) read -p "New duration: " val; dur="$val" ;;
            e) if $loop_infinite; then loop_infinite=false; else loop_infinite=true; fi ;;
            f) read -p "New dither: " val; [[ -n "$val" ]] && dither="$val" ;;
            g) if [[ "$dither" == "bayer" ]]; then read -p "New bayer scale: " val; [[ -n "$val" ]] && bayer_scale="$val"; fi ;;
          esac
        else
          case $letter in
            a) read -p "New codec (libx265/libx264): " val; [[ -n "$val" ]] && codec="$val" ;;
            b) read -p "New CRF: " val; [[ -n "$val" ]] && crf="$val" ;;
            c) read -p "New preset: " val; [[ -n "$val" ]] && preset="$val" ;;
            d) read -p "New audio bitrate or 'copy': " val; [[ -n "$val" ]] && audio_bitrate="$val" ;;
            e) read -p "New FPS (empty=keep): " val; fps="$val" ;;
            f) read -p "New width (empty=keep): " val; width="$val" ;;
            g) read -p "New start time: " val; start_time="$val" ;;
            h) read -p "New duration: " val; dur="$val" ;;
            i) if $faststart; then faststart=false; else faststart=true; fi ;;
          esac
        fi
        ;;
      4) echo -e "${YELLOW}Exiting.${RESET}"; exit 0 ;;
      *) ;;
    esac
  done
}

configure_settings

echo -e "\n${GREEN}Starting compression...${RESET}"
echo -e "${YELLOW}Command: $(build_command_string)${RESET}\n"

cmd_array=(ffmpeg -y)
if [[ -n "$start_time" ]]; then
  cmd_array+=(-ss "$start_time")
fi
cmd_array+=(-i "$input")
if [[ -n "$dur" ]]; then
  cmd_array+=(-t "$dur")
fi

if $is_gif; then
  vf="$(build_vf)"
  if [[ -n "$vf" ]]; then
    full_vf="${vf},split[s0][s1];[s0]palettegen=stats_mode=${stats_mode}[p];[s1][p]paletteuse=dither=${dither}"
    if [[ "$dither" == "bayer" ]]; then
      full_vf+=":bayer_scale=${bayer_scale}"
    fi
    cmd_array+=(-vf "$full_vf")
  else
    full_vf="split[s0][s1];[s0]palettegen=stats_mode=${stats_mode}[p];[s1][p]paletteuse=dither=${dither}"
    if [[ "$dither" == "bayer" ]]; then
      full_vf+=":bayer_scale=${bayer_scale}"
    fi
    cmd_array+=(-vf "$full_vf")
  fi
  if $loop_infinite; then
    cmd_array+=(-loop 0)
  else
    cmd_array+=(-loop 1)
  fi
else
  vf="$(build_vf)"
  if [[ -n "$vf" ]]; then
    cmd_array+=(-vf "$vf")
  fi
  cmd_array+=(-c:v "$codec" -crf "$crf" -preset "$preset")
  if [[ "$audio_bitrate" == "copy" ]]; then
    cmd_array+=(-c:a copy)
  else
    cmd_array+=(-c:a aac -b:a "$audio_bitrate")
  fi
  if $faststart; then
    cmd_array+=(-movflags +faststart)
  fi
fi
cmd_array+=("$output_file")

"${cmd_array[@]}"

if [[ -f "$output_file" ]]; then
  size=$(du -h "$output_file" | awk '{print $1}')
  echo -e "\n${GREEN}✓ Compression finished!${RESET}"
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
        base=$(basename "$output_file" | sed "s/-[0-9]*\.${ext}$//")
        i=0
        while [[ -f "${base}-${i}.${ext}" ]]; do
          ((i++))
        done
        output_file="${base}-${i}.${ext}"
      else
        base=$(basename "$output_file" | sed "s/\.${ext}$//")
        i=0
        while [[ -f "${base}-${i}.${ext}" ]]; do
          ((i++))
        done
        output_file="${base}-${i}.${ext}"
      fi
      echo -e "New output file will be: ${YELLOW}${output_file}${RESET}"
      configure_settings
      echo -e "\n${GREEN}Starting new compression...${RESET}"
      cmd_array=(ffmpeg -y)
      if [[ -n "$start_time" ]]; then cmd_array+=(-ss "$start_time"); fi
      cmd_array+=(-i "$input")
      if [[ -n "$dur" ]]; then cmd_array+=(-t "$dur"); fi
      if $is_gif; then
        vf="$(build_vf)"
        if [[ -n "$vf" ]]; then
          full_vf="${vf},split[s0][s1];[s0]palettegen=stats_mode=${stats_mode}[p];[s1][p]paletteuse=dither=${dither}"
          if [[ "$dither" == "bayer" ]]; then full_vf+=":bayer_scale=${bayer_scale}"; fi
          cmd_array+=(-vf "$full_vf")
        else
          full_vf="split[s0][s1];[s0]palettegen=stats_mode=${stats_mode}[p];[s1][p]paletteuse=dither=${dither}"
          if [[ "$dither" == "bayer" ]]; then full_vf+=":bayer_scale=${bayer_scale}"; fi
          cmd_array+=(-vf "$full_vf")
        fi
        if $loop_infinite; then cmd_array+=(-loop 0); else cmd_array+=(-loop 1); fi
      else
        vf="$(build_vf)"
        if [[ -n "$vf" ]]; then cmd_array+=(-vf "$vf"); fi
        cmd_array+=(-c:v "$codec" -crf "$crf" -preset "$preset")
        if [[ "$audio_bitrate" == "copy" ]]; then cmd_array+=(-c:a copy); else cmd_array+=(-c:a aac -b:a "$audio_bitrate"); fi
        if $faststart; then cmd_array+=(-movflags +faststart); fi
      fi
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
      echo -e "\n${GREEN}Starting compression (overwrite mode)...${RESET}"
      cmd_array=(ffmpeg -y)
      if [[ -n "$start_time" ]]; then cmd_array+=(-ss "$start_time"); fi
      cmd_array+=(-i "$input")
      if [[ -n "$dur" ]]; then cmd_array+=(-t "$dur"); fi
      if $is_gif; then
        vf="$(build_vf)"
        if [[ -n "$vf" ]]; then
          full_vf="${vf},split[s0][s1];[s0]palettegen=stats_mode=${stats_mode}[p];[s1][p]paletteuse=dither=${dither}"
          if [[ "$dither" == "bayer" ]]; then full_vf+=":bayer_scale=${bayer_scale}"; fi
          cmd_array+=(-vf "$full_vf")
        else
          full_vf="split[s0][s1];[s0]palettegen=stats_mode=${stats_mode}[p];[s1][p]paletteuse=dither=${dither}"
          if [[ "$dither" == "bayer" ]]; then full_vf+=":bayer_scale=${bayer_scale}"; fi
          cmd_array+=(-vf "$full_vf")
        fi
        if $loop_infinite; then cmd_array+=(-loop 0); else cmd_array+=(-loop 1); fi
      else
        vf="$(build_vf)"
        if [[ -n "$vf" ]]; then cmd_array+=(-vf "$vf"); fi
        cmd_array+=(-c:v "$codec" -crf "$crf" -preset "$preset")
        if [[ "$audio_bitrate" == "copy" ]]; then cmd_array+=(-c:a copy); else cmd_array+=(-c:a aac -b:a "$audio_bitrate"); fi
        if $faststart; then cmd_array+=(-movflags +faststart); fi
      fi
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

