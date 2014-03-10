package de.grammarcraft.xtend.flow

import java.util.List

abstract class IntegrationErrorHandling {
    
    static def void onIntegrationErrorAt(
        List<? extends FunctionUnitBase> functionUnits, 
        (Exception)=>void errorOperation
    )
    {
        functionUnits.forEach[
            integrationError -> errorOperation
        ]
    }
}