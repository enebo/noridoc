package org.jruby.ext.noridoc;

import com.sun.javadoc.Doclet;
import com.sun.javadoc.RootDoc;
import org.jruby.embed.ScriptingContainer;

/**
 * The smallest possible shim in Java to work around inflexible interface to Javadoc.
 */
public class NoriDoclet extends Doclet {
    private static ScriptingContainer container = new ScriptingContainer();
    
    public static boolean start(RootDoc root) {
        // FIXME: To be replaced by a resource loading mechanism once developed a little more
        Object noridocClass = container.runScriptlet("$LOAD_PATH << 'lib'; require 'noridoc'; NoriDoc::Doclet");
        Boolean result = (Boolean) container.callMethod(noridocClass, "start", root);
        return result.booleanValue();
    }
}
