module main(
input Clock,
output reg [4:0] Red,
output reg  [5:0] Green,
output reg  [4:0] Blue,
output reg  Vsync,
output reg  Hsync,
output reg  Pixel_Clock,
output reg  DEN
);

always @(posedge Clock) begin


end

endmodule

module Hsync_Vsync(
input CLKIN,
output reg Vsync,
output reg Hsync
);
reg [3:0]  counter;
always @(negedge CLKIN) begin
if (Hsync == 1)
    Hsync <= 0;
if (Hsync ==0)
    counter <=1;
    if (counter <40)
        counter <= counter + 1'd1;
    if (counter >=40)
        Hsync <=1;
end 

reg [3:0]  counter2;
always @(posedge Hsync)
begin
    Vsync <= 0;
      counter2 <= 1;
    if (Vsync == 0)
        counter2 <= counter2 + 1'd1;
    if (counter2 > 20)
        Vsync <= 1;
        
end

endmodule