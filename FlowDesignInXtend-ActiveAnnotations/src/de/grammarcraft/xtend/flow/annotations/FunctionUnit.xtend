package de.grammarcraft.xtend.flow.annotations

import de.grammarcraft.xtend.flow.FunctionUnitBase
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Active(FunctionUnitProcessor)
annotation FunctionUnit {
    // Java <= 7 does not supported repeated annotations of the same type; therefore they have to be grouped into an array
    InputPort[] inputPorts = #[]
    OutputPort[] outputPorts = #[]
}

annotation InputPort {
    String name
    Class<?> type
    Class<?>[] typeParameters = #[]
}

annotation OutputPort {
    String name
    Class<?> type
    Class<?>[] typeParameters = #[]
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
        annotationReference.getValue("typeParameters") as TypeReference[]
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
                    
        extendConstructor(annotatedClass)

        addInputPorts(annotatedClass, context) 
        
        addOutputPorts(annotatedClass, context)
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

    private def checkForContextWarnings(extension TransformationContext context, MutableClassDeclaration annotatedClass) {
        if (inputPortAnnotations.empty)
            annotatedClass.addWarning("no input port defined")
        
        if (outputPortAnnotations.empty)
            annotatedClass.addWarning("no output port defined")
    }
    
    private static def extendConstructor(MutableClassDeclaration annotatedClass) {
        val hasConstructorsDeclared = !annotatedClass.declaredConstructors.empty
        if (hasConstructorsDeclared) {
            annotatedClass.declaredConstructors.forEach[
                val oldBody = body
                body = ['''
                    super("«annotatedClass.simpleName»");
                    
                    // currently there is no way in xtend to insert generated java code (generated from xtend constructor code)
                    // therefore the following is xtend code and must be like native Java code (e.g. having semicolons) to avoid java compiler errors
                    «oldBody»
                ''']
            ]            
        }
        else {
            annotatedClass.addConstructor[
                body = ['''super("«annotatedClass.simpleName»");''']
            ]
        }
    }
    
    private def addInputPorts(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
        inputPortAnnotations.forEach[ inputPortAnnotation |
                
            val portName = inputPortAnnotation.portName
            val inputPortInterfaceName = getInputPortInterfaceName(annotatedClass, inputPortAnnotation)
            val msgType = inputPortAnnotation.portType.type.newTypeReference(inputPortAnnotation.portTypeParameters)
            
            annotatedClass.addField(portName, [
                final = true
                visibility = Visibility::PUBLIC
                type = Procedures.Procedure1.newTypeReference(msgType.newWildcardTypeReferenceWithLowerBound)
                initializer = ['''
                    new org.eclipse.xtext.xbase.lib.Functions.Function0<org.eclipse.xtext.xbase.lib.Procedures.Procedure1<? super «msgType»>>() {
                        public org.eclipse.xtext.xbase.lib.Procedures.Procedure1<? super «msgType»> apply() {
                          final org.eclipse.xtext.xbase.lib.Procedures.Procedure1<«msgType»> _function = new org.eclipse.xtext.xbase.lib.Procedures.Procedure1<«msgType»>() {
                            public void apply(final «msgType» msg) {
                              «annotatedClass.simpleName».this.«portName»(msg);
                            }
                          };
                          return _function;
                        }
                    }.apply();
                ''']
            ])
            
            val processInputMethodName = '''process«portName.toFirstUpper»'''
            val msgParameterName = 'msg'
            annotatedClass.addMethod(portName, [
                final = true
                addParameter(msgParameterName, msgType)
                body = ['''«processInputMethodName»(«msgParameterName»);''']
            ])
            
            // add the interface to the list of implemented interfaces
            val interfaceType = findInterface(inputPortInterfaceName)
            annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[interfaceType.newTypeReference]
            
            interfaceType.addMethod(processInputMethodName) [
                docComment = '''
                    Implement this method to process input arriving via input port "«portName»".
                    Message coming in have type "«msgType»".
                '''
                addParameter(msgParameterName, msgType)
            ]
            
            // override the canonical function unit base method getTheOneAndOnlyInputPort for returning
            // the procedure assigned to this one and only input port
            if (inputPortAnnotations.size == 1) {
                annotatedClass.addMethod('getTheOneAndOnlyInputPort', 
                        [
                            returnType = 
                                Procedures.Procedure1.newTypeReference(msgType.newWildcardTypeReferenceWithLowerBound)
                            body = ['''
                                return this.«portName»;
                            ''']
                        ]
                )
                
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
            
            // add output connection operators -> if it is an one output port only function unit
            if (outputPortAnnotations.size == 1) {
                annotatedClass.addMethod('operator_mappedTo', 
                    [
                        val operationType = 
                            Procedures.Procedure1.newTypeReference(msgType.newWildcardTypeReferenceWithLowerBound)
                        addParameter('operation', operationType)
                        body = ['''this.«portName».operator_mappedTo(operation);''']
                    ]
                )
                annotatedClass.addMethod('operator_mappedTo', 
                    [
                        addParameter('fu', FunctionUnitBase.newTypeReference)
                        body = ['''this.«portName».operator_mappedTo(fu.<«msgType»>getTheOneAndOnlyInputPort());''']
                    ]
                )                
            }
            
        ]
    }    

}

