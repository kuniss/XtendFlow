package de.grammarcraft.xtend.firstflow

package class FunctionUnit {
    
    val String name
    
    new(String name) {
        this.name = name
    }
    
    override toString() { this.name }
    
    public val integrationError = new OutputPort<Exception>('integrationError',
        [
            ex | println('FATAL ERROR: ' + ex.message)
        ]
    )
    
    protected def forwardIntegrationError(Exception ex) {
        integrationError.forward(ex)
    }
    
    /**
     * Must be overridden by the derived function unit iff it has exactly one input port, not more.
     * By default it forwards and integration error and returns an doing-nothing method object.
     * This method is used for connecting this function unit (if it has only one input port) as 
     * flow target with another function unit without specifying the one and only input port.
     */
    def <T> (T)=>void getTheOneAndOnlyInputPort() {
        forwardIntegrationError(
            new UnsupportedOperationException(
                "The function unit has more than one input port or, " + 
                "getTheOneAndOnlyInputPort() is not implemented.")
        )
        return [];
    }
    
}