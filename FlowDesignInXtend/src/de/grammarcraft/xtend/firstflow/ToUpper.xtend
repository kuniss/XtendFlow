package de.grammarcraft.xtend.firstflow

class ToUpper extends FunctionUnit {
    
    new() { super('ToUpper') }
    
    // input pin
    public val (String)=>void input = [msg | input(msg)]
    def input(String msg) { processInput(msg) }

    // output pin    
    public val output = new OutputPin<String>('output', 
        [forwardIntegrationError]
    )

    // convenient operator for function units defining one and only one output pin:
    // defines operator "->", used as function unit connector
    def void operator_mappedTo((String)=>void operation) {
        output -> operation
    }


    // This method implements the semantic of the function unit
    private def processInput(String msg) {
        output.forward(msg.toUpperCase);
    }
    
}

