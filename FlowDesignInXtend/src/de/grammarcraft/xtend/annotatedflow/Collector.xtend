package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.FunctionUnit
import de.grammarcraft.xtend.flow.annotations.InputPin
import de.grammarcraft.xtend.flow.annotations.OutputPin
import java.util.List
import java.util.ArrayList

@FunctionUnit(
    inputPins = #[
        @InputPin(name="lower", type=String),
        @InputPin(name="upper", type=String)
    ],
    outputPins = #[
        @OutputPin(name="output", type=String),
        @OutputPin(name="error", type=String)
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