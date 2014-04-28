package de.grammarcraft.xtend.firstflow

package class Reverse extends FunctionUnit {
    
    new() { super("Reverse") }
    
    // input port
    public val (String)=>void input = [msg | processInput(msg)]
    def input(String msg) { processInput(msg) }

    // output port    
    public val output = new OutputPort<String>('''«this».output''', 
        [forwardIntegrationError]
    )

    // convenient operator for function units defining one and only one output port:
    // defines operator "->", used as function unit connector
    def void operator_mappedTo((String)=>void operation) {
        output -> operation
    }
    
    // convenient operator for function units defining one and only one output port 
    // and, connecting it to function units having one and only one input port:
    // defines operator "->", used as function unit connector
    def void operator_mappedTo(FunctionUnit fu) {
        output -> fu.theOneAndOnlyInputPort
    }
    
    // This method implements the semantic of the function unit      
    def processInput(String msg) {
        val reversedMsgBuilder = new StringBuilder
        var index = msg.length
        while (index > 0) {
            index = index - 1
            reversedMsgBuilder.append(msg.charAt(index))
        }
        output.forward(reversedMsgBuilder.toString)
    }
    
}