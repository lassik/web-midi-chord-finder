import WebMidi exposing (..)
import Graphics.Element exposing (Element, show)
import Signal exposing (..)
import Task exposing (Task)

{- basic plumbing just to get the WebMidi init task run -}
myTaskMailbox = mailbox WebMidi.init
port myTaskPort : Signal (Task () ())
port myTaskPort = myTaskMailbox.signal

main : Signal Element
main =
  Signal.map show midiNoteS
