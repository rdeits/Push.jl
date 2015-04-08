# Top level of the Push interpreter.
run(p::String, cfg::String) = run(p, load_configuration(cfg))
run(p::ASCIIString, cfg::Configuration) = run(Parser.to_push(p), configure(cfg))
function run(p::Any, s::State)
  if s.parameters.top_level_push_code
    push!(s.code, p)
  end
  push!(s.exec, p)
  execute(s)
  if s.parameters.top_level_pop_code
    pop!(s.code)
  end
  return s
end

# No termination limit for now.
execute(s::State) = while !isempty(s.exec)

  # QUOTE MODE.
  execute(s, pop!(s.exec))
end

# Not too happy about this...
execute(s::State, v::Vector{Any}) = while !isempty(v)
  push!(s.exec, pop!(v))
end

execute(s::State, v::Bool) =
  push!(s.boolean, v)

execute(s::State, v::Int32) =
  push!(s.integer, v)

execute(s::State, f::Float32) = 
  push!(s.float, f)

function execute(s::State, v::Symbol)
  # Check if this name refers to a "built-in" instruction.
  if haskey(s.instructions, v)
    s.instructions[v](s)

  # Check if the name refers to a stored macro.
  #c.macros
  #elseif haskey(s.macros, v)
  #  s.macros[v](s)

  # If neither of the above, treat the symbol as a literal name
  # and add it to the NAME stack.
  else
    push!(s.name, v)
  end
end