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
    InputPin[] inputPins = #[]
    OutputPin[] outputPins = #[]
}

annotation InputPin {
    String name
    Class<?> type
    Class<?>[] typeParameters = #[]
}

annotation OutputPin {
    String name
    Class<?> type
    Class<?>[] typeParameters = #[]
}

class FunctionUnitProcessor extends AbstractClassProcessor {
    
    Iterable<? extends AnnotationReference> inputPinAnnotations
    Iterable<? extends AnnotationReference> outputPinAnnotations
    Iterable<? extends AnnotationReference> doubledInputAnnotations
    Iterable<? extends AnnotationReference> doubledOutputAnnotations
    
    Object inputPinAnnotationArgument
    Object outputPinAnnotationArgument
    
        
    override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {
        val functionUnitAnnotation = annotatedClass.annotations?.findFirst[annotationTypeDeclaration.simpleName == 'FunctionUnit']

        inputPinAnnotationArgument = functionUnitAnnotation?.getValue("inputPins")
        if (inputPinAnnotationArgument?.class == typeof(AnnotationReference[])) {
            inputPinAnnotations = inputPinAnnotationArgument as AnnotationReference[]
            doubledInputAnnotations = inputPinAnnotations.doubledAnnotations
            
            if (doubledInputAnnotations.empty)
                inputPinAnnotations.forEach[ inputPinAnnotation |
                    context.registerInterface(
                        getInputPinInterfaceName(annotatedClass, inputPinAnnotation)
                    )
                ]
        }
        
        outputPinAnnotationArgument = functionUnitAnnotation?.getValue("outputPins")
        if (outputPinAnnotationArgument?.class == typeof(AnnotationReference[])) {
            outputPinAnnotations = outputPinAnnotationArgument  as AnnotationReference[]
            doubledOutputAnnotations = outputPinAnnotations.doubledAnnotations
        }
    }
    
    private static def String getInputPinInterfaceName(ClassDeclaration annotatedClass, AnnotationReference inputPinAnnotation) {
        '''«annotatedClass.qualifiedName»_InputPin_«inputPinAnnotation.pinName»'''
    }

    private static def String pinName(AnnotationReference annotationReference) {
        (annotationReference.getValue("name") as String).trim
    }
    
    private static def TypeReference pinType(AnnotationReference annotationReference) {
        annotationReference.getValue("type") as TypeReference
    }
    
    private static def TypeReference[] pinTypeParameters(AnnotationReference annotationReference) {
        annotationReference.getValue("typeParameters") as TypeReference[]
    }
    
    private static def doubledAnnotations(Iterable<? extends AnnotationReference> pinAnnotations) {
        pinAnnotations.filter[doubledAnnotation(pinAnnotations)]
    }
    
    private static def doubledAnnotation(AnnotationReference pinAnnotation, Iterable<? extends AnnotationReference> pinAnnotations) {
        pinAnnotations.filter[pinName == pinAnnotation.pinName].size > 1
    }
    
    
    override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
        var boolean hasContextErrors = false

        hasContextErrors = checkForContextErrors(context, annotatedClass)
        
        if (hasContextErrors) {
            annotatedClass.addWarning("due to pin annotation errors, no code can be generated")
            return            
        }
            
        checkForContextWarnings(context, annotatedClass)
        
        // add extends clause 
        annotatedClass.extendedClass = FunctionUnitBase.newTypeReference
        annotatedClass.final = true
                    
        extendConstructor(annotatedClass)

        addInputPins(annotatedClass, context) 
        
