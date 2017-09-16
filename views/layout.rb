class App
  module Views
    ##
    # Stock layout
    class Layout < Mustache
      def title
        @title || 'GitHub Scoreboard'
      end
    end
  end
end
