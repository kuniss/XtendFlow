package de.grammarcraft.xtend.firstflow

import java.util.ArrayList
import java.util.List

class ToUpper {
    
    // input pins
    public val (String)=>void input = [msg | input(msg)]

    // output pins    
    public val error = new OutputPin<Exception>([bindErrorTo])
    public val output = new OutputPinEx<String>([forwardError])


    def input(String msg) {
        process(msg)
    }
    
    private val List<(Exception)=>void> errorOperations = new ArrayList
     
    private def void bindErrorTo((Exception)=>void operation) {
        errorOperations.add(operation)
    }
  
    private def void forwardError(Exception exception) {
        if (!errorOperations.isEmpty) {
            errorOperations.forEach[ forward | forward.apply(exception)]
        }
        else {
            println("no binding defined for error of " + this)
        }
    }
    
   
    override toString() {
        this.getClass.simpleName        
    }


    // This method implements the semantic of the function unit
    private def process(String msg) {
        output.forward(msg.toUpperCase);
    }
    
}

