package de.grammarcraft.xtend.firstflow

import java.util.List
import java.util.ArrayList

class Reverse {
    
    public val (String)=>void input = [msg | input(msg)]
    
    def input(String msg) {
        process(msg)
    }
    
    private val List<(String)=>void> outputOperations = new ArrayList
    
    private def output(String msg) {
        if (!outputOperations.empty) {
            outputOperations.forEach[
                operation | operation.apply(msg)
            ]
        }
    }
    
    // defines operator "->", used as function unit connector
    def void operator_mappedTo((String)=>void operation) {
        outputOperations.add(operation)
    }

    override toString() {
        this.getClass.simpleName        
    }
    
    
    // This method implements the semantic of the function unit      
    def process(String msg) {
        val reversedMsgBuilder = new StringBuilder
        var index = msg.length
        while (index > 0) {
            index = index - 1
            reversedMsgBuilder.append(msg.charAt(index))
        }
        output(reversedMsgBuilder.toString)
    }
    
}