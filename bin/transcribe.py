#!/usr/bin/env python

import signal
import time
from os import environ
from sys import argv

from deepgram import (
    DeepgramClient,
    FileSource,
    PrerecordedOptions,
    LiveOptions,
    LiveTranscriptionEvents,
    Microphone,
)

## NOTIFICATIONS



## SIGNAL HANDLER


def signal_handler(*_):
    global RUNNING_STATE
    RUNNING_STATE = False


RUNNING_STATE = True

signal.signal(signal.SIGUSR1, signal_handler)  # termination signal

## DEEPGRAM CLIENT


class Transcriber:
    client: DeepgramClient = DeepgramClient(environ["DEEPGRAM_API_KEY"])

    def from_mic(self) -> str:
        options = LiveOptions(
            model="nova-3",
            language="en-US",
            smart_format=True,
            encoding="linear16",
            channels=1,
            sample_rate=16000,
            interim_results=True,
            utterance_end_ms="1000",
            vad_events=True,
            endpointing=300,
        )
        addons = {"no_delay": "true"}

        transcript = []
        is_finals = []

        def on_message(_, result, **__):
            nonlocal is_finals, transcript
            sentence = result.channel.alternatives[0].transcript
            if len(sentence) == 0:
                return
            if result.is_final:
                is_finals.append(sentence)
                if result.speech_final:
                    transcript.append(" ".join(is_finals))
                    is_finals = []
            return

        connection = self.client.listen.websocket.v("1")
        connection.on(LiveTranscriptionEvents.Transcript, on_message)
        connection.start(options, addons=addons)

        microphone = Microphone(connection.send)
        microphone.start()

        while RUNNING_STATE:
            time.sleep(0.1)
        time.sleep(0.5)

        microphone.finish()
        connection.finish()

        return " ".join(transcript)

    def from_file(self, audio_file: str) -> str:
        with open(audio_file, "rb") as file:
            buffer_data = file.read()

        payload: FileSource = {
            "buffer": buffer_data,
        }

        options: PrerecordedOptions = PrerecordedOptions(
            model="nova-3",
            smart_format=True,
            utterances=True,
            punctuate=True,
            diarize=True,
        )

        response = self.client.listen.rest.v("1").transcribe_file(payload, options)

        return response.to_json(indent=4)


if __name__ == "__main__":
    transcribe = Transcriber()
    if len(argv) > 2:
        transcript = transcribe.from_file(argv[2])
    else:
        transcript = transcribe.from_mic()

    print(transcript)
