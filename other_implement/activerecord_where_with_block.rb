# frozen_string_literal: true

require "active_record"
require "rensei"
require_relative "where_with_block/version"

module Activerecord
  module WhereWithBlock
    class Parser < Struct.new(:klass, :context)
      using Module.new {
        refine Object do
          def eq(other);      other.eq(self);      end
          def not_eq(other);  other.not_eq(self);  end
          def matches(other); other.matches(self); end
          def gt(other);      other.lt(self);      end
          def gteq(other);    other.lteq(self);    end
          def lt(other);      other.gt(self);      end
          def lteq(other);    other.gteq(self);    end
        end
      }

      def eval_node(node)
        context.eval(Rensei.unparse(node))
      end

      def parse(node)
        case node.type
        when :SCOPE
          parse(node.children.last)
        when :OPCALL
          left, op, right = node.children.then { |left, op, right| [left, op, right.children.first] }
          case op
          when :==
            parse(left).eq parse(right)
          when :!=
            parse(left).not_eq parse(right)
          when :>
            parse(left).gt parse(right)
          when :>=
            parse(left).gteq parse(right)
          when :<
            parse(left).lt parse(right)
          when :<=
            parse(left).lteq parse(right)
          else
            eval_node(node)
          end
        when :CALL
          if node.children[1] == :=~
            parse(node.children[0]).matches parse(node.children[2].children.first)
          else
            eval_node(node)
          end
        when :AND
          left, right = node.children
          parse(left).and parse(right)
        when :OR
          left, right = node.children
          parse(left).or parse(right)
        when :LIT
          if Symbol === node.children.last
            column = node.children.last
            klass.arel_table[column]
          else
            node.children.last
          end
        else
          eval_node(node)
        end
      end
    end

    def where(*, &block)
      if block
        arel = Parser.new(klass, block.binding).parse(RubyVM::AbstractSyntaxTree.of(block))
        where(arel)
      else
        super
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Relation.prepend Activerecord::WhereWithBlock
end
