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

  def initialize(options={})
    @root = options.fetch(:root){ Bundler.root if defined? Bundler } or \
      raise ArgumentError, "expected root to be present. got #{@root.inspect}"
    @directories = options.fetch(:directories){ %w{javascripts stylesheets images} }
    @paths = options.fetch(:paths){
      @directories + @directories.map{|d| "vendor/#{d}" }
    }
    @paths or raise ArgumentError, "expected paths to be present. got #{@paths.inspect}"
    @compass = options.fetch(:compass){ false }
    use_compass! if compass?
  end

  def call(env)
    binding.pry
    sprockets_environment.call(env)
  end

  def root
    sprockets_environment.root
  end

  def paths
    sprockets_environment.paths
  end

  def compass?
    !!@compass
  end

  def files
    files = []
    sprockets_environment.each_file do |path|
      next if path.to_s.split('/').last =~ /^_/
      relative_paths = sprockets_environment.paths.map{|p| path.relative_path_from(Pathname(p)) }
      file = relative_paths.find{|p| !p.to_s.include? '../' }.to_s
      files << file
    end
    files
  end

  def sprockets_environment
    return @sprockets_environment if defined? @sprockets_environment
    @sprockets_environment = Sprockets::Environment.new(@root)
    @paths.each do |path|
      @sprockets_environment.append_path path
    end
    @sprockets_environment
  end

  def use_compass!
    require "compass"
    sprockets_environment.append_path Compass::Frameworks['compass'].path+'/stylesheets'
  end

end
