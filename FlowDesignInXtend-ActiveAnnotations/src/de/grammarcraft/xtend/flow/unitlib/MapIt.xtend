package de.grammarcraft.xtend.flow.unitlib

import de.grammarcraft.xtend.flow.FunctionUnitWithOnlyOneInputPort
import de.grammarcraft.xtend.flow.InputPort
import de.grammarcraft.xtend.flow.OutputPort
import de.grammarcraft.xtend.flow.FunctionUnitWithOnlyOneOutputPort
import de.grammarcraft.xtend.flow.IFunctionUnit

class MapIt<InputType, OutputType> implements IFunctionUnit, 
	FunctionUnitWithOnlyOneInputPort<InputType>, FunctionUnitWithOnlyOneOutputPort<OutputType> 
{
	val String name;
    
    // input port
    val input = new InputPort<InputType>('''«this».input''', [processInput], [forwardIntegrationError])
    // output port    
    val output = new OutputPort<OutputType>('''«this».output''', [forwardIntegrationError])
	// integration error port
	val integrationError = new OutputPort<Exception>('''«this».integrationError''', [println('''FATAL ERROR: «message»''')])
	
	val (InputType)=>OutputType operation
	

	/**
	 * Creates an operation unit in the sense of Flow Design which performs a mapping of input message 
	 * to an output message by applying the given operation which must be a function.
	 * @param operation the function to be applied for mapping
	 */
    new((InputType)=>OutputType operation) {
    	this("MapIt", operation)
    }
    
	/**
	 * Creates an operation unit in the sense of Flow Design which performs a mapping of input message 
	 * to an output message by applying the given operation which must be a function.
	 * @param name the function unit name to be used for this instance
	 * @param operation the function to be applied for mapping
	 */
    new (String unitName, (InputType)=>OutputType operation) {
		this.name = unitName
		this.operation = operation
    }
    
	override toString() { this.name	}
   
	// getter
	def InputPort<InputType> in() { return this.input }
	def OutputPort<OutputType> out() { return this.output }

    override InputPort<InputType> theOneAndOnlyInputPort() { return this.input } 
	override OutputPort<Exception> integrationError() {	this.integrationError }
	
	
	override forwardIntegrationError(Exception ex) {
		this.integrationError <= ex
	}
    
    // This methods implement the semantic of the function unit
    private def processInput(InputType msg) {
        output <= this.operation.apply(msg)
    }
    
	override <= (InputType msg) {
		output <= this.operation.apply(msg)
	}
	
	override <= (()=>InputType msgClosure) {
		output <= this.operation.apply(msgClosure.apply)
	}
	
	
    // convenient operator for function units defining one and only one output port:
    // defines operator "->", used as function unit connector
    override -> ((OutputType)=>void closure) {
        output -> closure
    }
	
    override -> (InputPort<OutputType> foreignInputPort) {
        output -> foreignInputPort.inputProcessingOperation
    }
        
	override -> (FunctionUnitWithOnlyOneInputPort<OutputType> rightSideFunctionUnit) {
		output -> rightSideFunctionUnit.theOneAndOnlyInputPort.inputProcessingOperation
	}

	override -> (OutputPort<OutputType> rightSideFunctionUnitOutputPort) {
		output -> rightSideFunctionUnitOutputPort
	}
    	
}