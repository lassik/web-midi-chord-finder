import WebMidi exposing (..)
import Graphics.Element exposing (Element, show)
import Signal exposing (..)
import Task exposing (Task)
import List
import Set
import Maybe exposing (..)
import Array

-- Patch current deficiencies in the Elm core Set library
setsAreEqual a b = (a |> Set.toList |> List.sort) == (b |> Set.toList |> List.sort)
isSubset super sub = setsAreEqual sub (Set.intersect super sub)

{- basic plumbing just to get the WebMidi init task run -}
myTaskMailbox = mailbox WebMidi.init
port myTaskPort : Signal (Task () ())
port myTaskPort = myTaskMailbox.signal

middleC = 60
pitchClassCount = 12
allPitchClasses = [0..pitchClassCount-1]
pitchClass pitch = (middleC + pitch) % pitchClassCount
pitchClassSet pitches = Set.map pitchClass pitches
noteNames = Array.fromList ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
noteName pitch = Array.get (pitchClass pitch) noteNames |> withDefault "C"

majorIntervals = [2, 2, 1, 2, 2, 2]
naturalMinorIntervals = [2, 1, 2, 2, 1, 2]

scale intervals root = List.scanl (+) root intervals
buildScale name intervals rootPitchClass =
  { name = (noteName rootPitchClass)++" "++name
  , pitchClassSet = pitchClassSet (Set.fromList (scale intervals rootPitchClass))
  }

allScalesLike name intervals = List.map (buildScale name intervals) allPitchClasses
allMajorScales = allScalesLike "major" majorIntervals
allMinorScales = allScalesLike "minor" naturalMinorIntervals
allScales = allMajorScales ++ allMinorScales
scalesWithPitchClasses set = if Set.isEmpty set then [] else List.filter (\scale -> isSubset scale.pitchClassSet set) allScales
scalesWithPitches pitches = pitches |> pitchClassSet |> scalesWithPitchClasses

lowestNote set = set |> Set.toList |> List.sort |> List.head
pitchSetToScale set = lowestNote set `andThen` (\root -> Just (scale majorIntervals root |> List.map pitchClass))

update m set = (if m.noteOn then Set.insert else Set.remove) m.pitch set
depressedPitchSet = foldp update Set.empty midiNoteS
main = depressedPitchSet |> Signal.map pitchClassSet
     |> Signal.map scalesWithPitchClasses |> Signal.map (\xs -> (List.map .name xs))
     |> Signal.map show
