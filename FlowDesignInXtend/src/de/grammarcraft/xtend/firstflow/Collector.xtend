package de.grammarcraft.xtend.firstflow

import java.util.List
import java.util.ArrayList

class Collector {

    String separator
    
    new(String separator) {
        this.separator = separator
    }
    
    public val (String)=>void input1 = [msg | input1(msg)]
    
    def input1(String msg) {
        accumulateInput(msg)
    }

    public val (String)=>void input2 = [msg | input2(msg)]

    def input2(String msg) {
        accumulateInput(msg)
    }
    
    val List<String> accumulation = new ArrayList
    
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
    private def accumulateInput(String msg) {
        accumulation.add(msg)
        if (accumulation.length == 2) output(accumulation.join(separator))
    }
        
}