module Regexp::Expression

  class CharacterSet < Regexp::Expression::Base
    attr_accessor :members

    def initialize(token)
      @members  = []
      @negative = false
      @closed   = false
      super
    end

    # Override base method to clone set members as well.
    def clone
      copy = super
      copy.members = @members.map {|m| m.clone }
      copy
    end

    def <<(member)
      if @members.last.is_a?(CharacterSubSet) and not @members.last.closed?
        @members.last << member
      else
        @members << member
      end
    end

    def include?(member, directly = false)
      @members.each do |m|
        if m.is_a?(CharacterSubSet) and not directly
          return true if m.include?(member)
        else
          return true if member == m.to_s
        end
      end; false
    end

    def each(&block)
      @members.each {|m| yield m}
    end

    def each_with_index(&block)
      @members.each_with_index {|m, i| yield m, i}
    end

    def length
      @members.length
    end

    def negate
      if @members.last.is_a?(CharacterSubSet)
        @members.last.negate
      else
        @negative = true
      end
    end

    def negative?
      @negative
    end
    alias :negated? :negative?

    def close
      if @members.last.is_a?(CharacterSubSet) and not @members.last.closed?
        @members.last.close
      else
        @closed = true
      end
    end

    def closed?
      @closed
    end

    def to_s(format = :full)
      s = ''

      s << @text.dup
      s << '^' if negative?
      s << @members.join
      s << ']'

      case format
      when :base
      else
        s << @quantifier.to_s if quantified?
      end

      s
    end

    def matches?(input)
      input =~ /#{to_s}/ ? true : false
    end
  end

  class CharacterSubSet < CharacterSet
  end

end # module Regexp::Expression