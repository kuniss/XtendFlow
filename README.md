XtendFlow [![Build Status](https://travis-ci.org/kuniss/XtendFlow.svg?branch=master)](https://travis-ci.org/kuniss/XtendFlow) [![Download](https://api.bintray.com/packages/kuniss/maven/de.grammarcraft.xtend.flow/images/download.svg) ](https://bintray.com/kuniss/maven/de.grammarcraft.xtend.flow/_latestVersion) [![Get automatic notifications about new "de.grammarcraft.xtend.flow" versions](https://www.bintray.com/docs/images/bintray_badge_color.png) ](https://bintray.com/kuniss/maven/de.grammarcraft.xtend.flow/view?source=watch)
=====================================================================================================================

This library enables [Xtend](https://www.eclipse.org/xtend/) for Flow Design based programming, the natural approach for [IODA Architectures](http://geekswithblogs.net/theArchitectsNapkin/archive/2015/04/29/the-ioda-architecture.aspx).

The notation tries to follow the intention of the inventor of Flow Design [Ralf Westphal](http://blog.ralfw.de/) as close as possible. 
This programming paradigm and its notation was initially explained by him in English in his articles 
["Flow-Design Cheat Sheet – Part I, Notation"](http://www.geekswithblogs.net/theArchitectsNapkin/archive/2011/03/19/flow-design-cheat-sheet-ndash-part-i-notation.aspx) and
["Flow-Design Cheat Sheet – Part II, Notation"](http://www.geekswithblogs.net/theArchitectsNapkin/archive/2011/03/20/flow-design-cheat-sheet-ndash-part-ii-translation.aspx).
He introduces the underlying paradigm in detail in his article series ["The Incremental Architect´s Napkin"](http://geekswithblogs.net/theArchitectsNapkin/category/19718.aspx) and in his book ["Messaging as a Programming Model"](https://leanpub.com/messaging_as_a_programming_model).
The according architectural approach he describes in his article ["The IODA Architecture"](http://geekswithblogs.net/theArchitectsNapkin/archive/2015/04/29/the-ioda-architecture.aspx). However, this architectural approach is more general and is going beyond Flow Design and may be applicable to any programming platform.
All, absolutely worth to read!

Who understands German may read [my blog article](http://blog.grammarcraft.de/2014/06/05/extend-your-flow-horizon-flow-design-mit-xtend/)
on how this notation was initially mapped to Xtend.

However, since version [0.2.0](https://bintray.com/kuniss/maven/de.grammarcraft.xtend.flow/0.2.0/view) the Xtend Flow library 
supports a notation which takes the advantages of Xtend regarding operator overriding forming up a tiny DSL which is very concise and 
quite closer to the original flow notation than my first attempt.
Since version [0.4.0](https://bintray.com/kuniss/maven/de.grammarcraft.xtend.flow/0.4.0/view) the libraries domain language officially follows the nomenclature of the [IODA Architecture](http://geekswithblogs.net/theArchitectsNapkin/archive/2015/04/29/the-ioda-architecture.aspx).

## Xtend Flow DSL

The Xtend flow DSL consists of [active annotations](https://eclipse.org/xtend/documentation/204_activeannotations.html) for declaring 
function units as operations and integrations including their input and output ports, as well as of operators for wiring ports and for forwarding message to output ports.

### Function Unit Annotation `@Unit`

The annotation `@Unit` is applied to Xtend classes marking them as function units and declares input and output ports for them.
E.g., the function unit

![Simple Function Unit](http://blog.grammarcraft.de/wp-content/uploads/2013/03/Bild3-ToUpper.png)

would be declared in Xtend as the follows:
```java
@Unit(
    inputPorts = #[
        @InputPort(name="input", type=String)
    ],
    outputPorts = #[
        @OutputPort(name="output", type=String)
    ]
)
class ToUpper {
...
}
```

Organizing software systems in function units is one of the main design keys of Flow Design. It follows closely the [Principle of Mutual Oblivion (PoMO)](http://geekswithblogs.net/theArchitectsNapkin/archive/2014/08/24/the-incremental-architectrsquos-napkin---5---design-functions-for.aspx). There is no dependency between the implementation of different function units. Function units does not know each other. There are only global dependencies to message data types flowing through the ports.


## Operation Unit Annotation `@Operation`

Marking an function unit with annotation `@Operation` declares an operation in the sense of the IODA architecture and automatically adds particular Xtend class properties and class operations for allowing to program message processing and message forwarding.

The `ToUpper` function unit from above is intended to be a operation unit in the sense of IODA. Therefore, this function unit should be defined with the `@Operation` annotation in front:
```java
@Operation @Unit(
    inputPorts = #[
        @InputPort(name="input", type=String)
    ],
    outputPorts = #[
        @OutputPort(name="output", type=String)
    ]
)
class ToUpper {
...
}
```

How the string messages arriving over the port `input` are processed is implemented by the method `process` annotated by the port name at the end:
```java
class ToUpper {
    override process$input(String msg) {
       ...
    }
```
Having added the according function unit annotation to a Xtend class, the implementation of the right named method for processing the input 
arriving over the `input` port is also requested by compiler and supported by quick fix proposals in IDEs like Eclipse.


### Message Forwarding Operator `<=`

The computed messages may be forwarded to the declared `output` port using the message forwarding operator `<=`:

```java
output <= msg.toUpperCase;
``` 

The message forwarding operator also accepts closures computing the message to be forwarded:

```java
output <= [
    if (msg.startsWith("_"))
        msg.toFirstUpper
    else
        msg.toUpperCase
]
``` 

## Operation Unit Annotation `@Integration`

While operation units are used for implementing the pieces of logic a system is composed of, the only reason of integration units following the IODA architecture approach is the integration of other function units, operation or integration units. Integration units are used to compose systems and parts of systems. 
Nevertheless they are treated as function units as well, having input and output ports. Therefore input ports and output ports are declared in the same way.

```java
@Integration @Unit(
    inputPorts = #[
        @InputPort(name="input", type=String)
    ],
    outputPorts = #[
        @OutputPort(name="lower", type=String),
        @OutputPort(name="upper", type=String)
    ]
)
class Normalize {
  ...
}
```

Separating operation units - for implementing functionality - from integration units for integration purposes is one of the main goals of the IODA architecture and within Flow Design. It allows to structure software systems in several levels of abstraction having implementation details only on the lowest level of abstraction. On upper level of abstraction the implementation consist of integration functionality only, represented by integration units.
This is the second main principle of Flow Design and follows closely the [Integration Operation Segregation Principle (IOSP)](http://geekswithblogs.net/theArchitectsNapkin/archive/2014/09/13/the-incremental-architectacutes-napkin---7---nest-flows-to.aspx). 

### Port Wiring Operator `->`

The function units are either instantiated by the board or passed via constructor injection. Any [Dependency Injection](TODO add DP wiki link) approach could be applied here.

As integrating is the only reason for an integration unit, it normally has only a constructor method, nothing else.
This constructor connects output to input ports of the integrated function units, as well as the integration unit's own
input ports to the integrated function unit's input ports, and the integrated function unit's output ports to the integration unit's own output ports. 
For this the wiring operator `->` is used. Here comes an example:

```java
class Normalize {
    
    val toLower = new ToLower
    val toUpper = new ToUpper
    
    new() { 
        toLower.output -> lower
        toUpper.output -> upper
        input -> toLower
        input -> toUpper
    }

}
```  

The wiring follows the data flow implemented by the system to be designed. The Xtend class above integrates the two instances of function units `ToLower` and `ToUpper` as shown in the following figure. In fact, it does not matter whether the integrated function units are integration or operation function units!

![Integrating Function Board](http://blog.grammarcraft.de/wp-content/uploads/2013/07/Bild3-Normalize-reingezoomt1.png)

The wiring operator works for full qualified port names, like
```
fu1.output -> fu2.input
```
as well as for function units with only one input or output port, like
```
fu1 -> fu2
```
as well as for mixed combinations, like
```
fu1.output -> fu2
fu1 -> fu2.output
```

Unfortunately, no error is shown by the Xtend compiler if the wiring operator is applied to a function unit with more 
than one input port or output port without using full qualified port names as then the operator is treated as Xtend's
pairing operator.

## Implicit Input Ports

Under circumstances a flow needs to be started by an event without any data delivering; e.g. on an intial start of a program. In this case the definition of the inpurt port may be omitted. The framework will create an implicit input port of type `de.grammarcraft.xtend.flow.data.None`. 

Let's assume a function unit with no input port declared. It reads user input from the console - a typical use case for starting a flow without explicit input data delivery:
```
@Operation @Unit(
    outputPorts = #[
        @Port(name="readNumber", type=String)
    ]
)
class ReadNumberToConvert {..}
```

The flow trough this function unit may be started by forwarding the predefined constant value `None` to it:
```
class Program 
{
    def static void main(String[] args) 
    {
        ReadNumberToConvert entry_point
        ...
	    entry_point <= None
	}
}
```

For this example the following method for processing the data less input event have to be overridden:
```
class ReadNumberToConvert {

    override process$start(None msg) {
        output <= this.inputProvider.read_number_to_convert()
    }
    
}
```


## Error Handling


### Integration Error Handling

An integration error is given if a declared output port is not connected to any input port or any closure processing message from it. This is a meta-model error and is treated by the library by the special port `intergationError` of type `java.lang.Exception` predefined for each function unit and function board. By default this port is always connected to a closure printing a fatal error message on the standard console.

However, this connection may be overridden by the library user, explicitly forwarding the exception to an user defined closure or input port.

```
fu.integrationError -> [ log.fatal("integration error happened: {0}", exception.message) ] 
```

as this may become a hassle if for all instantiated function units the same closure has to be connected, there is an helper expression implemented where a bunch of function units may be connected at once to one closure:
```
      onIntegrationErrorAt(#[reverse, collector]) [ 
          exception | log.fatal("integration error happened: {0}", exception.message)
      ]
```

Here, the variables `reverse` and `collector` are referencing function unit instances.

### Model Error Handling

The more interesting part for system designers is, how to handle errors which are inherent part of the system to be modeled. 
In fact, this is quite easy: All errors implicated by the system's model should be design as ordinary ports. They are still messages flowing through the system and must be handled explicitly by system's design.


## Example

A simple example applying this notation may be found [as sub project at this repository](https://github.com/kuniss/XtendFlow/tree/master/FlowDesignInXtend) on GitHub.


## Runtime Cost Considerations

In fact, wiring up ports results in method call implementations which are not very expensive and are almost well optimized by the Hotspot JVM.

E.g., the wiring of the function units from the example above into a chain, throwing an exception at the end, like
```
reverse -> toUpper
toUpper -> toLower
toLower -> [msg | throw new RuntimeException(msg)]
  
try {
    reverse <= "some input"
}
catch (RuntimeException re) {
    re.printStackTrace
}
```
will result in an exception with the following stack trace (shorten to show the important calls):
```
java.lang.RuntimeException: tupni emos
    at de.grammarcraft.xtend.annotatedflow.CallStackExample$1.apply(CallStackExample.java:20)
    ...
    at de.grammarcraft.xtend.flow.OutputPort.forward(OutputPort.java:52)
    ...
    at de.grammarcraft.xtend.annotatedflow.ToLower.process$input(ToLower.java:27)
    ...
    at de.grammarcraft.xtend.flow.OutputPort.forward(OutputPort.java:52)
    ...
    at de.grammarcraft.xtend.annotatedflow.ToUpper.process$input(ToUpper.java:27)
    ...
    at de.grammarcraft.xtend.flow.OutputPort.forward(OutputPort.java:52)
    ...
    at de.grammarcraft.xtend.annotatedflow.Reverse.process$input(Reverse.java:45)
    ...
    at de.grammarcraft.xtend.annotatedflow.CallStackExample.main(CallStackExample.java:25)
```


## Concurrency Considerations

The message forwarding mechanisms of this Flow Design implementation are not thread safe at all. 
So, if messages may be forwarded to an input port of a function unit instance in concurrent situations, means, the particular `process` method of  that input port may be called concurrently from different threads, the implementation of this method must handle such concurrent calls properly by a thread safe internal implementation according to the Java synchronization rules.

Detecting concurrent situations in the system to be designed is an inherent mission of the system designer. Flow design does not help him in that challenge. However, support may be added in later versions of the library, when the actors concept (like in Scala or Erlang) is integrated letting function units becomes actors for concurrent designs. An example for combining the Flow Design approach with the Actors Design may be found in Ralf Westphal's article ["Actors in a IODA Architecture by Example"](http://geekswithblogs.net/theArchitectsNapkin/archive/2015/05/12/actors-in-a-ioda-architecture-by-example.aspx)

## Flow Cycle Considerations

The designer has strictly to avoid specifying direct or indirect cycles in the message flow! Cycles cannot be detected by the compiler or the annotation processor as the library and its notation has been realized as an internal DSL utilizing [Xtend's active annotations](https://eclipse.org/xtend/documentation/204_activeannotations.html). Active annotation processors are working in the context of classes not in the global context of all compilation units. For detecting cycles, the analysis of the global context would be needed. This may only be done by an external DSL.

Who understands German may read my [blog article](http://blog.grammarcraft.de/2014/02/08/kreisfluss-rueckgekoppelte-systeme-mit-flow-design/) about that issue.

## Build Integration

The library is provided for arbitrary build systems via
[Bintray](https://bintray.com/kuniss/maven/de.grammarcraft.xtend.flow/view) 
and via [Maven Central](http://search.maven.org/#search|ga|1|a%3A%22de.grammarcraft.xtend.flow%22) thanks to [Stefan Öhme's article](http://mnmlst-dvlpr.blogspot.de/2014/12/my-lightweight-release-process.html).

E.g., the integration via Gradle is as follows:
```
dependencies {
  compile 'org.eclipse.xtend:org.eclipse.xtend.lib:2.8.+'
  compile 'de.grammarcraft:de.grammarcraft.xtend.flow:0.2.+'
}
```


## How It Gets Released

The building is done applying Gradle plugins 
for [Xtend compiling](http://plugins.gradle.org/plugin/org.xtend.xtend) 
and [for releasing to Bintray and Maven Central](http://plugins.gradle.org/plugin/com.github.oehme.sobula.bintray-release).

The build is running on [Travis CI](https://travis-ci.org/kuniss/XtendFlow).

## Example Implementations

Example implentations applying this library may be found on GitHub in the repository [XtendFlow-Examples](https://github.com/kuniss/XtendFlow-Examples).
