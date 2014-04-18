package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.InputPin
import de.grammarcraft.xtend.flow.annotations.FunctionUnit
import de.grammarcraft.xtend.flow.annotations.OutputPin

@FunctionUnit(
    inputPins = #[
        @InputPin(name="input", type=String)
    ],
    outputPins = #[
        @OutputPin(name="ausgabe", type=String)
    ]
)
class ToLower {
    
    // This method implements the semantic of the function unit
    override processInput(String msg) {
        ausgabe.forward(msg.toLowerCase);
    }
        
}