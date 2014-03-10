package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.FunctionUnit
import de.grammarcraft.xtend.flow.annotations.InputPin
import de.grammarcraft.xtend.flow.annotations.OutputPin
import java.util.List
import java.util.ArrayList

@FunctionUnit(
    inputPins = #[
        @InputPin(name="input1", type=String),
        @InputPin(name="input2", type=String)
    ],
    outputPins = #[
        @OutputPin(name="output", type=String)
    ]
)
class Collector {
    
    new(String separator) {
        this.separator = separator;
    }
    
    override processInput1(String msg) {
        accumulateInput(msg)
    }
    
    override processInput2(String msg) {
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