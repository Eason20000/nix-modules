#!/usr/bin/env bash

set -o pipefail

show_time=true
show_network=true
separator_arg=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-time)
      show_time=false
      shift
      ;;
    --no-network)
      show_network=false
      shift
      ;;
    --*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      if [[ -z $separator_arg ]]; then
        separator_arg="$1"
      fi
      shift
      ;;
  esac
done

SEPARATOR="${separator_arg:- }"

# Nerd Font icons, written as escapes so the source stays ASCII.
CPU_ICON=$'\uF4BC'   # nf-oct-cpu
RAM_ICON=$'\uEFC5'   # nf-fa-memory
UP_ICON=$'\uF062'    # nf-fa-arrow_up
DOWN_ICON=$'\uF063'  # nf-fa-arrow_down

# Raw counters plus the last computed deltas are shared by everything that
# reads the same tmux server. A one second cache keeps multiple clients and
# sessions from sampling and diffing at the same time.
umask 077
runtime_dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"
state_dir="$runtime_dir/system-status-$(id -u)"
mkdir -p "$state_dir"

if [[ -n ${TMUX:-} ]]; then
  # $TMUX is "<socket>,<server pid>,<session>"; key by server so sessions and
  # clients share one sample.
  state_key=$(printf '%s' "${TMUX%,*}" | cksum | cut -d' ' -f1)
else
  state_key="default"
fi
state_file="$state_dir/state-$state_key"

# libstatgrab reports the same keys on Linux and Darwin, so there is no
# per-platform code below.
raw_output=$(statgrab -n cpu. mem. net. 2>/dev/null || true)
read -r -a raw <<<"$(
  printf '%s\n' "$raw_output" | awk -F' = ' '
    $1 == "cpu.total" { cpu_total = $2 }
    $1 == "cpu.idle"  { cpu_idle  = $2 }
    $1 == "mem.total" { mem_total = $2 }
    $1 == "mem.free"  { mem_free  = $2 }
    $1 == "mem.cache" { mem_cache = $2 }
    $1 ~ /^net\..*\.rx$/ && $1 !~ /^net\.(lo|lo0)\./ { rx += $2 }
    $1 ~ /^net\..*\.tx$/ && $1 !~ /^net\.(lo|lo0)\./ { tx += $2 }
    END {
      printf "%d %d %d %d %d %d %d\n", cpu_total, cpu_idle, mem_total,
             mem_free, mem_cache, rx, tx
    }
  '
)"

cpu_total=${raw[0]:-0}
cpu_idle=${raw[1]:-0}
mem_total=${raw[2]:-0}
mem_free=${raw[3]:-0}
mem_cache=${raw[4]:-0}
net_rx=${raw[5]:-0}
net_tx=${raw[6]:-0}

ram_pct=0
if ((mem_total > 0)); then
  mem_used=$((mem_total - mem_free - mem_cache))
  if ((mem_used < 0)); then
    mem_used=0
  fi
  ram_pct=$((100 * mem_used / mem_total))
  if ((ram_pct > 100)); then
    ram_pct=100
  fi
fi

now=$(date +%s)
cpu_pct=0
tx_bps=0
rx_bps=0

prev_ts=""
prev_cpu_total=0
prev_cpu_idle=0
prev_rx=0
prev_tx=0
prev_cpu_pct=0
prev_tx_bps=0
prev_rx_bps=0
if [[ -r $state_file ]]; then
  read -r prev_ts prev_cpu_total prev_cpu_idle prev_rx prev_tx \
    prev_cpu_pct prev_tx_bps prev_rx_bps <"$state_file" || true
fi

if [[ $prev_ts =~ ^[0-9]+$ ]] && ((now - prev_ts < 1)); then
  cpu_pct=$prev_cpu_pct
  tx_bps=$prev_tx_bps
  rx_bps=$prev_rx_bps
else
  if [[ $prev_ts =~ ^[0-9]+$ ]] && ((now > prev_ts)); then
    elapsed=$((now - prev_ts))
    total_diff=$((cpu_total - prev_cpu_total))
    idle_diff=$((cpu_idle - prev_cpu_idle))
    if ((total_diff > 0)); then
      cpu_pct=$((100 * (total_diff - idle_diff) / total_diff))
      if ((cpu_pct < 0)); then
        cpu_pct=0
      fi
      if ((cpu_pct > 100)); then
        cpu_pct=100
      fi
    fi
    rx_diff=$((net_rx - prev_rx))
    tx_diff=$((net_tx - prev_tx))
    if ((rx_diff < 0)); then
      rx_diff=0
    fi
    if ((tx_diff < 0)); then
      tx_diff=0
    fi
    rx_bps=$((rx_diff / elapsed))
    tx_bps=$((tx_diff / elapsed))
  fi

  tmp=$(mktemp "$state_dir/.state.XXXXXX")
  printf '%s %s %s %s %s %s %s %s\n' "$now" "$cpu_total" "$cpu_idle" \
    "$net_rx" "$net_tx" "$cpu_pct" "$tx_bps" "$rx_bps" >"$tmp"
  mv -f "$tmp" "$state_file"
fi

pad_percent() {
  if (($1 < 10)); then
    printf '  %d%%' "$1"
  elif (($1 < 100)); then
    printf ' %d%%' "$1"
  else
    printf '%d%%' "$1"
  fi
}

format_bytes() {
  awk -v bytes="$1" 'BEGIN {
    value = bytes / 1024
    unit = 1
    split("kB MB GB", units, " ")
    while (value >= 1024 && unit < 3) {
      value /= 1024
      unit++
    }
    printf "%.1f %s", value, units[unit]
  }'
}

output="${CPU_ICON} $(pad_percent "$cpu_pct")"
output+="${SEPARATOR}${RAM_ICON} $(pad_percent "$ram_pct")"
if [[ $show_network == true ]]; then
  output+="${SEPARATOR}${UP_ICON} $(format_bytes "$tx_bps")"
  output+="${SEPARATOR}${DOWN_ICON} $(format_bytes "$rx_bps")"
fi
if [[ $show_time == true ]]; then
  output+="${SEPARATOR}$(date '+%m月%d日 %H:%M')"
fi
printf '%s\n' "$output"
