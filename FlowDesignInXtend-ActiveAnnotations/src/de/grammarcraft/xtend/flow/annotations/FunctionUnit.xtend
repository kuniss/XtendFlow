/*******************************************************************************
 * Copyright (c) 2014 Denis Kuniss (http://www.grammarcraft.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/

package de.grammarcraft.xtend.flow.annotations

import de.grammarcraft.xtend.flow.FunctionUnitWithOnlyOneInputPort
import de.grammarcraft.xtend.flow.FunctionUnitWithOnlyOneOutputPort
import de.grammarcraft.xtend.flow.IFunctionUnit
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
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1

/**
 * Represents an Function Unit in the sense of the Flow Design paradigm.
 * It defines input ports for receiving data and output ports to forward computation results to
 * other function units or for applying side effects.
 */
@Active(FunctionUnitProcessor)
annotation Unit {
    // Java <= 7 does not supported repeated annotations of the same type; therefore they have to be grouped into an array
    /** 
     * Defines on or more named Input Ports the function unit receives typed input data 
     * over from other function units.<br>
     * Each of the declared ports may be connected to other function unit's output ports using the 
     * wiring operator: other_fu.out -> this_fu.a.<br>
     * Each input port <i>a</i> message may be forwarded using the forward operator:
     * this_fu.a <= message.<br>
     * For integration units an integrated function unit input port may be connected to this unit's 
     * input port forwarding input messages to those integrated function unit: 
     * this_fu.i -> integrated_fu.in.
     */
    Port[] inputPorts = #[]
    /** 
     * Defines one or more named and typed Output Ports the computation results of this function unit are 
     * forwarded over to other function units or to be processed for side effects.<br
     * Each of the declared port <i>o</i> may be connected to other function unit's out ports using the 
     * wiring operator: this_fu.o -> other_fu.in.<br>
     * For integration units an integrated function unit output port may be connected to this unit's 
     * output port forwarding computation result messages of those  unit to this function unit's 
     * output port: integrated_fu.out -> this_fu.o.
     */
    Port[] outputPorts = #[]
}

/**
 * {@link Unit} modifier marking a Function Unit as an operation in the sense of the Flow Design paradigm.
 * The term <i>operation</i> has the same meaning as in the IODA architecture.<br>
 * Operation units are implementing the real functionality of the software system. They are the basic 
 * components of a software system wired together by {@link Integration} {@link Unit}s. 
 * Only operation units contain logic and control flow implementations.<br>
 * For every declared port <i>a</i> in this list of inputPorts a method <i>process$a</i> with a parameter 
 * of the port's type must be implemented for processing the incoming messages.<br>
 */
annotation Operation {}

/**
 * {@link Unit} modifier marking a Function Unit as an integration in the sense of the Flow Design paradigm. 
 * The term <i>integration</i> has the same meaning as in the IODA architecture.<br>
 * Integration unit's only purpose is to integrate other function units by wiring them together defining
 * the data flow between them. Integration units never contain logic and control flow implementations.<br>
 * Typically, they only contain function unit instantiations and a constructor with wiring operations.
 */
annotation Integration {}

/**
 * Defines a Port in the sense of Flow Design. Over the port the associated Function Unit
 * receives input data for processing from other function units or forwards computation
 * results to other function units down stream.<br> 
 * The port has a <i>name</i> and a <i>type</i> with optional type arguments. 
 * This name and type is used for creating appropriate port types, getter, setter, and operation methods 
 * allowing those ports to be wired up with other function unit ports.<br>
 * Example:<br>
 * <code>@Port(name="in", type=String)</code> is defining a port with name <i>in</i> of 
 * type <i>java.lang.String</i><br>
 * <code>@Port(name="in", type=Map, typeArguments=#[Integer,String])</code> is defining a port 
 * with name <i>in</i> of the generic type <i>Map&lt;Integer,String&gt;</i><br>
 */
annotation Port {
    String name
    Class<?> type
    Class<?>[] typeArguments = #[]
}

/**
 * Use annotations {@link Operation} {@link Unit} both together.
 */
@Deprecated
@Active(FunctionUnitProcessor)
annotation FunctionUnit {
    // Java <= 7 does not supported repeated annotations of the same type; therefore they have to be grouped into an array
    InputPort[] inputPorts = #[]
    OutputPort[] outputPorts = #[]
}

