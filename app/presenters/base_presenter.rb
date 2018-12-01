class BasePresenter
  def initialize(object)
    @object = object
  end

  def self.present(name)
    define_method(name) do
      @object
    end
  end
end
