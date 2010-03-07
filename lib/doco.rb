
require 'rack/utils'
require 'fileutils'
require 'yaml'
require 'mustache'
require 'RedCloth'

require 'digest'

module Doco
  class App
    def initialize(app, options={})
      @app = app
      @url = options[:url] || "/"
      @root = options[:root] || Dir.pwd
    
      @notFoundPage = File.join(@root, "public", "404.html")
    end
  
    def call(env)
      path = Rack::Utils.unescape(File.expand_path(env['PATH_INFO']))
      can_serve = path.index(@url) == 0 && env["REQUEST_METHOD"] == "GET"
    
      if can_serve
        route = path.split('/').reject {|i| i.empty? }
        route << "index" if route.empty?

        respond 200, render(route)
      else
        @app.call(env)
      end
    rescue Errno::ENOENT => e
      @app.call(env)
    end
      
    private 
      def respond status, body
        headers = {
          "Content-Type" => "text/html",
          "Content-Length" => Rack::Utils.bytesize(body).to_s,
          "Etag" => Digest::SHA1.hexdigest(body)
        }
    
        return [status, headers, body]
      end
    
      def render(route)
        content = File.read(File.join(@root, "pages", route) + ".textile")
        data    = {"title" => "untitled", "layout" => "default"}
      
        if content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
          content = content[($1.size + $2.size)..-1]
          data = data.merge(YAML.load($1))
        end
      
        mustache(File.read(File.join(@root, "layouts", data["layout"] + ".mustache")), data.merge({
          :body => textile(content),
          :base_url => @url
        }))
      end

      def textile(content)
        RedCloth.new(content).to_html
      end
    
      def mustache(template, data)
        Mustache.render(template, data)
      end      
  end
end