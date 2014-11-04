package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.FunctionUnit
import de.grammarcraft.xtend.flow.annotations.InputPort
import de.grammarcraft.xtend.flow.annotations.OutputPort
import de.grammarcraft.xtend.flow.annotations.Wiring

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
    
    @Wiring
    private def void wiring() { 
        toLower.output -> [msg | lower.forward(msg)]
        toUpper.output -> [msg | upper.forward(msg)]
    }

    override processInput(String msg) {
        toLower.input(msg)
        toUpper.input(msg)
    }
    
}