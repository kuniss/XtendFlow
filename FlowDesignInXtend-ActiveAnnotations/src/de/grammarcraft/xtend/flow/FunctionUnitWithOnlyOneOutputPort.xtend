package de.grammarcraft.xtend.flow

interface FunctionUnitWithOnlyOneOutputPort<MessageType> {
    
    def void -> (FunctionUnitWithOnlyOneInputPort<MessageType> foreignFunctionUnit)
    
    def void -> (InputPort<MessageType> foreignInputPort)
    
    def void -> (OutputPort<MessageType> foreignOutputPort)
    
    def void -> ((MessageType) => void msgProcessingClosure)
}