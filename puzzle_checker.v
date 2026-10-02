module puzzle_checker (
    input  wire expected,
    input  wire actual,
    output wire result
);

    function test;
        input expected_f;
        input actual_f;

        begin
            test = (expected_f == actual_f);
        end
    endfunction

    assign result = test(expected, actual);

endmodule
