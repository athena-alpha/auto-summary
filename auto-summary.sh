#!/bin/bash

# Check if URL or file is provided as argument
if [ $# -eq 0 ]
then
    read -p "Error: Please provide a YouTube URL or a local file path of type video, audio or PDF: " input
else
    input=$1
    input_cleaned=$(basename "$input" | sed 's/\.[^.]*$//')
    input_no_extension=${input_cleaned%.*}
fi

# Check if all required programs are installed and available

if ! command -v jq &> /dev/null # Used to read in and extract API responses
then
    echo
    echo "You don't have jq, so let's install it..."
    echo "--------------------------------------"
    sudo apt-get install -y jq
    echo
    echo "Installation complete"
    echo "--------------------------------------"
fi

if ! command -v yt-dlp &> /dev/null # Used to download YouTube videos
then
    echo
    echo "You don't have yt-dlp, so let's install it..."
    echo "--------------------------------------"
    if ! command -v ffmpeg &> /dev/null # Required for yt-dlp
    then
        sudo apt update && sudo apt install -y ffmpeg
    fi
    sudo add-apt-repository -y ppa:tomtomtom/yt-dlp
    sudo apt update && sudo apt install -y yt-dlp
    echo
    echo "Installation complete"
    echo "--------------------------------------"
fi

if ! command -v ~/.local/bin/whisper &> /dev/null # Used to transcribe audio/video to text
then
    echo
    echo "You don't have whisper, so let's install it (requires ~2.8 GB download)..."
    echo "--------------------------------------"
    if ! command -v pip &> /dev/null # Used to install Whisper
    then
        sudo apt update && sudo apt install -y pip
    fi
    pip install -U openai-whisper
    echo
    echo "Installation complete"
    echo "--------------------------------------"
fi

# Set the mode based on the input given and transcribe into text

if [[ $input == https://www.youtube.com* ]]; then
    # YouTube Mode: Need to download the video as an MP3 and also get its title
    TITLE=$(yt-dlp --quiet --no-warnings --get-title $input)
    DURATION=$(yt-dlp --quiet --no-warnings --get-duration $input)
    echo
    echo "Welcome! Summarising: $TITLE (Video Duration: $DURATION)"
    echo "--------------------------------------"
    echo "Step 1: Downloading and extracting audio from YouTube using yt-dlp..."
    yt-dlp --quiet --no-warnings --output extracted-audio-temp.mp3 --extract-audio --audio-format mp3 $input >> /dev/null

    # Transacribe files via Whisper
    echo "Step 2: Transcribing with Whisper..."
    ~/.local/bin/whisper "extracted-audio-temp.mp3" --model small >> /dev/null

    text_to_summarise=$(<"extracted-audio-temp.txt")

elif [[ $input == *.pdf ]]; then
    # PDF Mode: Need to convert the PDF into a text file then jump straight to LLM
    TITLE=$input_cleaned
    echo
    echo "Welcome! Summarising PDF: $input"
    echo "--------------------------------------"
    echo "Step 1: Local PFD detected, extracting text from PDF file..."
    pdftotext "$input" extracted-pdf-temp.txt
    text_to_summarise=$(<"extracted-pdf-temp.txt")

    echo "Step 2: File is a PDF, so no need for transcription"

else
    # Local File Mode: Assume the input is a local file of type audio or video
    TITLE=$input_cleaned
    echo
    echo "Welcome! Summarising: $input"
    echo "--------------------------------------"
    echo "Step 1: Local audio/video file detected, so no need for yt-dlp..."

    # Transacribe files via Whisper
    echo "Step 2: Transcribing with Whisper..."
    ~/.local/bin/whisper "$input" --model small >> /dev/null

    text_to_summarise=$(<"${input_no_extension}.txt")

fi

# Get LLM summary of text
echo "Step 3: Summarising text with LLM..."
echo
echo "Here's you summary!"
echo "--------------------------------------"

# Remove special characters and replace spaces with dashes in the title
# This is used as the final output file for the summarized text
output_filename=$(echo "$TITLE" | sed 's/[^[:alnum:]]/-/g; s/--/-/g; s/^-//; s/-$//; s/-*$//')

# Set the chunk size, if text is more than this size, it's split up and sent
# to the LLM in grounps so it doesn't overload the context length
CHUNK_SIZE=20000
start=0

# Split the text into chunks and submit each chunk to LLM one by one
while [ $start -lt ${#text_to_summarise} ]; do

    # Setup the text chunk and sanitize it
    chunk="${text_to_summarise:$start:$CHUNK_SIZE}"
    chunk=$(echo "$chunk" | tr -d '\n\r' | tr -cd '\11\12\15\40-\176'  | sed 's/\\/\\\\/g; s/"/\\"/g')
    start=$((start + CHUNK_SIZE))

    # API request to LLM for summary
    api_response=$(curl -s http://localhost:1234/v1/chat/completions \
        -H "Content-Type: application/json" \
        -d '{ 
        "messages": [ 
            {"role": "system", "content": "Summarize the following in dots point form"},
            {"role": "user", "content": "'"$chunk"'"}
        ], 
        "temperature": 0, 
        "max_tokens": -1,
        "stream": false
        }
    ')
        
    # Extract content from the processed API response
    output=$(echo "$api_response" | jq -r '.choices[0].message.content')

    # Output the summary to the terminal
    echo "$output"
    # Also save the summary to the text file
    echo "$output" > "${output_filename}.txt"

done

echo "--------------------------------------"
echo "Summary saved to ${output_filename}.txt"

# Clean up temp files
if [ -f "${input_no_extension}.mp3" ]; then
    rm "${input_no_extension}.mp3"
fi
if [ -f "${input_no_extension}.json" ]; then
    rm "${input_no_extension}.json"
fi
if [ -f "${input_no_extension}.srt" ]; then
    rm "${input_no_extension}.srt"
fi
if [ -f "${input_no_extension}.tsv" ]; then
    rm "${input_no_extension}.tsv"
fi
if [ -f "${input_no_extension}.vtt" ]; then
    rm "${input_no_extension}.vtt"
fi
if [ -f "${input_no_extension}.txt" ]; then
    rm "${input_no_extension}.txt"
fi

if [ -f "extracted-pdf-temp.txt" ]; then
    rm "extracted-pdf-temp.txt"
fi

if [ -f "extracted-audio-temp.mp3" ]; then
    rm "extracted-audio-temp.mp3"
fi
if [ -f "extracted-audio-temp.json" ]; then
    rm "extracted-audio-temp.json"
fi
if [ -f "extracted-audio-temp.srt" ]; then
    rm "extracted-audio-temp.srt"
fi
if [ -f "extracted-audio-temp.tsv" ]; then
    rm "extracted-audio-temp.tsv"
fi
if [ -f "extracted-audio-temp.vtt" ]; then
    rm "extracted-audio-temp.vtt"
fi
if [ -f "extracted-audio-temp.txt" ]; then
    rm "extracted-audio-temp.txt"
fi
echo
