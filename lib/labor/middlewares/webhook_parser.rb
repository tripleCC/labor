module Labor
  class WebhookParser
    def initialize(app)
      @app = app
    end

    def call(env)
      p env
      @app.call(env)
    end
  end
end
