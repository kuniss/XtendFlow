package de.grammarcraft.xtend.firstflow

/**
 * Marks an function unit as having one and only one input port.<br>
 * This input port is returned by the dedicated interface method.
 */
interface FunctionUnitWithOnlyOneInputPort<MessageType> {
    /**
     * @return the one and only {@link InputPort}
     */
    def InputPort<MessageType> theOneAndOnlyInputPort()
}