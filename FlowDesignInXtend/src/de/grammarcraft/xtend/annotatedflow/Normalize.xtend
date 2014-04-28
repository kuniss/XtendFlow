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