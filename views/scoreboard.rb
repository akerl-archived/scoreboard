class App
  module Views
    class Scoreboard < Layout
      attr_reader :player_one, :full_rows, :partial_rows

      def row_template
        ROW_TEMPLATE.gsub('"', '\"').gsub("\n",'')
      end

      def max
        @preload.empty? ? 0 : @preload.map { |x| x.fetch(:score, 0) }.max
      end
    end
  end
end
