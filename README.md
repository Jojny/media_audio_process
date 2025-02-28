# 音频处理脚本

该脚本用于处理音频文件，包括从视频中分离音轨和根据配置文件裁剪音频。它支持多种文件类型，并允许根据配置进行音频提取和裁剪。

## 功能

- **音频提取**：从视频文件中提取音频，支持配置音频通道、采样率和位深。
- **音频裁剪**：根据配置文件中的开始时间和结束时间裁剪提取的音频。
- **交互式目录处理**：如果输出目录已存在，脚本会提示用户选择是否删除该目录。

## 先决条件

- `ffmpeg`：请确保系统上已安装 `ffmpeg`。可以从 [FFmpeg官网](https://ffmpeg.org/download.html) 下载。

## 配置文件

在与脚本相同的目录下创建 `config.toml` 文件，格式如下：

```toml
[input]
types = ["mp4", "mkv"]

[cut]
start_time = "00:01:30"
end_time = "00:02:30"

[audio]
channels = "stereo"  # 可选值: "mono", "stereo"
sample_rate = "44100" # 例如: 16000, 44100, 48000
bit_depth = "16"      # 例如: 16, 24
```

- **`types`**: 需要处理的文件类型列表（例如，"mp4", "mkv"）。
- **`start_time`**: 音频裁剪的开始时间（格式: HH:MM:SS）。
- **`end_time`**: 音频裁剪的结束时间（格式: HH:MM:SS）。
- **`channels`**: 音频通道，选项为 "mono"（单声道）或 "stereo"（立体声）。
- **`sample_rate`**: 采样率（Hz），例如 44100、48000。
- **`bit_depth`**: 位深，支持 16 位或 24 位。

## 使用方法

1. **使脚本可执行**：

   ```sh
   chmod +x media_audio_process.sh
   ```

2. **运行脚本**：

   ```sh
   ./media_audio_process.sh <input_directory> <output_directory>
   ```

   - `<input_directory>`：包含输入文件的目录。
   - `<output_directory>`：保存处理后文件的目录。

3. **处理已存在的输出目录**：

   - 如果输出目录已存在，脚本会提示你选择是否删除该目录。
   - 输入 `Y` 删除目录并继续处理。
   - 输入 `N` 退出脚本，不做任何更改。

## 示例

要处理 `videos` 目录中的音频文件，并将结果保存到 `processed_audio` 目录中，可以使用以下命令：

```sh
cd <文件所在目录> && ./media_audio_process.sh ../S01 S03
cd /cygdrive/d/media_audio_process && ./media_audio_process.sh /cygdrive/d/<input_directory> /cygdrive/d/<output_directory>
```

## 目录说明
- **默认情况下CYGWIN使用的window路径为**: `/cygdrive/d/`

## 故障排除

- **找不到 ffmpeg**：确保 `ffmpeg` 已安装并且在系统的 PATH 中。
- **配置问题**：确保 `config.toml` 文件格式正确，并且与脚本位于相同目录下。

## 许可

该脚本仅用于奥飞内部测试使用。

### 说明：

- **功能**：描述了脚本的主要功能和用途。
- **先决条件**：列出了运行脚本所需的依赖。
- **配置文件**：解释了 `config.toml` 文件的格式和选项。
- **使用方法**：提供了使脚本可执行和运行的步骤。
- **示例**：提供了一个实际运行脚本的示例。
- **故障排除**：提供了常见问题的解决方案。
- **许可**：说明脚本的许可类型。