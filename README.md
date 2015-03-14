XtendFlow [![Build Status](https://travis-ci.org/kuniss/XtendFlow.svg?branch=master)](https://travis-ci.org/kuniss/XtendFlow) [![Download](https://api.bintray.com/packages/kuniss/maven/de.grammarcraft.xtend.flow/images/download.svg) ](https://bintray.com/kuniss/maven/de.grammarcraft.xtend.flow/_latestVersion) [![Get automatic notifications about new "de.grammarcraft.xtend.flow" versions](https://www.bintray.com/docs/images/bintray_badge_color.png) ](https://bintray.com/kuniss/maven/de.grammarcraft.xtend.flow/view?source=watch)
=====================================================================================================================

This library enables [Xtend](https://www.eclipse.org/xtend/) for Flow Design based programming.

The notation tries to follow the intention of the inventor of Flow Design [Ralf Westphal](http://blog.ralfw.de/) as close as possible. 
This programming paradigm and its notation was initially explained by him in English in his articles 
["Flow-Design Cheat Sheet – Part I, Notation"](http://www.geekswithblogs.net/theArchitectsNapkin/archive/2011/03/19/flow-design-cheat-sheet-ndash-part-i-notation.aspx) and
["Flow-Design Cheat Sheet – Part II, Notation"](http://www.geekswithblogs.net/theArchitectsNapkin/archive/2011/03/20/flow-design-cheat-sheet-ndash-part-ii-translation.aspx).
He introduces the underlying paradigm in detail at his book ["Messaging as a Programming Model"](https://leanpub.com/messaging_as_a_programming_model). Absolutely worth to read!

Who understands German may read [my blog article](http://blog.grammarcraft.de/2014/06/05/extend-your-flow-horizon-flow-design-mit-xtend/)
on how this notation was initially mapped to Xtend.

However, since version [0.2.0](https://bintray.com/kuniss/maven/de.grammarcraft.xtend.flow/0.2.0/view) the Xtend Flow library 
supports a notation which takes the advantages of Xtend regarding operator overriding forming up a tiny DSL which is very concise and 
quite closer to the original flow notation than my first attempt.

## Xtend Flow DSL

The Xtend flow DSL consists of [active annotations](https://eclipse.org/xtend/documentation/204_activeannotations.html) for declaring 
function units and function boards including their input and output ports, as well as of operators for wiring ports and for forwarding message to output ports.

### Function Unit Annotation `@FunctionUnit`

The annotation `@FunctionUnit` is applied to Xtend classes marking them as function units and declares input and output ports.
E.g., the function unit

![Simple Function Unit](http://blog.grammarcraft.de/wp-content/uploads/2013/03/Bild3-ToUpper.png)

would be declared in Xtend as the follows:
```java
@FunctionUnit(
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

How the string messages arriving over the port `input` are processed is implemented by the method `process` annotated by the port name:
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

### Function Board Annotation `@FunctionBoard`

While function units are used for implementing the real functionality of a system, the only reason of function unit boards is 
the integration of other function units and boards. Nevertheless they are treated as function units as well, 
having input and output ports. Therefore input port and output ports are declared in the same way as on function unit annotations.

```java
@FunctionBoard(
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

### Port Wiring operator `->`

The integrated function units and boards are either instantiated by the board or 
passed via constructor injection. 
As integrating is the only reason for a function board, it normally has only a constructor method, nothing else.
This constructor connects output to input ports of the integrated function units, as well as the function board's own
input ports to integrated function unit's input ports, and the integrated function unit's output ports to function board's 
own output ports. 
For this the wiring operator `->` is used.

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

The wiring follows the data flow implemented by the system to be designed. The Xtend class above integrates the two instances of function units `ToLower` and `ToUpper` as shown in the following figure.

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
than one input ports or output ports without using full qualified port names as then the operator is treated as Xtend's
pairing operator.  


## Example

A simple example applying this notation may be found [as sub project at this repository](https://github.com/kuniss/XtendFlow/tree/master/FlowDesignInXtend) on GitHub.


## Build Integration

The library is provided for arbitrary build systems via
[Bintray](https://bintray.com/kuniss/maven/de.grammarcraft.xtend.flow/view) 
and via [Maven Central](http://search.maven.org/#search|ga|1|a%3A%22de.grammarcraft.xtend.flow%22) thanks to [Stefan Öhme's article](http://mnmlst-dvlpr.blogspot.de/2014/12/my-lightweight-release-process.html).


## How It Gets Released

The building is done applying Gradle plugins 
for [Xtend compiling](http://plugins.gradle.org/plugin/org.xtend.xtend) 
and [for releasing to Bintray and Maven Central](http://plugins.gradle.org/plugin/com.github.oehme.sobula.bintray-release).

The build is running on [Travis CI](https://travis-ci.org/kuniss/XtendFlow).
