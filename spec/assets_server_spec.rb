require 'spec_helper'

describe AssetsServer do

  let(:options){ {} }
  subject(:app){ AssetsServer.new(options) }


  describe "#call" do
    it "should delegate to sprockets_environment" do
      env = double(:env)
      app.sprockets_environment.should_receive(:call).with(env)
      app.call(env)
    end
  end

  describe "#root" do
    context "when the root is given" do
      let(:options){ {root: '/tmp/foo'} }
      it "should return the given root" do
        app.root.should == '/tmp/foo'
      end
    end
    context "when the root is not given" do
      let(:options){ {} }
      it "should return Bundler.root" do
        app.root.should == Bundler.root
      end
    end
    context "when the root option is nil" do
      let(:options){ {root: nil} }
      it "should return Bundler.root" do
        expect{ app.root }.to raise_error AssetsServer::OptionError, "root option not set for AssetsServer"
      end
    end
  end

  describe "#paths" do
    context "when the paths is given" do
      let(:options){ {paths: ['/a/b', '/c/d']} }
      it "should return the given paths" do
        app.paths.should == ['/a/b', '/c/d']
      end
    end
    context "when the paths is not given" do
      let(:options){ {} }
      it "should return the directories + vendor" do
        app.paths.should == %w{
          javascripts
          stylesheets
          images
          vendor/javascripts
          vendor/stylesheets
          vendor/images
        }
      end
      context "when directories is given" do
        let(:options){ {directories: %w{shoes socks}} }
        it "should return the directories + vendor" do
          app.paths.should == %w{
            shoes
            socks
            vendor/shoes
            vendor/socks
          }
        end
      end
    end
    context "when the paths option is nil" do
      let(:options){ {paths: nil} }
      it "should return Bundler.paths" do
        expect{ app.paths }.to raise_error AssetsServer::OptionError, "paths option not set for AssetsServer"
      end
    end
  end

  describe "#compass?" do
    context "when the option `compass: true' is given" do
      let(:options){ {compass: true} }
      it "should return true" do
        app.should be_compass
      end
    end
    context "when the option `compass: false' is given" do
      let(:options){ {compass: false} }
      it "should return false" do
        app.should_not be_compass
      end
    end
    context "when the option compass is not given" do
      let(:options){ {} }
      it "should return false" do
        app.should_not be_compass
      end
    end
  end

  describe "#sprockets_environment" do
    let(:options){ {root: '/foo/bar'} }
    it "should return a Sprockets::Environment" do
      app.sprockets_environment.should be_a Sprockets::Environment
      app.sprockets_environment.root.should == '/foo/bar'
    end
    it "should append each append each path" do
      app.sprockets_environment.paths.should == %w(
        /foo/bar/javascripts
        /foo/bar/stylesheets
        /foo/bar/images
        /foo/bar/vendor/javascripts
        /foo/bar/vendor/stylesheets
        /foo/bar/vendor/images
      )
    end
    context "when compass is enabled" do
      let(:options){ {compass: true} }
      it "should append the compass framework stylesheets path" do
        app.sprockets_environment.paths.should include Compass::Frameworks['compass'].path+'/stylesheets'
      end
    end
  end

end
