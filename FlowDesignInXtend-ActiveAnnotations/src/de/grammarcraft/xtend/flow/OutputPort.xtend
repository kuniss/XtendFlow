package de.grammarcraft.xtend.flow

import java.util.ArrayList
import java.util.List

class OutputPort<MessageType> {
    
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
    
    // convenient operator for connecting to function units defining one and only one input port:
    // defines operator "->", used as function unit connector
    def void operator_mappedTo(FunctionUnitBase fu) {
        outputOperations.add(fu.theOneAndOnlyInputPort)
    }
    
    
}