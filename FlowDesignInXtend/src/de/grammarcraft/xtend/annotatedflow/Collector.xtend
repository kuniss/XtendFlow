package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.FunctionUnit
import java.util.List
import java.util.ArrayList
import de.grammarcraft.xtend.flow.annotations.InputPort
import de.grammarcraft.xtend.flow.annotations.OutputPort

/**
 * Collects the input arriving over ports 'lower' and 'upper' 
 * by concatenating them and forwards the concatenation result
 * to port 'output'.
 */
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

    new() {
        this.separator = ", ";
    }
    
    new(String separator) {
        this.separator = separator;
    }
    
    override process$lower(String msg) {
        accumulateInput(msg)
    }
    
    override process$upper(String msg) {
        accumulateInput(msg)
    }
    
    var String separator
    val List<String> accumulation = new ArrayList

    // This method implements the semantic of the function unit      
    private def accumulateInput(String msg) {
        if (accumulation.length >= 2) 
            error <= this + ' got more than two input messages; not allowed'
        accumulation.add(msg)
        if (accumulation.length == 2) 
            output <= [
                accumulation.join(separator)
            ]
    }
    
    
}
