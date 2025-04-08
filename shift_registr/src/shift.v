module shift_reg 
(
    input clk,
    input o1,
    output reg led18,
    output reg led17,
    output reg led16,
    output reg led15
);
reg [31:0]count;
    always @(posedge clk) begin
    count <= count+1;
    if (count == 2700000) begin
    count <=0;
    end
     if(count==1350000) begin
        if (o1) begin
            led15 <= led16;
            led16 <= led17;
            led17<=led18;
            led18<=~led15;
        end
        end
     end   
endmodule

