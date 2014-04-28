package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.FunctionUnit
import java.util.List
import java.util.ArrayList
import de.grammarcraft.xtend.flow.annotations.InputPort
import de.grammarcraft.xtend.flow.annotations.OutputPort

@FunctionUnit(
    inputPorts = #[
        @InputPort(name="lower", type=String),
        @InputPort(name="upper", type=String)
    ],
    outputPorts = #[
        @OutputPort(name="output", type=String),
        @OutputPort(name="error", type=String)
    ]
)
class Collector {
    
    new(String separator) {
        this.separator = separator;
    }
    
    override processLower(String msg) {
        if (accumulation.length >= 2) 
            error.forward(this + ' got more than two input messages; not allowed')
        accumulateInput(msg)
    }
    
    override processUpper(String msg) {
        if (accumulation.length >= 2) 
            error.forward(this + ' got more than two input messages; not allowed')
        accumulateInput(msg)
    }
    
    var String separator
    val List<String> accumulation = new ArrayList

    // This method implements the semantic of the function unit      
    private def accumulateInput(String msg) {
        accumulation.add(msg)
        if (accumulation.length == 2) output.forward(accumulation.join(separator))
    }
    
    
    
}