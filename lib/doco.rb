
require 'rack/utils'
require 'yaml'
require 'mustache'
require 'RedCloth'

require 'digest'

module Rack
  class Doco
    def initialize(app, options={})
      @app = app
      @url = (options[:url] || "/").chomp("/")
      @root = options[:root] || Dir.pwd
    end
    
    def call(env)
      dup._call(env)
    end
    
    F = ::File
    
    def _call(env)
      path = Utils.unescape(F.expand_path(env['PATH_INFO']))
    
      result = if path.index(@url) == 0 && env["REQUEST_METHOD"] == "GET"
        route = path[@url.length..-1].split('/').reject {|i| i.empty? }
        route << "index" if route.empty?

        handle(route)
      end
      
      result.first == 404 ? @app.call(env) : result
    end
      
    private 
      def respond status, body
        headers = {
          "Content-Type" => "text/html",
          "Content-Length" => Utils.bytesize(body).to_s,
          "Etag" => Digest::SHA1.hexdigest(body)
        }
    
        return [status, headers, body]
      end
    
      def handle(route)
        page = F.join(@root, "pages", route) + ".textile"
        
        if F.exists?(page)
          content = F.read(page)
          data    = {"title" => "untitled", "layout" => "default"}
      
          if content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
            content = content[($1.size + $2.size)..-1]
            data = data.merge(YAML.load($1))
          end
      
          respond 200, mustache(load_layout(data["layout"]), data.merge({
            :body => textile(content),
            :base_url => @url
          }))
        else
          [404, {}, ""]
        end
      rescue Errno::ENOENT => e
        [404, {}, ""]
      end
      
      def load_layout(layout)
        F.read(F.join(@root, "layouts", layout + ".mustache"))
      end

      def textile(content)
        RedCloth.new(content).to_html
      end
    
      def mustache(template, data)
        Mustache.render(template, data)
      end      
  end
end