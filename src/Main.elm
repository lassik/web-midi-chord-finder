module Main exposing (main)

import Array
import CoMidi
import Html
import List
import MidiTypes
import Set
import WebMidi


type alias Model =
    { depressedPitchSet : Set.Set Int }


type Msg
    = MidiMessage WebMidi.Message



-- Patch current deficiencies in the Elm core Set library


setsAreEqual a b =
    (a |> Set.toList |> List.sort) == (b |> Set.toList |> List.sort)


isSubset super sub =
    setsAreEqual sub (Set.intersect super sub)


middleC =
    60


pitchClassCount =
    12


allPitchClasses =
    List.range 0 (pitchClassCount - 1)


pitchClass pitch =
    (middleC + pitch) % pitchClassCount


pitchClassSet pitches =
    Set.map pitchClass pitches


noteNames =
    Array.fromList [ "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" ]


noteName pitch =
    Array.get (pitchClass pitch) noteNames |> Maybe.withDefault "C"


majorTriad =
    [ 4, 3 ]


minorTriad =
    [ 3, 4 ]


majorIntervals =
    [ 2, 2, 1, 2, 2, 2 ]


naturalMinorIntervals =
    [ 2, 1, 2, 2, 1, 2 ]


scale intervals root =
    List.scanl (+) root intervals


buildScale name intervals rootPitchClass =
    { name = noteName rootPitchClass ++ " " ++ name
    , pitchClassSet = pitchClassSet (Set.fromList (scale intervals rootPitchClass))
    }


allScalesLike name intervals =
    List.map (buildScale name intervals) allPitchClasses


allMajorScales =
    allScalesLike "major" majorTriad



--majorIntervals


allMinorScales =
    allScalesLike "minor" minorTriad



--naturalMinorIntervals


allScales =
    allMajorScales ++ allMinorScales


scalesWithPitchClasses set =
    if Set.isEmpty set then
        []
    else
        List.filter (\scale -> isSubset scale.pitchClassSet set) allScales


scalesWithPitches pitches =
    pitches |> pitchClassSet |> scalesWithPitchClasses


lowestNote : Set.Set Int -> Maybe Int
lowestNote set =
    set |> Set.toList |> List.sort |> List.head


pitchSetToScale set =
    lowestNote set |> Maybe.andThen (\root -> Just (scale majorIntervals root |> List.map pitchClass))


stringsToUl : List String -> Html.Html Msg
stringsToUl strings =
    strings |> List.map (\x -> Html.li [] [ Html.text x ]) |> Html.ul []


init : ( Model, Cmd Msg )
init =
    ( { depressedPitchSet = Set.empty }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    WebMidi.onMidiMessage MidiMessage


updatePitchSet : Result String MidiTypes.MidiEvent -> Set.Set Int -> Set.Set Int
updatePitchSet midiEvent set =
    case midiEvent of
        Ok (MidiTypes.NoteOn chan pitch velo) ->
            Set.insert pitch set

        Ok (MidiTypes.NoteOff chan pitch velo) ->
            Set.remove pitch set

        _ ->
            set


update : Msg -> Model -> ( Model, Cmd Msg )
update (MidiMessage message) model =
    let
        midiEvent =
            message.midiEvent |> CoMidi.parseMidiEvent
    in
    ( { model | depressedPitchSet = updatePitchSet midiEvent model.depressedPitchSet }
    , Cmd.none
    )


view : Model -> Html.Html Msg
view model =
    model.depressedPitchSet
        |> pitchClassSet
        |> scalesWithPitchClasses
        |> List.map .name
        |> stringsToUl


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
