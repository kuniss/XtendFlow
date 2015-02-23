/*******************************************************************************
 * Copyright (c) 2014 Denis Kuniss (http://www.grammarcraft.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/

package de.grammarcraft.xtend.flow.annotations

import de.grammarcraft.xtend.flow.FunctionUnitBase
import de.grammarcraft.xtend.flow.FunctionUnitWithOnlyOneInputPort
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtext.xbase.lib.Functions.Function0

@Active(FunctionUnitProcessor)
annotation FunctionUnit {
    // Java <= 7 does not supported repeated annotations of the same type; therefore they have to be grouped into an array
    InputPort[] inputPorts = #[]
    OutputPort[] outputPorts = #[]
}

annotation InputPort {
    String name
    Class<?> type
    Class<?>[] typeArguments = #[]
}

annotation OutputPort {
    String name
    Class<?> type
    Class<?>[] typeArguments = #[]
}

class FunctionUnitProcessor extends AbstractClassProcessor {
    
    Iterable<? extends AnnotationReference> inputPortAnnotations
    Iterable<? extends AnnotationReference> outputPortAnnotations
    Iterable<? extends AnnotationReference> doubledInputAnnotations
    Iterable<? extends AnnotationReference> doubledOutputAnnotations
    
    Object inputPortAnnotationArgument
    Object outputPortAnnotationArgument
    
        
    override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {
        val functionUnitAnnotation = annotatedClass.annotations?.findFirst[annotationTypeDeclaration.simpleName == 'FunctionUnit']

        inputPortAnnotationArgument = functionUnitAnnotation?.getValue("inputPorts")
        if (inputPortAnnotationArgument?.class == typeof(AnnotationReference[])) {
            inputPortAnnotations = inputPortAnnotationArgument as AnnotationReference[]
            doubledInputAnnotations = inputPortAnnotations.doubledAnnotations
            
            if (doubledInputAnnotations.empty)
                inputPortAnnotations.forEach[ inputPortAnnotation |
                    context.registerInterface(
                        getInputPortInterfaceName(annotatedClass, inputPortAnnotation)
                    )
                ]
        }
        
        outputPortAnnotationArgument = functionUnitAnnotation?.getValue("outputPorts")
        if (outputPortAnnotationArgument?.class == typeof(AnnotationReference[])) {
            outputPortAnnotations = outputPortAnnotationArgument  as AnnotationReference[]
            doubledOutputAnnotations = outputPortAnnotations.doubledAnnotations
        }
    }
    
    private static def String getInputPortInterfaceName(ClassDeclaration annotatedClass, AnnotationReference inputPortAnnotation) {
        '''«annotatedClass.qualifiedName»_InputPort_«inputPortAnnotation.portName»'''
    }

    private static def String portName(AnnotationReference annotationReference) {
        (annotationReference.getValue("name") as String).trim
    }
    
    private static def TypeReference portType(AnnotationReference annotationReference) {
        annotationReference.getValue("type") as TypeReference
    }
    
    private static def TypeReference[] portTypeParameters(AnnotationReference annotationReference) {
        annotationReference.getValue("typeArguments") as TypeReference[]
    }
    
    private static def doubledAnnotations(Iterable<? extends AnnotationReference> portAnnotations) {
        portAnnotations.filter[doubledAnnotation(portAnnotations)]
    }
    
    private static def doubledAnnotation(AnnotationReference portAnnotation, Iterable<? extends AnnotationReference> portAnnotations) {
        portAnnotations.filter[portName == portAnnotation.portName].size > 1
    }
    
    
    override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
        var boolean hasContextErrors = false

        hasContextErrors = checkForContextErrors(context, annotatedClass)
        
        if (hasContextErrors) {
            annotatedClass.addWarning("due to port annotation errors, no code can be generated")
            return            
        }
            
        checkForContextWarnings(context, annotatedClass)
        
        // add extends clause 
        annotatedClass.extendedClass = FunctionUnitBase.newTypeReference
        annotatedClass.final = true
        
        addInterfaces(annotatedClass, context)
        
        addNamingStuff(annotatedClass, context)
                    
        addInputPorts(annotatedClass, context) 
        
        addOutputPorts(annotatedClass, context)
        
        addFlowOperators(annotatedClass, context)
    }
    
    /**
     * Adds "implements FunctionUnitWithOnlyOneInputPort<?>" if only one input port defined.
     * Add "implements FunctionUnitWithOnlyOneOutputPort<?>" if only one output port defined
     */
    def addInterfaces(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
        if (inputPortAnnotations.size == 1 || outputPortAnnotations.size == 1) 
        {
            val List<TypeReference> interfacesToBeAdded = new ArrayList
        
            if (inputPortAnnotations.size == 1) {
                val inputPortAnnotation = inputPortAnnotations.head
                interfacesToBeAdded.add( 
                    de.grammarcraft.xtend.flow.FunctionUnitWithOnlyOneInputPort.newTypeReference(
                        inputPortAnnotation.portType.type.newTypeReference(inputPortAnnotation.portTypeParameters)
                    )
                )
            }
            
            if (outputPortAnnotations.size == 1) {
                val outputPortAnnotation = outputPortAnnotations.head
                interfacesToBeAdded.add( 
                    de.grammarcraft.xtend.flow.FunctionUnitWithOnlyOneOutputPort.newTypeReference(
                        outputPortAnnotation.portType.type.newTypeReference(outputPortAnnotation.portTypeParameters)
                    )
                )
            }
            annotatedClass.implementedInterfaces = interfacesToBeAdded
        }
    }
    
    
    private def checkForContextWarnings(extension TransformationContext context, MutableClassDeclaration annotatedClass) {
        if (inputPortAnnotations.empty)
            annotatedClass.addWarning("no input port defined")
        
        if (outputPortAnnotations.empty)
            annotatedClass.addWarning("no output port defined")
    }
    
    private def checkForContextErrors(extension TransformationContext context, MutableClassDeclaration annotatedClass) {
        var boolean contextError = false
        
        if (inputPortAnnotationArgument?.class != typeof(AnnotationReference[])) {
            annotatedClass.addError("array of input port annotations expected")
            contextError = true            
        }
        
        if (outputPortAnnotationArgument?.class != typeof(AnnotationReference[])) {
            annotatedClass.addError("array of output port annotations expected")
            contextError = true            
        }
        
        if (contextError) return true
        
        if (!doubledInputAnnotations.empty) {
            doubledInputAnnotations.forEach[
                annotatedClass.addError('''input port "«portName»" is declared twice''')
            ]
            contextError = true            
        }

        if (!doubledOutputAnnotations.empty) {
            doubledOutputAnnotations.forEach[
                annotatedClass.addError('''output port "«portName»" is declared twice''')
            ]
            contextError = true            
        }
        
        return contextError
    }

    /**
     * Adds function unit's naming field and overwriting of toString method, like
     * <pre>
     * private final static String _name = "MyFunctionUnit";
     * public final String toString() { return this._name; }
     * </pre>
     */
    private static def void addNamingStuff(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
        annotatedClass.addField('_name', [
            visibility = Visibility::PRIVATE
            type = String.newTypeReference
            initializer = ['''"«annotatedClass.simpleName»"''']
        ])
        annotatedClass.addMethod('toString', [
            final = true
            visibility = Visibility::PUBLIC
            returnType = String.newTypeReference
            body = ['''return this._name;''']
        ])
        annotatedClass.addMethod('setName', [
            final = true
            visibility = Visibility::PUBLIC
            addParameter('newValue', String.newTypeReference)
            body = ['''this._name = newValue;''']
        ])
    }
    
    private def addInputPorts(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
        inputPortAnnotations.forEach[ inputPortAnnotation |
                
            val portName = inputPortAnnotation.portName
            val inputPortInterfaceName = getInputPortInterfaceName(annotatedClass, inputPortAnnotation)
            val msgType = inputPortAnnotation.portType.type.newTypeReference(inputPortAnnotation.portTypeParameters)
            val processInputMethodName = '''process«portName.toFirstUpper»'''
            
            annotatedClass.addField(portName, [
                final = true
                visibility = Visibility::PUBLIC
                type = de.grammarcraft.xtend.flow.InputPort.newTypeReference(msgType) // msgType.newWildcardTypeReferenceWithLowerBound?
                initializer = ['''
                    new org.eclipse.xtext.xbase.lib.Functions.Function0<de.grammarcraft.xtend.flow.InputPort<«msgType»>>() {
                        public de.grammarcraft.xtend.flow.InputPort<«msgType»> apply() {
                          org.eclipse.xtend2.lib.StringConcatenation _builder = new org.eclipse.xtend2.lib.StringConcatenation();
                          _builder.append(«annotatedClass.simpleName».this, "");
                          _builder.append(".«portName»");
                          final org.eclipse.xtext.xbase.lib.Procedures.Procedure1<«msgType»> _function = new org.eclipse.xtext.xbase.lib.Procedures.Procedure1<«msgType»>() {
                            public void apply(final «msgType» msg) {
                              «annotatedClass.simpleName».this.«processInputMethodName»(msg);
                            }
                          };
                          final org.eclipse.xtext.xbase.lib.Procedures.Procedure1<Exception> _function_1 = new org.eclipse.xtext.xbase.lib.Procedures.Procedure1<Exception>() {
                            public void apply(final Exception it) {
                              «annotatedClass.simpleName».this.forwardIntegrationError(it);
                            }
                          };
                          de.grammarcraft.xtend.flow.InputPort<«msgType»> _inputPort = new de.grammarcraft.xtend.flow.InputPort<«msgType»>(_builder.toString(), _function, _function_1);
                          return _inputPort;
                        }
                    }.apply();
                ''']
            ])
            
            // add the interface to the list of implemented interfaces
            val interfaceType = findInterface(inputPortInterfaceName)
            annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[interfaceType.newTypeReference]
            
            interfaceType.addMethod(processInputMethodName) [
                docComment = '''
                    Implement this method to process input arriving via input port "«portName»".
                    Message coming in has type "«msgType»".
                '''
                addParameter('msg', msgType)
            ]
        ]
            
    }
    
    private def addOutputPorts(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
        outputPortAnnotations.forEach[ outputPortAnnotation |
            val portName = outputPortAnnotation.portName
            val msgType = outputPortAnnotation.portType.type.newTypeReference(outputPortAnnotation.portTypeParameters)
                        
            // add output port
            annotatedClass.addField(portName, [
                final = true
                visibility = Visibility::PUBLIC
                type = de.grammarcraft.xtend.flow.OutputPort.newTypeReference(msgType)
                initializer = ['''
                  new org.eclipse.xtext.xbase.lib.Functions.Function0<de.grammarcraft.xtend.flow.OutputPort<«msgType»>>() {
                      public de.grammarcraft.xtend.flow.OutputPort<«msgType»> apply() {
                          org.eclipse.xtend2.lib.StringConcatenation _builder = new org.eclipse.xtend2.lib.StringConcatenation();
                          _builder.append(«annotatedClass.simpleName».this, "");
                          _builder.append(".«portName»");
                          final org.eclipse.xtext.xbase.lib.Procedures.Procedure1<Exception> _function = new org.eclipse.xtext.xbase.lib.Procedures.Procedure1<Exception>() {
                            public void apply(final Exception it) {
                              «annotatedClass.simpleName».this.forwardIntegrationError(it);
                            }
                          };
                          de.grammarcraft.xtend.flow.OutputPort<«msgType»> _outputPort = new de.grammarcraft.xtend.flow.OutputPort<«msgType»>(_builder.toString(), _function);
                          return _outputPort;
                      }
                  }.apply();
                ''']
            ])
        ]
    }
    
    def addFlowOperators(MutableClassDeclaration annotatedClass, extension TransformationContext context) {

        if (inputPortAnnotations.size == 1) 
        {
            val portName = inputPortAnnotations.head.portName
            val msgType = inputPortAnnotations.head.portType.type.newTypeReference(inputPortAnnotations.head.portTypeParameters)
            
            annotatedClass.addMethod('theOneAndOnlyInputPort', [
                returnType = de.grammarcraft.xtend.flow.InputPort.newTypeReference(msgType)
                body = ['''
                    return this.«portName»;
                ''']
            ])
            
            annotatedClass.addMethod('operator_lessEqualsThan', [
                final = true
                docComment = '''
                    Flow DSL operator "&lt;=" for forwarding a message of type '«msgType.name»' value to 
                    the one and only input port '«portName»' for being processed.<br>
                    example:<pre> 
                      input <= "some string"
                    </pre>
                '''
                val parameterVarName = 'msg'
                addParameter(parameterVarName, msgType)
                body = ['''
                    this.«portName».operator_lessEqualsThan(«parameterVarName»);
                ''']
            ])

            annotatedClass.addMethod('operator_lessEqualsThan', [
                final = true
                docComment = '''
                    Flow DSL operator "&lt;=" for forwarding a message value of type '«msgType.name»' to 
                    the one and only input port '«portName»' for being processed.<br>
                    For computing the message to be forwarded the right side closure is applied.
                    example:<pre> 
                      input &lt;= [ if (state&gt;0) "some string" else "some other string"
                    </pre>
                '''
                val msgClosureVarName = 'msgClosure'
                addParameter(msgClosureVarName, Function0.newTypeReference(newWildcardTypeReference(msgType)))
                body = ['''
                    «msgType» _apply = «msgClosureVarName».apply();
                    this.«portName».operator_lessEqualsThan(_apply);
                ''']
            ])
        }
        
        // add output connection operators -> if it is an one output port only function unit
        if (outputPortAnnotations.size == 1) 
        {
            val portName = outputPortAnnotations.head.portName
            val msgType = outputPortAnnotations.head.portType.type.newTypeReference(outputPortAnnotations.head.portTypeParameters)
            
            annotatedClass.addMethod('operator_mappedTo', [
                final = true
                docComment = '''
                    Flow DSL operator "-&gt;" for letting all message issued by the one and only output port '«portName»' being 
                    processed by the right side closure.
                    Typically this is used to process the message for a side effect like printing on standard out. 
                    example:<pre>
                      fu -&gt; [msg|println("message received: " + msg")]
                    </pre>
                '''
                val msgProessingClosureVarName = 'msgProcessingClosure'
                val operationType = 
                    Procedures.Procedure1.newTypeReference(msgType.newWildcardTypeReferenceWithLowerBound)
                addParameter(msgProessingClosureVarName, operationType)
                body = ['''this.«portName».operator_mappedTo(«msgProessingClosureVarName»);''']
            ])
            
            annotatedClass.addMethod('operator_mappedTo', [
                final = true
                docComment = '''
                    Flow DSL operator "-&gt;" for connecting two function units. 
                    Connects the left one function unit's one and only one output port '«portName»' with 
                    the right side funtion unit which has one and only one input port.<br>
                    example:<pre>
                      fu -&gt; fu'
                    </pre>
                '''
                val rightSideFunctionUnitVarName = 'rightSideFunctionUnit'
                addParameter(rightSideFunctionUnitVarName, FunctionUnitWithOnlyOneInputPort.newTypeReference(msgType))
                body = ['''
                        de.grammarcraft.xtend.flow.InputPort<«msgType»> _theOneAndOnlyInputPort = «rightSideFunctionUnitVarName».theOneAndOnlyInputPort();
                        org.eclipse.xtext.xbase.lib.Procedures.Procedure1<? super «msgType»> _inputProcessingOperation = _theOneAndOnlyInputPort.inputProcessingOperation();
                        this.«portName».operator_mappedTo(_inputProcessingOperation);
                ''']
            ])
            
            annotatedClass.addMethod('operator_mappedTo', [
                final = true
                docComment = '''
                    Flow DSL operator "-&gt;" for connecting two function units. 
                    Connects the left one function unit's one and only one output port '«portName»' with 
                    the right side function unit's named input port.<br>
                    example:<pre>
                      fu -&gt; fu'.input
                    </pre>
                '''
                val rightSideFunctionUnitInputPortVarName = 'rightSideFunctionUnitInputPort'
                addParameter(rightSideFunctionUnitInputPortVarName, de.grammarcraft.xtend.flow.InputPort.newTypeReference(msgType))
                body = ['''
                    this.«portName».operator_mappedTo(«rightSideFunctionUnitInputPortVarName»);
                ''']
            ])

            annotatedClass.addMethod('operator_mappedTo', [
                final = true
                docComment = '''
                    Flow DSL operator "-&gt;" for connecting two function units. 
                    Connects the left side function unit's one and only one output port '«portName»' with 
                    the right side function unit's named output port.<br>
                    This is normally only used in integrating function units for connecting an integrated function unit with
                    an output port of the integrating function unit.
                    example:<pre>
                      fu -&gt; output
                    </pre>
                '''
                val rightSideFunctionUnitOutputPortVarName = 'rightSideFunctionUnitOutputPort'
                addParameter(rightSideFunctionUnitOutputPortVarName, de.grammarcraft.xtend.flow.OutputPort.newTypeReference(msgType))
                body = ['''
                    this.«portName».operator_mappedTo(«rightSideFunctionUnitOutputPortVarName»);
                ''']
            ])
            
        }
    }
    
        

}

