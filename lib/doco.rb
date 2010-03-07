
require 'fileutils'
require 'yaml'
require 'mustache'
require 'RedCloth'

require 'digest'

module Doco
  class App
    attr_accessor :config
    
    def initialize(config)
      @config = config
      @notFoundPage = File.join(@config[:root], "public", "404.html")
    end
    
    def route(request)
      route = (request.path || '/').split('/').reject {|i| i.empty? }
      route << "index" if route.empty?
      
      respond 200, render(route)
      
    rescue Errno::ENOENT => e
      respond 404, if File.exists?(@notFoundPage)
        body = File.read(@notFoundPage)
      else
        "404 Not Found"
      end
    end
    
    private 
      def respond status, body, mime="text/html"
        headers = {
          "Content-Type" => mime,
          "Content-Length" => body.length.to_s,
          "Etag" => Digest::SHA1.hexdigest(body)
        }
      
        return [status, headers, body]
      end
      
      def render(route)
        content = File.read(File.join(@config[:root], "pages", route) + ".textile")
        data    = {"title" => "untitled", "layout" => "default"}
        
        if content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
          content = content[($1.size + $2.size)..-1]
          data = data.merge(YAML.load($1))
        end
        
        mustache(File.read(File.join(@config[:root], "layouts", data["layout"] + ".mustache")), data.merge({
          :body => textile(content),
          :base_url => @config[:base_url]
        }))
      end

      def textile(content)
        RedCloth.new(content).to_html
      end
      
      def mustache(template, data)
        Mustache.render(template, data)
      end      
  end
  
  class Server
    def initialize(config={})
      @config = {:base_url => ''}.merge(config)
      @app = Doco::App.new @config
    end
    
    def call(env)
      puts ENV.to_json
      
      @request = Rack::Request.new env
      @response = Rack::Response.new
      
      if @request.get?
        status, headers, body = @app.route(@request)
        @response.status = status
        @response.body = body
        
        headers.each {|key, value|
          @response[key] = value
        }
      else
        @response.status = 400
      end
      
      @response.finish
    end
  end
end