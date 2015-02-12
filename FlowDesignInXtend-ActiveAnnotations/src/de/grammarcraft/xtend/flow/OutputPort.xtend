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
    
    /**
     * Convenience operator for forwarding a message value to the output port.<br>
     * Defines operator "&lt;=", used to forward a message value.<br>
     * Example:<pre> 
     *   output <= "some string"
     * </pre>
     */
    def void <= (MessageType msg) {
        forward(msg)
    }
    

    /**
     * Convenience operator for forwarding a message value to the output port.<br>
     * Defines operator "&lt;=", used to forward a message value computed from the passed closure.<br>
     * Example:<pre> 
     *   output &lt;= [ if (state &gt; 0) "some string" else "some other string" ]
     * </pre>
     */
    def void <= (()=>MessageType msgClosure) {
        forward(msgClosure.apply)
    }
    
    // defines operator "->", used as function unit connector
    def void ->((MessageType)=>void operation) {
        outputOperations.add(operation)
    }
    
    // convenient operator for connecting to function units defining one and only one input port:
    // defines operator "->", used as function unit connector
    def void ->(FunctionUnitBase fu) {
        outputOperations.add(fu.theOneAndOnlyInputPort)
    }
    
    // convenience operator for connecting from output port to output port when wiring in 
    // integration function units, see Normalize.xtend for example
    // defines operator "->", used as connector between an output port of an integrated function unit and an own output port
    def void ->(OutputPort<MessageType> outputPort) {
        outputOperations.add([msg|outputPort.forward(msg)])
    }
    
}