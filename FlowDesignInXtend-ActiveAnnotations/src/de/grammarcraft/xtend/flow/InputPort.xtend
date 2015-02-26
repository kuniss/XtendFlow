/*******************************************************************************
 * Copyright (c) 2015 Denis Kuniss (http://www.grammarcraft.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/

package de.grammarcraft.xtend.flow

class InputPort<MessageType> {

    val String name
    (MessageType)=>void processInputOperation
    val (Exception)=>void integrationErrorOperation

    /**
     * Creates a named input port with the given port name.
     * @param name the name of the port
     * @param processInputOperation the closure to be applied to an input message received over this port
     * @param intergationErrorOperation the closure to be executed if the input processing closure given before is null
     */
    new(String name, (MessageType)=>void processInputOperation, (Exception)=>void integrationErrorOperation) {
        this.name = name
        this.processInputOperation = processInputOperation
        this.integrationErrorOperation = integrationErrorOperation
    }
    
    /**
     * Creates a named input port with the given port name without predefined input processing closure.<br>
     * This is intended to be used inside integration function units where the input processing closure is defined at the constructor by
     * an dedicated wiring operation.
     * @param name the name of the port
     * @param intergationErrorOperation the closure to be executed if the input processing closure is not defined
     */
    new(String name, (Exception)=>void errorOperation) {
        this(name, null, errorOperation)    
    }
    
    override toString() { this.name }
    
    private def processInput(MessageType msg) {
        if (processInputOperation == null) {
            integrationErrorOperation.apply(
                new RuntimeException(
                    '''no binding defined for '«this»' - message '«msg»' could not be processed.'''))
        }
        else {
            processInputOperation.apply(msg)
        }
    }
    
    /**
     * Forward operation of the flow DSL.<br>
     * Forwards a message value to the function unit's input port <i>fu.input</i>.<br>
     * E.g.: fu.input <= input value<br>
     * This is typically used to provide an initial value to the function unit's flow this 
     * input port belongs to.
     */
    def void <= (MessageType msg) {
        processInput(msg)
    }
    
    /**
     * Forward operation of the flow DSL.<br>
     * Forwards a message value computed by the passed closure to the function unit's input port <i>fu.input</i>.<br>
     * E.g.: fu.input <= input value<br>
     * This is typically used to provide an initial value to the function unit's flow this 
     * input port belongs to.
     */
    def void <= (()=>MessageType msgClosure) {
        processInput(msgClosure.apply)
    }
    
    def (MessageType)=>void inputProcessingOperation() {
        return this.processInputOperation
    }
    
    /**
     * Wiring operation of the flow DSL.<br>
     * Connects function unit own input port <i>input</i> to a 
     * named input port of an integrated function unit.<br>
     * E.g.: .input -> fu'.input<br>
     * This is typically used to forward input messages inside an integration function unit to 
     * the an input port of an function unit which is integrated.
     */
    def void -> (InputPort<MessageType> integratedInputPort) {
        this.processInputOperation = integratedInputPort.inputProcessingOperation
    }
      
    /**
     * Wiring operation of the flow DSL.<br>
     * Connects function unit own input port <i>input</i> to the one and only one 
     * input port of an integrated function unit.<br>
     * E.g.: .input -> fu'<br>
     * This is typically used to forward input messages inside an integration function unit to 
     * the an input port of an function unit which is integrated.
     */
    def void -> (FunctionUnitWithOnlyOneInputPort<MessageType> integratedFunctionUnit) {
        this.processInputOperation = integratedFunctionUnit.theOneAndOnlyInputPort.inputProcessingOperation
    }

}