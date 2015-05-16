package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.Integration
import de.grammarcraft.xtend.flow.annotations.Port
import de.grammarcraft.xtend.flow.annotations.Unit

/**
 * Normalizes the incoming string by converting all character 
 * to lower and to upper case and forwards the result of that to
 * 'lower' and 'upper' ports respectively.
 */
@Integration @Unit(
    inputPorts = #[
        @Port(name="input", type=String)
    ],
    outputPorts = #[
        @Port(name="lower", type=String),
        @Port(name="upper", type=String)
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