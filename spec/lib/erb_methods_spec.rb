require 'spec_helper'
require 'service_mock/erb_methods'

describe ::ServiceMock::ErbMethods do
  it 'reads a file and provides the contents to erb' do
    expect(File).to receive(:read).and_return "<%= foo %>"
    object = OpenStruct.new('foo' => 'bar')
    object.extend ::ServiceMock::ErbMethods
    output = object.render('/foo/bar')
    expect(output).to eql 'bar'
  end

  it 'allows one to provide a default value' do
    expect(File).to receive(:read).and_return "<%= value_with_default(foo, 'default') %>"
    object = OpenStruct.new
    object.extend ::ServiceMock::ErbMethods
    output = object.render('/foo/bar')
    expect(output).to eql 'default'
  end

  it "overrides the default when a value is provided" do
    expect(File).to receive(:read).and_return "<%= value_with_default(foo, 'default') %>"
    object = OpenStruct.new
    object.extend ::ServiceMock::ErbMethods
    expect(object).to receive(:foo).and_return 'foo'
    output = object.render('/foo/bar')
    expect(output).to eql 'foo'
  end
end