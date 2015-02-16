package de.grammarcraft.xtend.firstflow

package class ToUpper extends FunctionUnit implements FunctionUnitWithOnlyOneInputPort<String> {
    
    new() { super('ToUpper') }
    
    // input port
    InputPort<String> input = new InputPort('''«this».input''', [processInput])
    
    // output port    
    public val output = new OutputPort<String>('''«this».output''', [forwardIntegrationError])

    override theOneAndOnlyInputPort() {
        return this.input
    }
    
    // convenient operator for function units defining one and only one output port:
    // defines operator "->", used as function unit connector
    def void -> ((String)=>void operation) {
        output -> operation
    }

    def void -> (InputPort<String> foreignInputPort) {
        output -> foreignInputPort.inputProcessingOperation
    }
        

    // This method implements the semantic of the function unit
    private def processInput(String msg) {
        output <= msg.toUpperCase
    }
    
}
