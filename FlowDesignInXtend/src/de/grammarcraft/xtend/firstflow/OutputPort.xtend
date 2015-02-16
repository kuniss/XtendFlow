package de.grammarcraft.xtend.firstflow

import java.util.ArrayList
import java.util.List

package class OutputPort<MessageType> {
    
    String name
    (Exception)=>void errorOperation
    
    new(String name, (Exception)=>void errorOperation) {
        this.name = name
        this.errorOperation = errorOperation
    }

    override toString() { this.name }

    private val List<(MessageType)=>void> outputOperations = new ArrayList
    
    private def forward(MessageType msg) {
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
    
    /**
     * Wiring operation of the flow DSL.<br>
     * Connects function unit own output port <i>fu.output</i> to an 
     * anonymous closure (which may have side effects).<br>
     * E.g.: fu.output -> [closure]
     */
    def void -> ((MessageType)=>void operation) {
        outputOperations.add(operation)
    }

    /**
     * Wiring operation of the flow DSL.<br>
     * Connects function unit own output port <i>fu.output</i> to an 
     * foreign function unit with one and only one input port.<br>
     * E.g.: fu.output -> fu'
     */
    def void -> (FunctionUnitWithOnlyOneInputPort<MessageType> foreignFu) {
        outputOperations.add(foreignFu.theOneAndOnlyInputPort.inputProcessingOperation)
    }
    
    /**
     * Wiring operation of the flow DSL.<br>
     * Connects function unit own output port <i>fu.output</i> to a 
     * named input port of a foreign function unit.<br>
     * E.g.: fu.output -> fu'.input
     */
    def void -> (InputPort<MessageType> foreignInputPort) {
        outputOperations.add(foreignInputPort.inputProcessingOperation)
    }

    /**
     * Wiring operation of the flow DSL.<br>
     * Connects function unit own output port <i>fu.output</i> to an 
     * anonymous closure (which may have side effects).<br>
     * E.g.: fu.output -> fu'
     */
    def void -> (OutputPort<MessageType> ownOutputPort) {
        outputOperations.add([msg|ownOutputPort.forward(msg)])
    }
    
    
    /**
     * Forward operation of the flow DSL.<br>
     * Forwards a message value to an function unit own output port <i>fu.output</i>.<br>
     * E.g.: .output <= output value<br>
     * This is typically used inside the implementation of function unit to forward 
     * results of the function unit's computation to outside over outut ports.
     */
    def void <= (MessageType msg) {
        forward(msg);
    }
    
    /**
     * Forward operation of the flow DSL.<br>
     * Forwards a message value to an function unit own output port <i>fu.output</i>.<br>
     * E.g.: .output <= [closure computing output value]<br>
     * This is typically used inside the implementation of function unit to forward 
     * results of the function unit's computation to outside over outut ports.
     */
    def void <= (()=>MessageType msgClosure) {
        forward(msgClosure.apply)
    }
    
}