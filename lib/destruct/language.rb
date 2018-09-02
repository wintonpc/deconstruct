# frozen_string_literal: true

require 'destructure'
require 'active_support/core_ext/object/deep_dup'

class Destruct
  class Language
    LITERAL_TYPES = %i[int sym float str].freeze

    Rule = Struct.new(:pat, :translate)
    NIL = Object.new

    attr_reader :rules

    def initialize
      @rules = []
    end

    def translate(expr=nil, &pat_proc)
      expr ||= ExprCache.get(pat_proc)
      if !expr.is_a?(Parser::AST::Node)
        expr
      elsif LITERAL_TYPES.include?(expr.type)
        expr.children[0]
      elsif name = try_read_var(expr)
        Var.new(name)
      else
        NIL
      end
    end

    def add_rule(pat_proc, &translate)
      node = ExprCache.get(pat_proc)
      rules << Rule.new(node_to_pattern(node), translate)
    end

    private

    def node_to_pattern(node)
      if name = try_read_var(node)
        Var.new(name)
      else

      end
    end

    def try_read_var(node)
      e = DMatch.match(n(:send, nil, v(:name)), node)
      e[:name] if e
    end

    def n(type, *children)
      DMatch::Obj.of_type(Parser::AST::Node, {type: type, children: children})
    end

    def v(name)
      DMatch::Var.new(name)
    end
  end
end