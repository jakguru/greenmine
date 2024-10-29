module FridayPlugin
  class AdminConstraint
    def matches?(request)
      Rails.logger.info JSON.pretty_generate(request)
      true
    end
  end
end
