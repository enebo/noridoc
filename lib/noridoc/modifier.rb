require 'java'

module NoriDoc
  # Helper which provides predicates for each modifiers based on
  # including class providing an modifiers method return the Java
  # int value for all modifiers.
  module Modifier
    JModifier = java.lang.reflect.Modifier

    def abstract?; JModifier.abstract?(modifiers); end
    def final?; JModifier.final?(modifiers); end
    def interface?; JModifier.interface?(modifiers); end
    def native?; JModifier.native?(modifiers); end
    def private?; JModifier.private?(modifiers); end
    def protected?; JModifier.protected?(modifiers); end
    def public?; JModifier.public?(modifiers); end
    def static?; JModifier.static?(modifiers); end
    def strict?; JModifier.strict?(modifiers); end
    def synchronized?; JModifier.synchronized?(modifiers); end
    def transient?; JModifier.transient?(modifiers); end
    def volatile?; JModifier.final?(modifiers); end
  end
end
