package de.grammarcraft.xtend.annotatedflow

import static de.grammarcraft.xtend.flow.IntegrationErrorHandling.*

class RunFlow {
  def static void main(String[] args) {
      
	  // build
	  println("instantiate flow units...")
	  val reverse = new Reverse
	  val normalizer = new Normalize
	  val collector = new Collector(", ")
      val notConnectedFunctionUnit = new Reverse
	  
	  // bind
	  println("bind them...")
	  reverse -> normalizer
	  normalizer.lower -> collector.lower
	  normalizer.upper -> collector.upper
	  collector.output -> [ msg | 
		  println("received '" + msg + "' from " + collector)
	  ]
	  collector.error -> [ errMsg |
	      println('error received: ' + errMsg)
	  ]
	  
	  onIntegrationErrorAt(#[reverse, collector, notConnectedFunctionUnit]) [ 
	      exception | println("integration error happened: " + exception.message)
	  ]

	  // run
	  println("run them...")
	  val palindrom = "Trug Tim eine so helle Hose nie mit Gurt?"
	  println("send message: " + palindrom)
	  reverse <= palindrom
	  
      reverse <= palindrom // second call should raise an error message on the Collectors error port

      notConnectedFunctionUnit <= palindrom // should raise an integration error as function unit is not connected to any one

	  println("finished.")
	  
  }

}