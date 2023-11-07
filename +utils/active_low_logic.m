function converted_signal = active_low_logic(logic_signal)
    arguments (Input)
        logic_signal logical
    end
    arguments (Output)
        converted_signal
    end
    converted_signal = ~logic_signal;
end