Noridoc is a codename for a new potential feature of JRuby.  This project will introspect Javadocs and then also introspect your Ruby source to create a Ruby API document.  This document will show the Java APIs along side your Ruby ones indicating:

1. Which language the method is defined in providing additional typing info when it is a Java API
1. Ruby shortcut methods which get added by the JRuby runtime
1. Indications when a Ruby method overrides a Java method

