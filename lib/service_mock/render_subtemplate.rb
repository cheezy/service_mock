require 'erb'

module ServiceMock
  module RenderSubTemplate

    def render(path)
      content = File.read(File.expand_path(path))
      template = ERB.new(content)
      template.result(binding)
    end

  end
end