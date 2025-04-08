module i2s #(parameter  SAMPLE_WIDTH = 16)(
                                  input CLK,    
                                  input BCLK,               // Bit clock от кодека
                                  input LRCLK,              // LR clock от кодека
                                  input ADCDA,              // оцифрованные АЦП данные от кодека
                                  input [SAMPLE_WIDTH-1:0] LEFT_IN,  // вектор левого канала для вывода на ЦАП
                                  input [SAMPLE_WIDTH-1:0] RIGHT_IN, // вектор правого канала для вывода на ЦАП
                                  output reg [SAMPLE_WIDTH-1:0] LEFT_OUT, // десериализованные данные АЦП, левый канал
                                  output reg [SAMPLE_WIDTH-1:0] RIGHT_OUT, // десериализованные данные АЦП, правый канал
                                  output reg DATAREADY, // строб - данные обновлены
                                  output BCLK_S,            // синхронизированный сигнал BCLK
                                  output LRCLK_S,           // синхронизированный сигнал LRCLK
                                  output DACDA);            // выход данных на ЦАП кодека
reg [2:0] bclk_trg; always @(posedge CLK) bclk_trg <= { bclk_trg[1:0], BCLK };
assign BCLK_S = bclk_trg[1];                    // синхронизированный BCLK
wire BCLK_PE = ~bclk_trg[2] & BCLK_S;           // выделенный передний фронт BCLK
wire BCLK_NE = bclk_trg[2] & ~BCLK_S;           // выделенный задний фронт BCLK
     
reg [2:0] lrclk_trg; always @(posedge CLK) lrclk_trg <= { lrclk_trg[1:0], LRCLK };
assign LRCLK_S = lrclk_trg[1];                  // синхронизированный LRCLK
wire LRCLK_PRV = lrclk_trg[2];                  // предыдущее значение LRCLK
wire LRCLK_CH = LRCLK_PRV ^ LRCLK_S;            // любое измененение LRCLK
     
reg [1:0] adcda_trg; always @(posedge CLK) adcda_trg <= { adcda_trg[0], ADCDA };
wire ADCDA_S = adcda_trg[1];                        // синхронизированный DAT

//Для сохранения полученных данных нужен 32-х битный вектор. 
//При обнаружении положительного фронта сигнала BCLK производим захват данных и задвигаем в регистр.
wire [31:0] shift_w = { shift[30:0], ADCDA_S };
reg [31:0] shift; always @(posedge CLK) if (BCLK_PE) shift <= shift_w;

//При обнаружении изменения сигнала LRCLK 
//мы сохраняем полученные данные в соответствующем каналу векторе и генерируем строб, сигнализирующий, что данные обновились. 
//Естественно частота строба будет равна частоте дискретизации.

always @(posedge CLK) 
begin
    if (LRCLK_CH)
    begin
        if (LRCLK_PRV)
            begin
                RIGHT_OUT <= shift_w[31:32-SAMPLE_WIDTH];
                DATAREADY <= 1'b1;
            end
        else
            LEFT_OUT <= shift_w[31:32-SAMPLE_WIDTH];
    end
        else
            DATAREADY <= 1'b0;
end

//Заведем два вектора, в которые будут защелкиваться входные данные. 
//И указатель (счетчик от 0 до 31), а также регистр, по которому будет выбирать канал.
reg [SAMPLE_WIDTH-1:0] lb;
reg [SAMPLE_WIDTH-1:0] rb;
 
reg [4:0] bit_cnt; // указатель текущего бита
reg actualLR;
always @(posedge CLK)
begin
    if (LRCLK_CH)
    begin
        bit_cnt <= 5'd31;
        actualLR <= ~LRCLK_S;
    end
        else
            if (BCLK_NE)
            begin
                actualLR <= LRCLK_S;
                 
                bit_cnt <= bit_cnt + 1'b1;
                if (bit_cnt == 5'd31)
                begin
                    lb <= LEFT_IN;
                    rb <= RIGHT_IN;
                end
                 
            end
end

wire [4:0] bit_ptr = (~bit_cnt - (32-SAMPLE_WIDTH));
assign DACDA = (bit_cnt < SAMPLE_WIDTH) ? actualLR ? lb[bit_ptr] : rb[bit_ptr] : 1'b0;
endmodule