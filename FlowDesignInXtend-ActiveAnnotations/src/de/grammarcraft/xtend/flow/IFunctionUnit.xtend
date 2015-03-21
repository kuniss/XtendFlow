package de.grammarcraft.xtend.flow

interface IFunctionUnit {
    
    /**
     * @return the integration error port for forwarding {@link Exception}s to in case 
     * an functional output port of that function unit has not been connected to an input port 
     * or a side effect closure
     */
    def OutputPort<Exception> integrationError()
    
    /**
     * Method for forwarding an {@link Exception} in case 
     * an functional output port of that function unit has not been connected to an input port 
     * or a side effect closure
     */
    def void forwardIntegrationError(Exception ex)
}