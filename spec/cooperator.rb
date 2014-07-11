require 'cooperator'

class Interactor
  prepend Cooperator
end

subject Cooperator

spec '#success? delegates to context.success?' do
  interactor = Interactor.new

  interactor.context.success!

  assert interactor, :success?

  interactor.context.failure!

  refute interactor, :success?
end

spec '#failure? delegates to context.failure?' do
  interactor = Interactor.new

  interactor.context.failure!

  assert interactor, :failure?

  interactor.context.success!

  refute interactor, :failure?
end

spec '#include? delegates to context.include?' do
  interactor = Interactor.new

  refute interactor, :include?, :name

  interactor.context.name = 'Apple'

  assert interactor, :include?, :name
end

spec 'delegate to the current context' do
  interactor = Interactor.new name: 'Apple'

  assert interactor.name, :==, 'Apple'
end

spec '#failure! accepts an error key and message' do
  context = Cooperator::Context.new
  interactor = Interactor.new context

  interactor.failure! action: 'Failure!'

  assert context.errors, :==, action: ['Failure!']
end
