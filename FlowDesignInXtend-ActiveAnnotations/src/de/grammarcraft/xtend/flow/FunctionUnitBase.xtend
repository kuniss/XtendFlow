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
    
}