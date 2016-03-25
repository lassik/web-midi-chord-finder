import WebMidi exposing (..)
import Graphics.Element exposing (Element, show)
import Signal exposing (..)
import Task exposing (Task)
import List
import Set
import Maybe exposing (..)

{- basic plumbing just to get the WebMidi init task run -}
myTaskMailbox = mailbox WebMidi.init
port myTaskPort : Signal (Task () ())
port myTaskPort = myTaskMailbox.signal

majorScale = [2, 2, 1, 2, 2, 2]
naturalMinorScale = [2, 1, 2, 2, 1, 2]

scale intervals root = List.scanl (+) root intervals

update m set = (if m.noteOn then Set.insert else Set.remove) m.pitch set
pitchSet = foldp update Set.empty midiNoteS
pitchSetToScale set = (set |> Set.toList |> List.sort |> List.head) `andThen` (\root -> Just (scale majorScale root))
main =
  Signal.map pitchSetToScale pitchSet |> Signal.map show
