Noridoc is a codename for a new potential feature of JRuby.  This project will introspect Javadocs and then also introspect your Ruby source to create a Ruby API document.  This document will show the Java APIs along side your Ruby ones indicating:

1. Which language the method is defined in providing additional typing info when it is a Java API
1. Ruby shortcut methods which get added by the JRuby runtime
1. Indications when a Ruby method overrides a Java method


For those playing at home the bootstrapping is really, really ugly at the moment.  You need to point your JRUBY_HOME at a valid JRuby distro and you also need to run from the root of the noridoc project.  I plan on fixing the bootstrapping later since I know I can do jar resource loading towards the end and I am more interested in the meat of noridoc should do:

JRUBY_HOME=/Users/enebo/work/jruby CLASSPATH=dist/noridoc.jar javadoc -doclet org.jruby.ext.noridoc.NoriDoclet -sourcepath src org.jruby.ext.noridoc


Notes:

1. This class.forName style of framework loading really sucks.
1. I can save Java docs in neutral ad-hoc format, grab rdoc in same way and then make translator to doc format.  The main issue right now is that rdoc has no type info for representing Java and we clearly don't want to see types in Javadoc.
1. I am inclined to get rdocs and save in-memory and then resolve those against Java methods (and resulting shortcuts) as I encounter them...Then dump straight out to destined format.
1. Need to determine proper intermediate representation so that we can dump HTML, PDF, and possibly other formats.
