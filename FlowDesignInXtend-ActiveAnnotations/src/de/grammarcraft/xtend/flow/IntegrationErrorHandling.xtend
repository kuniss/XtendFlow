/*******************************************************************************
 * Copyright (c) 2014 Denis Kuniss (http://www.grammarcraft.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/

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