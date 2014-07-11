require 'cooperator/version'
require 'cooperator/context'

module Cooperator
  module ClassMethods
    def perform(context = {})
      action = new context

      catch :_finish do
        action.perform
      end

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
    actions.each do |action|
      action.perform context

      break if context.failure?
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

  def failure!(messages = {})
    context.failure! messages
    throw :_finish
  end

  def method_missing(method, *args, &block)
    return context.send method, *args, &block if context.respond_to? method

    super
  end
end
