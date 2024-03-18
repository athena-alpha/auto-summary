# Auto Summary
**This is a VERY rough bash script that automatically summarizes any YouTube link or local PDF, audio or video file.**

All processing is done locally and thus, requires a decent CPU and/or GPU for it to run. Please don't expect any support or growth for this, it's just something we found useful to quickly and easily summarize all the various podcasts, YouTube videos, PDF files, videos and audio files that we come accross day to day.

Here is an example of it summarizing this 1.5 hour long [YouTube Podcast](https://www.youtube.com/watch?v=NOD4IBv5Oys). With a desktop CPU and modest GPU (eg. RTX 3060) it takes around 5 minutes.

![image](https://github.com/athena-alpha/auto-summary/assets/97640728/d5ef8808-24a0-48c8-bcb7-d6150a203eea)

## REQUIREMENTS
**Ubuntu:** As of now, the bash script only works on Ubuntu. While there's no reason why it couldn't be adapted to run on Windows, macOS etc, we'll leave that to others.

## INSTALLATION & RUNNING
1. Download and install [LM Studio](https://lmstudio.ai/) (Auto Summary relies on open source LLMs to do the summarizing)

2. In LM Studio download any appropriate LLM that works for your machine (**Search -> "Mistral" -> Download**)

![image](https://github.com/athena-alpha/auto-summary/assets/97640728/8f2e6b59-40f7-4659-9425-7be409ce9a88)

3. Once download, navigate to the **Local Server** area, select your LLM and click **Start Server**

![image](https://github.com/athena-alpha/auto-summary/assets/97640728/8a847d96-9faf-4ca7-934d-d7f96eecaff3)

4. In a terminal, download Auto Summary to your system and give it execution permission

```shell
gh repo clone athena-alpha/auto-summary
cd auto-summary && chmod +x auto-summary.sh
```

5. Run the Auto Summary script:

YouTube Summary Example:
```shell
./auto-summary.sh https://www.youtube.com/watch?v=dQw4w9WgXcQ
```

Local PDF Example:
```shell
./auto-summary.sh highly_technical_scientific_paper.pdf
```

Local Audio/Video Example:
```shell
./auto-summary.sh highly_questionable_video_file.mp4
```

Auto Summary will automatically detect and install a few required programs on its first run, so you don't need to  including:
- **[yt-dlp](https://github.com/yt-dlp/yt-dlp):** Used to download and extract YouTube audio
- **[Whisper](https://github.com/openai/whisper):** Used to transacribe audio or video to text
- **[jq](https://jqlang.github.io/jq/):** Uused to process the API JSON replies
