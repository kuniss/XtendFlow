package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.FunctionUnit
import de.grammarcraft.xtend.flow.annotations.OutputPin
import de.grammarcraft.xtend.flow.annotations.InputPin

@FunctionUnit(
    inputPins = #[
        @InputPin(name="input", type=String)
    ],
    outputPins = #[
        @OutputPin(name="output", type=String)
    ]
)
class ToUpper {

    override processInput(String msg) {
        output.forward(msg.toUpperCase);
    }
    
}

