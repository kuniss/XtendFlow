package de.grammarcraft.xtend.firstflow

import static de.grammarcraft.xtend.firstflow.IntegrationErrorHandling.*

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
	  
	  onIntegrationErrorAt(#[toUpper, toLower, reverse, collector], 
	      [ exception | println("integration error happened: " + exception.message)]
	  )

	  // run
	  println("run them...")
	  val palindrom = "Trug Tim eine so helle Hose nie mit Gurt?"
	  println("send message: " + palindrom)
	  reverse.input(palindrom)

	  println("finished.")
	  
  }

}