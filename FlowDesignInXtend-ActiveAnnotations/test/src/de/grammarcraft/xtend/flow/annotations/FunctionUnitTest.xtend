/*******************************************************************************
 * Copyright (c) 2014 Denis Kuniss (http://www.grammarcraft.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/

package de.grammarcraft.xtend.flow.annotations

import de.grammarcraft.xtend.flow.FunctionUnitWithOnlyOneInputPort
import java.util.Map
import java.util.Set
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.junit.Test

import static org.junit.Assert.*
import org.eclipse.xtend.lib.macro.declaration.Visibility

class FunctionUnitTest {

    extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Unit)
    
    private def String interfaceName(String className, String inputPortName) '''«className»_InputPort_«inputPortName»'''

    private def String processMethodName(String inputPortName) '''process$«inputPortName»'''
    
    @Test def void test_String_typed_ports() {
        val className = 'MyFunctionUnit'
        val inputPortName = 'input'
        val inputPortTypeName = 'String'
        val outputPortName = 'output'
        val outputPortTypeName = 'String'
        '''
            import de.grammarcraft.xtend.flow.annotations.Unit
            import de.grammarcraft.xtend.flow.annotations.Port
            import de.grammarcraft.xtend.flow.annotations.Operation
        
            @Operation @Unit(
                inputPorts = #[
                    @Port(name="«inputPortName»", type=«inputPortTypeName»)
                ],
                outputPorts = #[
                    @Port(name="«outputPortName»", type=«outputPortTypeName»)
                ]
            )
            class «className» {
            
                override «inputPortName.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName» <= msg.toUpperCase;
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
            assertLessEqualsThanOperatorsGenerated(className, inputPortType, clazz, ctx)
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
            import de.grammarcraft.xtend.flow.annotations.Unit
            import de.grammarcraft.xtend.flow.annotations.Port
            import de.grammarcraft.xtend.flow.annotations.Operation
        
            @Operation @Unit(
                inputPorts = #[
                    @Port(name="«inputPortName»", type=«inputPortTypeName»)
                ],
                outputPorts = #[
                    @Port(name="«outputPortName»", type=«outputPortTypeName»)
                ]
            )
            class «className» {
            
                override «inputPortName.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName» <= msg.toUpperCase;
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
            assertInputPortInterfaceGenerated(inputPortName, inputPortType, className, clazz, ctx)
            assertOutputPortGenerated(outputPortName, outputPortType, className, clazz, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodGenerated(className, inputPortType, clazz, ctx)
            assertLessEqualsThanOperatorsGenerated(className, inputPortType, clazz, ctx)
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
            import de.grammarcraft.xtend.flow.annotations.Unit
            import de.grammarcraft.xtend.flow.annotations.Port
            import de.grammarcraft.xtend.flow.annotations.Operation
        
            @Operation @Unit(
                inputPorts = #[
                    @Port(name="«inputPortName»", type=«inputPortTypeName»)
                ],
                outputPorts = #[
                    @Port(name="«outputPortName»", type=«outputPortTypeName»)
                ]
            )
            class «className» {
            
                override «inputPortName.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName» <= msg;
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
            assertInputPortInterfaceGenerated(inputPortName, inputPortType, className, clazz, ctx)
            assertOutputPortGenerated(outputPortName, outputPortType, className, clazz, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodGenerated(className, inputPortType, clazz, ctx)
            assertLessEqualsThanOperatorsGenerated(className, inputPortType, clazz, ctx)
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
            import de.grammarcraft.xtend.flow.annotations.Unit
            import de.grammarcraft.xtend.flow.annotations.Port
            import de.grammarcraft.xtend.flow.annotations.Operation
        
            @Operation @Unit(
                inputPorts = #[
                    @Port(name="«inputPortName»", type=«inputPortTypeName»),
                    @Port(name="«inputPort2Name»", type=«inputPort2TypeName»)
                ],
                outputPorts = #[
                    @Port(name="«outputPortName»", type=«outputPortTypeName»)
                ]
            )
            class «className» {
            
                override «inputPortName.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName» <= msg;
                }
                
                override «inputPort2Name.processMethodName»(«inputPort2TypeName» msg) {
                    «outputPortName» <= «inputPort2TypeName».toString(msg);
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
            assertInputPortInterfaceGenerated(inputPortName, inputPortType, className, clazz, ctx)
            assertInputPortGenerated(inputPort2Name, inputPort2Type, className, clazz, ctx)            
            assertInputPortInterfaceGenerated(inputPort2Name, inputPort2Type, className, clazz, ctx)
            assertOutputPortGenerated(outputPortName, outputPortType, className, clazz, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodNOTGenerated(className, inputPortType, clazz, ctx)
            assertMappedToOperatorGenerated(className, outputPortType, clazz, ctx)
            assertLessEqualsThanOperatorsNOTGenerated(className, outputPortType, clazz, ctx)
            
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
            import de.grammarcraft.xtend.flow.annotations.Unit
            import de.grammarcraft.xtend.flow.annotations.Port
            import de.grammarcraft.xtend.flow.annotations.Operation
        
            @Operation @Unit(
                inputPorts = #[
                    @Port(name="«inputPortName»", type=«inputPortTypeName»)
                ],
                outputPorts = #[
                    @Port(name="«outputPortName»", type=«outputPortTypeName»),
                    @Port(name="«output2PortName»", type=«output2PortTypeName»)
                ]
            )
            class «className» {
            
                override «inputPortName.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName» <= msg.toUpperCase;
                    «output2PortName» <= msg.toLowerCase;
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
            assertInputPortInterfaceGenerated(inputPortName, inputPortType, className, clazz, ctx)
            assertOutputPortGenerated(outputPortName, outputPortType, className, clazz, ctx)
            assertOutputPortGenerated(output2PortName, output2PortType, className, clazz, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodGenerated(className, inputPortType, clazz, ctx)
            assertLessEqualsThanOperatorsGenerated(className, inputPortType, clazz, ctx)
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
            import de.grammarcraft.xtend.flow.annotations.Unit
            import de.grammarcraft.xtend.flow.annotations.Port
            import de.grammarcraft.xtend.flow.annotations.Operation
            import java.util.Set
            import java.util.Map
        
            @Operation @Unit(
                inputPorts = #[
                    @Port(name="«inputPortName»", type=«inputPortTypeName», typeArguments=#[«inputPortTypeParameters»])
                ],
                outputPorts = #[
                    @Port(name="«outputPortName»", type=«outputPortTypeName», typeArguments=#[«outputPortTypeParameters»])
                ]
            )
            class «className» {
            
                override «inputPortName.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName» <= msg.keySet;
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
            assertInputPortInterfaceGenerated(inputPortName, inputPortType, className, clazz, ctx)
            assertOutputPortGenerated(outputPortName, outputPortType, className, clazz, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodGenerated(className, inputPortType, clazz, ctx)
            assertLessEqualsThanOperatorsGenerated(className, inputPortType, clazz, ctx)
            assertMappedToOperatorGenerated(className, outputPortType, clazz, ctx)
            
        ]
    }
    
    @Test def void test_FunctionBoard() {
        val className = 'MyFunctionBoard'
        val inputPortName = 'input'
        val inputPortTypeName = 'String'
        val outputPortName = 'output'
        val outputPortTypeName = 'String'
        '''
            import de.grammarcraft.xtend.flow.annotations.Unit
            import de.grammarcraft.xtend.flow.annotations.Integration
            import de.grammarcraft.xtend.flow.annotations.Port
            import de.grammarcraft.xtend.flow.annotations.Operation
        
            @Operation @Unit(
                inputPorts = #[@Port(name="in", type=«inputPortTypeName»)],
                outputPorts = #[@Port(name="out", type=«outputPortTypeName»)]
            )
            class A {
                override processIn(«inputPortTypeName» msg) {
                    out <= msg;
                }
            }

            @Operation @Unit(
                inputPorts = #[@Port(name="in", type=«inputPortTypeName»)],
                outputPorts = #[@Port(name="out", type=«outputPortTypeName»)]
            )
            class B {
                override processIn(«inputPortTypeName» msg) {
                    out <= msg;
                }
            }

            @Integration @Unit(
                inputPorts = #[
                    @Port(name="«inputPortName»", type=«inputPortTypeName»)
                ],
                outputPorts = #[
                    @Port(name="«outputPortName»", type=«outputPortTypeName»)
                ]
            )
            class «className» {
                val A A = new A
                val B B = new B
                new() {
                    «inputPortName» -> A
                    A -> B
                    B -> «outputPortName»
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
            assertInputPortInterfaceNOTGenerated(inputPortName, inputPortType, className, clazz, ctx)
            assertOutputPortGenerated(outputPortName, outputPortType, className, clazz, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodGenerated(className, inputPortType, clazz, ctx)
            assertLessEqualsThanOperatorsGenerated(className, inputPortType, clazz, ctx)
            assertMappedToOperatorGenerated(className, outputPortType, clazz, ctx)

        ]
    }

    @Test def void test_FunctionBoard_Splitting_Input() {
        val className = 'MyFunctionBoard'
        val inputPortName = 'input'
        val inputPortTypeName = 'String'
        val outputPort1Name = 'output1'
        val outputPort1TypeName = 'String'
        val outputPort2Name = 'output1'
        val outputPort2TypeName = 'String'
        '''
            import de.grammarcraft.xtend.flow.annotations.Unit
            import de.grammarcraft.xtend.flow.annotations.FunctionBoard
            import de.grammarcraft.xtend.flow.annotations.Port
            import de.grammarcraft.xtend.flow.annotations.Operation
        
            @Operation @Unit(
                inputPorts = #[@Port(name="in", type=«inputPortTypeName»)],
                outputPorts = #[@Port(name="out", type=«outputPort1TypeName»)]
            )
            class A {
                override processIn(«inputPortTypeName» msg) {
                    out <= msg;
                }
            }

            @Operation @Unit(
                inputPorts = #[@Port(name="in", type=«inputPortTypeName»)],
                outputPorts = #[@Port(name="out", type=«outputPort1TypeName»)]
            )
            class B {
                override processIn(«inputPortTypeName» msg) {
                    out <= msg;
                }
            }

            @Integration @Unit(
                inputPorts = #[
                    @Port(name="«inputPortName»", type=«inputPortTypeName»)
                ],
                outputPorts = #[
                    @Port(name="«outputPort1Name»", type=«outputPort1TypeName»)
                ]
            )
            class «className» {
                val A A = new A
                val B B = new B
                new() {
                    «inputPortName» -> A
                    «inputPortName» -> B
                    A -> «outputPort1Name»
                    B -> «outputPort2Name»
                }
            }
        '''.compile [
            val extension ctx = transformationContext

            val clazz = findClass(className)
            val inputPortType = String.newTypeReference
            val outputPortType = String.newTypeReference
            
            assertEquals(inputPortTypeName, inputPortType.toString)
            assertEquals(outputPort1TypeName, outputPortType.toString)
            assertEquals(outputPort2TypeName, outputPortType.toString)

            assertInputPortGenerated(inputPortName, inputPortType, className, clazz, ctx)
            assertInputPortInterfaceNOTGenerated(inputPortName, inputPortType, className, clazz, ctx)
            assertOutputPortGenerated(outputPort1Name, outputPortType, className, clazz, ctx)
            assertOutputPortGenerated(outputPort2Name, outputPortType, className, clazz, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodGenerated(className, inputPortType, clazz, ctx)
            assertLessEqualsThanOperatorsGenerated(className, inputPortType, clazz, ctx)
            assertMappedToOperatorGenerated(className, outputPortType, clazz, ctx)
        ]
    }
    
        @Test def void test_two_subsequent_function_units_in_the_same_compilation_unit() {
        val inputPortTypeName = 'String'
        val outputPortTypeName = 'String'
        val className = 'MyFunctionUnit1'
        val inputPortName = 'input1'
        val outputPortName = 'output1'
        val className2 = 'MyFunctionUnit2'
        val inputPortName2 = 'input2'
        val outputPortName2 = 'output2'
        '''
            import de.grammarcraft.xtend.flow.annotations.Unit
            import de.grammarcraft.xtend.flow.annotations.Port
            import de.grammarcraft.xtend.flow.annotations.Operation
        
            @Operation @Unit(
                inputPorts = #[
                    @Port(name="«inputPortName»", type=«inputPortTypeName»)
                ],
                outputPorts = #[
                    @Port(name="«outputPortName»", type=«outputPortTypeName»)
                ]
            )
            class «className» {
            
                override «inputPortName.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName» <= msg.toUpperCase;
                }
                
            }
            
            @Operation @Unit(
                inputPorts = #[
                    @Port(name="«inputPortName2»", type=«inputPortTypeName»)
                ],
                outputPorts = #[
                    @Port(name="«outputPortName2»", type=«outputPortTypeName»)
                ]
            )
            class «className2» {
            
                override «inputPortName2.processMethodName»(«inputPortTypeName» msg) {
                    «outputPortName2» <= msg.toUpperCase;
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
            assertLessEqualsThanOperatorsGenerated(className, inputPortType, clazz, ctx)
            assertMappedToOperatorGenerated(className, outputPortType, clazz, ctx)


            val clazz2 = findClass(className2)
            assertInputPortGenerated(inputPortName2, inputPortType, className2, clazz2, ctx)            
            assertOutputPortGenerated(outputPortName2, outputPortType, className2, clazz2, ctx)
            
            assertTheOneAndOnlyInputPortCanonicalMethodGenerated(className2, inputPortType, clazz2, ctx)
            assertLessEqualsThanOperatorsGenerated(className2, inputPortType, clazz2, ctx)
            assertMappedToOperatorGenerated(className2, outputPortType, clazz2, ctx)

        ]
    }
    
    
    private def assertInputPortInterfaceGenerated(String inputPortName, TypeReference inputPortType, String className, 
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        val interf = findInterface(className.interfaceName(inputPortName))
        assertNotNull(interf)
        
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
        
        assertTrue('''method '«inputPortName.processMethodName»' does not exist at «className»''', 
            clazz.declaredMethods.exists[simpleName == inputPortName.processMethodName]
        )
            
    }

    private def assertInputPortInterfaceNOTGenerated(String inputPortName, TypeReference inputPortType, String className, 
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        assertNull('''overriding interface for input port '«inputPortName»' found, but must not be defined for function board''', 
            findInterface(className.interfaceName(inputPortName))
        )
        
        assertFalse('''method '«inputPortName.processMethodName»' exist at «className» but function boards must not define methods''', 
            clazz.declaredMethods.exists[simpleName == inputPortName.processMethodName]
        )
        
    }
    
    private def assertInputPortGenerated(String inputPortName, TypeReference inputPortType, String className, 
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        assertTrue('''field '«inputPortName»' does not exist''', 
            clazz.declaredFields.exists[simpleName == inputPortName]
        )
        clazz.declaredFields.filter[simpleName == inputPortName].head => [
            assertEquals('''field '«simpleName»' is not of type «de.grammarcraft.xtend.flow.InputPort.newTypeReference(inputPortType)»''', 
                de.grammarcraft.xtend.flow.InputPort.newTypeReference(inputPortType), type
            )
            assertEquals('''field '«inputPortName»' is not delared private''', Visibility::PRIVATE, visibility)
        ]
        
        assertTrue('''getter '«inputPortName»' does not exist''', 
            clazz.declaredMethods.exists[simpleName == inputPortName]
        )
        clazz.declaredMethods.filter[simpleName == inputPortName].head => [
            assertEquals('''getter '«simpleName»' is not of type «de.grammarcraft.xtend.flow.InputPort.newTypeReference(inputPortType)»''', 
                de.grammarcraft.xtend.flow.InputPort.newTypeReference(inputPortType), returnType
            )
            assertEquals('''getter '«inputPortName»' is not delared public''', Visibility::PUBLIC, visibility)
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
            assertEquals('''field '«outputPortName»' is not delared private''', Visibility::PRIVATE, visibility)
        ]

        assertTrue('''getter '«outputPortName»' does not exist''', 
            clazz.declaredMethods.exists[simpleName == outputPortName]
        )
        clazz.declaredMethods.filter[simpleName == outputPortName].head => [
            assertEquals('''getter '«simpleName»' is not of type «de.grammarcraft.xtend.flow.OutputPort.newTypeReference(outputPortType)»''', 
                de.grammarcraft.xtend.flow.OutputPort.newTypeReference(outputPortType), returnType
            )
            assertEquals('''getter '«outputPortName»' is not delared public''', Visibility::PUBLIC, visibility)
        ]

    }

    private def assertLessEqualsThanOperatorsGenerated(String className, TypeReference inputPortType,
        MutableClassDeclaration clazz, extension TransformationContext ctx)
    {
        assertTrue('''operator <= (operator_lessEqualsThan) does not exist at «className»''',
            clazz.declaredMethods.exists[simpleName == 'operator_lessEqualsThan']
        )
        val operatorMethods = clazz.declaredMethods.filter[simpleName == 'operator_lessEqualsThan']
        assertEquals('''there are not 2 operator <= (operator_lessEqualsThan) methods at «className»''',
            2, operatorMethods.size
        )
        assertEquals('''there is no operator <= (operator_lessEqualsThan) method with parameter «inputPortType»''',
            1, operatorMethods.filter[parameters.head.type == inputPortType].size
        )
        assertEquals('''there is no operator <= (operator_lessEqualsThan) method with closure parameter «Functions.Function0.newTypeReference(inputPortType.newWildcardTypeReference)»''',
            1, operatorMethods.filter[parameters.head.type == Functions.Function0.newTypeReference(inputPortType.newWildcardTypeReference)].size
        )
    }

    private def assertMappedToOperatorGenerated(String className, TypeReference outputPortType,
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        assertTrue('''operator -> (operator_mappedTo) does not exist at «className»''',
            clazz.declaredMethods.exists[simpleName == 'operator_mappedTo']
        )
        val operatorMethods = clazz.declaredMethods.filter[simpleName == 'operator_mappedTo']
        assertEquals('''there are not 4 operators -> (operator_mappedTo) methods at «className»''',
            4, operatorMethods.size
        )
        assertEquals('''there is no operator -> (operator_mappedTo) method with parameter «FunctionUnitWithOnlyOneInputPort.newTypeReference(outputPortType)»''',
            1, operatorMethods.filter[parameters.head.type == FunctionUnitWithOnlyOneInputPort.newTypeReference(outputPortType)].size
        )
        assertEquals('''there is no operator -> (operator_mappedTo) method with parameter «de.grammarcraft.xtend.flow.InputPort.newTypeReference(outputPortType)»''',
            1, operatorMethods.filter[parameters.head.type == de.grammarcraft.xtend.flow.InputPort.newTypeReference(outputPortType)].size
        )
        assertEquals('''there is no operator -> (operator_mappedTo) method with parameter «de.grammarcraft.xtend.flow.OutputPort.newTypeReference(outputPortType)»''',
            1, operatorMethods.filter[parameters.head.type == de.grammarcraft.xtend.flow.OutputPort.newTypeReference(outputPortType)].size
        )
        assertEquals('''there is no operator -> (operator_mappedTo) method with closure parameter «Procedures.Procedure1.newTypeReference(outputPortType.newWildcardTypeReferenceWithLowerBound)»''',
            1, operatorMethods.filter[parameters.head.type == Procedures.Procedure1.newTypeReference(outputPortType.newWildcardTypeReferenceWithLowerBound)].size
        )
    }

    private def assertMappedToOperatorNOTGenerated(String className, 
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        assertFalse('''operator -> (operator_mappedTo) must NOT not exist at «className», but is there''',
            clazz.declaredMethods.exists[simpleName == 'operator_mappedTo']
        )
    }

    private def assertLessEqualsThanOperatorsNOTGenerated(String className, TypeReference outputPortType,
        MutableClassDeclaration clazz, extension TransformationContext ctx)
    {
        assertFalse('''operator <= (operator_lessEqualsThan) must NOT not exist at «className», but is there''',
            clazz.declaredMethods.exists[simpleName == 'operator_lessEqualsThan']
        )
    }

    private def assertTheOneAndOnlyInputPortCanonicalMethodGenerated(String className, TypeReference inputPortType,
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        assertTrue('''canonical method 'theOneAndOnlyInputPort' is not overridden at «className»''',
            clazz.declaredMethods.exists[simpleName == 'theOneAndOnlyInputPort']
        )
        clazz.declaredMethods.filter[simpleName == 'theOneAndOnlyInputPort'].head => [
            assertTrue('''method '«simpleName»' must not have parameters''', parameters.empty)
            assertEquals('''method '«simpleName»' return type is not «Procedures.Procedure1.newTypeReference»''', 
                de.grammarcraft.xtend.flow.InputPort.newTypeReference(inputPortType), 
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