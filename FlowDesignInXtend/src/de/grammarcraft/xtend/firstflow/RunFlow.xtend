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
	  reverse -> toUpper.input
	  toLower -> collector.input1
//	  toUpper.output -> collector.input2
	  collector -> [ msg | 
		  println("received '" + msg + "' from " + collector)
	  ]
	  
	  // error handling
      toUpper.integrationError -> 
      [ exception  |
        println("exception happended at " + toUpper + 
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