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
        bind();
    }
    
    private def bind() { // warning comes from an error in Xtend
        // the error will be solved with Xtend release subsequent to 2.5.4
        // see also https://bugs.eclipse.org/bugs/show_bug.cgi?id=430489 
        toLower.output -> [msg | lower.forward(msg)]
        toUpper.output -> [msg | upper.forward(msg)]
    }
    
    override processInput(String msg) {
        toLower.input(msg)
        toUpper.input(msg)
    }
    
}