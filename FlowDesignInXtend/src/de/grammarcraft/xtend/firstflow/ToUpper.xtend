package de.grammarcraft.xtend.firstflow

class ToUpper extends FunctionUnit {
    
    new() { super("ToUpper") }
    
    // input pins
    public val (String)=>void input = [msg | input(msg)]

    // output pins    
    public val output = new OutputPinEx<String>('output', 
        [forwardIntegrationError]
    )


    def input(String msg) {
        process(msg)
    }
    
    // This method implements the semantic of the function unit
    private def process(String msg) {
        output.forward(msg.toUpperCase);
    }
    
}

