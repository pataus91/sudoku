require 'set'

module ArrayExtensions
  refine Array do
    def valid?
      Set[*self].size == 9
    end

    def fill
      new_digit = (1..9).each do |digit|
        break digit unless Set[*self].include? digit
      end
      self << new_digit
    end
  end
end

class Sudoku
  using ArrayExtensions

  def self.done_or_not(grid)
    grid = Sudoku.new(grid)
    if grid.rows.all?(&:valid?) && grid.columns.all?(&:valid?) &&
        grid.regions.all?(&:valid?)
      'Finished!'
    else
      'Try again!'
    end
  end

  def initialize(input)
    @grid = input
  end

  def rows
    @grid
  end

  def columns
    @grid.transpose
  end

  def regions
    flat_triplet_list = @grid.flatten.each_slice(3).to_a
    (0..20).step(9).each_with_object([]) do |i, result|
      (0..2).each do |k|
        result << [0, 3, 6].each_with_object([]) do |j, region|
          region << flat_triplet_list[i + j + k]
        end.flatten
      end
    end
  end

  def grid_valid?
    rows.all?(&:valid?) && columns.all?(&:valid?) &&
        regions.all?(&:valid?)
  end

  def find_empty_positions
    @grid.each_with_index.with_object([]) do |(row, row_index), empty_positions|
      row.each_with_index do |digit, digit_index|
        empty_positions << [row_index, digit_index] if digit.zero?
      end
    end
  end

  def check_row(row, digit)
    !rows[row].include? digit
  end

  def check_column(col, digit)
    !columns[col].include? digit
  end

  def check_region(row, col, digit)
    region_index = region_index(row, col)
    !regions[region_index].include? digit
  end

  def check_value(row, col, digit)
    check_row(row, digit) && check_column(col, digit) && check_region(row, col, digit)
  end

  def region_index(row, col)
    (row / 3) * 3 + (col / 3)
  end

  def with(row, column, digit)
    new_grid = @grid.map &:dup
    new_grid[row][column] = digit
    Sudoku.new(new_grid)
  end

  def possibilities
    if (row, column = self.find_empty_positions.sample)
      (1..9).select { |digit| self.check_value(row, column, digit) }
          .map { |digit| self.with(row, column, digit) }
    else
      []
    end
  end

  def fill_all
    @grid = Backtracker
                .new(state: self, next_states: :possibilities.to_proc, solved: :grid_valid?.to_proc)
                .solve
                .grid
  end

    # def fill_all
    #   empty_positions = find_empty_positions
    #   i = 0
    #
    #   while i < empty_positions.length
    #     row, column = empty_positions[i]
    #     found = false
    #
    #     (1..9).each do |digit|
    #       if check_value(row, column, digit)
    #         found = true
    #         @grid[row][column] = digit
    #         i += 1
    #         break
    #       end
    #     end
    #
    #     unless found
    #       @grid[row][column] = 0
    #       i -= 1
    #     end
    #   end
    #
    #   @grid
    #     # found = false
    #     #
    #     # until empty_positions.empty?
    #     #   row, col = empty_positions.last
    #     #   found = false
    #     #   p empty_positions.size
    #     #   (1..9).each do |digit|
    #     #     if check_value(row, col, digit)
    #     #       @grid[row][col] = digit
    #     #       found = true
    #     #       row_next, col_next = empty_positions.pop unless empty_positions.empty?
    #     #       break
    #     #     end
    #     #   end
    #     #
    #     #   if !found
    #     #     @grid[row][col] = 0
    #     #     empty_positions << [row, col]
    #     #     # found = false
    #     #   end
    #     #
    #     # end
    #     # @grid
    # end

end

if __FILE__ == $0
  # grid_3 = [[5, 3, 4, 6, 7, 8, 9, 1, 2],
  #           [6, 7, 2, 1, 9, 5, 3, 4, 8],
  #           [1, 9, 8, 3, 4, 2, 5, 6, 7],
  #           [8, 5, 0, 7, 6, 1, 4, 2, 3],
  #           [4, 2, 6, 8, 5, 3, 0, 9, 1],
  #           [7, 1, 3, 9, 2, 4, 8, 5, 6],
  #           [9, 6, 1, 5, 3, 7, 2, 8, 4],
  #           [2, 8, 7, 4, 1, 9, 6, 3, 5],
  #           [3, 4, 5, 2, 8, 6, 1, 0, 9]]
  # filled_grid  = Sudoku.new(grid_3).fill_all
  # p Sudoku.done_or_not(filled_grid)
  grid_6 = [[0, 3, 4, 6, 7, 8, 9, 1, 2],
            [6, 7, 0, 1, 9, 5, 3, 4, 8],
            [1, 9, 8, 3, 4, 2, 5, 6, 7],
            [8, 5, 0, 7, 6, 1, 4, 2, 3],
            [4, 2, 6, 8, 5, 3, 0, 9, 1],
            [7, 1, 3, 9, 2, 4, 8, 5, 6],
            [9, 6, 1, 5, 3, 7, 2, 8, 4],
            [2, 8, 0, 4, 1, 9, 6, 3, 5],
            [3, 4, 5, 2, 8, 6, 1, 0, 9]]
  filled_grid = Sudoku.new(grid_6).fill_all
  pp filled_grid
  p Sudoku.done_or_not(filled_grid)
end