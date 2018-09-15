# frozen_string_literal: true

class Destruct
  module RuleSets
    class Destruct
      include RuleSet
      include Helpers

      def initialize
        add_rule(n(:case, [v(:value), s(:clauses)])) do |value:, clauses:|
          *whens, last = clauses
          if last.is_a?(CaseClause)
            Case.new(value, clauses)
          else
            Case.new(value, whens, last)
          end
        end
        add_rule(n(:when, [v(:pred), v(:body)])) { |pred:, body:| CaseClause.new(pred, body) }
        add_rule_set(UnpackEnumerables)
      end

      class Case
        attr_reader :value, :whens, :else_body

        def initialize(value, whens, else_body=nil)
          @value = value
          @whens = whens
          @else_body = else_body
        end

        def to_s
          "#<Case: #{value.inspect} #{whens.inspect} #{else_body.inspect}}"
        end
        alias_method :inspect, :to_s
      end

      class CaseClause
        attr_reader :pred, :body

        def initialize(pred, body)
          @pred = pred
          @body = body
        end

        def to_s
          "#<CaseClause: #{pred.inspect.gsub(/\s+/, " ")} #{body.inspect.gsub(/\s+/, " ")}"
        end
        alias_method :inspect, :to_s
      end
    end
  end
end
