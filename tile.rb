require "colorize"
require_relative "./error_types.rb"

class Tile
    attr_reader :value

    NUMBERS = (1..9).to_a

    def initialize(value = " ", given = false)
        @value = value 
        @given = given #true/false
        @highlight = false
    end

    def display 
        if @highlight
            if @given                
                @value.to_s.colorize(:background => :red).bold
            else
                @value.to_s.colorize(:color => :yellow, :background => :red).bold
            end
        else       
            @given ? @value : @value.to_s.colorize(:yellow)
        end
    end

    def change_value(new_value)        
        validate_input(new_value)            
        @value = new_value
    end   
    
    def validate_input(value)
        if @given
            raise ChangedGivenError.new("You can't change the value of a given.")
        end
        unless NUMBERS.include?(value) 
            raise InvalidValueError.new("Please enter a valid value.")
        end 
    end 
    
    def highlight
        @highlight = true
    end

    def unhighlight
        @highlight = false
    end

    def erase
        if @given
            raise ErasedGivenError.new("You can't erase a given.")
        end
        @value = " "
    end
end