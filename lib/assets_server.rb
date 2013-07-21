require "assets_server/version"
require "sprockets"

# AssetsServer
#
# Usage
#
# AssetsServer.new(
#   root: './assets',
#   directories: %w{javascripts stylesheets images templates fonts}
#   paths: ['javascripts','stylesheets','vendor/javascripts','vendor/stylesheets'],
#   compass: true,
# )
#
class AssetsServer

  OptionError = Class.new(ArgumentError)

  def initialize(options={})
    @root = options.fetch(:root){ Bundler.root if defined? Bundler }
    @directories = options.fetch(:directories){ %w{javascripts stylesheets images} }
    @paths = options.fetch(:paths){
      @directories + @directories.map{|d| "vendor/#{d}" }
    }
    @compass = options.fetch(:compass){ false }
    use_compass! if compass?
  end

  def call(env)
    sprockets_environment.call(env)
  end

  def root
    @root or raise OptionError, "root option not set for #{self.class}"
  end

  def paths
    @paths or raise OptionError, "paths option not set for #{self.class}"
  end

  def compass?
    !!@compass
  end

  def sprockets_environment
    return @sprockets_environment if defined? @sprockets_environment
    @sprockets_environment = Sprockets::Environment.new(root)
    paths.each do |path|
      @sprockets_environment.append_path path
    end
    @sprockets_environment
  end

  def use_compass!
    require "compass"
    sprockets_environment.append_path Compass::Frameworks['compass'].path+'/stylesheets'
  end

end
