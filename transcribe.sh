#!/usr/bin/env sh
set -eu

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <audio-file>" >&2
  exit 1
fi

AUDIO_FILE="$1"

if [ ! -f "$AUDIO_FILE" ]; then
  echo "Error: file not found: $AUDIO_FILE" >&2
  exit 1
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "Error: OPENAI_API_KEY is not set" >&2
  exit 1
fi

OUTPUT_FILE="${AUDIO_FILE%.*}.txt"

if [ -f "$OUTPUT_FILE" ]; then
  echo "Transcription already exists at $OUTPUT_FILE; skipping."
  exit 0
fi

LANGUAGE_ARG=""
if [ -n "${WHISPER_LANGUAGE:-}" ]; then
  LANGUAGE_ARG="-F language=$WHISPER_LANGUAGE"
fi

curl -sS https://api.openai.com/v1/audio/transcriptions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F "model=whisper-1" \
  -F "response_format=text" \
  $LANGUAGE_ARG \
  -F "file=@${AUDIO_FILE}" \
  -o "$OUTPUT_FILE"

echo "Wrote transcription to $OUTPUT_FILE"
