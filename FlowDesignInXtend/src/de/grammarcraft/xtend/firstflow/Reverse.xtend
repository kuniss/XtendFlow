package de.grammarcraft.xtend.firstflow

class Reverse extends FunctionUnit {
    
    new() { super("Reverse") }
    
    // input pins
    public val (String)=>void input = [msg | processInput(msg)]
    def input(String msg) { processInput(msg) }

    // output pins    
    public val output = new OutputPin<String>('output', 
        [forwardIntegrationError]
    )

    // convenient operator for function units defining one and only one output pin:
    // defines operator "->", used as function unit connector
    def void operator_mappedTo((String)=>void operation) {
        output -> operation
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