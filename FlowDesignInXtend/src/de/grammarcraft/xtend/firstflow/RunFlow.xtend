package de.grammarcraft.xtend.firstflow


class RunFlow {
  def static void main(String[] args) {
      
	  // build
	  println("instantiate flow units...")
	  val reverse = new Reverse
	  val toLower = new ToLower
	  val toUpper = new ToUpper
	  val collector = new Collector(", ")
	  
	  // bind
	  println("bind them...")
	  reverse -> toLower.input
	  reverse.output -> toUpper.input
	  toLower -> collector.input1
	  toUpper -> collector.input2
	  collector -> [ msg | 
		  println("received '" + msg + "' from " + collector)
	  ]
	  
	  // error handling
      toUpper.integrationError -> 
      [ exception  |
        println("exception happened at " + toUpper + 
            ": " + exception.getMessage())
      ]
      toLower.integrationError -> 
      [ exception  |
        println("exception happened at " + toLower + 
            ": " + exception.getMessage())
      ]
      reverse.integrationError -> 
      [ exception  |
        println("exception happened at " + reverse + 
            ": " + exception.getMessage())
      ]
      collector.integrationError -> 
      [ exception  |
        println("exception happened at " + collector + 
            ": " + exception.getMessage())
      ]

	  // run
	  println("run them...")
	  val palindrom = "Trug Tim eine so helle Hose nie mit Gurt?"
	  println("send message: " + palindrom)
	  reverse.input(palindrom)

	  println("finished.")
	  
  }

}