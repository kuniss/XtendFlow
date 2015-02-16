package de.grammarcraft.xtend.firstflow

class InputPort<MessageType> {

    String name
    (MessageType)=>void processInputOperation
    
    new(String name, (MessageType)=>void processInputOperation) {
        this.name = name
        this.processInputOperation = processInputOperation
    }
    
    override toString() { this.name }
    
    /**
     * Forward operation of the flow DSL.<br>
     * Forwards a message value to the function unit's input port <i>fu.input</i>.<br>
     * E.g.: fu.input <= input value<br>
     * This is typically used to provide an initial value to the function unit's flow this 
     * input port belongs to.
     */
    def void <= (MessageType msg) {
        processInputOperation.apply(msg)
    }
    
    /**
     * Forward operation of the flow DSL.<br>
     * Forwards a message value computed by the passed closure to the function unit's input port <i>fu.input</i>.<br>
     * E.g.: fu.input <= input value<br>
     * This is typically used to provide an initial value to the function unit's flow this 
     * input port belongs to.
     */
    def void <= (()=>MessageType msgClosure) {
        processInputOperation.apply(msgClosure.apply)
    }
    
    package def (MessageType)=>void inputProcessingOperation() {
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