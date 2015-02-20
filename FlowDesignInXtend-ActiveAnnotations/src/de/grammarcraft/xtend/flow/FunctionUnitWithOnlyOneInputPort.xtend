package de.grammarcraft.xtend.flow

/**
 * Marks an function unit as having one and only one input port.<br>
 * This input port is returned by the dedicated interface method.
 */
interface FunctionUnitWithOnlyOneInputPort<MessageType> {
    /**
     * @return the one and only {@link InputPort}
     */
    def InputPort<MessageType> theOneAndOnlyInputPort()
    
    /**
     * Flow DSL operator "&lt;=" for forwarding a message value to the one and only input port for being processed.<br>
     * example:<pre> 
     *   input <= "some string"
     * </pre>
     * @param msg the message to be forwarded
     */
    def void <= (MessageType msg)
    
    /**
     * Flow DSL operator "&lt;=" for forwarding a message value to the one and only input port for being processed.<br>
     * example:<pre> 
     *   input &lt;= [ if (state&gt;0) "some string" else "some other string"
     * </pre>
     * @param msgClosure the closure to be applied to compute the message to be forwarded
     */
    def void <= (()=> MessageType msgClosure)
}