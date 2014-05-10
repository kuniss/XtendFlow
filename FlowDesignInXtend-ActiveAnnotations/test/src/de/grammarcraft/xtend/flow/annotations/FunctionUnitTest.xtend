/*******************************************************************************
 * Copyright (c) 2014 Denis Kuniss (http://www.grammarcraft.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/

package de.grammarcraft.xtend.flow.annotations

import java.util.Map
import java.util.Set
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.junit.Test

import static org.junit.Assert.*
import de.grammarcraft.xtend.flow.FunctionUnitBase

class FunctionUnitTest {

    extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(FunctionUnit)
    
    private def String interfaceName(String className, String inputPortName) '''«className»_InputPort_«inputPortName»'''

    private def String processMethodName(String inputPortName) '''process«inputPortName.toFirstUpper»'''
    
    @Test def void test_String_typed_ports() {
        val className = 'MyFunctionUnit'
        val inputPortName = 'input'
        val inputPortTypeName = 'String'
        val outputPortName = 'output'
        val outputPortTypeName = 'String'
        '''
            import de.grammarcraft.xtend.flow.annotations.FunctionUnit
            import de.grammarcraft.xtend.flow.annotations.OutputPort
            import de.grammarcraft.xtend.flow.annotations.InputPort
        
            @FunctionUnit(
                inputPorts = #[
                    @InputPort(name="«inputPortName»", type=«inputPortTypeName»)
                ],
                outputPorts = #[
                    @OutputPort(name="«outputPortName»", type=«outputPortTypeName»)
                ]
            )
            class «className» {
            
                override «inputPortName.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName».forward(msg.toUpperCase);
                }
                
            }
        '''.compile [
            val extension ctx = transformationContext

            val clazz = findClass(className)
            val inputPortType = String.newTypeReference
            val outputPortType = String.newTypeReference
            
            assertEquals(inputPortTypeName, inputPortType.toString)
            assertEquals(outputPortTypeName, outputPortType.toString)

            assertInputPortGenerated(inputPortName, inputPortType, className, clazz, ctx)            
            assertOutputPortGenerated(outputPortName, outputPortType, className, clazz, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodGenerated(className, inputPortType, clazz, ctx)
            assertMappedToOperatorGenerated(className, outputPortType, clazz, ctx)
            
        ]
    }
    
    @Test def void test_unusal_named_ports() {
        val className = 'Funktionseinheit'
        val inputPortName = 'eingabe'
        val inputPortTypeName = 'String'
        val outputPortName = 'ausgabe'
        val outputPortTypeName = 'String'
        '''
            import de.grammarcraft.xtend.flow.annotations.FunctionUnit
            import de.grammarcraft.xtend.flow.annotations.OutputPort
            import de.grammarcraft.xtend.flow.annotations.InputPort
        
            @FunctionUnit(
                inputPorts = #[
                    @InputPort(name="«inputPortName»", type=«inputPortTypeName»)
                ],
                outputPorts = #[
                    @OutputPort(name="«outputPortName»", type=«outputPortTypeName»)
                ]
            )
            class «className» {
            
                override «inputPortName.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName».forward(msg.toUpperCase);
                }
                
            }
        '''.compile [
            val extension ctx = transformationContext

            val clazz = findClass(className)
            val inputPortType = String.newTypeReference
            val outputPortType = String.newTypeReference
            
            assertEquals(inputPortTypeName, inputPortType.toString)
            assertEquals(outputPortTypeName, outputPortType.toString)

            assertInputPortGenerated(inputPortName, inputPortType, className, clazz, ctx)            
            assertOutputPortGenerated(outputPortName, outputPortType, className, clazz, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodGenerated(className, inputPortType, clazz, ctx)
            assertMappedToOperatorGenerated(className, outputPortType, clazz, ctx)
            
        ]
    }

    @Test def void test_Integer_typed_ports() {
        val className = 'MyFunctionUnit'
        val inputPortName = 'input'
        val inputPortTypeName = 'Integer'
        val outputPortName = 'output'
        val outputPortTypeName = 'Integer'
        '''
            import de.grammarcraft.xtend.flow.annotations.FunctionUnit
            import de.grammarcraft.xtend.flow.annotations.OutputPort
            import de.grammarcraft.xtend.flow.annotations.InputPort
        
            @FunctionUnit(
                inputPorts = #[
                    @InputPort(name="«inputPortName»", type=«inputPortTypeName»)
                ],
                outputPorts = #[
                    @OutputPort(name="«outputPortName»", type=«outputPortTypeName»)
                ]
            )
            class «className» {
            
                override «inputPortName.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName».forward(msg);
                }
                
            }
        '''.compile [
            val extension ctx = transformationContext

            val clazz = findClass(className)
            val inputPortType = Integer.newTypeReference
            val outputPortType = Integer.newTypeReference
            
            assertEquals(inputPortTypeName, inputPortType.toString)
            assertEquals(outputPortTypeName, outputPortType.toString)

            assertInputPortGenerated(inputPortName, inputPortType, className, clazz, ctx)            
            assertOutputPortGenerated(outputPortName, outputPortType, className, clazz, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodGenerated(className, inputPortType, clazz, ctx)
            assertMappedToOperatorGenerated(className, outputPortType, clazz, ctx)
            
        ]
    }
    
    @Test def void test_2_input_ports() {
        val className = 'MyFunctionUnit'
        val inputPortName = 'input'
        val inputPortTypeName = 'String'
        val inputPort2Name = 'input2'
        val inputPort2TypeName = 'Integer'
        val outputPortName = 'output'
        val outputPortTypeName = 'String'
        '''
            import de.grammarcraft.xtend.flow.annotations.FunctionUnit
            import de.grammarcraft.xtend.flow.annotations.OutputPort
            import de.grammarcraft.xtend.flow.annotations.InputPort
        
            @FunctionUnit(
                inputPorts = #[
                    @InputPort(name="«inputPortName»", type=«inputPortTypeName»),
                    @InputPort(name="«inputPort2Name»", type=«inputPort2TypeName»)
                ],
                outputPorts = #[
                    @OutputPort(name="«outputPortName»", type=«outputPortTypeName»)
                ]
            )
            class «className» {
            
                override «inputPortName.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName».forward(msg);
                }
                
                override «inputPort2Name.processMethodName»(«inputPort2TypeName» msg) {
                    «outputPortName».forward(«inputPort2TypeName».toString(msg));
                }
            }
        '''.compile [
            val extension ctx = transformationContext

            val clazz = findClass(className)
            val inputPortType = String.newTypeReference
            val inputPort2Type = Integer.newTypeReference
            val outputPortType = String.newTypeReference
            
            assertEquals(inputPortTypeName, inputPortType.toString)
            assertEquals(inputPort2TypeName, inputPort2Type.toString)
            assertEquals(outputPortTypeName, outputPortType.toString)

            assertInputPortGenerated(inputPortName, inputPortType, className, clazz, ctx)            
            assertInputPortGenerated(inputPort2Name, inputPort2Type, className, clazz, ctx)            
            assertOutputPortGenerated(outputPortName, outputPortType, className, clazz, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodNOTGenerated(className, inputPortType, clazz, ctx)
            assertMappedToOperatorGenerated(className, outputPortType, clazz, ctx)
            
        ]
    }
    
        @Test def void test_2_output_ports() {
        val className = 'MyFunctionUnit'
        val inputPortName = 'input'
        val inputPortTypeName = 'String'
        val outputPortName = 'output'
        val outputPortTypeName = 'String'
        val output2PortName = 'output2'
        val output2PortTypeName = 'String'
        '''
            import de.grammarcraft.xtend.flow.annotations.FunctionUnit
            import de.grammarcraft.xtend.flow.annotations.OutputPort
            import de.grammarcraft.xtend.flow.annotations.InputPort
        
            @FunctionUnit(
                inputPorts = #[
                    @InputPort(name="«inputPortName»", type=«inputPortTypeName»)
                ],
                outputPorts = #[
                    @OutputPort(name="«outputPortName»", type=«outputPortTypeName»),
                    @OutputPort(name="«output2PortName»", type=«output2PortTypeName»)
                ]
            )
            class «className» {
            
                override «inputPortName.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName».forward(msg.toUpperCase);
                    «output2PortName».forward(msg.toLowerCase);
                }
                
            }
        '''.compile [
            val extension ctx = transformationContext

            val clazz = findClass(className)
            val inputPortType = String.newTypeReference
            val outputPortType = String.newTypeReference
            val output2PortType = String.newTypeReference
            
            assertEquals(inputPortTypeName, inputPortType.toString)
            assertEquals(outputPortTypeName, outputPortType.toString)
            assertEquals(output2PortTypeName, output2PortType.toString)

            assertInputPortGenerated(inputPortName, inputPortType, className, clazz, ctx)            
            assertOutputPortGenerated(outputPortName, outputPortType, className, clazz, ctx)
            assertOutputPortGenerated(output2PortName, output2PortType, className, clazz, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodGenerated(className, inputPortType, clazz, ctx)
            assertMappedToOperatorNOTGenerated(className, clazz, ctx)
            
        ]
    }
    
        @Test def void test_complex_typed_ports() {
        val className = 'MyFunctionUnit'
        val inputPortName = 'input'
        val inputPortTypeName = 'Map'
        val inputPortTypeParameters = 'Integer, String' 
        val outputPortName = 'output'
        val outputPortTypeName = 'Set'
        val outputPortTypeParameters = 'Integer' 
        '''
            import de.grammarcraft.xtend.flow.annotations.FunctionUnit
            import de.grammarcraft.xtend.flow.annotations.OutputPort
            import de.grammarcraft.xtend.flow.annotations.InputPort
            import java.util.Set
            import java.util.Map
        
            @FunctionUnit(
                inputPorts = #[
                    @InputPort(name="«inputPortName»", type=«inputPortTypeName», typeArguments=#[«inputPortTypeParameters»])
                ],
                outputPorts = #[
                    @OutputPort(name="«outputPortName»", type=«outputPortTypeName», typeArguments=#[«outputPortTypeParameters»])
                ]
            )
            class «className» {
            
                override «inputPortName.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName».forward(msg.keySet);
                }
                
            }
        '''.compile [
            val extension ctx = transformationContext

            val clazz = findClass(className)
            val inputPortType = Map.newTypeReference(Integer.newTypeReference, String.newTypeReference)
            val outputPortType = Set.newTypeReference(Integer.newTypeReference)
            
            assertEquals('''«inputPortTypeName»<«inputPortTypeParameters»>'''.toString, inputPortType.toString)
            assertEquals('''«outputPortTypeName»<«outputPortTypeParameters»>'''.toString, outputPortType.toString)

            assertInputPortGenerated(inputPortName, inputPortType, className, clazz, ctx)            
            assertOutputPortGenerated(outputPortName, outputPortType, className, clazz, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodGenerated(className, inputPortType, clazz, ctx)
            assertMappedToOperatorGenerated(className, outputPortType, clazz, ctx)
            
        ]
    }
    
    
    
    
    private def assertInputPortGenerated(String inputPortName, TypeReference inputPortType, String className, 
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        val interf = findInterface(className.interfaceName(inputPortName))
        
        // input ports
        assertTrue('''class '«className»' does not implement required interface '«className.interfaceName(inputPortName)»' ''', 
            clazz.implementedInterfaces.exists[it.name == interf.qualifiedName]
        )
        
        assertTrue('''method '«inputPortName.processMethodName»' does not exist at «className.interfaceName(inputPortName)»''', 
            interf.declaredMethods.exists[simpleName == inputPortName.processMethodName]
        )
        interf.declaredMethods.filter[simpleName == inputPortName.processMethodName ].head => [
            assertEquals('''method '«simpleName»' has not exactly one parameter at «className.interfaceName(inputPortName)»''',
                1, parameters.size
            )
            assertEquals('''method '«simpleName»' parameter is not of type «inputPortType» at «className.interfaceName(inputPortName)»''', 
                inputPortType, parameters.head.type
            )
        ]
        
        assertTrue('''method '«inputPortName»' does not exist at «className»''', 
            clazz.declaredMethods.exists[simpleName == inputPortName]
        )
        assertTrue('''field '«inputPortName»' does not exist at «className»''', 
            clazz.declaredFields.exists[simpleName == inputPortName]
        )
        assertTrue('''method '«inputPortName.processMethodName»' does not exist at «className»''', 
            clazz.declaredMethods.exists[simpleName == inputPortName.processMethodName]
        )
        
        clazz.declaredMethods.filter[simpleName == inputPortName ].head => [
            assertEquals('''method '«simpleName»' has not exactly one parameter''', 
                1, parameters.size
            )
            assertEquals('''method '«simpleName»' parameter is not of type «inputPortType»''', 
                inputPortType, parameters.head.type
            )
        ]
        clazz.declaredFields.filter[simpleName == inputPortName].head => [
            assertEquals('''field '«simpleName»' is not of type «Procedures.Procedure1.newTypeReference(inputPortType.newWildcardTypeReferenceWithLowerBound)»''', 
                Procedures.Procedure1.newTypeReference(inputPortType.newWildcardTypeReferenceWithLowerBound), type
            )
        ]
    }
    
    private def assertOutputPortGenerated(String outputPortName, TypeReference outputPortType, String className, 
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        assertTrue('''field '«outputPortName»' does not exist''', 
            clazz.declaredFields.exists[simpleName == outputPortName]
        )
        clazz.declaredFields.filter[simpleName == outputPortName].head => [
            assertEquals('''field '«simpleName»' is not of type «de.grammarcraft.xtend.flow.OutputPort.newTypeReference(outputPortType)»''', 
                de.grammarcraft.xtend.flow.OutputPort.newTypeReference(outputPortType), type
            )
        ]
    }

    private def assertMappedToOperatorGenerated(String className, TypeReference outputPortType,
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        assertTrue('''operator -> (operator_mappedTo) does not exist at «className»''',
            clazz.declaredMethods.exists[simpleName == 'operator_mappedTo']
        )
        val operatorMethods = clazz.declaredMethods.filter[simpleName == 'operator_mappedTo']
        assertEquals('''there are not two operator -> (operator_mappedTo) methods at «className»''',
            2, operatorMethods.size
        )
        assertEquals('''there is no operator -> (operator_mappedTo) method with parameter «FunctionUnitBase.newTypeReference»''',
            1, operatorMethods.filter[parameters.head.type == FunctionUnitBase.newTypeReference].size
        )
        operatorMethods.filter[parameters.head.type != FunctionUnitBase.newTypeReference].head => [
            assertEquals('''method '«simpleName»' has not exactly one parameter''', 
                1, parameters.size
            )
            assertEquals('''method '«simpleName»' parameter is not of type «Procedures.Procedure1.newTypeReference»''', 
                Procedures.Procedure1.newTypeReference(outputPortType.newWildcardTypeReferenceWithLowerBound), 
                parameters.head.type
            )
        ]
    }

    private def assertMappedToOperatorNOTGenerated(String className, 
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        assertFalse('''operator -> (operator_mappedTo) must NOT not exist at «className», but is there''',
            clazz.declaredMethods.exists[simpleName == 'operator_mappedTo']
        )
    }


    private def assertTheOneAndOnlyInputPortCanonicalMethodGenerated(String className, TypeReference outputPortType,
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        assertTrue('''canonical method 'theOneAndOnlyInputPort' is not overridden at «className»''',
            clazz.declaredMethods.exists[simpleName == 'getTheOneAndOnlyInputPort']
        )
        clazz.declaredMethods.filter[simpleName == 'getTheOneAndOnlyInputPort'].head => [
            assertTrue('''method '«simpleName»' must not have parameters''', parameters.empty)
            assertEquals('''method '«simpleName»' return type is not «Procedures.Procedure1.newTypeReference»''', 
                Procedures.Procedure1.newTypeReference(outputPortType.newWildcardTypeReferenceWithLowerBound), 
                returnType
            )
        ]
    }
    
    private def assertTheOneAndOnlyInputPortCanonicalMethodNOTGenerated(String className, TypeReference outputPortType,
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        assertFalse('''canonical method 'theOneAndOnlyInputPort' must NOT not exist at «className», but is there''',
            clazz.declaredMethods.exists[simpleName == 'getTheOneAndOnlyInputPort']
        )
    }
    
}