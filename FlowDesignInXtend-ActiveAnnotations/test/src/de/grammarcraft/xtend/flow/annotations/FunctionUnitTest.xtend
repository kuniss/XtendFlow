package de.grammarcraft.xtend.flow.annotations

import java.util.Map
import java.util.Set
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.junit.Test

import static org.junit.Assert.*

class FunctionUnitTest {

    extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(FunctionUnit)
    
    private def String interfaceName(String className, String inputPinName) '''«className»_InputPin_«inputPinName»'''

    private def String processMethodName(String inputPinName) '''process«inputPinName.toFirstUpper»'''
    
    @Test def void test_String_typed_pins() {
        val className = 'MyFunctionUnit'
        val inputPinName = 'input'
        val inputPinTypeName = 'String'
        val outputPinName = 'output'
        val outputPinTypeName = 'String'
        '''
            import de.grammarcraft.xtend.flow.annotations.FunctionUnit
            import de.grammarcraft.xtend.flow.annotations.OutputPin
            import de.grammarcraft.xtend.flow.annotations.InputPin
        
            @FunctionUnit(
                inputPins = #[
                    @InputPin(name="«inputPinName»", type=«inputPinTypeName»)
                ],
                outputPins = #[
                    @OutputPin(name="«outputPinName»", type=«outputPinTypeName»)
                ]
            )
            class «className» {
            
                override «inputPinName.processMethodName»(«inputPinTypeName» msg) {
                    «outputPinName».forward(msg.toUpperCase);
                }
                
            }
        '''.compile [
            val extension ctx = transformationContext

            val clazz = findClass(className)
            val inputPinType = String.newTypeReference
            val outputPinType = String.newTypeReference
            
            assertEquals(inputPinTypeName, inputPinType.toString)
            assertEquals(outputPinTypeName, outputPinType.toString)

            assertInputPinGenerated(inputPinName, inputPinType, className, clazz, ctx)            
            assertOutputPinGenerated(outputPinName, outputPinType, className, clazz, ctx)
            
            assertMappedToOperatorGenerated(className, outputPinType, clazz, ctx)
            
        ]
    }
    
    @Test def void test_unusal_named_pins() {
        val className = 'Funktionseinheit'
        val inputPinName = 'eingabe'
        val inputPinTypeName = 'String'
        val outputPinName = 'ausgabe'
        val outputPinTypeName = 'String'
        '''
            import de.grammarcraft.xtend.flow.annotations.FunctionUnit
            import de.grammarcraft.xtend.flow.annotations.OutputPin
            import de.grammarcraft.xtend.flow.annotations.InputPin
        
            @FunctionUnit(
                inputPins = #[
                    @InputPin(name="«inputPinName»", type=«inputPinTypeName»)
                ],
                outputPins = #[
                    @OutputPin(name="«outputPinName»", type=«outputPinTypeName»)
                ]
            )
            class «className» {
            
                override «inputPinName.processMethodName»(«inputPinTypeName» msg) {
                    «outputPinName».forward(msg.toUpperCase);
                }
                
            }
        '''.compile [
            val extension ctx = transformationContext

            val clazz = findClass(className)
            val inputPinType = String.newTypeReference
            val outputPinType = String.newTypeReference
            
            assertEquals(inputPinTypeName, inputPinType.toString)
            assertEquals(outputPinTypeName, outputPinType.toString)

            assertInputPinGenerated(inputPinName, inputPinType, className, clazz, ctx)            
            assertOutputPinGenerated(outputPinName, outputPinType, className, clazz, ctx)
            
            assertMappedToOperatorGenerated(className, outputPinType, clazz, ctx)
            
        ]
    }

    @Test def void test_Integer_typed_pins() {
        val className = 'MyFunctionUnit'
        val inputPinName = 'input'
        val inputPinTypeName = 'Integer'
        val outputPinName = 'output'
        val outputPinTypeName = 'Integer'
        '''
            import de.grammarcraft.xtend.flow.annotations.FunctionUnit
            import de.grammarcraft.xtend.flow.annotations.OutputPin
            import de.grammarcraft.xtend.flow.annotations.InputPin
        
            @FunctionUnit(
                inputPins = #[
                    @InputPin(name="«inputPinName»", type=«inputPinTypeName»)
                ],
                outputPins = #[
                    @OutputPin(name="«outputPinName»", type=«outputPinTypeName»)
                ]
            )
            class «className» {
            
                override «inputPinName.processMethodName»(«inputPinTypeName» msg) {
                    «outputPinName».forward(msg);
                }
                
            }
        '''.compile [
            val extension ctx = transformationContext

            val clazz = findClass(className)
            val inputPinType = Integer.newTypeReference
            val outputPinType = Integer.newTypeReference
            
            assertEquals(inputPinTypeName, inputPinType.toString)
            assertEquals(outputPinTypeName, outputPinType.toString)

            assertInputPinGenerated(inputPinName, inputPinType, className, clazz, ctx)            
            assertOutputPinGenerated(outputPinName, outputPinType, className, clazz, ctx)
            
            assertMappedToOperatorGenerated(className, outputPinType, clazz, ctx)
            
        ]
    }
    
