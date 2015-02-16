package de.grammarcraft.xtend.firstflow

import java.util.List
import java.util.ArrayList

package class Collector extends FunctionUnit {
  
    new(String separator) {
        super('Collector')
        this.separator = separator
    }
    
    // input1 port
    public val input1 = new InputPort<String>('''«this».input1''', [accumulateInput], [forwardIntegrationError])

    // input2 port
    public val input2 = new InputPort<String>('''«this».input2''', [accumulateInput], [forwardIntegrationError])
    
    
    // output port    
    public val output = new OutputPort<String>('''«this».output''', [forwardIntegrationError])
    
    // convenient operator for function units defining one and only one output port:
    // defines operator "->", used as function unit connector
    def void ->((String)=>void operation) {
        output -> operation
    }
    
    
    val String separator
    val List<String> accumulation = new ArrayList

    // This method implements the semantic of the function unit      
    private def accumulateInput(String msg) {
        accumulation.add(msg)
        if (accumulation.length == 2) 
            output <= accumulation.join(separator)
    }
        
}