# Represents a function argument.
# Can also be a list of arguments if :rest is specified in modifiers
# for variable argument functions.
class Arg
  attr_reader :name, :rest

  def initialize(name, *modifiers)
    @name = name
    # @rest indicates if we have
    # a variable amount of parameters
    @rest = modifiers.include?(:rest)
  end

  def rest?
    @rest
  end

  def type
    rest? ? :argaddr : :arg
  end
end

# Represents a function.
# Takes arguments and a body of code.
class Function
  attr_reader :args, :body, :scope

  # Constructor for functions.
  # Takes an argument list, a body of expressions as well as
  # the scope the function was defined in. For methods this is a
  # class scope.
  def initialize(args, body, scope)
    @body = body || []
    @rest = false
    args ||= []
    @args = args.collect do |a|
      arg = Arg.new(*[a].flatten)
      @rest = true if arg.rest?
      arg
    end

    @scope = scope
  end

  def rest?
    @rest
  end

  def get_arg(a)
    if a == :numargs
      # This is a bit of a hack, but it turns :numargs
      # into a constant for any non-variadic function
      return rest? ? [:lvar, -1] : [:int, args.size]
    end

    args.each_with_index do |arg,i|
      return [arg.type, i] if arg.name == a
    end

    return @scope.get_arg(a)
  end
end
