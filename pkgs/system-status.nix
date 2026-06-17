{
  lib,
  stdenv,
  writeShellApplication,
  bc,
  gnugrep,
  gawk,
  coreutils,
  findutils,
  gnused,
}:

writeShellApplication {
  name = "system-status";
  runtimeInputs = [
    bc
    gnugrep
    gawk
    coreutils
    findutils
    gnused
  ];

  text = ''
    #!/usr/bin/env bash

    # Parse command line options
    show_time=true
    show_network=true
    separator_arg=""

    while [[ $# -gt 0 ]]; do
        case "''$1" in
            --no-time)      # Disable time display
                show_time=false
                shift
                ;;
            --no-network)   # Disable network stats display
                show_network=false
                shift
                ;;
            --*)
                echo "Unknown option: ''$1" >&2
                exit 1
                ;;
            *)              # First non-option argument is the separator
                if [[ -z "''$separator_arg" ]]; then
                    separator_arg="''$1"
                fi
                shift
                ;;
        esac
    done

    SEPARATOR="''${separator_arg:- }"   # Separator between metrics

    # Nerd Font icons
    CPU_ICON=""    # nf-oct-cpu
    RAM_ICON=""     # nf-fa-memory
    UP_ICON=""      # nf-fa-arrow_up
    DOWN_ICON=""    # nf-fa-arrow_down

    # State files for delta calculations
    TEMP_DIR="/tmp/system_stats"
    NET_PREV_FILE="$TEMP_DIR/network_prev"
    CPU_PREV_FILE="$TEMP_DIR/cpu_prev"

    mkdir -p "$TEMP_DIR"

    # Get CPU usage percentage (delta since last call)
    get_cpu_usage() {
        local cpu_usage
        local current_stats
        local current_total
        local current_idle
        local i

        if [[ -f "$CPU_PREV_FILE" ]]; then
            local prev_idle prev_total
            read -r prev_idle prev_total < "$CPU_PREV_FILE"

            # Read current CPU times from /proc/stat
            IFS=' ' read -r -a current_stats <<< "$(grep '^cpu ' /proc/stat)"
            current_total=0
            for i in "''${current_stats[@]:1:8}"; do
                current_total=$((current_total + i))
            done
            current_idle=''${current_stats[4]}

            local total_diff=$((current_total - prev_total))
            local idle_diff=$((current_idle - prev_idle))

            # Usage = (total - idle) / total
            if [[ $total_diff -gt 0 ]]; then
                cpu_usage=$((100 * (total_diff - idle_diff) / total_diff))
            else
                cpu_usage=0
            fi

            echo "$current_idle $current_total" > "$CPU_PREV_FILE"
        else
            # First run: store current values, output 0%
            IFS=' ' read -r -a current_stats <<< "$(grep '^cpu ' /proc/stat)"
            current_total=0
            for i in "''${current_stats[@]:1:8}"; do
                current_total=$((current_total + i))
            done
            current_idle=''${current_stats[4]}
            echo "$current_idle $current_total" > "$CPU_PREV_FILE"
            cpu_usage=0
        fi

        # Align percentage with spaces
        if [[ $cpu_usage -lt 10 ]]; then
            printf "  %d%%" "$cpu_usage"
        elif [[ $cpu_usage -lt 100 ]]; then
            printf " %d%%" "$cpu_usage"
        else
            printf "%d%%" "$cpu_usage"
        fi
    }

    # Get RAM usage percentage from /proc/meminfo
    get_ram_usage() {
        local mem_info
        local mem_total
        local mem_available

        mem_info=$(</proc/meminfo)
        mem_total=$(echo "$mem_info" | awk '/MemTotal/ {print $2}')
        mem_available=$(echo "$mem_info" | awk '/MemAvailable/ {print $2}')

        if [[ -n "$mem_total" && -n "$mem_available" && "$mem_total" -gt 0 ]]; then
            local mem_used=$((mem_total - mem_available))
            local ram_usage=$((100 * mem_used / mem_total))

            if [[ $ram_usage -lt 10 ]]; then
                printf "  %d%%" "$ram_usage"
            elif [[ $ram_usage -lt 100 ]]; then
                printf " %d%%" "$ram_usage"
            else
                printf "%d%%" "$ram_usage"
            fi
        else
            printf "  0%%"
        fi
    }

    # Convert bytes to human readable format (kB/MB/GB)
    format_bytes() {
        local bytes=$1
        local units=("kB" "MB" "GB")
        local unit_index=0
        local value

        # Start with kB (bytes/1024), one decimal
        value=$(echo "scale=1; $bytes / 1024" | bc -l 2>/dev/null)
        if [[ -z "$value" ]]; then
            echo "0.0 kB"
            return
        fi

        # Scale up to MB/GB while >= 1024 and units remain
        while (( $(echo "$value >= 1024 && $unit_index < 2" | bc -l 2>/dev/null) )); do
            value=$(echo "scale=1; $value / 1024" | bc -l)
            unit_index=$((unit_index + 1))
        done

        printf "%.1f %s" "$value" "''${units[$unit_index]}"
    }

    # Calculate total network up/down rates (bytes/sec) across all interfaces
    get_network_stats() {
        local interface
        local total_rx=0
        local total_tx=0
        local iface_name
        local rx_bytes
        local tx_bytes

        # Sum rx/tx bytes from all non-loopback interfaces
        for interface in /sys/class/net/*; do
            iface_name=$(basename "$interface")
            if [[ "$iface_name" != "lo" ]] && \
               [[ -f "$interface/statistics/rx_bytes" ]] && \
               [[ -f "$interface/statistics/tx_bytes" ]]; then
                rx_bytes=$(<"$interface/statistics/rx_bytes")
                tx_bytes=$(<"$interface/statistics/tx_bytes")
                total_rx=$((total_rx + rx_bytes))
                total_tx=$((total_tx + tx_bytes))
            fi
        done

        # Retrieve previous snapshot
        local prev_rx=0
        local prev_tx=0
        local prev_time
        prev_time=$(date +%s)

        if [[ -f "$NET_PREV_FILE" ]]; then
            read -r prev_rx prev_tx prev_time < "$NET_PREV_FILE"
        fi

        local current_time
        current_time=$(date +%s)
        local time_diff=$((current_time - prev_time))
        if [[ $time_diff -eq 0 ]]; then
            time_diff=1
        fi

        local rx_rate=0
        local tx_rate=0
        # Compute rates only if we have previous data
        if [[ $prev_rx -gt 0 ]] && [[ $prev_tx -gt 0 ]]; then
            rx_rate=$(((total_rx - prev_rx) / time_diff))
            tx_rate=$(((total_tx - prev_tx) / time_diff))
        fi

        # Save current totals for next run
        echo "$total_rx $total_tx $current_time" > "$NET_PREV_FILE"

        local rx_formatted
        local tx_formatted
        rx_formatted=$(format_bytes "$rx_rate")
        tx_formatted=$(format_bytes "$tx_rate")

        echo "$tx_formatted|$rx_formatted"
    }

    # Current time in "MM月DD日 HH:MM" format (Chinese style)
    get_current_time() {
        date '+%m月%d日 %H:%M'
    }

    # Assemble final output based on enabled components
    main() {
        local cpu_usage
        local ram_usage
        local network_stats=""
        local tx_rate=""
        local rx_rate=""
        local current_time=""

        cpu_usage=$(get_cpu_usage)
        ram_usage=$(get_ram_usage)

        if [[ "''$show_network" == true ]]; then
            network_stats=$(get_network_stats)
            tx_rate=$(echo "''$network_stats" | cut -d'|' -f1)
            rx_rate=$(echo "''$network_stats" | cut -d'|' -f2)
        fi

        if [[ "''$show_time" == true ]]; then
            current_time=$(get_current_time)
        fi

        # Build output string, inserting separator between each part
        local output=""
        output+="''${CPU_ICON} ''${cpu_usage}"
        output+="''${SEPARATOR}''${RAM_ICON} ''${ram_usage}"
        if [[ "''$show_network" == true ]]; then
            output+="''${SEPARATOR}''${UP_ICON} ''${tx_rate}"
            output+="''${SEPARATOR}''${DOWN_ICON} ''${rx_rate}"
        fi
        if [[ "''$show_time" == true ]]; then
            output+="''${SEPARATOR}''${current_time}"
        fi

        echo "''$output"
    }

    # No-op cleanup (placeholder for future use)
    cleanup() {
        :
    }

    trap cleanup EXIT
    main
  '';

  meta = with lib; {
    # description = "A high-performance system status monitor for tmux with automatic unit scaling";
    # homepage = "";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
    mainProgram = "system-status";
  };
}