        addOutputPins(annotatedClass, context)
    }
    
    
    private def checkForContextErrors(extension TransformationContext context, MutableClassDeclaration annotatedClass) {
        var boolean contextError = false
        
        if (inputPinAnnotationArgument?.class != typeof(AnnotationReference[])) {
            annotatedClass.addError("array of input pin annotations expected")
            contextError = true            
        }
        
        if (outputPinAnnotationArgument?.class != typeof(AnnotationReference[])) {
            annotatedClass.addError("array of output pin annotations expected")
            contextError = true            
        }
        
        if (contextError) return true
        
        if (!doubledInputAnnotations.empty) {
            doubledInputAnnotations.forEach[
                annotatedClass.addError('''input pin "«pinName»" is declared twice''')
            ]
            contextError = true            
        }

        if (!doubledOutputAnnotations.empty) {
            doubledOutputAnnotations.forEach[
                annotatedClass.addError('''output pin "«pinName»" is declared twice''')
            ]
            contextError = true            
        }
        
        return contextError
    }

    private def checkForContextWarnings(extension TransformationContext context, MutableClassDeclaration annotatedClass) {
        if (inputPinAnnotations.empty)
            annotatedClass.addWarning("no input pin defined")
        
        if (outputPinAnnotations.empty)
            annotatedClass.addWarning("no output pin defined")
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
    
    private def addInputPins(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
        inputPinAnnotations.forEach[ inputPinAnnotation |
                
            val pinName = inputPinAnnotation.pinName
            val inputPinInterfaceName = getInputPinInterfaceName(annotatedClass, inputPinAnnotation)
            val msgType = inputPinAnnotation.pinType.type.newTypeReference(inputPinAnnotation.pinTypeParameters)
            
            annotatedClass.addField(pinName, [
                final = true
                visibility = Visibility::PUBLIC
                type = Procedures.Procedure1.newTypeReference(msgType.newWildcardTypeReferenceWithLowerBound)
                initializer = ['''
                    new org.eclipse.xtext.xbase.lib.Functions.Function0<org.eclipse.xtext.xbase.lib.Procedures.Procedure1<? super «msgType»>>() {
                        public org.eclipse.xtext.xbase.lib.Procedures.Procedure1<? super «msgType»> apply() {
                          final org.eclipse.xtext.xbase.lib.Procedures.Procedure1<«msgType»> _function = new org.eclipse.xtext.xbase.lib.Procedures.Procedure1<«msgType»>() {
                            public void apply(final «msgType» msg) {
                              «annotatedClass.simpleName».this.«pinName»(msg);
                            }
                          };
                          return _function;
                        }
                    }.apply();
                ''']
            ])
            
            val processInputMethodName = '''process«pinName.toFirstUpper»'''
            val msgParameterName = 'msg'
            annotatedClass.addMethod(pinName, [
                final = true
                addParameter(msgParameterName, msgType)
                body = ['''«processInputMethodName»(«msgParameterName»);''']
            ])
            
            // add the interface to the list of implemented interfaces
            val interfaceType = findInterface(inputPinInterfaceName)
            annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[interfaceType.newTypeReference]
            
            interfaceType.addMethod(processInputMethodName) [
                docComment = '''
                    Implement this method to process input arriving via input pin "«pinName»".
                    Message coming in have type "«msgType»".
                '''
                addParameter(msgParameterName, msgType)
            ]
            
            // override the canonical function unit base method getTheOneAndOnlyInputPin for returning
            // the procedure assigned to this one and only input pin
            if (inputPinAnnotations.size == 1) {
                annotatedClass.addMethod('getTheOneAndOnlyInputPin', 
                        [
                            returnType = 
                                Procedures.Procedure1.newTypeReference(msgType.newWildcardTypeReferenceWithLowerBound)
                            body = ['''
                                return this.«pinName»;
                            ''']
                        ]
                )
                
            }
        ]
    }
    
    private def addOutputPins(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
        outputPinAnnotations.forEach[ outputPinAnnotation |
            val pinName = outputPinAnnotation.pinName
            val msgType = outputPinAnnotation.pinType.type.newTypeReference(outputPinAnnotation.pinTypeParameters)
                        
            // add output pin
            annotatedClass.addField(pinName, [
                final = true
                visibility = Visibility::PUBLIC
                type = de.grammarcraft.xtend.flow.OutputPin.newTypeReference(msgType)
                initializer = ['''
                  new org.eclipse.xtext.xbase.lib.Functions.Function0<de.grammarcraft.xtend.flow.OutputPin<«msgType»>>() {
                      public de.grammarcraft.xtend.flow.OutputPin<«msgType»> apply() {
                          org.eclipse.xtend2.lib.StringConcatenation _builder = new org.eclipse.xtend2.lib.StringConcatenation();
                          _builder.append(«annotatedClass.simpleName».this, "");
                          _builder.append(".«pinName»");
                          final org.eclipse.xtext.xbase.lib.Procedures.Procedure1<Exception> _function = new org.eclipse.xtext.xbase.lib.Procedures.Procedure1<Exception>() {
                            public void apply(final Exception it) {
                              «annotatedClass.simpleName».this.forwardIntegrationError(it);
                            }
                          };
                          de.grammarcraft.xtend.flow.OutputPin<«msgType»> _outputPin = new de.grammarcraft.xtend.flow.OutputPin<«msgType»>(_builder.toString(), _function);
                          return _outputPin;
                      }
                  }.apply();
                ''']
            ])
            
            // add output connection operators -> if it is an one output pin only function unit
            if (outputPinAnnotations.size == 1) {
                annotatedClass.addMethod('operator_mappedTo', 
                    [
                        val operationType = 
                            Procedures.Procedure1.newTypeReference(msgType.newWildcardTypeReferenceWithLowerBound)
                        addParameter('operation', operationType)
                        body = ['''this.«pinName».operator_mappedTo(operation);''']
                    ]
                )
                annotatedClass.addMethod('operator_mappedTo', 
                    [
                        addParameter('fu', FunctionUnitBase.newTypeReference)
                        body = ['''this.«pinName».operator_mappedTo(fu.<«msgType»>getTheOneAndOnlyInputPin());''']
                    ]
                )                
            }
            
        ]
    }    

}

