class App
  module Views
    ##
    # Scoreboard layout
    class Scoreboard < Layout
      attr_reader :player_one, :full_rows, :partial_rows

      def initialize
        @full_rows, @hollow_rows = @preload.partition { |x| x[:score] }
      end

      def row_template
        ROW_TEMPLATE.gsub('"', '\"').delete("\n")
      end

      def max
        @preload.empty? ? 0 : @preload.map { |x| x.fetch(:score, 0) }.max
      end
    end
  end
end
