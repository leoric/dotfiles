fcrop() {
  if [[ -z "$1" ]]; then
    echo "Usage: fcrop <video_file>"
    return 1
  fi
  ffmpeg -i "$1" -vf cropdetect=24:16:0 -f null -
}

ff1() {
    codec=(-c:v h264_videotoolbox -crf 31)
    vf_stack=("scale=-1:360")

    # Adjust second argument if it contains ":"
    if [[ "$2" == *:* ]]; then
        second_arg="00:$2"
    else
        second_arg="$2"
    fi

    # Construct FFmpeg command
    cmd=(ffmpeg -hide_banner -i "$1" "${codec[@]}" -c:a copy -preset fast -t 1)
    [[ -n "$second_arg" ]] && cmd+=(-ss "$second_arg")
    cmd+=(-vf "${vf_stack[*]}" -y "${1%.*}_1.mp4")

    # **Formatted output display**
    echo -n "Executing:"
    for arg in "${cmd[@]}"; do
        [[ "$arg" == "$1" || "$arg" == "${1%.*}_1.mp4" ]] && printf ' "%s"' "$arg" || printf ' %s' "$arg"
    done
    echo

    # Run command
    "${cmd[@]}"
}

# fb <file> [target] [-p percent]
# Prints the target video bitrate in kbps (default: 65% of source).
# Target short side defaults to 720. Never upscales.
# Short side <= target:  "nnn kbps"
# Short side >  target:  "nnn kbps" (scaled to target)
#                        "mmm kbps (WxH)" (original)
fb() {
    local input="$1" target=720 pct=65 w h br
    shift
    while (( $# )); do
        case "$1" in
            -p) pct="$2"; shift ;;
            <->) target="$1" ;;
        esac
        shift
    done

    if [[ -z "$input" || ! -f "$input" ]]; then
        echo "fb: usage: fb <file> [target] [-p percent]" >&2
        return 1
    fi

    local probe
    probe=$(ffprobe -v error -select_streams v:0 \
        -show_entries stream=width,height,bit_rate \
        -of default=nw=1 "$input")

    w=$(awk -F= '$1=="width"{print $2; exit}' <<< "$probe")
    h=$(awk -F= '$1=="height"{print $2; exit}' <<< "$probe")
    br=$(awk -F= '$1=="bit_rate"{print $2; exit}' <<< "$probe")

    # Fall back to container bitrate (mkv/webm etc.)
    if [[ ! "$br" =~ ^[0-9]+$ ]]; then
        br=$(ffprobe -v error -show_entries format=bit_rate -of default=nw=1:nk=1 "$input")
    fi

    if [[ ! "$br" =~ ^[0-9]+$ || ! "$w" =~ ^[0-9]+$ || ! "$h" =~ ^[0-9]+$ ]]; then
        echo "fb: couldn't read width/height/bitrate" >&2
        return 1
    fi

    awk -v w="$w" -v h="$h" -v b="$br" -v p="$pct" -v t="$target" 'BEGIN {
        short = (w < h) ? w : h
        k0 = int(b * (p / 100) / 1000)
        if (k0 < 100) k0 = 100

        if (short > t) {
            r  = t / short
            k1 = int(b * (p / 100) * r * r / 1000)
            if (k1 < 100) k1 = 100
            printf "%d kbps\n%d kbps (%dx%d)\n", k1, k0, w, h
        } else {
            printf "%d kbps\n", k0
        }
    }'
}

_ff_is_time() { [[ "$1" =~ ^[0-9:.]+$ && "$1" != 264 && "$1" != 720 ]]; }
_ff_norm_time() { [[ "$1" == *:* ]] && echo "00:$1" || echo "$1"; }

# -> start_mark, end_mark, to_flag, consumed
_ff_parse_time() {
  consumed=0
  _ff_is_time "$1" || return 0
  start_mark=$(_ff_norm_time "$1"); consumed=1
  if _ff_is_time "$2"; then
    end_mark=$(_ff_norm_time "$2"); consumed=2
    [[ "$2" == *:* ]] && to_flag=1
  fi
}

# -> src_codec, src_h, src_br, fps (+ fps=30 в vf_stack)
_ff_probe() {
  local probe
  probe=$(ffprobe -v error -select_streams v:0 \
    -show_entries stream=codec_name,height,bit_rate,r_frame_rate \
    -of default=nw=1 "$input_file")
  src_codec=$(awk -F= '$1=="codec_name"{print $2; exit}' <<< "$probe")
  src_h=$(awk -F= '$1=="height"{print $2; exit}' <<< "$probe")
  src_br=$(awk -F= '$1=="bit_rate"{print $2; exit}' <<< "$probe")
  fps=$(awk -F= '$1=="r_frame_rate"{print $2; exit}' <<< "$probe" \
        | awk -F'/' '{ if ($2) print $1/$2; else print $1 }')

  # mkv/webm: битрейт может быть только на уровне контейнера
  if [[ ! "$src_br" =~ ^[0-9]+$ ]]; then
    src_br=$(ffprobe -v error -show_entries format=bit_rate -of default=nw=1:nk=1 "$input_file")
  fi
  if (( $(printf "%.0f" "${fps:-0}") > 30 )); then vf_stack+=("fps=30"); fi
}

