package de.grammarcraft.xtend.flow.annotations

import org.junit.Test
import static org.junit.Assert.*
import org.junit.Ignore

class OperationTest {
    
    package def static String forwardTrough(de.grammarcraft.xtend.flow.InputPort<String> port, String msg) {
        return appendPort(msg, port.toString)
    }

    package def static String forwardTrough(de.grammarcraft.xtend.flow.OutputPort<String> port, String msg) {
        return '''«msg»-«port»'''
    }
    
    private def static String appendPort(String msg, String port) '''«msg»-«port»'''

    @FunctionUnit(
        inputPorts = #[
            @InputPort(name="in", type=String)
        ],
        outputPorts = #[
            @OutputPort(name="out", type=String)
        ]
    )
    static class A {
        
        override process$in(String msg) {
            val addedInputPortSignature = OperationTest.forwardTrough(in, msg)
            out <= OperationTest.forwardTrough(out, addedInputPortSignature)
        }
    }

    @FunctionUnit(
        inputPorts = #[
            @InputPort(name="in", type=String)
        ],
        outputPorts = #[
            @OutputPort(name="out", type=String)
        ]
    )
    static class B {
        
        
        override process$in(String msg) {
            out <= OperationTest.forwardTrough(out, OperationTest.forwardTrough(in, msg))
        }
       
    }
    
    /**
     * fu -> fu'
     */    
    @Test def test_connecting_FU_with_only_one_output_port_to_FU_with_only_one_input_port() {
        val A A = new A
        val B B = new B
        A -> B
        B.out -> [assertEquals('start-A.in-A.out-B.in-B.out', it)]
        A.in <= 'start'
    }

    /**
     * fu -> fu'.input
     */
    @Test def test_connecting_FU_with_only_one_output_port_to_FU_with_named_input_port() {
        val A A = new A
        val B B = new B
        A -> B.in
        B.out -> [assertEquals('start-A.in-A.out-B.in-B.out', it)]
        A.in <= 'start'
    }
    /**
     * fu -> [closure]
     */
    @Test def test_connecting_FU_with_only_one_output_port_to_closure() {
        val A A = new A
        A -> [assertEquals('start-A.in-A.out', it)]
        A.in <= 'start'
    }

    /**
     * fu <= input value
     */
    @Test def test_forwarding_message_to_FU_with_only_one_input_port() {
        val A A = new A
        A.out -> [assertEquals('start-A.in-A.out', it)]
        A <= 'start'
    }
    
    /**
     * fu.input <= input value
     */
    @Test def test_forwarding_message_to_FU_with_named_input_port() {
        val A A = new A
        A.out -> [assertEquals('start-A.in-A.out', it)]
        A.in <= 'start'
    }
    
    /**
     * fu.input <= [input value closure]
     */
    @Test def test_forwarding_message_from_closure_to_FU_with_named_input_port() {
        val A A = new A
        A.out -> [assertEquals('start-A.in-A.out', it)]
        A.in <= ['start']
    }
    
    /**
     * fu.output -> fu'
     */
    @Test def test_connection_FU_with_named_output_port_to_FU_with_only_one_input_port() {
        val A A = new A
        val B B = new B
        A.out -> B
        B.out -> [assertEquals('start-A.in-A.out-B.in-B.out', it)]
        A.in <= 'start'
    }
    
    /**
     * fu.output -> fu'.input
     */
    @Test def test_connection_FU_with_named_output_port_to_FU_with_named_input_port() {
        val A A = new A
        val B B = new B
        A.out -> B.in
        B.out -> [assertEquals('start-A.in-A.out-B.in-B.out', it)]
        A.in <= 'start'
    }

    /**
     * fu.output -> [closure]
     */
    @Test def test_connection_FU_with_named_output_port_to_closure() {
        val A A = new A
        A.out -> [assertEquals('start-A.in-A.out', it)]
        A.in <= 'start'
    }


    @FunctionUnit(
        inputPorts = #[
            @InputPort(name="in", type=String)
        ],
        outputPorts = #[
            @OutputPort(name="out", type=String)
        ]
    )
    static class I1 {
        val A A = new A
        /**
         * Test operation fu -> .output
         */
        new() { A -> out }
        override process$in(String msg) { 
            A <= forwardTrough(in, msg)
        }
        
    }

    /**
     * fu -> .output
     */
    @Test def test_connection_of_inner_FU_with_only_one_output_port_to_named_own_output_port() {
        val I1 I1 = new I1
        I1.out -> [assertEquals('start-I1.in-A.in-A.out', it)]
        I1.in <= 'start'
    }

    @FunctionUnit(
        inputPorts = #[
            @InputPort(name="in", type=String)
        ],
        outputPorts = #[
            @OutputPort(name="out", type=String)
        ]
    )
    static class I2 {
        val A A = new A
        /**
         * Test operation fu.output -> .output
         */
        new() { A.out -> out }
        override process$in(String msg) { 
            A <= forwardTrough(in, msg)
        }
    }

    /**
     * fu.output -> .output
     */
    @Test def test_connection_of_inner_FU_with_named_output_port_to_named_own_output_port() {
        val I2 I2 = new I2
        I2.out -> [assertEquals('start-I2.in-A.in-A.out', it)]
        I2.in <= 'start'
    }

    @FunctionUnit(
        inputPorts = #[
            @InputPort(name="in", type=String)
        ],
        outputPorts = #[
            @OutputPort(name="out", type=String)
        ]
    )
    static class C {
        /**
         * .output <= [output value closure]
         */
        override process$in(String msg) { 
            out <= [forwardTrough(out, forwardTrough(in, msg))]
        }
        
    }

    /**
     * .output <= [output value closure]
     */
    @Test def test_forward_message_from_closure_to_own_named_output_port() {
        val C C = new C
        C.out -> [assertEquals('start-C.in-C.out', it)]
        C.in <= 'start'
    }
    
    @Ignore @Test def test_Java_identifiers() {
        var int i
        for (i = Character.MIN_CODE_POINT; i <= Character.MAX_CODE_POINT; i++)
           if (Character.isJavaIdentifierStart(i) && !Character.isAlphabetic(i)) {
                System.out.print(i as char)
                System.out.print(" ");
           }
    }
    
    @FunctionBoard(
        inputPorts = #[@InputPort(name="in", type=String)],
        outputPorts = #[
            @OutputPort(name="outA", type=String),
            @OutputPort(name="outB", type=String)
        ]
    )
    static class FB {
        A A = new A
        B B = new B
        new() {
            in -> A
            in -> B
            A -> outA
            B -> outB
        }   
    }
    
    @Test def test_function_board_splitting_input() {
        val FB fb = new FB
        val StringBuilder result = new StringBuilder
        fb.outA -> [result.append(it).append(':')]
        fb.outB -> [result.append(it)]
        fb.in <= "start"
        assertEquals('start-A.in-A.out:start-B.in-B.out', result.toString)
    }
    
    
}
