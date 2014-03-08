package de.grammarcraft.xtend.firstflow

import java.util.ArrayList
import java.util.List

package class OutputPin<MessageType> {
    
    String name
    (Exception)=>void errorOperation
    
    new(String name, (Exception)=>void errorOperation) {
        this.name = name
        this.errorOperation = errorOperation
    }

    override toString() { this.name }

    private val List<(MessageType)=>void> outputOperations = new ArrayList
    
    
    def forward(MessageType msg) {
        if (!outputOperations.empty) {
            outputOperations.forEach[
                operation | operation.apply(msg)
            ]
        }
        else {
            errorOperation.apply(
                new RuntimeException(
                    '''no binding defined for '«this»' - message '«msg»' could not be delivered.'''))
        }
    }
    
    // defines operator "->", used as function unit connector
    def void operator_mappedTo((MessageType)=>void operation) {
        outputOperations.add(operation)
    }
    
}