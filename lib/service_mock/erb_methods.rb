require 'erb'

module ServiceMock
  module ErbMethods

    def render(path)
      content = File.read(File.expand_path(path))
      template = ERB.new(content)
      template.result(binding)
    end

    def value_with_default(value, default)
      return value if value
      default
    end

  end
end