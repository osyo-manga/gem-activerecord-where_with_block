# frozen_string_literal: true

require "active_record"
require "rensei"
require "kenma"
require_relative "where_with_block/version"

module Activerecord
  module WhereWithBlock
    class Proxy < BasicObject
      using ::Module.new {
        refine ::Activerecord::WhereWithBlock::Proxy do
          include ::Kernel
          def itself
            klass.arel_table[column.to_s]
          end
        end
      }

      attr_reader :column, :klass, :arel

      def initialize(column, klass)
        @column = column
        @klass = klass
        @arel = klass.arel_table[column.to_s]
      end

      def method_missing(name, *args)
        reflections = klass._reflections
        if reflections.key?(column.to_s)
          self.class.new(name, reflections[column.to_s].klass)
        else
          column.__send__(name, *args)
        end
      end

      def ==(other);  arel.eq(other.itself) end
      def !=(other);  arel.not_eq(other.itself) end
      def >(other);   arel.gt(other.itself) end
      def >=(other);  arel.gteq(other.itself) end
      def <(other);   arel.lt(other.itself) end
      def <=(other);  arel.lteq(other.itself) end
      def =~(other);  arel.matches(other.itself) end
      def and(other); arel.and(other.itself) end
      def or(other);  arel.or(other.itself) end
    end

    module WhereMacro
      using Kenma::Macroable

      def and(node, left:, right:)
        ast { $left.and($right) }
      end
      macro_pattern pat { $left && $right }, :and

      def or(node, left:, right:)
        ast { $left.or($right) }
      end
      macro_pattern pat { $left || $right }, :or

      def lit(node, parent)
        klass = RubyVM::AbstractSyntaxTree.parse(bind.eval("klass.name"))
        if Symbol === node.children.first
          ast { ::Activerecord::WhereWithBlock::Proxy.new($node, $klass) }
        else
          ast { $node }
        end
      end
      macro_node :LIT, :lit
    end

    module ReverseOp
      using Kenma::Macroable

      def opcall(node, parent)
        if !(Symbol === node.children[0].children.first) \
        && Symbol === node.children[2].children&.first&.children&.first
          left = node.children[0]
          op = node.children[1]
          right = node.children[2].children.first
          case op
          when :==, :!=, :=~
            ast { $right.__send__(stringify!($op), $left) }
          when :>
            ast { $right < $left }
          when :>=
            ast { $right <= $left }
          when :<
            ast { $right > $left }
          when :<=
            ast { $right >= $left }
          else
            node
          end
        else
          node
        end
      end
      macro_node :OPCALL, :opcall
    end

    def where(*, &body)
      if body
        reversed = Kenma.compile_of(body, use_macros: [ReverseOp], bind: binding)
        ast = Kenma.compile(reversed, use_macros: [WhereMacro], bind: binding)
        arel = eval(Rensei.unparse(ast), body.binding)
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
