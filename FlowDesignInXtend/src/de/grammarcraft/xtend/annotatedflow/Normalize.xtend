package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.OutputPin
import de.grammarcraft.xtend.flow.annotations.InputPin
import de.grammarcraft.xtend.flow.annotations.FunctionUnit

@FunctionUnit(
    inputPins = #[
        @InputPin(name="input", type=String)
    ],
    outputPins = #[
        @OutputPin(name="lower", type=String),
        @OutputPin(name="upper", type=String)
    ]
)
class Normalize {
    
    new() {
        bind();
    }
    
    val toLower = new ToLower
    val toUpper = new ToUpper
    
    private def bind() { // warning comes from an error in Xtend
        toLower -> [msg | lower.forward(msg)]
        toUpper -> [msg | upper.forward(msg)]
    }
    
    override processInput(String msg) {
        toLower.input(msg)
        toUpper.input(msg)
    }
    
}