package de.grammarcraft.xtend.firstflow

import java.util.ArrayList
import java.util.List

class ToUpper {
    
    // input pins
    public val (String)=>void input = [msg | input(msg)]

    // output pins    
    public val error = new OutputPin<Exception>([bindErrorTo])
    public val output = new OutputPin<String>([bindOutputTo])


    def input(String msg) {
        process(msg)
    }
    
    private val List<(String)=>void> outputOperations = new ArrayList
    
    private def forwardOutput(String msg) {
        if (!outputOperations.empty) {
            outputOperations.forEach[
                operation | operation.apply(msg)
            ]
        }
        else {
            forwardError(new RuntimeException("no binding defined for output of " + this + ": '" + 
                msg + "' could not be delivered"))
        }
    }
    
    // defines operator "->", used as function unit connector
    private def void bindOutputTo((String)=>void operation) {
        outputOperations.add(operation)
    }
    
    
    private val List<(Exception)=>void> errorOperations = new ArrayList
     
    private def void bindErrorTo((Exception)=>void operation) {
        errorOperations.add(operation)
    }
  
    private def forwardError(Exception exception) {
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
        forwardOutput(msg.toUpperCase)
    }
    
}

