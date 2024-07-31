#!/bin/bash

# bin
FFMPEG_BIN="./libs/ffmpeg/bin/ffmpeg.exe"

# �������Ƿ��㹻
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_directory> <output_directory>"
    exit 1
fi

# ��ȡ����
INPUT_DIR="$1"
OUTPUT_DIR="$2"
CONFIG_FILE="config.toml"

# ��������ļ��Ƿ����
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file $CONFIG_FILE not found!"
    exit 1
fi

# ������Ŀ¼�Ƿ����
if [ -d "$OUTPUT_DIR" ]; then
    read -p "Output directory $OUTPUT_DIR already exists. Do you want to delete it? (Y/N): " choice
    case "$choice" in
        [Yy]* )
            rm -rf "$OUTPUT_DIR"
            echo "Output directory $OUTPUT_DIR has been deleted."
            ;;
        [Nn]* )
            echo "Exiting without making changes."
            exit 1
            ;;
        * )
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
fi

# ��ȡ�����ļ��еĲ���
FILE_TYPES=$(grep 'types' $CONFIG_FILE | sed -e 's/types = \[\(.*\)\]/\1/' | tr -d '"' | tr ',' '|')
START_TIME=$(grep 'start_time' $CONFIG_FILE | awk -F'"' '{print $2}')
END_TIME=$(grep 'end_time' $CONFIG_FILE | awk -F'"' '{print $2}')
CHANNELS=$(grep 'channels' $CONFIG_FILE | awk -F'"' '{print $2}')
SAMPLE_RATE=$(grep 'sample_rate' $CONFIG_FILE | awk -F'"' '{print $2}')
BIT_DEPTH=$(grep 'bit_depth' $CONFIG_FILE | awk -F'"' '{print $2}')

# �������Ŀ¼
mkdir -p "$OUTPUT_DIR"

# ��׽ Ctrl+C �źŲ�����
trap "echo 'Script interrupted by user. Exiting...'; exit 1" SIGINT

# ������뺯��
separate_audio() {
    local input_file="$1"
    local output_audio="$2"

    # ������Ƶѡ��
    local channel_option=""
    if [ "$CHANNELS" = "mono" ]; then
        channel_option="-ac 1"
    elif [ "$CHANNELS" = "stereo" ]; then
        channel_option="-ac 2"
    fi

    local sample_rate_option=""
    if [ -n "$SAMPLE_RATE" ]; then
        sample_rate_option="-ar $SAMPLE_RATE"
    fi

    local bit_depth_option=""
    if [ "$BIT_DEPTH" = "24" ]; then
        bit_depth_option="-sample_fmt s32"
    elif [ "$BIT_DEPTH" = "16" ]; then
        bit_depth_option="-sample_fmt s16"
    fi

    ${FFMPEG_BIN} -i "$input_file" $channel_option $sample_rate_option $bit_depth_option -q:a 0 -map a "$output_audio"
}

# ��Ƶ�ü�����
cut_audio() {
    local input_audio="$1"
    local output_cut="$2"
    ${FFMPEG_BIN} -i "$input_audio" -ss "$START_TIME" -to "$END_TIME" -c copy "$output_cut"
}

# ����Ƿ��� Cygwin ������
is_cygwin() {
    case "$(uname -s)" in
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# �����ļ�����
find_files() {
    local regex_pattern="$1"
    regex_pattern="${regex_pattern//$'\r'/}"  # ȥ���س���
    local -n files_ref=$2  # ʹ���������ô�������

    if is_cygwin; then
        # Cygwin �����µ� find ��������
        while IFS= read -r -d $'\0' file; do
            files_ref+=("$(cygpath -w "$file")")  # ת��·����ʽΪ Windows ���
        done < <(find "$INPUT_DIR" -type f -regex ".*\.\($regex_pattern\)" -print0)
    else
        # �� Cygwin ����
        while IFS= read -r -d $'\0' file; do
            files_ref+=("$file")
        done < <(find "$INPUT_DIR" -type f -regex ".*\.\($regex_pattern\)" -print0)
    fi
}

# �����ļ�����
process_files() {
    local regex_pattern="$1"
    regex_pattern="${regex_pattern//$'\r'/}"  # ȥ���س���
    local files=()
    
    # �����ļ�
    find_files "$regex_pattern" files
    
    for FILE in "${files[@]}"; do
        if [ -f "$FILE" ]; then
            local BASENAME=$(basename "$FILE" | sed 's/\.[^.]*$//')
            local OUTPUT_AUDIO="$OUTPUT_DIR/${BASENAME}.mp3"
            local OUTPUT_CUT="$OUTPUT_DIR/${BASENAME}_cut.mp3"
            
            # �������
            separate_audio "$FILE" "$OUTPUT_AUDIO"
            
            # ��Ƶ�ü�
            cut_audio "$OUTPUT_AUDIO" "$OUTPUT_CUT"
        fi
    done
    echo "Processing completed!"
}

# ���������ļ�����
process_files "$FILE_TYPES"

echo "Processing completed!"
