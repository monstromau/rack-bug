require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Rack::Bug do
  it "inserts the Rack::Bug toolbar" do
    response = get "/"
    response.should contain("Rack::Bug")
  end
  
  it "updates the Content-Length" do
    response = get "/"
    response["Content-Length"].should == response.body.join.size.to_s
  end
  
  it "serves the Rack::Bug assets under /__rack_bug__/" do
    response = get "/__rack_bug__/bug.css"
    response.should be_ok
  end
  
  it "does not modify XMLHttpRequest responses" do
    response = get "/", {}, { :xhr => true }
    response.should_not contain("Rack::Bug")
  end
  
  it "modifies XHTML responses" do
    response = get "/", :content_type => "application/xhtml+xml"
    response.should contain("Rack::Bug")
  end
  
  it "does not modify non-HTML responses" do
    response = get "/", :content_type => "text/csv"
    response.should_not contain("Rack::Bug")
  end

  it "does not modify redirects" do
    response = get "/redirect"
    response.body.should == []
  end
  
  it "does not modify server errors" do
    response = get "/error"
    response.should_not contain("Rack::Bug")
  end
  
  context "configured with an IP address restriction" do
    def app
      Rack::Builder.new do
        use Rack::Bug::Middleware, :ip_mask => "127.0.0.1/255.255.255.0"
        run SampleApp.new
      end
    end
    
    it "inserts the Rack::Bug toolbar when the IP matches" do
      response = get "/", {}, "REMOTE_ADDR" => "127.0.0.2"
      response.should contain("Rack::Bug")
    end
    
    it "is disabled when the IP doesn't match" do
      response = get "/", {}, "REMOTE_ADDR" => "128.0.0.1"
      response.should_not contain("Rack::Bug")
    end
  end
  
  context "configured with a password" do
    def app
      Rack::Builder.new do
        use Rack::Bug::Middleware, :password => "secret"
        run SampleApp.new
      end
    end
    
    it "inserts the Rack::Bug toolbar when the password matches" do
      sha = "545049d1c5e2a6e0dfefd37f9a9e0beb95241935"
      response = get "/", {}, :cookie => "rack_bug_password=#{sha}"
      response.should contain("Rack::Bug")
    end
    
    it "is disabled when the password doesn't match" do
      response = get "/"
      response.should_not contain("Rack::Bug")
    end
  end
end