import WebMidi exposing (..)
import Graphics.Element exposing (Element, show)
import Signal exposing (..)
import Task exposing (Task)
import Set

{- basic plumbing just to get the WebMidi init task run -}
myTaskMailbox = mailbox WebMidi.init
port myTaskPort : Signal (Task () ())
port myTaskPort = myTaskMailbox.signal

update m set = (if m.noteOn then Set.insert else Set.remove) m.pitch set
pitchSet = foldp update Set.empty midiNoteS
main = pitchSet |> Signal.map show
