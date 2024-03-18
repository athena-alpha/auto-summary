# Auto Summary
This is a VERY rough bash script that automatically summarizes any YouTube link or local PDF, audio or video file. All processing is done locally and thus requires a decent CPU and/or GPU for the two AI's to run.

## REQUIREMENTS
**Ubuntu 22:** While there's no reason why the Auto Summary script couldn't be adapted to run on Windows, macOS etc, we'll leave that to others.

## INSTALLATION & RUNNING
To perform the text summarization part, Auto Summary relies on open source Large Language Model (LLM) AIs run via (LM Studio)[https://lmstudio.ai/].

1. Download and install (LM Studio)[https://lmstudio.ai/]

2. LM Studio and download any appropriate LLM that works for your machine
![image](https://github.com/athena-alpha/auto-summary/assets/97640728/86d7dd00-e64d-409e-8a43-820665728cb9)

3. In LM Studio navigate to the Local Server area (see the side menu), select your LLM and click Start Server
![image](https://github.com/athena-alpha/auto-summary/assets/97640728/f37d94f2-2c21-47fe-a428-79ee305d42bd)

4. In a terminal window run Auto Summary:

YouTube Summary Example:
<code>./auto-summary.sh https://www.youtube.com/watch?v=dQw4w9WgXcQ</code>

Local PDF Example:
<code>./auto-summary.sh highly_technical_scientific_paper.pdf</code>

Local Audio/Video Example:
<code>./auto-summary.sh highly_questionable_video_file.mp4</code>

Auto Summary will automatically detect and install a few required programs on its first run, so you don't need to  including:
- (yt-dlp)[https://github.com/yt-dlp/yt-dlp] (used to download and extract YouTube audio)
- (Whisper)[https://github.com/openai/whisper] (used to transacribe audio or video to text)
- (jq)[https://jqlang.github.io/jq/] (used to process the API JSON replies).
