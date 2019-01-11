require 'spec_helper'

describe ServiceMock::CommandLineOptions do

  let(:clo) {ServiceMock::Server.new('123')}

  it 'provides a port option' do
    clo.port = 123
    expect(clo.port_command).to eql ['--port', '123']
  end

  it 'provides a https port option' do
    clo.https_port = 123
    expect(clo.https_port_command).to eql ['--https-port', '123']
  end

  it 'provides a verbose option' do
    clo.verbose = true
    expect(clo.verbose_command).to eql ['--verbose']
  end

  it 'provides a root_dir option' do
    clo.root_dir = 'foo/bar'
    expect(clo.root_dir_command).to eql ['--root-dir', 'foo/bar']
  end

  it 'provides a record_mappings option' do
    clo.record_mappings = true
    expect(clo.record_mappings_command).to eql ['--record-mappings']
  end

  it 'provides a proxy_all option' do
    clo.proxy_all = 'http://proxy.ca'
    expect(clo.proxy_all_command).to eql ['--proxy-all=http://proxy.ca']
  end

  it 'provides a match_headers option' do
    clo.match_headers =  'Accept,Content-Type'
    expect(clo.match_headers_command).to eql ['--match-headers="Accept,Content-Type"']
  end

  it 'provides a proxy_via option' do
    clo.proxy_via = 'http://blah.com'
    expect(clo.proxy_via_command).to eql ['--proxy-via http://blah.com']
  end

  it 'provides a https_keystore option' do
    clo.https_keystore = '/path/to/keystore'
    expect(clo.https_keystore_command).to eql ['--https-keystore', '/path/to/keystore']
  end

  it 'provides a keystore_password option' do
    clo.keystore_password = 'passWord'
    expect(clo.keystore_password_command).to eql ['--keystore-password', 'passWord']
  end

  it 'provides a enable_borwser_proxying option' do
    clo.enable_browser_proxying = true
    expect(clo.enable_browser_proxying_command).to eql ['--enable-browser-proxying']
  end

  it 'provides a preserve_host_header option' do
    clo.preserve_host_header = true
    expect(clo.preserve_host_header_command).to eql ['--preserve-host-header']
  end

  it 'provides a https_truststore option' do
    clo.https_truststore = '/path/to/truststore'
    expect(clo.https_truststore_command).to eql ['--https-truststore /path/to/truststore']
  end

  it 'provides a truststore_password option' do
    clo.truststore_password = 'secret'
    expect(clo.truststore_password_command).to eql ['--truststore-password secret']
  end

  it 'provides a https_require_client_cert option' do
    clo.https_require_client_cert = true
    expect(clo.https_require_client_cert_command).to eql ['--https-require-client-cert']
  end

  it 'provides a no_request_journal option' do
    clo.no_request_journal = true
    expect(clo.no_request_journal_command).to eql ['--no-request-journal']
  end

  it 'provides a max_request_journal_entries option' do
    clo.max_request_journal_entries = 40
    expect(clo.max_request_journal_entries_command).to eql ['--max-request-journal-entries 40']
  end

  it 'provides an extensions option' do
    clo.extensions = 'com.foo.FooExt,com.bar.BarExt'
    expect(clo.extensions_command).to eql ['--extensions', 'com.foo.FooExt,com.bar.BarExt']
  end
end
