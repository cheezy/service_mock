require 'spec_helper'

describe String do
  it 'should strip newline characters' do
    value = "foo\nbar"
    expect(value.remove_newlines).to eql 'foobar'
  end

  it 'should escape double quotes' do
    value = '"foobar"'
    expect(value.escape_double_quotes).to eql '\"foobar\"'
  end

  it 'should remove witespace' do
    value = "\t\r\n  foobar"
    expect(value.remove_whitespace).to eql "foobar"
  end
end
