BASIC_INS   = {'mov' => '', 'add' => '+', 'sub' => ?-, 'mul' => ?*, 'div' => ?/}
CONTROL_INS = {'jne' => '!=', 'je' => '==', 'jge' => '>=', 'jg' => '>', 'jle' => '<=', 'jl' => '<'}

def cast e
  e =~ /\d+/ ? e : "$___#{e}"
end

def taste(r = nil)
  return r.nil? ? "NOTHING" : @tokens[0] if @tokens.empty?
  r.nil? ? false : @tokens[0].match(r)
end

def eat(r = nil)
  raise StandardError if !r.nil? && !taste(r)
  @tokens.shift
end

def to_rb(line, is_main = false)
  @tokens = line.scan(/\w+|,|:|'[^']+'|;.+/).map { |e| e =~ /^;/ ? e.sub(';', '#') : e }
  ins = eat
  return "def #{ins[/\w+/].to_s}" if taste /^\:/
  case ins
  when Regexp.union(BASIC_INS.keys)   then @tokens.values_at(0,2).map(&method(:cast)).join(" #{BASIC_INS[ins]}= ")
  when Regexp.union(CONTROL_INS.keys) then"return #{eat} if #{$last_cmp.join(" #{CONTROL_INS[ins]} ")} "
  when /dec|inc/                      then "$___#{eat} #{ins == 'inc' ? ?+ : ?-}= 1"
  when /ret/                          then 'return'
  when /cmp/                          then $last_cmp = @tokens.values_at(0,2).map(&method(:cast)); ''
  when /call/                         then is_main ? "#{eat}" : "return #{eat}"
  when /jmp/                          then "return #{eat}"
  when /msg/                          then "$out = " +  @tokens.map { |t| t =~ /^\#.*/ ? t : t == ?, ? ?+ : t =~ /^'.*'$/ ? t : "$___#{t}.to_s"}.join(' ')
  end
end

def assembler_interpreter(program)
  $var, $err, $out = {}, false, ''
  main, *blocks = program.split("\n").reject{|t| t =~ /^;.*/}.slice_before{|t| (t =~ /\w+\:/) && !(t =~ / +msg/)}.to_a

  eval blocks.map { |block|
    block.map {|line| to_rb line }.join("\n") + "\n$err = true \nend\n"
  }.join("\n") + main.reject{|x| x.strip == 'end'}.map {|line| to_rb line, true }.join("\n")
  $err ? -1 : $out
end