# -> use264, use720, q, vf_stack, extra_args
_ff_parse_flags() {
  local vf_flag=0
  while (( $# )); do
    case "$1" in
      264) use264=1; vf_flag=0 ;;
      720) use720=1; vf_flag=0
           vf_stack+=("scale='if(gt(ih,720),-1,iw)':'if(gt(ih,720),720,ih)'") ;;
      -q)  if [[ -z "$2" || "$2" == -* ]]; then
             echo "ff: -q requires a value" >&2; return 1
           fi
           q="$2"; shift; vf_flag=0 ;;
      -vf) vf_flag=1 ;;
      *)   if [[ $vf_flag -eq 1 && ! "$1" =~ ^- ]]; then
             vf_stack+=("$1")
           else
             vf_flag=0; extra_args+=("$1")
           fi ;;
    esac
    shift
  done
}

# -> enc (h264|av1|hevc), out_ext, codec[]
_ff_pick_codec() {
  local common=(-r 23.98 -c:a aac -b:a 64k -ar 44100 -color_range pc -sws_flags lanczos)

  if (( use264 )); then
    enc=h264; out_ext=mp4
    codec=(-c:v h264_videotoolbox -pix_fmt nv12)
  elif [[ "$src_codec" == av1 ]]; then
    enc=av1; out_ext=mkv
    codec=(-c:v libsvtav1 -pix_fmt yuv420p)       # svtav1 не умеет nv12
  else
    enc=hevc; out_ext=mp4
    codec=(-c:v hevc_videotoolbox -tag:v hvc1 -pix_fmt nv12)
  fi

  [[ $out_ext == mp4 ]] && common+=(-movflags +faststart)
  codec+=("${common[@]}")
}

# -> добавляет в codec[] либо -q:v, либо -b:v
_ff_pick_quality() {
  if [[ -n "$q" && "$enc" != hevc ]]; then
    echo "ff: -q is only for hevc, ignoring" >&2
    q=""
  fi

  if [[ -n "$q" ]]; then
    codec+=(-q:v "$q"); return 0
  fi

  if [[ ! "$src_br" =~ ^[0-9]+$ || ! "$src_h" =~ ^[0-9]+$ ]]; then
    if [[ $enc == hevc ]]; then
      echo "ff: couldn't read source bitrate, falling back to -q:v 50" >&2
      codec+=(-q:v 50); return 0
    fi
    echo "ff: couldn't read source bitrate" >&2; return 1
  fi

  # hevc — 65% от исходника, h264/av1 — 100%
  local factor=1
  [[ $enc == hevc ]] && factor=0.65

  # поправка на число пикселей после масштабирования до 720
  local ratio=1
  if (( use720 && src_h > 720 )); then
    ratio=$(awk -v h="$src_h" 'BEGIN{ r=720/h; printf "%.6f", r*r }')
  fi

  local kbps
  kbps=$(awk -v b="$src_br" -v f="$factor" -v r="$ratio" 'BEGIN{ printf "%d", b*f*r/1000 }')
  (( kbps < 100 )) && kbps=100
  codec+=(-b:v "${kbps}k")
}

ff() {
  local input_file="$1"; shift
  local -a codec=() vf_stack=() extra_args=()
  local start_mark="" end_mark="" to_flag=0 q="" use264=0 use720=0
  local src_codec src_h src_br fps enc out_ext consumed

  _ff_parse_time "$@"; shift $consumed
  _ff_probe
  _ff_parse_flags "$@" || return 1
  _ff_pick_codec
  _ff_pick_quality || return 1

  local out="${input_file%.*}_.$out_ext"
  local -a cmd=(ffmpeg -hide_banner -i "$input_file" "${codec[@]}")
  [[ -n "$start_mark" ]] && cmd+=(-ss "$start_mark")
  if [[ -n "$end_mark" ]]; then
    if (( to_flag )); then cmd+=(-to "$end_mark"); else cmd+=(-t "$end_mark"); fi
  fi
  if (( ${#vf_stack[@]} )); then
    cmd+=(-vf "$(IFS=,; echo "${vf_stack[*]}")")
  fi
  cmd+=("${extra_args[@]}" -y "$out")

  printf 'Executing:'; printf ' %q' "${cmd[@]}"; echo
  "${cmd[@]}"
}

ff4() {
  ff "$@" 264
}

ff7() {
  ff "$@" 720
}
