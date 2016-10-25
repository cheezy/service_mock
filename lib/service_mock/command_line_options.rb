module ServiceMock
  module CommandLineOptions

    OPTIONS = [:port, :https_port, :verbose, :root_dir, :record_mappings, :proxy_all,
               :match_headers, :proxy_via, :https_keystore, :keystore_password,
               :enable_browser_proxying, :preserve_host_header, :https_truststore,
               :truststore_password, :https_require_client_cert, :no_request_journal,
               :max_request_journal_entries, :extensions]
    NOT_IMPLEMENTED = [:container_threads, :jetty_acceptor_threads, :jetty_accept_queue_size,
                       :jetty_header_buffer_size, :help]

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

    def match_headers_command
      ["--match-headers=\"#{match_headers}\""]
    end

    def proxy_via_command
      ["--proxy-via #{proxy_via}"]
    end

    def https_keystore_command
      ["--https-keystore #{https_keystore}"]
    end

    def keystore_password_command
      ["--keystore-password #{keystore_password}"]
    end

    def enable_browser_proxying_command
      ['--enable-browser-proxying']
    end

    def preserve_host_header_command
      ['--preserve-host-header']
    end

    def https_truststore_command
      ["--https-truststore #{https_truststore}"]
    end

    def truststore_password_command
      ["--truststore-password #{truststore_password}"]
    end

    def https_require_client_cert_command
      ['--https-require-client-cert']
    end

    def no_request_journal_command
      ['--no-request-journal']
    end

    def max_request_journal_entries_command
      ["--max-request-journal-entries #{max_request_journal_entries}"]
    end

    def extensions_command
      ['--extensions', extensions]
    end
  end
end
