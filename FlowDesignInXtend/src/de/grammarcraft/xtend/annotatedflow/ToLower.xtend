package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.FunctionUnit
import de.grammarcraft.xtend.flow.annotations.InputPort
import de.grammarcraft.xtend.flow.annotations.OutputPort

@FunctionUnit(
    inputPorts = #[
        @InputPort(name="input", type=String)
    ],
    outputPorts = #[
        @OutputPort(name="output", type=String)
    ]
)
class ToLower {
    
    // This method implements the semantic of the function unit
    override processInput(String msg) {
        output <= msg.toLowerCase;
    }
    
    /**
     * Convenience operator for forwarding a message value to the input port for being processed.<br>
     * Defines operator "&lt;=", used to forward a message value.<br>
     * example:<pre> 
     *   input <= "some string"
     * </pre>
     * Note: Will later be automatically generated by the FunctionUnit annotation. 
     * Here added only for exploring Xtend's embedded DSL design capabilities
     */
    def void <= (String msg) {
        input(msg)
    }
        
}