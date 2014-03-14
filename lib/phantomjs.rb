require "tempfile"
require "phantomjs/configuration"
require "phantomjs/version"
require "phantomjs/errors"

class Phantomjs

  attr_accessor :path, :args, :given_block
  def initialize(opts={}, *args)
    self.path = opts[:path] || script_path(opts[:script])
    self.args = args
    self.given_block = block_given? ? Proc.new : nil
    ensure_path
  end

  def self.run(path, *args, &block)
    Phantomjs.new({path: path}, *args, &block).execute
  end

  def self.inline(script, *args, &block)
    Phantomjs.new({script: script}, *args, &block).execute
  end

  def self.configure(&block)
    Configuration.configure(&block)
  end

  def execute
    begin
      given_block ? block_read : run_phantom.read
    rescue Errno::ENOENT
      raise CommandNotFoundError.new('Phantomjs is not installed')
    ensure
      @pfile.close if @pfile && !@pfile.closed?
      @tmpfile.unlink if @tmpfile
    end
  end

  private

  def block_read
    run_phantom.each_line { |line| given_block.call(line) }
  end

  def exec
    Phantomjs::Configuration.phantomjs_path
  end

  def env_path
    Phantomjs::Configuration.phantomjs_env_path
  end

  def phantomjs_tmpdir
    Phantomjs::Configuration.phantomjs_tmpdir
  end

  def run_phantom
    cmd = [ env_path, exec, path, args ].flatten
    ap cmd
    @pfile = IO.popen( cmd )
  end

  def ensure_path
    raise NoSuchPathError.new(File.expand_path(path)) unless File.exist?(path)
  end

  def script_path(script)
    begin
      @tmpfile = Tempfile.new('script.js', phantomjs_tmpdir || Dir.tmpdir )
      @tmpfile.write(script)
    ensure
      @tmpfile.close
    end
    @tmpfile.path
  end
end
