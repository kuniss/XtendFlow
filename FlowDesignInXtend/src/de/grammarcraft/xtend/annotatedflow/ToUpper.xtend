package de.grammarcraft.xtend.annotatedflow

import de.grammarcraft.xtend.flow.annotations.InputPort
import de.grammarcraft.xtend.flow.annotations.Operation
import de.grammarcraft.xtend.flow.annotations.OutputPort
import de.grammarcraft.xtend.flow.annotations.Unit

@Operation @Unit(
    inputPorts = #[
        @InputPort(name="input", type=String)
    ],
    outputPorts = #[
        @OutputPort(name="output", type=String)
    ]
)
class ToUpper {

    override process$input(String msg) {
        output <= msg.toUpperCase;
    }

}

