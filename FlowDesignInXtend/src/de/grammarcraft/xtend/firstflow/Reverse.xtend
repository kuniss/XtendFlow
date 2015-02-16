package de.grammarcraft.xtend.firstflow

package class Reverse extends FunctionUnit {
    
    new() { super("Reverse") }
    
    // input port
    public val input = new InputPort<String>('''«this».input''', [processInput], [forwardIntegrationError])
    
    // output port    
    public val output = new OutputPort<String>('''«this».output''', [forwardIntegrationError])

    // convenient operator for function units defining one and only one output port:
    // defines operator "->", used as function unit connector
    def void -> ((String)=>void operation) {
        output -> operation
    }
    
    // convenient operator for function units defining one and only one output port 
    // and, connecting it to function units having one and only one input port:
    // defines operator "->", used as function unit connector
    def void -> (FunctionUnitWithOnlyOneInputPort<String> fu) {
        output -> fu.theOneAndOnlyInputPort.inputProcessingOperation
    }
    
    // This method implements the semantic of the function unit      
    private def processInput(String msg) {
        output <= [ 
            val reversedMsgBuilder = new StringBuilder
            var index = msg.length
            while (index > 0) {
                index = index - 1
                reversedMsgBuilder.append(msg.charAt(index))
            }
            reversedMsgBuilder.toString
        ]
    }
    
}