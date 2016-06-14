module ServiceMock
  module CommandLineOptions

    OPTIONS = [:port, :https_port, :verbose, :root_dir, :record_mappings, :proxy_all]
    NOT_IMPLEMENTED = [:https_keystore, :keystore_password, :truststore_password,
                       :https_require_client_cert, :preserve_host_header, :proxy_via,
                       :enable_browser_proxying, :no_request_journal, :container_threads,
                       :match_headers, :max_request_journal_entries, :jetty_acceptor_threads,
                       :jetty_accept_queue_size,:jetty_header_buffer_size, :extensions, :help]

    attr_accessor *OPTIONS

    def command_line_options
      OPTIONS.inject([]) do |value, option|
        value += self.send("#{option}_command") if self.send(option).to_s.size > 0
        value
      end
    end

    def port_command
      ['--port', port.to_s]
    end

    def https_port_command
      ['--https-port', https_port.to_s]
    end

    def verbose_command
      ['--verbose']
    end

    def root_dir_command
      ['--root-dir', root_dir]
    end

    def record_mappings_command
      ['--record-mappings']
    end

    def proxy_all_command
      ["--proxy-all=#{proxy_all.to_s}"]
    end
  end
end