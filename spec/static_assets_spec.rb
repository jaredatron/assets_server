require 'spec_helper'

describe "static assets" do

  def root
    @root ||= Bundler.root.join('spec/test_app')
  end

  def options
    @options ||= {root: root, compass: true}
  end

  def app
    @app ||= AssetsServer.new(options)
  end

  context "GET /application.js" do
    before{ get '/application.js' }
    it "should return the rendered asset" do
      last_response.should be_ok
      last_response.body.should == \
        "function jQuery(){}\n;\nModal = {};\n\n\n\nApplication = {};\n"
    end
  end

  context "GET /modal.js" do
    before{ get '/modal.js' }
    it "should return the rendered asset" do
      last_response.should be_ok
      last_response.body.should == "Modal = {};\n"
    end
  end

  context "GET /application.css" do
    before{ get '/application.css' }
    it "should return the rendered asset" do
      last_response.should be_ok
      last_response.body.should == \
        ".bootstrap {\n  content: \"awesome\"; }\n\nhtml, body {\n  padding: 0; }\n\n.page {\n  width: 960px; }\n"
    end
  end

  context "GET /laout.css" do
    before{ get '/layout.css' }
    it "should return the rendered asset" do
      last_response.should_not be_ok
    end
  end

  context "GET /bootstrap.css" do
    before{ get '/bootstrap.css' }
    it "should return the rendered asset" do
      last_response.should_not be_ok
    end
  end

  context "GET /1x1.png" do
    before{ get '/1x1.png' }
    it "should return the rendered asset" do
      last_response.should be_ok
      last_response.body.should == \
        root.join('images/1x1.png').binread
    end
  end

  context "GET /1x1-red.png" do
    before{ get '/1x1-red.png' }
    it "should return the rendered asset" do
      last_response.should be_ok
      last_response.body.should == \
        root.join('vendor/images/1x1-red.png').binread
    end
  end

end
