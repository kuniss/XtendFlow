package de.grammarcraft.xtend.firstflow

class FunctionUnit {
    
    String name
    
    new(String name) {
        this.name = name
    }
    
    override toString() { this.name }
    
    public val integrationError = new OutputPin<Exception>('integrationError',
        [
            ex | println(ex.message)
        ]
    )
    
    protected def forwardIntegrationError(Exception ex) {
        integrationError.forward(ex)
    }
    
}