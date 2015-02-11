package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.FunctionUnit
import de.grammarcraft.xtend.flow.annotations.InputPort
import de.grammarcraft.xtend.flow.annotations.OutputPort

@FunctionUnit(
    inputPorts = #[
        @InputPort(name="input", type=String)
    ],
    outputPorts = #[
        @OutputPort(name="lower", type=String),
        @OutputPort(name="upper", type=String)
    ]
)
class Normalize {
    
    val toLower = new ToLower
    val toUpper = new ToUpper
    
    new() { 
        toLower.output -> lower
        toUpper.output -> upper
    }

    override processInput(String msg) {
        toLower.input(msg)
        toUpper.input(msg)
    }
    
}