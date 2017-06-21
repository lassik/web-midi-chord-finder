"use strict";

var app;

function stringFromBytes(bytes) {
    return String.fromCharCode.apply(String, bytes);
}

function onMidiMessage(event) {
    app.ports.onMidiMessage.send({midiEvent: stringFromBytes(event.data)});
}

function initMidiPort(port) {
    if ((port.type === "input") && (port.state === "connected")) {
        console.log("MIDI input connected:", port);
        port.onmidimessage = onMidiMessage;
    }
}

function onMidiStateChange(event) {
    initMidiPort(event.port);
}

function initMidi(midi) {
    midi.inputs.forEach(initMidiPort);
    midi.onstatechange = onMidiStateChange;
}

if (navigator.requestMIDIAccess) {
    navigator.requestMIDIAccess().then(initMidi, console.log);
}

app = Elm.Main.fullscreen();
