class App
  module Views
    class Layout < Mustache
      def title 
        @title || 'GitHub Scoreboard'
      end
    end
  end
end
