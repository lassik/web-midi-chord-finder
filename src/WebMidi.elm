port module WebMidi exposing (..)

import Char
import String


type alias Message =
    { midiEvent : String }


port onMidiMessage : (Message -> msg) -> Sub msg


emptyMessage : Message
emptyMessage =
    { midiEvent = String.repeat 3 (String.fromChar (Char.fromCode 0)) }
