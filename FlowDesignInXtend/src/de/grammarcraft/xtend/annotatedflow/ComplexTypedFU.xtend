package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.Operation
import de.grammarcraft.xtend.flow.annotations.Port
import de.grammarcraft.xtend.flow.annotations.Unit
import java.util.List

@Operation @Unit(
        inputPorts = #[
            @Port(name="input", type=List, typeArguments=#[String])
        ],
        outputPorts = #[
            @Port(name="output", type=List, typeArguments=#[String])
        ]
    )
class ComplextypedFU {
    
    override process$input(List<String> msg) {
        output <= msg
    }

}
