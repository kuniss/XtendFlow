package de.grammarcraft.xtend.firstflow

class OutputPin<MessageType> {
    
    ((MessageType)=>void)=>void registerOperation
    
    package new(((MessageType)=>void)=>void registerOperation) {
        this.registerOperation = registerOperation
    }
    // defines operator "->", used as function unit connector
    def void operator_mappedTo((MessageType)=>void operation) {
        registerOperation.apply(operation)
    }
}