/**
 * Use annotations {@link Integration} {@link Unit} both together instead.
 */
@Deprecated
@Active(FunctionUnitProcessor)
annotation FunctionBoard {
    // Java <= 7 does not supported repeated annotations of the same type; therefore they have to be grouped into an array
    InputPort[] inputPorts = #[]
    OutputPort[] outputPorts = #[]
}

/**
 * Use annotation {@link Port} together with  {@link Unit}.
 */
@Deprecated
annotation InputPort {
    String name
    Class<?> type
    Class<?>[] typeArguments = #[]
}

/**
 * Use annotation {@link Port} together with  {@link Unit}.
 */
@Deprecated
annotation OutputPort {
    String name
    Class<?> type
    Class<?>[] typeArguments = #[]
}

class FunctionUnitProcessor extends AbstractClassProcessor {
    
    AnnotationReference unitAnnotation
    AnnotationReference unitModifier
    
    Iterable<? extends AnnotationReference> inputPortAnnotations
    Iterable<? extends AnnotationReference> outputPortAnnotations
    Iterable<? extends AnnotationReference> doubledInputAnnotations
    Iterable<? extends AnnotationReference> doubledOutputAnnotations
    
    Object inputPortAnnotationArgument
    Object outputPortAnnotationArgument
    
        
    private def static boolean isFunctionUnit(AnnotationReference annotation) {
        return annotation?.annotationTypeDeclaration?.qualifiedName == FunctionUnit.name
    }

    private def static boolean isFunctionBoard(AnnotationReference annotation) {
        return annotation?.annotationTypeDeclaration?.qualifiedName == FunctionBoard.name
    }
    
    private def static boolean isFlowUnit(AnnotationReference annotation) {
        return annotation?.annotationTypeDeclaration?.qualifiedName == Unit.name
    }
    
    private def static boolean isOperation(AnnotationReference annotation) {
        return annotation?.annotationTypeDeclaration?.qualifiedName == Operation.name
    }

    private def static boolean isIntegration(AnnotationReference annotation) {
        return annotation?.annotationTypeDeclaration?.qualifiedName == Integration.name
    }
    
    /**
     * @return true if the processed class is annotated with @Integration @Unit
     */
    private def boolean isIntegrationUnit() {
        return this.unitAnnotation.isFlowUnit && this.unitModifier.isIntegration
    }

    /**
     * @return true if the processed class is annotated with @Operation @Unit
     */
    private def boolean isOperationUnit() {
        return this.unitAnnotation.isFlowUnit && this.unitModifier.isOperation
    }
    
    override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {
        unitAnnotation = annotatedClass.annotations?.findFirst[ functionUnit || functionBoard || flowUnit ]
        unitModifier = annotatedClass.annotations?.findFirst[ operation || integration ]

        inputPortAnnotationArgument = unitAnnotation?.getValue("inputPorts")
        if (inputPortAnnotationArgument?.class == typeof(AnnotationReference[])) {
            inputPortAnnotations = inputPortAnnotationArgument as AnnotationReference[]
            doubledInputAnnotations = inputPortAnnotations.doubledAnnotations
            
            if (doubledInputAnnotations.empty && (unitAnnotation.isFunctionUnit || operationUnit))
                inputPortAnnotations.forEach[ inputPortAnnotation |
                    context.registerInterface(
                        getInputPortInterfaceName(annotatedClass, inputPortAnnotation)
                    )
                ]
        }
        
        outputPortAnnotationArgument = unitAnnotation?.getValue("outputPorts")
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
        
        annotatedClass.final = true
        
        annotatedClass.docComment = '''
            «annotatedClass.docComment»
            «if (!(annotatedClass.docComment == null || annotatedClass.docComment.empty)) '<br><br>'»
            Implements a function unit as defined by Flow Design paradigm.<br>
            It consumes input messages over the input ports<br>
                «inputPortAnnotations.map['''"«portName»" of type "«portType»"'''].join('<br>\n')»<br>
            And issues computation results over the output ports<br>
                «outputPortAnnotations.map['''"«portName»" of type "«portType»"'''].join('<br>\n')»<br>
        '''
        
        addClassCommentToConstructors(annotatedClass, context)
        
        addInterfaces(annotatedClass, context)
        
        addNamingStuff(annotatedClass, context)
        
        addIntegrationErrorPort(annotatedClass, context)
                    
        addInputPorts(annotatedClass, context) 
        
        addOutputPorts(annotatedClass, context)
        
        addFlowOperators(annotatedClass, context)
    }
    
