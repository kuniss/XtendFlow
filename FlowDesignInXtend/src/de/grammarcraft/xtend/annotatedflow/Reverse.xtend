package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.InputPin
import de.grammarcraft.xtend.flow.annotations.FunctionUnit
import de.grammarcraft.xtend.flow.annotations.OutputPin

@FunctionUnit(
    inputPins = #[
        @InputPin(name="input", type=String)
    ],
    outputPins = #[
        @OutputPin(name="output", type=String)
    ]
)
class Reverse {
    
    // This method implements the semantic of the function unit      
    override processInput(String msg) {
        val reversedMsgBuilder = new StringBuilder
        var index = msg.length
        while (index > 0) {
            index = index - 1
            reversedMsgBuilder.append(msg.charAt(index))
        }
        output.forward(reversedMsgBuilder.toString)
    }
    
}