`timescale 1ps/1ps

module SPIProtocol (
    input  clk,                                         // System Clock
    input  rst,                                         // Asynchronous Reset
    input  [15:0]dat_in,                                // Data Input Vector 
    output spi_mclk,                                    // SPI Clock from Master
    output spi_dat,                                     // SPI bus data
    output spi_ssal,                                    // SPI Slave Select (Active Low)
    output [4:0]bit_count                               // Data bit count
);

reg [15:0] MOSI;                                        // Master-Out Slave-In line
reg [4:0] count;                                        // Control Counter
reg ssal;                                               // Slave Select (Active Low)
reg mclk;                                               // SPI Clock from Master
reg [1:0] state;                                        // SPI State Register

always @ (posedge clk or posedge rst)
if (rst)                                                // Defining the reset state
    begin
        MOSI    <= 16'b0;                               // Clearing the MOSI bus
        count   <= 5'd16;                               // Resetting the bit count to MSB
        ssal    <= 1'b1;                                // Resetting the Slave Select
        mclk    <= 1'b0;                                // Resetting SPI Master Clock 
    end
else
    begin
        case (state)
            0:begin                                     // Initial State
                mclk    <= 1'b0;                        // SPI Master Clock is still zero as no Slave selected
                ssal    <= 1'b1;                        // Slave not selected
                state   <= 1;                           // Going to the next state
              end

            1:begin                                     // Load state
                mclk    <= 1'b0;                        // SPI Master Clock is zero because data is loaded
                ssal    <= 1'b0;                        // Slave Selected
                MOSI    <= dat_in[count-1];           // MOSI Bus is loaded with the data bit
                count   <= count-1;                     // Data bit is shifted
                state   <= 2;                           // Going to the next state
              end
            
            2:begin                                     // Transmission State
                mclk    <= 1'b1;                        // SPI Master Clock is one because data is being transmitted    
                if (count > 0)                          // Checking if all data bits have been exhausted
                    state <= 1;                         // If data bits are remaining, going back to the previous state
                    
                else                                    // If data bits are not remaining then performing the following operations :
                    begin                                   
                        count <= 16;                    // Setting data bit count to MSB
                        state <= 0;                     // Going to state 0
                    end                             
              end

            default:  state <= 0;                       // Default State sets state to 0
        endcase
    end

    assign spi_ssal = ssal;                             // Assigning the port values to the respective reg values
    assign spi_mclk = mclk;
    assign spi_dat  = MOSI;
    assign bit_count = count;

endmodule