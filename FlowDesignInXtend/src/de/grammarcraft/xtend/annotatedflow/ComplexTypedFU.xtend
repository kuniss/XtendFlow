package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.FunctionUnit
import de.grammarcraft.xtend.flow.annotations.InputPin
import de.grammarcraft.xtend.flow.annotations.OutputPin
import java.util.List

@FunctionUnit(
        inputPins = #[
            @InputPin(name="input", type=List, typeParameters=#[String])
        ],
        outputPins = #[
            @OutputPin(name="output", type=List, typeParameters=#[String])
        ]
    )
class ComplextypedFU {
    
    override processInput(List<String> msg) {
        output.forward(msg)
    }
    
}
