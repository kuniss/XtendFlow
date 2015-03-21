package de.grammarcraft.xtend.annotatedflow

class CallStackExample {
    
    def static void main(String[] args) {
        // build
        val reverse = new Reverse
        val toUpper = new ToUpper
        val toLower = new ToLower
        
        // bind
        reverse -> toUpper
        toUpper -> toLower
        toLower -> [msg | throw new RuntimeException(msg)]
          
        try {
            reverse <= "some input"
        }
        catch (RuntimeException re) {
            re.printStackTrace
        }
    }
    
}