`timescale 1ns/100ps
`define CLOCK_PERIOD 100
`define SPI_MASTER_CLOCK_PERIOD 425
`define RESET_INACTIVE 1
`define RESET_ACTIVE 0

`define SPI_MESSAGE_WIDTH 2
`define SPI_MESSAGE_DEPTH 32
`define MANDELBROT_MAX_ITERATIONS 255

module tb_top ();

    integer i;
    
    reg tb_clk, tb_nrst;
    reg tb_spi_data, tb_imaginary_in, tb_spi_clk, tb_spi_en;
    wire tb_is_mandelbrot, tb_valid_out;
    wire [23:0] tb_RGB;
    
    wire [7:0] tb_R, tb_G, tb_B;
    assign {tb_R, tb_G, tb_B} = tb_RGB;

    reg tb_spi_clk_active;
    reg [63:0] tb_spi_packet;
    reg [63:0] tb_spi_next_packet;

    task inputs_to_zero;
        begin
            tb_spi_data = 0;
            tb_imaginary_in = 0; 
            tb_spi_clk_active = 0;
            tb_spi_en = 0; 
        end
    endtask

    task send_packet;
        begin
            @(negedge tb_clk);

            tb_spi_packet = tb_spi_next_packet;
            tb_spi_en = 1;
            tb_spi_clk_active = 1;
            
            tb_spi_data = tb_spi_packet[0];
            for (i = 0; i < `SPI_MESSAGE_DEPTH * `SPI_MESSAGE_WIDTH; i = i + 1) begin
                @(negedge tb_spi_clk);
                tb_spi_packet = tb_spi_packet >> 1;
                tb_spi_data = tb_spi_packet[0];
                #(0.1);
            end

            tb_spi_en = 0;
            tb_spi_clk_active = 0;
        end
    endtask


    initial begin
        $dumpfile ("dump.vcd");
        $dumpvars;
    end

    
    always begin
        tb_clk = 1'b0;
        #(`CLOCK_PERIOD / 2);
        tb_clk = 1'b1;
        #(`CLOCK_PERIOD / 2);
    end

    always begin
        tb_spi_clk = 1'b0;
        #(`SPI_MASTER_CLOCK_PERIOD / 2);
        tb_spi_clk = tb_spi_clk_active;
        #(`SPI_MASTER_CLOCK_PERIOD / 2);
    end

    ref_top DUT (
        .clk(tb_clk), .nrst(tb_nrst),
        .spi_clk(tb_spi_clk),
        .spi_en(tb_spi_en),
        .spi_data(tb_spi_data),
        .is_mandelbrot(tb_is_mandelbrot),
        .valid_out(tb_valid_out)
    );

    initial begin
        tb_nrst = `RESET_ACTIVE;
        #(`CLOCK_PERIOD * 1);
        inputs_to_zero();
        #(`CLOCK_PERIOD * 2);
        tb_nrst = `RESET_INACTIVE;
        #(`CLOCK_PERIOD * 10);

        // -0 + 0i
        tb_spi_next_packet = 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001;
        send_packet();

        @(posedge tb_valid_out);
        #(`CLOCK_PERIOD * 5);

        // -1 + 0.5i
        //                       FFFF FFFF FFFF FFFF FFFF FFFF FFFF FIIS FFFF FFFF FFFF FFFF FFFF FFFF FFFF FIIS
        tb_spi_next_packet = 64'b0000_0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000_0000_0000_0000_1111;
        send_packet();

        @(posedge tb_valid_out);
        #(`CLOCK_PERIOD * 10);

        $display("Opening .bmp file...");
        f = $fopen("img/mandel_1.bmp","w");

        // I am sorry...
        $display("Writing .bmp file header...");
        $fwrite(f, "%c", 8'h42);
        $fwrite(f, "%c", 8'h4d);
        $fwrite(f, "%c", 8'h36);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h03);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00); // 1/2
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h36);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h28);
        $fwrite(f, "%c", 8'h00); // 1
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h01);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h01); // 3/2
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h01);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h18);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00); // 2
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h03);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00); // 5/2
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        
        $display("Writing colormap...");
        for (tb_passes = 0; tb_passes < 256; tb_passes = tb_passes + 1) begin
            for (tb_iterations = 0; tb_iterations < 256; tb_iterations = tb_iterations + 1) begin
                @(posedge tb_clk);
                $fwrite(f, "%c%c%c", tb_iterations, 8'h00, tb_passes);
                @(negedge tb_clk);
            end
        end

        $display("Closing .bmp file...");
        $fclose(f);

        $finish;
    end

endmodule
