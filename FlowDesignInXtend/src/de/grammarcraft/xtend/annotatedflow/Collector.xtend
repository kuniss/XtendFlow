package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.Operation
import de.grammarcraft.xtend.flow.annotations.Port
import de.grammarcraft.xtend.flow.annotations.Unit
import java.util.ArrayList
import java.util.List

/**
 * Collects the input arriving over ports 'lower' and 'upper' 
 * by concatenating them and forwards the concatenation result
 * to port 'output'.
 */
@Operation @Unit(
    inputPorts = #[
        @Port(name="lower", type=String),
        @Port(name="upper", type=String)
    ],
    outputPorts = #[
        @Port(name="output", type=String),
        @Port(name="error", type=String)
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