    @Test def void test_2_input_pins() {
        val className = 'MyFunctionUnit'
        val inputPinName = 'input'
        val inputPinTypeName = 'String'
        val inputPin2Name = 'input2'
        val inputPin2TypeName = 'Integer'
        val outputPinName = 'output'
        val outputPinTypeName = 'String'
        '''
            import de.grammarcraft.xtend.flow.annotations.FunctionUnit
            import de.grammarcraft.xtend.flow.annotations.OutputPin
            import de.grammarcraft.xtend.flow.annotations.InputPin
        
            @FunctionUnit(
                inputPins = #[
                    @InputPin(name="«inputPinName»", type=«inputPinTypeName»),
                    @InputPin(name="«inputPin2Name»", type=«inputPin2TypeName»)
                ],
                outputPins = #[
                    @OutputPin(name="«outputPinName»", type=«outputPinTypeName»)
                ]
            )
            class «className» {
            
                override «inputPinName.processMethodName»(«inputPinTypeName» msg) {
                    «outputPinName».forward(msg);
                }
                
                override «inputPin2Name.processMethodName»(«inputPin2TypeName» msg) {
                    «outputPinName».forward(«inputPin2TypeName».toString(msg));
                }
            }
        '''.compile [
            val extension ctx = transformationContext

            val clazz = findClass(className)
            val inputPinType = String.newTypeReference
            val inputPin2Type = Integer.newTypeReference
            val outputPinType = String.newTypeReference
            
            assertEquals(inputPinTypeName, inputPinType.toString)
            assertEquals(inputPin2TypeName, inputPin2Type.toString)
            assertEquals(outputPinTypeName, outputPinType.toString)

            assertInputPinGenerated(inputPinName, inputPinType, className, clazz, ctx)            
            assertInputPinGenerated(inputPin2Name, inputPin2Type, className, clazz, ctx)            
            assertOutputPinGenerated(outputPinName, outputPinType, className, clazz, ctx)
            
            assertMappedToOperatorGenerated(className, outputPinType, clazz, ctx)
            
        ]
    }
    
        @Test def void test_2_output_pins() {
        val className = 'MyFunctionUnit'
        val inputPinName = 'input'
        val inputPinTypeName = 'String'
        val outputPinName = 'output'
        val outputPinTypeName = 'String'
        val output2PinName = 'output2'
        val output2PinTypeName = 'String'
        '''
            import de.grammarcraft.xtend.flow.annotations.FunctionUnit
            import de.grammarcraft.xtend.flow.annotations.OutputPin
            import de.grammarcraft.xtend.flow.annotations.InputPin
        
            @FunctionUnit(
                inputPins = #[
                    @InputPin(name="«inputPinName»", type=«inputPinTypeName»)
                ],
                outputPins = #[
                    @OutputPin(name="«outputPinName»", type=«outputPinTypeName»),
                    @OutputPin(name="«output2PinName»", type=«output2PinTypeName»)
                ]
            )
            class «className» {
            
                override «inputPinName.processMethodName»(«inputPinTypeName» msg) {
                    «outputPinName».forward(msg.toUpperCase);
                    «output2PinName».forward(msg.toLowerCase);
                }
                
            }
        '''.compile [
            val extension ctx = transformationContext

            val clazz = findClass(className)
            val inputPinType = String.newTypeReference
            val outputPinType = String.newTypeReference
            val output2PinType = String.newTypeReference
            
            assertEquals(inputPinTypeName, inputPinType.toString)
            assertEquals(outputPinTypeName, outputPinType.toString)
            assertEquals(output2PinTypeName, output2PinType.toString)

            assertInputPinGenerated(inputPinName, inputPinType, className, clazz, ctx)            
            assertOutputPinGenerated(outputPinName, outputPinType, className, clazz, ctx)
            assertOutputPinGenerated(output2PinName, output2PinType, className, clazz, ctx)
            
            assertMappedToOperatorNOTGenerated(className, clazz, ctx)
            
        ]
    }
    
