require 'cooperator/version'
require 'cooperator/context'

module Cooperator
  module ClassMethods
    def expected
      @_expected ||= []
    end

    def accepted
      @_accepted ||= []
    end

    def committed
      @_committed ||= []
    end

    def defaults
      @_defaults ||= {}
    end

    def expects(property)
      define_method property do
        context.send property
      end

      expected << property
    end

    def accepts(property, default: nil)
      define_method property do
        if context.include? property
          value = context.send property
          value.is_a?(Proc) ? value.call : value
        else
          nil
        end
      end

      accepted << property

      defaults[property] = default if default
    end

    def commits(property)
      committed << property
    end

    def perform(context = {})
      expected.each do |property|
        raise Exception, "missing expected property: #{expect}" unless context.include? expect
      end

      defaults.each do |property, value|
        context[property] = value
      end

      action = new context

      catch :_finish do
        action.perform
      end

      committed.each do |property|
        raise Exception, "missing committed property: #{expect}" unless context.include? expect
      end

      action.context
    end

    def rollback(context = {})
      action = new context

      action.rollback if action.respond_to? :rollback

      action.context
    end
  end

  def context
    @_context
  end

  def initialize(context = Context.new)
    @_context = if context.is_a? Context
                  context
                else
                  Context.new context
                end
  end

  def cooperate(*actions)
    done = []

    actions.each do |action|
      action.perform context

      break if context.failure?

      done << action
    end

    if context.failure?
      done.reverse.each do |action|
        action.rollback context
      end
    end
  end

  def self.prepended(base)
    base.extend ClassMethods
  end

  private

  def success!
    context.success!
    throw :_finish
  end

  def success?
    context.success?
  end

  def failure!(messages = {})
    context.failure! messages
    throw :_finish
  end

  def failure?
    context.failure?
  end

  def include?(property)
    context.include?(property)
  end
end
