package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.FunctionUnit
import de.grammarcraft.xtend.flow.annotations.InputPort
import de.grammarcraft.xtend.flow.annotations.OutputPort

@FunctionUnit(
    inputPorts = #[
        @InputPort(name="input", type=String)
    ],
    outputPorts = #[
        @OutputPort(name="output", type=String)
    ]
)
class ToLower {
    
    // This method implements the semantic of the function unit
    override processInput(String msg) {
        output.forward(msg.toLowerCase);
    }
        
}