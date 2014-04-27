package de.grammarcraft.xtend.flow

class FunctionUnitBase {
    
    val String name
    
    new(String name) {
        this.name = name
    }
    
    override toString() { this.name }
    
    public val integrationError = new OutputPin<Exception>('integrationError',
        [
            ex | println('FATAL ERROR: ' + ex.message)
        ]
    )
    
    protected def forwardIntegrationError(Exception ex) {
        integrationError.forward(ex)
    }
    
    /**
     * Must be overridden by the derived function unit iff it has exactly one input pin, not more.
     * <br>
     * By default it forwards an integration error and returns an doing-nothing method object.
     * <br>
     * This method is used for connecting this function unit (if it has only one input pin) as 
     * flow target with another function unit without specifying the one and only input pin.
     */
    def <T> (T)=>void getTheOneAndOnlyInputPin() {
        forwardIntegrationError(
            new UnsupportedOperationException(
                "The function unit has more than one input pin or, " + 
                "getTheOneAndOnlyInputPin() is not implemented.")
        )
        return [];
    }
    
}