    /**
     * Adds the class documentation to all constructors after the user's given documentation.
     * This is done because in Xtend the types are typically not given when instantiating 
     * a function unit. By promoting the class documentation to constructors they will
     * become visible by hovers in IDEs.
     */
    def private static addClassCommentToConstructors(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
        annotatedClass.declaredConstructors.forEach[ 
            docComment = '''
                «docComment»
                «if (!(docComment == null || docComment.empty)) '<br><br>'»
                «annotatedClass.docComment»
            '''
        ]
    }
    
    /**
     * Adds "implements FunctionUnitWithOnlyOneInputPort<?>" if only one input port defined.
     * Add "implements FunctionUnitWithOnlyOneOutputPort<?>" if only one output port defined
     */
    def private addInterfaces(MutableClassDeclaration annotatedClass, extension TransformationContext context) 
    {
        val List<TypeReference> interfacesToBeAdded = new ArrayList
    
        interfacesToBeAdded.add(IFunctionUnit.newTypeReference)    
        
        if (inputPortAnnotations.size == 1 || outputPortAnnotations.size == 1) 
        {
        
            if (inputPortAnnotations.size == 1) {
                val inputPortAnnotation = inputPortAnnotations.head
                interfacesToBeAdded.add( 
                    FunctionUnitWithOnlyOneInputPort.newTypeReference(
                        inputPortAnnotation.portType.type.newTypeReference(inputPortAnnotation.portTypeParameters)
                    )
                )
            }
            
            if (outputPortAnnotations.size == 1) {
                val outputPortAnnotation = outputPortAnnotations.head
                interfacesToBeAdded.add( 
                    FunctionUnitWithOnlyOneOutputPort.newTypeReference(
                        outputPortAnnotation.portType.type.newTypeReference(outputPortAnnotation.portTypeParameters)
                    )
                )
            }
        }
        annotatedClass.implementedInterfaces = interfacesToBeAdded
    }
    
    
    private def checkForContextWarnings(extension TransformationContext context, MutableClassDeclaration annotatedClass) {
        if (inputPortAnnotations.empty)
            annotatedClass.addWarning("no input port defined")
        
        if (outputPortAnnotations.empty)
            annotatedClass.addWarning("no output port defined")
            
        if ((unitAnnotation.isFunctionBoard || integrationUnit) && 
            annotatedClass.declaredMethods.filter[visibility != Visibility::PRIVATE].size > 0)
        {
            annotatedClass.declaredMethods.filter[visibility != Visibility::PRIVATE].forEach[
                addWarning("a FunctionBoard must not have other than private methods")
            ]
        }
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
        
        if (unitModifier == null && unitAnnotation.isFlowUnit) {
            annotatedClass.addError("modifier @Operation or @Integration required")
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
    
    /**
     * Adds methods and fields for implementing {@link IFunctionUnit}.
     */
    def private addIntegrationErrorPort(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
        val integrationErrorPortName = 'integrationError'
        annotatedClass.addField(integrationErrorPortName, [
            final = true
            visibility = Visibility::PRIVATE
            type = de.grammarcraft.xtend.flow.OutputPort.newTypeReference(Exception.newTypeReference)
            initializer = ['''
                new «de.grammarcraft.xtend.flow.OutputPort.name»<«Exception.name»>("integrationError", 
                    new org.eclipse.xtext.xbase.lib.Procedures.Procedure1<«Exception.name»>() {
                      @Override
                      public void apply(final «Exception.name» ex) {
                        String _message = ex.getMessage();
                        String _plus = ("FATAL ERROR: " + _message);
                        «InputOutput.name».<String>println(_plus);
                      }
                    }
                )
            ''']
        ])
        annotatedClass.addMethod(integrationErrorPortName, [
            final = true
            returnType = de.grammarcraft.xtend.flow.OutputPort.newTypeReference(Exception.newTypeReference)
            body = ['''return this.«integrationErrorPortName»;''']
        ])
        annotatedClass.addMethod('forwardIntegrationError', [
            final = true
            val parameterName = 'integrationException'
            addParameter(parameterName, Exception.newTypeReference)
            body = ['''this.«integrationErrorPortName».operator_lessEqualsThan(«parameterName»);''']
        ])
    }
    

    private def addInputPorts(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
        inputPortAnnotations.forEach[ inputPortAnnotation |
                
            val portName = inputPortAnnotation.portName
            val inputPortInterfaceName = getInputPortInterfaceName(annotatedClass, inputPortAnnotation)
            val msgType = inputPortAnnotation.portType.type.newTypeReference(inputPortAnnotation.portTypeParameters)
            val processInputMethodName = '''process$«portName»'''
            
            annotatedClass.addField(portName, [
                final = true
                visibility = Visibility::PRIVATE
                type = de.grammarcraft.xtend.flow.InputPort.newTypeReference(msgType) // msgType.newWildcardTypeReferenceWithLowerBound?
                initializer = ['''
                    new org.eclipse.xtext.xbase.lib.Functions.Function0<de.grammarcraft.xtend.flow.InputPort<«msgType»>>() {
                        public de.grammarcraft.xtend.flow.InputPort<«msgType»> apply() {
                          org.eclipse.xtend2.lib.StringConcatenation _builder = new org.eclipse.xtend2.lib.StringConcatenation();
                          _builder.append(«annotatedClass.simpleName».this, "");
                          _builder.append(".«portName»");
                          final org.eclipse.xtext.xbase.lib.Procedures.Procedure1<Exception> _function_1 = new org.eclipse.xtext.xbase.lib.Procedures.Procedure1<Exception>() {
                            public void apply(final Exception it) {
                              «annotatedClass.simpleName».this.forwardIntegrationError(it);
                            }
                          };
                          «IF (unitAnnotation.isFunctionBoard || integrationUnit)»
                          de.grammarcraft.xtend.flow.InputPort<«msgType»> _inputPort = new de.grammarcraft.xtend.flow.InputPort<«msgType»>(_builder.toString(), _function_1);
                          «ELSE»
                          final org.eclipse.xtext.xbase.lib.Procedures.Procedure1<«msgType»> _function = new org.eclipse.xtext.xbase.lib.Procedures.Procedure1<«msgType»>() {
                            public void apply(final «msgType» msg) {
                              «annotatedClass.simpleName».this.«processInputMethodName»(msg);
                            }
                          };
                          de.grammarcraft.xtend.flow.InputPort<«msgType»> _inputPort = new de.grammarcraft.xtend.flow.InputPort<«msgType»>(_builder.toString(), _function, _function_1);
                          «ENDIF»
                          return _inputPort;
                        }
                    }.apply();
                ''']
            ])
            
            annotatedClass.addMethod(portName, [
                final = true
                returnType = de.grammarcraft.xtend.flow.InputPort.newTypeReference(msgType)
                docComment = '''
                    Input port '«portName»' of function unit '«annotatedClass.simpleName»', receives messages of 
                    type '«msgType»' for further processing by this function unit.
                '''
                body = ['''
                    return this.«portName»;
                ''']
            ])

            if (unitAnnotation.isFunctionUnit || operationUnit) {
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
            }
        ]
            
    }
    
    private def addOutputPorts(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
        outputPortAnnotations.forEach[ outputPortAnnotation |
            val portName = outputPortAnnotation.portName
            val msgType = outputPortAnnotation.portType.type.newTypeReference(outputPortAnnotation.portTypeParameters)
                        
            // add output port
            annotatedClass.addField(portName, [
                final = true
                visibility = Visibility::PRIVATE
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
            
            annotatedClass.addMethod(portName, [
                final = true
                returnType = de.grammarcraft.xtend.flow.OutputPort.newTypeReference(msgType)
                docComment = '''
                    Output port '«portName»' of function unit '«annotatedClass.simpleName»', issues messages of 
                    type '«msgType»' as computation result of this function unit.
                '''
                body = ['''
                    return this.«portName»;
                ''']
            ])

            
        ]
    }
    
    def private addFlowOperators(MutableClassDeclaration annotatedClass, extension TransformationContext context) {

        if (inputPortAnnotations.size == 1) 
        {
            val portName = inputPortAnnotations.head.portName
            val msgType = inputPortAnnotations.head.portType.type.newTypeReference(inputPortAnnotations.head.portTypeParameters)
            
            annotatedClass.addMethod('theOneAndOnlyInputPort', [
                final = true
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