        @Test def void test_complex_typed_pins() {
        val className = 'MyFunctionUnit'
        val inputPinName = 'input'
        val inputPinTypeName = 'Map'
        val inputPinTypeParameters = 'Integer, String' 
        val outputPinName = 'output'
        val outputPinTypeName = 'Set'
        val outputPinTypeParameters = 'Integer' 
        '''
            import de.grammarcraft.xtend.flow.annotations.FunctionUnit
            import de.grammarcraft.xtend.flow.annotations.OutputPin
            import de.grammarcraft.xtend.flow.annotations.InputPin
            import java.util.Set
            import java.util.Map
        
            @FunctionUnit(
                inputPins = #[
                    @InputPin(name="«inputPinName»", type=«inputPinTypeName», typeParameters=#[«inputPinTypeParameters»])
                ],
                outputPins = #[
                    @OutputPin(name="«outputPinName»", type=«outputPinTypeName», typeParameters=#[«outputPinTypeParameters»])
                ]
            )
            class «className» {
            
                override «inputPinName.processMethodName»(«inputPinTypeName» msg) {
                    «outputPinName».forward(msg.keySet);
                }
                
            }
        '''.compile [
            val extension ctx = transformationContext

            val clazz = findClass(className)
            val inputPinType = Map.newTypeReference(Integer.newTypeReference, String.newTypeReference)
            val outputPinType = Set.newTypeReference(Integer.newTypeReference)
            
            assertEquals('''«inputPinTypeName»<«inputPinTypeParameters»>'''.toString, inputPinType.toString)
            assertEquals('''«outputPinTypeName»<«outputPinTypeParameters»>'''.toString, outputPinType.toString)

            assertInputPinGenerated(inputPinName, inputPinType, className, clazz, ctx)            
            assertOutputPinGenerated(outputPinName, outputPinType, className, clazz, ctx)
            
            assertMappedToOperatorGenerated(className, outputPinType, clazz, ctx)
            
        ]
    }
    
    
    
    
    private def assertInputPinGenerated(String inputPinName, TypeReference inputPinType, String className, 
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        val interf = findInterface(className.interfaceName(inputPinName))
        
        // input pins
        assertTrue('''class '«className»' does not implement required interface '«className.interfaceName(inputPinName)»' ''', 
            clazz.implementedInterfaces.exists[it.name == interf.qualifiedName]
        )
        
        assertTrue('''method '«inputPinName.processMethodName»' does not exist at «className.interfaceName(inputPinName)»''', 
            interf.declaredMethods.exists[simpleName == inputPinName.processMethodName]
        )
        interf.declaredMethods.filter[simpleName == inputPinName.processMethodName ].head => [
            assertEquals('''method '«simpleName»' has not exactly one parameter at «className.interfaceName(inputPinName)»''',
                1, parameters.size
            )
            assertEquals('''method '«simpleName»' parameter is not of type «inputPinType» at «className.interfaceName(inputPinName)»''', 
                inputPinType, parameters.head.type
            )
        ]
        
        assertTrue('''method '«inputPinName»' does not exist at «className»''', 
            clazz.declaredMethods.exists[simpleName == inputPinName]
        )
        assertTrue('''field '«inputPinName»' does not exist at «className»''', 
            clazz.declaredFields.exists[simpleName == inputPinName]
        )
        assertTrue('''method '«inputPinName.processMethodName»' does not exist at «className»''', 
            clazz.declaredMethods.exists[simpleName == inputPinName.processMethodName]
        )
        
        clazz.declaredMethods.filter[simpleName == inputPinName ].head => [
            assertEquals('''method '«simpleName»' has not exactly one parameter''', 
                1, parameters.size
            )
            assertEquals('''method '«simpleName»' parameter is not of type «inputPinType»''', 
                inputPinType, parameters.head.type
            )
        ]
        clazz.declaredFields.filter[simpleName == inputPinName].head => [
            assertEquals('''field '«simpleName»' is not of type «Procedures.Procedure1.newTypeReference(inputPinType.newWildcardTypeReferenceWithLowerBound)»''', 
                Procedures.Procedure1.newTypeReference(inputPinType.newWildcardTypeReferenceWithLowerBound), type
            )
        ]
    }
    
    private def assertOutputPinGenerated(String outputPinName, TypeReference outputPinType, String className, 
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        assertTrue('''field '«outputPinName»' does not exist''', 
            clazz.declaredFields.exists[simpleName == outputPinName]
        )
        clazz.declaredFields.filter[simpleName == outputPinName].head => [
            assertEquals('''field '«simpleName»' is not of type «de.grammarcraft.xtend.flow.OutputPin.newTypeReference(outputPinType)»''', 
                de.grammarcraft.xtend.flow.OutputPin.newTypeReference(outputPinType), type
            )
        ]
    }

    private def assertMappedToOperatorGenerated(String className, TypeReference outputPinType,
        MutableClassDeclaration clazz, extension TransformationContext ctx) 
    {
        assertTrue('''operator -> (operator_mappedTo) does not exist at «className»''',
            clazz.declaredMethods.exists[simpleName == 'operator_mappedTo']
        )
        clazz.declaredMethods.filter[simpleName == 'operator_mappedTo'].head => [
            assertEquals('''method '«simpleName»' has not exactly one parameter''', 
                1, parameters.size
            )
            assertEquals('''method '«simpleName»' parameter is not of type «Procedures.Procedure1.newTypeReference»''', 
                Procedures.Procedure1.newTypeReference(outputPinType.newWildcardTypeReferenceWithLowerBound), 
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
    
}