package de.grammarcraft.xtend.flow

interface FunctionUnitWithOnlyOneOutputPort<MessageType> {
    
    /**
     * Flow DSL operator "-&gt;" for connecting two function unit. 
     * The left one with only one output port, right one with only one input port.<br>
     * example:<pre>
     *   fu -&gt; fu'
     * </pre>
     * @param rightSideFunctionUnit the right side function unit with only one input port
     */
    def void -> (FunctionUnitWithOnlyOneInputPort<MessageType> rightSideFunctionUnit)
    
    /**
     * Flow DSL operator "-&gt;" for connecting two function units. 
     * The left one with only one output port, the right one with named input port.<br>
     * example:<pre>
     *   fu -&gt; fu'.input
     * </pre>
     * @param rightSideFunctionUnitInputPort the right side function unit's named input port
     */
    def void -> (InputPort<MessageType> rightSideFunctionUnitInputPort)
    
    /**
     * Flow DSL operator "-&gt;" for connecting two function units. 
     * The left one with only one output port, the right one with named output port.<br>
     * This is normally only used in integrating function units for connecting and integrated function unit with the 
     * an output port of the integrating function unit.
     * example:<pre>
     *   fu -&gt; .output
     * </pre>
     * @param rightSideFunctionUnitOutputPort the right side function unit's named output port
     */
    def void -> (OutputPort<MessageType> rightSideFunctionUnitOutputPort)
    
    /**
     * Flow DSL operator "-&gt;" for specifying an function units output message to be processed by a particular closure.
     * Typically this is used to process the message for a side effect like printing on standard out. 
     * example:<pre>
     *   fu -&gt; [msg|println("message received: " + msg")]
     * </pre>
     * @param msgProcessingClosure the message processing closure
     */
    def void -> ((MessageType) => void msgProcessingClosure)
}