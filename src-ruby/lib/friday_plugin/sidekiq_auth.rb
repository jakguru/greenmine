module FridayPlugin
  class SidekiqAuth
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      session = request.session

      # Use a mutex to protect User.current
      mutex = Mutex.new

      # Set User.current in a thread-safe manner
      mutex.synchronize do
        User.current = if session["user_id"]
          User.find(session["user_id"])
        else
          User.anonymous
        end
      end

      if User.current.logged? && User.current.admin?
        # Proceed to Sidekiq web UI
        status, headers, response = @app.call(env)
      else
        # Redirect to Redmine's login page
        status, headers, response = [302, {"Location" => "/login?back_url=" + Rack::Utils.escape(request.fullpath), "Content-Type" => "text/html"}, []]
      end

      # Ensure User.current is reset after the request
      mutex.synchronize do
        User.current = nil
      end

      [status, headers, response]
    end
  end
end
