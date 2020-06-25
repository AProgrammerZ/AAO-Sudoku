require_relative "./board.rb"

class Game
    def initialize
        @board = Board.from_file("sudoku1")
    end

    def play        
        until @board.solved? do            
            begin
                @board.render
                row, col, value = prompt
                if row == "erase"            
                    @board.grid[col.to_i][value.to_i].erase
                else
                    @board.update(row.to_i, col.to_i, value.to_i)
                end
            rescue InvalidPositionError, InvalidValueError, ChangedGivenError, ErasedGivenError => my_error           
                puts "\n #{my_error.message}"
                sleep(2) 
            rescue => e # all other possible errors
                puts "\n #{e.class.name}: #{e.message}"                           
                sleep(2)
            end
            system("clear")
        end
        @board.render
        puts "\nYou win!"
        puts
    end

    def prompt
        puts "\nPlease enter a position (row, column) and a value (1-9) to change (like so: 2,4, 5)"
        puts "\nor"
        puts "\nTo erase a value, enter: erase row column (like so: erase, 2,4)"
        puts
        row, col, value = gets.chomp.split(",")        
    end        
end

game = Game.new
game.play