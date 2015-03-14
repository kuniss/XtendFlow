/*******************************************************************************
 * Copyright (c) 2014 Denis Kuniss (http://www.grammarcraft.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/

package de.grammarcraft.xtend.flow

import java.util.ArrayList
import java.util.List

class OutputPort<MessageType> {
    
    val String name
    val (Exception)=>void integrationErrorOperation
    
    /**
     * Creates a named output port with the given port name.
     * @param name the name of the port
     * @param integrationErrorOperation the closure to be executed if no foreign input port at all has been bound to this output port
     */
    new(String name, (Exception)=>void integrationErrorOperation) {
        this.name = name
        this.integrationErrorOperation = integrationErrorOperation
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
            integrationErrorOperation.apply(
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