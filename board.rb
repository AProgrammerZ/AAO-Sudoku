require "colorize"
require_relative "./tile.rb"
require_relative "./error_types.rb"

class Board 
    attr_reader :grid

    NUMBERS = (1..9).to_a
        
    def initialize(grid)
        @grid = grid
    end

    def self.from_file(file_name) # Example: Board.from_file("sudoku1")
        grid = []
        File.foreach("./puzzles/#{file_name}.txt") do |line|
            row = []
            line_array = line.chomp.chars.map(&:to_i)
            line_array.each do |num|                
                num == 0 ? tile = Tile.new : tile = Tile.new(num, true)
                row << tile
            end
            grid << row
        end
        
        Board.new(grid)
    end

    def update(row, col, value)                
        validate_input(row, col, value)        
        @grid[row][col].change_value(value)        
    end

    def validate_input(row, col, value)                  
        if @grid[row] == nil || @grid[col] == nil
            raise InvalidPositionError.new("Please enter a valid position.")
        end                
    end

    def do_highlighting        
        @grid.each do |row|
            row.each do |tile|
                if tile.value == " "
                    tile.unhighlight
                else
                    if dup_in_row_col_sqr?(tile)
                        tile.highlight
                    else
                        tile.unhighlight
                    end
                end
            end
        end          
    end    

    def dup_in_row_col_sqr?(tile)        
        # row
        row = @grid.select { |row| row.include?(tile) }.flatten        
        return true if dup_in_section?(row, tile)

        # column
        columns = @grid.transpose
        column = columns.select { |col| col.include?(tile) }.flatten
        return true if dup_in_section?(column, tile)

        # square
        sqrs = get_squares_hash.values
        square = sqrs.select { |sqr| sqr.include?(tile) }.flatten
        return true if dup_in_section?(square, tile)

        false
    end

    def dup_in_section?(section, tile)
        section_values = section.map(&:value).delete_if { |value| value == " " }
        return true if section_values.count(tile.value) > 1  
        false
    end

    def get_squares_hash # keys are positions ([row, col]) in square, values are the squares        
        squares_hash = {}
        col = 0 

        3.times do
            @grid.each_with_index do |row, idx|
                if idx == 0 || idx == 3 || idx == 6
                    square, positions, col = get_square(idx, col)      
                    squares_hash[positions] = square                    
                    col -= 3               
                end
            end
            col += 3
        end

        squares_hash
    end

    def get_square(idx, col)
        square = []
        positions = [] # keys for hash
        x = 0       

        until square.length == 9 do
            @grid[idx..idx+2].each do |row| # get one column of square
                square << row[col]
                positions << [idx + x, col]
                x += 1
            end
            col += 1
            x = 0
        end  

        [square,positions,col]
    end

    def render
        do_highlighting

        print "   "
        (0..2).each { |i| print "#{i.to_s.colorize(:blue)} "}
        print "  "
        (3..5).each { |i| print "#{i.to_s.colorize(:blue)} "}
        print "  "
        (6..8).each { |i| print "#{i.to_s.colorize(:blue)} "}
        puts
        puts

        i = 0
        @grid.each_with_index do |row, idx|
            print "#{i.to_s.colorize(:blue)}  "
            i += 1

            row.each_with_index do |tile, idx| 
                print "#{tile.display} "
                print "| " if idx == 2 || idx == 5
            end
            puts
            if idx == 2 || idx == 5
                print "   "
                21.times { print "-" }
                puts
            end
        end                
    end

    def solved?
        rows_solved? && cols_solved? && sqrs_solved?
    end

    def rows_solved?
        @grid.each do |row| 
            return false unless ( NUMBERS - row.map(&:value) ).empty?            
        end
        true                    
    end

    def cols_solved?
        columns = @grid.transpose
        columns.each do |column| 
            return false unless ( NUMBERS - column.map(&:value) ).empty?            
        end
        true 
    end

    def sqrs_solved?                
        squares_hash = get_squares_hash
        squares_hash.each_value do |square|
            square_values = square.map(&:value)
            return false unless (NUMBERS - square_values).empty? 
        end        
        true
    end    
end        

# board = Board.from_file("sudoku1")
# board.update(4,4,7)
# board.render