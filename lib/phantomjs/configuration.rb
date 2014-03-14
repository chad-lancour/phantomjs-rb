class Phantomjs
  module Configuration
    extend self

    attr_accessor :phantomjs_path
    attr_accessor :phantomjs_env_path
    attr_accessor :phantomjs_tmpdir

    Phantomjs::Configuration.phantomjs_path ||= 'phantomjs'
    Phantomjs::Configuration.phantomjs_env_path ||= {}
    Phantomjs::Configuration.phantomjs_tmpdir ||= nil

    def configure
      yield self
    end

  end
end
