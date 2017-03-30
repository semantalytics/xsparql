README XSPARQL


1) Prerequisites

You will need at least:

  * [Java JDK (at least Java 5)](http://java.sun.com/javase/downloads/)
  * [Apache Maven 2](http://maven.apache.org/)

The central Apache Maven repository contains almost all dependencies of XSPARQL. Because of licensing issues the following dependencies have to be downloaded manually and installed to your local maven repository:

  * The Saxon XSLT and XQuery Processor from Saxonica Limited, download from http://www.saxonica.com/
    if you have a license for Saxon EE you can use saxon9-ee.jar
    otherwise the home edition (HE) is enough (saxon9.jar)

    Install the jar file in your local maven repository:
    
    `mvn install:install-file -DgroupId=net.sf.saxon -DartifactId=saxon -Dversion=9.3 -Dpackaging=jar -Dfile=<path-to-jar-file>`


2) Building XSPARQL

In the main xsparql directory (where you probably found this README) run maven with the install goal:

   `mvn install`

When running the first time this will take some time since maven will download all the dependencies from the central repository.


3) OPTIONAL

If you want to use Graphviz to visualize a syntax tree download it from

   http://www.graphviz.org/

or from a repository if available for your platform.
Don't forget to set the path accordingly if not already done by the installation procedure.

You will also need a directory called ./tfd for the dot files and the generated files.


4) Running XSPARQL

You can run xsparql from the the created jar file:

   `java -jar lang/target/lang-0.2-jar-with-dependencies.jar query.xs`

To get an overview of the possible parameters of xsparql execute

   `java -jar lang/target/lang-0.2-jar-with-dependencies.jar -h`

You can also assign values to variables declared as external using an equals sign ($graph in this example):

   `java -jar lang/target/lang-0.2-jar-with-dependencies.jar query.xs graph="file:///home/user/graph.rdf"`

5) Further documentation

* [Wiki](../../wiki/Home)
* [Full grammar as html](doc/grammar.html)
* [Full grammar railroad diagrams](doc/grammar.xhtml)
* [Full grammar ebnf](doc/grammar.ebnf)
* [Non terminals grammar as html](doc/grammar-nonterminals.html)
* [Non terminals grammar railroad diagrams](doc/grammar-nonterminals.xhtml)
* [Non terminals grammar ebnf](doc/grammar-nonterminals.ebnf)
