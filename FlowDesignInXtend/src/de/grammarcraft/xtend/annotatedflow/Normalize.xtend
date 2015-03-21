package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.FunctionBoard
import de.grammarcraft.xtend.flow.annotations.InputPort
import de.grammarcraft.xtend.flow.annotations.OutputPort

/**
 * Normalizes the incoming string by converting all character 
 * to lower and to upper case and forwards the result of that to
 * 'lower' and 'upper' ports respectively.
 */
@FunctionBoard(
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
        input -> toLower
        input -> toUpper
    }

}