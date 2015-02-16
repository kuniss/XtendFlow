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
        integrationError <= ex
    }
    
}