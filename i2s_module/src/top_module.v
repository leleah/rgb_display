module top 
(           input clk,
            input bit_clk,
            input lr_clk,
            input data_input,
   
            output bit_clk_out,
            output lr_clk_output,
            output data_output,
            output data_ready_out

);
wire [15:0] left;
wire [15:0] right;
i2s transfer_i2s
(       .CLK(clk), // подключаем выход тактов с модуля i2s к выходу тактов топ-модуля
        .ADCDA(data_input), // вход АЦП подключаем к входу данных топ-модуля
        .DACDA(data_output), //выход ЦАП к выходу данных топ-модуля
        .BCLK(bit_clk),
        .LRCLK(lr_clk),
        .BCLK_S(bit_clk_out),
        .LRCLK_S(lr_clk_output),
        .DATAREADY(data_ready_out),
        .LEFT_OUT(left),
        .LEFT_IN(left),
        .RIGHT_OUT(right),
        .RIGHT_IN(right)
);
endmodule