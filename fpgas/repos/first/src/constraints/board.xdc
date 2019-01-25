create_clock -period 37.037 -name CLK27MHZ_REFCLK_N -waveform {0.000 18.519} [get_ports CLK27MHZ_REFCLK_N]
create_clock -period 3.367 -name SDI_A/SDI/I -waveform {0.000 1.684} [get_pins SDI_A/SDI/gtpe2_i/RXOUTCLK]
create_clock -period 3.367 -name SDI_A/SDI/TX_outclk -waveform {0.000 1.684} [get_pins SDI_A/SDI/gtpe2_i/TXOUTCLK]



set_property PACKAGE_PIN U20 [get_ports FPGA_REFCLK_N]
set_property PACKAGE_PIN T20 [get_ports FPGA_REFCLK_P]
set_property PACKAGE_PIN W20 [get_ports XAUI_LS_OK_IN_A]
set_property PACKAGE_PIN Y20 [get_ports XAUI_PDTRXA_N]
set_property PACKAGE_PIN T19 [get_ports XAUI_PRBSEN]
set_property PACKAGE_PIN U19 [get_ports XAUI_ST]
set_property PACKAGE_PIN V19 [get_ports XAUI_MODE_SEL]
set_property PACKAGE_PIN W19 [get_ports {XAUI_PRTAD[0]}]
set_property PACKAGE_PIN V18 [get_ports {XAUI_PRTAD[1]}]
set_property PACKAGE_PIN W18 [get_ports {XAUI_PRTAD[2]}]
set_property PACKAGE_PIN T14 [get_ports {XAUI_PRTAD[3]}]
set_property PACKAGE_PIN T15 [get_ports {XAUI_PRTAD[4]}]
set_property PACKAGE_PIN T17 [get_ports XAUI_RST_N]
set_property PACKAGE_PIN T18 [get_ports XAUI_MDIO]
set_property PACKAGE_PIN U15 [get_ports XAUI_MDC]
set_property PACKAGE_PIN U16 [get_ports {XAUI_GPIO[0]}]
set_property PACKAGE_PIN U14 [get_ports {XAUI_GPIO[1]}]
set_property PACKAGE_PIN V14 [get_ports {XAUI_GPIO[2]}]
set_property PACKAGE_PIN V16 [get_ports XAUI_LOSA]
set_property PACKAGE_PIN V17 [get_ports XAUI_LS_OK_OUT_A]
set_property PACKAGE_PIN U17 [get_ports XAUI_PRBS_PASS]
set_property PACKAGE_PIN C17 [get_ports {RX_SELECT[3]}]
set_property PACKAGE_PIN B17 [get_ports {RX_SELECT[4]}]
set_property PACKAGE_PIN A17 [get_ports {FOUT[1]}]
set_property PACKAGE_PIN A18 [get_ports {FOUT[2]}]
set_property PACKAGE_PIN B19 [get_ports {FOUT[3]}]
set_property PACKAGE_PIN A19 [get_ports {FOUT[4]}]
set_property PACKAGE_PIN E17 [get_ports NO_LOCK1]
set_property PACKAGE_PIN E18 [get_ports NO_ALIGN1]
set_property PACKAGE_PIN D18 [get_ports NO_REF1]
set_property PACKAGE_PIN B22 [get_ports CH1_SLEEP]
set_property PACKAGE_PIN A22 [get_ports CH1_EQ_ENn]
set_property PACKAGE_PIN E21 [get_ports CH1_SD_HDn]
set_property PACKAGE_PIN D21 [get_ports CH1_DISn]
set_property PACKAGE_PIN C22 [get_ports CH1_GAIN_SEL]
set_property PACKAGE_PIN C23 [get_ports CH1_CARRIER_DETECT]
set_property PACKAGE_PIN B25 [get_ports UART1_TXD]
set_property PACKAGE_PIN A25 [get_ports UART1_RXD]
set_property PACKAGE_PIN C26 [get_ports LED_POWER]
set_property PACKAGE_PIN B26 [get_ports LED_LINK]
set_property PACKAGE_PIN C24 [get_ports LED_SDI]
set_property PACKAGE_PIN B24 [get_ports LED_ACT]
set_property PACKAGE_PIN D23 [get_ports SW_GPIOB3]
set_property PACKAGE_PIN D24 [get_ports SW_GPIOB2]
set_property PACKAGE_PIN E22 [get_ports SW_GPIOB1]
set_property PACKAGE_PIN E6 [get_ports {A[14]}]
set_property PACKAGE_PIN D6 [get_ports {A[13]}]
set_property PACKAGE_PIN H8 [get_ports {A[12]}]
set_property PACKAGE_PIN G8 [get_ports {A[11]}]
set_property PACKAGE_PIN H7 [get_ports CK_P]
set_property PACKAGE_PIN G7 [get_ports CK_N]
set_property PACKAGE_PIN F8 [get_ports {A[10]}]
set_property PACKAGE_PIN F7 [get_ports {A[9]}]
set_property PACKAGE_PIN H6 [get_ports {A[8]}]
set_property PACKAGE_PIN G6 [get_ports {A[7]}]
set_property PACKAGE_PIN H9 [get_ports {A[6]}]
set_property PACKAGE_PIN G9 [get_ports {A[5]}]
set_property PACKAGE_PIN J6 [get_ports {A[4]}]
set_property PACKAGE_PIN J5 [get_ports {A[3]}]
set_property PACKAGE_PIN L8 [get_ports {A[2]}]
set_property PACKAGE_PIN K8 [get_ports {A[1]}]
set_property PACKAGE_PIN J4 [get_ports {A[0]}]
set_property PACKAGE_PIN H4 [get_ports {BA[2]}]
set_property PACKAGE_PIN K7 [get_ports {BA[1]}]
set_property PACKAGE_PIN K6 [get_ports {BA[0]}]
set_property PACKAGE_PIN G4 [get_ports RAS_N]
set_property PACKAGE_PIN F4 [get_ports CAS_N]
set_property PACKAGE_PIN G5 [get_ports WE_N]
set_property PACKAGE_PIN F5 [get_ports CS_N]
set_property PACKAGE_PIN B5 [get_ports CKE]
set_property PACKAGE_PIN A5 [get_ports ODT]
set_property PACKAGE_PIN K3 [get_ports DM0]
set_property PACKAGE_PIN J3 [get_ports {DQ[0]}]
set_property PACKAGE_PIN M7 [get_ports {DQ[1]}]
set_property PACKAGE_PIN L7 [get_ports {DQ[2]}]
set_property PACKAGE_PIN M4 [get_ports DQS0_P]
set_property PACKAGE_PIN L4 [get_ports DQS0_N]
set_property IOSTANDARD SSTL15 [get_ports DQS0_P]
set_property PACKAGE_PIN L5 [get_ports {DQ[3]}]
set_property PACKAGE_PIN K5 [get_ports {DQ[4]}]
set_property PACKAGE_PIN N7 [get_ports {DQ[5]}]
set_property PACKAGE_PIN N6 [get_ports {DQ[6]}]
set_property PACKAGE_PIN M6 [get_ports {DQ[7]}]
set_property PACKAGE_PIN K1 [get_ports DM1]
set_property PACKAGE_PIN J1 [get_ports {DQ[8]}]
set_property PACKAGE_PIN L3 [get_ports {DQ[9]}]
set_property PACKAGE_PIN K2 [get_ports {DQ[10]}]
set_property PACKAGE_PIN N1 [get_ports DQS1_P]
set_property PACKAGE_PIN M1 [get_ports DQS1_N]
set_property PACKAGE_PIN H2 [get_ports {DQ[11]}]
set_property PACKAGE_PIN H1 [get_ports {DQ[12]}]
set_property PACKAGE_PIN M2 [get_ports {DQ[13]}]
set_property PACKAGE_PIN L2 [get_ports {DQ[14]}]
set_property PACKAGE_PIN N3 [get_ports {DQ[15]}]
set_property PACKAGE_PIN N2 [get_ports DDR3_RST_N]
set_property PACKAGE_PIN R3 [get_ports {DQ[16]}]
set_property PACKAGE_PIN P3 [get_ports {DQ[17]}]
set_property PACKAGE_PIN P4 [get_ports {DQ[18]}]
set_property PACKAGE_PIN N4 [get_ports {DQ[19]}]
set_property PACKAGE_PIN R1 [get_ports DQS2_P]
set_property PACKAGE_PIN P1 [get_ports DQS2_N]
set_property PACKAGE_PIN T4 [get_ports DM2]
set_property PACKAGE_PIN T3 [get_ports {DQ[20]}]
set_property PACKAGE_PIN T2 [get_ports {DQ[21]}]
set_property PACKAGE_PIN R2 [get_ports {DQ[22]}]
set_property PACKAGE_PIN U2 [get_ports {DQ[23]}]
set_property PACKAGE_PIN P6 [get_ports DM3]
set_property PACKAGE_PIN T5 [get_ports {DQ[24]}]
set_property PACKAGE_PIN R5 [get_ports {DQ[25]}]
set_property PACKAGE_PIN U6 [get_ports DQS3_P]
set_property PACKAGE_PIN U5 [get_ports DQS3_N]
set_property PACKAGE_PIN R8 [get_ports {DQ[26]}]
set_property PACKAGE_PIN P8 [get_ports {DQ[27]}]
set_property PACKAGE_PIN R7 [get_ports {DQ[28]}]
set_property PACKAGE_PIN R6 [get_ports {DQ[29]}]
set_property PACKAGE_PIN T8 [get_ports {DQ[30]}]
set_property PACKAGE_PIN T7 [get_ports {DQ[31]}]
set_property PACKAGE_PIN R14 [get_ports {FLASH_D[0]}]
set_property PACKAGE_PIN R15 [get_ports {FLASH_D[1]}]
set_property PACKAGE_PIN P14 [get_ports {FLASH_D[2]}]
set_property PACKAGE_PIN N14 [get_ports {FLASH_D[3]}]
set_property PACKAGE_PIN N17 [get_ports uC_SDA]
set_property PACKAGE_PIN R16 [get_ports uC_SCL]
set_property PACKAGE_PIN R17 [get_ports PWM1]
set_property PACKAGE_PIN P18 [get_ports FLASH_FCS_B]
set_property PACKAGE_PIN L20 [get_ports RESETn]
set_property PACKAGE_PIN L24 [get_ports uC_SPICSn]
set_property PACKAGE_PIN L25 [get_ports uC_SPISCK]
set_property PACKAGE_PIN M24 [get_ports uC_MOSI]
set_property PACKAGE_PIN M25 [get_ports uC_MISO]
set_property PACKAGE_PIN L22 [get_ports uC_RXD2]
set_property PACKAGE_PIN L23 [get_ports uC_TXD2]
set_property PACKAGE_PIN N21 [get_ports RMII_TXCLK]
set_property PACKAGE_PIN P20 [get_ports RMII_RXCLK]
set_property PACKAGE_PIN N23 [get_ports uC_RXD]
set_property PACKAGE_PIN N24 [get_ports uC_TXD]
set_property PACKAGE_PIN P19 [get_ports {RMII_TXD[3]}]
set_property PACKAGE_PIN N19 [get_ports {RMII_TXD[2]}]
set_property PACKAGE_PIN P23 [get_ports {RMII_TXD[1]}]
set_property PACKAGE_PIN P24 [get_ports {RMII_TXD[0]}]
set_property PACKAGE_PIN R20 [get_ports RMII_TXCTL]
set_property PACKAGE_PIN R21 [get_ports RMII_CRS]
set_property PACKAGE_PIN R25 [get_ports RMII_COL]
set_property PACKAGE_PIN P25 [get_ports {RMII_RXD[3]}]
set_property PACKAGE_PIN N26 [get_ports {RMII_RXD[2]}]
set_property PACKAGE_PIN M26 [get_ports {RMII_RXD[1]}]
set_property PACKAGE_PIN T24 [get_ports {RMII_RXD[0]}]
set_property PACKAGE_PIN T25 [get_ports RMII_RXCTL]
set_property PACKAGE_PIN R26 [get_ports ETH_RSTN]
set_property PACKAGE_PIN P26 [get_ports SFP_FAULT]
set_property PACKAGE_PIN T22 [get_ports SFP_DIS]
set_property PACKAGE_PIN R22 [get_ports SFP_ABS]
set_property PACKAGE_PIN T23 [get_ports SFP_RS0]
set_property PACKAGE_PIN R23 [get_ports SFP_RS1]
set_property PACKAGE_PIN R18 [get_ports SFP_RX_LOS]
set_property PACKAGE_PIN J20 [get_ports {EMIF_A[0]}]
set_property PACKAGE_PIN J18 [get_ports {EMIF_A[1]}]
set_property PACKAGE_PIN H18 [get_ports {EMIF_A[2]}]
set_property PACKAGE_PIN G20 [get_ports ETH_25M]
set_property PACKAGE_PIN G21 [get_ports {EMIF_A[3]}]
set_property PACKAGE_PIN J23 [get_ports {EMIF_A[4]}]
set_property PACKAGE_PIN H23 [get_ports {EMIF_A[5]}]
set_property PACKAGE_PIN G22 [get_ports {EMIF_A[6]}]
set_property PACKAGE_PIN F22 [get_ports {EMIF_A[7]}]
set_property PACKAGE_PIN J24 [get_ports {EMIF_A[8]}]
set_property PACKAGE_PIN H24 [get_ports {EMIF_A[9]}]
set_property PACKAGE_PIN F23 [get_ports {EMIF_A[10]}]
set_property PACKAGE_PIN E23 [get_ports {EMIF_A[11]}]
set_property PACKAGE_PIN K22 [get_ports {EMIF_A[12]}]
set_property PACKAGE_PIN K23 [get_ports {EMIF_A[13]}]
set_property PACKAGE_PIN G24 [get_ports EMIF_NWE]
set_property PACKAGE_PIN F24 [get_ports EMIF_NRD]
set_property PACKAGE_PIN E25 [get_ports EMIF_NWAIT]
set_property PACKAGE_PIN D25 [get_ports EMIF_CS0]
set_property PACKAGE_PIN E26 [get_ports EMIF_CS1]
set_property PACKAGE_PIN D26 [get_ports {EMIF_D[0]}]
set_property PACKAGE_PIN H26 [get_ports {EMIF_D[1]}]
set_property PACKAGE_PIN G26 [get_ports {EMIF_D[2]}]
set_property PACKAGE_PIN G25 [get_ports {EMIF_D[3]}]
set_property PACKAGE_PIN F25 [get_ports {EMIF_D[4]}]
set_property PACKAGE_PIN J25 [get_ports {EMIF_D[5]}]
set_property PACKAGE_PIN J26 [get_ports {EMIF_D[6]}]
set_property PACKAGE_PIN L19 [get_ports {EMIF_D[7]}]
set_property PACKAGE_PIN D14 [get_ports CH2_SDIi_P]
set_property PACKAGE_PIN C14 [get_ports CH2_SDIi_N]
set_property PACKAGE_PIN B13 [get_ports CH3_SDIi_P]
set_property PACKAGE_PIN A13 [get_ports CH3_SDIi_N]
set_property PACKAGE_PIN D12 [get_ports CH4_SDIi_P]
set_property PACKAGE_PIN C12 [get_ports CH4_SDIi_N]
set_property PACKAGE_PIN E11 [get_ports SDI1A_REFCLK_N]
set_property PACKAGE_PIN F11 [get_ports SDI1A_REFCLK_P]
set_property PACKAGE_PIN E13 [get_ports SDI2A_REFCLK_N]
set_property PACKAGE_PIN F13 [get_ports SDI2A_REFCLK_P]
set_property PACKAGE_PIN AB13 [get_ports GTP2_REFCLK_N]
set_property PACKAGE_PIN AA13 [get_ports GTP2_REFCLK_P]


set_property PACKAGE_PIN H21 [get_ports AUDIO_REFCLK_P]


create_clock -period 37.000 -name clk27m -waveform {0.000 18.500} [get_nets -hierarchical *clk27*]

set_property IOSTANDARD LVCMOS33 [get_ports CH1_SLEEP]
set_property IOSTANDARD LVCMOS18 [get_ports XAUI_LS_OK_IN_A]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports FPGA_REFCLK_N]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports FPGA_REFCLK_P]
set_property IOSTANDARD LVCMOS18 [get_ports XAUI_PDTRXA_N]
set_property IOSTANDARD LVCMOS18 [get_ports XAUI_PRBSEN]
set_property IOSTANDARD LVCMOS18 [get_ports XAUI_ST]
set_property IOSTANDARD LVCMOS18 [get_ports XAUI_MODE_SEL]
set_property IOSTANDARD LVCMOS18 [get_ports {XAUI_PRTAD[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {XAUI_PRTAD[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {XAUI_PRTAD[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {XAUI_PRTAD[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {XAUI_PRTAD[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports XAUI_RST_N]
set_property IOSTANDARD LVCMOS18 [get_ports XAUI_MDIO]
set_property IOSTANDARD LVCMOS18 [get_ports XAUI_MDC]
set_property DRIVE 16 [get_ports XAUI_MDC]
set_property DRIVE 16 [get_ports XAUI_MDIO]
set_property SLEW FAST [get_ports XAUI_MDC]
set_property SLEW FAST [get_ports XAUI_MDIO]

set_property IOSTANDARD LVCMOS18 [get_ports {XAUI_GPIO[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {XAUI_GPIO[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {XAUI_GPIO[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports XAUI_LOSA]
set_property IOSTANDARD LVCMOS18 [get_ports XAUI_LS_OK_OUT_A]
set_property IOSTANDARD LVCMOS18 [get_ports XAUI_PRBS_PASS]
set_property IOSTANDARD LVCMOS33 [get_ports {FLASH_D[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FLASH_D[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FLASH_D[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FLASH_D[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports uC_SDA]
set_property IOSTANDARD LVCMOS33 [get_ports uC_SCL]
set_property IOSTANDARD LVCMOS33 [get_ports PWM1]
set_property IOSTANDARD LVCMOS33 [get_ports FLASH_FCS_B]
set_property IOSTANDARD LVCMOS33 [get_ports RESETn]
set_property IOSTANDARD LVCMOS33 [get_ports uC_SPICSn]
set_property IOSTANDARD LVCMOS33 [get_ports uC_SPISCK]
set_property IOSTANDARD LVCMOS33 [get_ports uC_MOSI]
set_property IOSTANDARD LVCMOS33 [get_ports uC_MISO]
set_property IOSTANDARD LVCMOS33 [get_ports uC_RXD2]
set_property IOSTANDARD LVCMOS33 [get_ports uC_TXD2]
set_property IOSTANDARD LVCMOS33 [get_ports RMII_RXCLK]
set_property IOSTANDARD LVCMOS33 [get_ports uC_TXD]
set_property IOSTANDARD LVCMOS33 [get_ports uC_RXD]
set_property IOSTANDARD LVCMOS33 [get_ports RMII_TXCLK]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports ETH_25M]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports AUDIO_REFCLK_P]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_A[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports EMIF_NWE]
set_property IOSTANDARD LVCMOS33 [get_ports EMIF_NRD]
set_property IOSTANDARD LVCMOS33 [get_ports EMIF_NWAIT]
set_property IOSTANDARD LVCMOS33 [get_ports EMIF_CS0]
set_property IOSTANDARD LVCMOS33 [get_ports EMIF_CS1]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_D[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_D[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_D[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_D[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_D[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_D[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_D[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EMIF_D[7]}]
set_property IOSTANDARD SSTL15 [get_ports DM0]
set_property IOSTANDARD SSTL15 [get_ports {DQ[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[1]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[2]}]
set_property IOSTANDARD SSTL15 [get_ports DQS0_N]
set_property IOSTANDARD SSTL15 [get_ports {DQ[3]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[4]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[5]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[6]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[7]}]
set_property IOSTANDARD SSTL15 [get_ports DM1]
set_property IOSTANDARD SSTL15 [get_ports {DQ[8]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[9]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[10]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[11]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[12]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[13]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[14]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[15]}]
set_property IOSTANDARD SSTL15 [get_ports DDR3_RST_N]
set_property IOSTANDARD SSTL15 [get_ports {DQ[16]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[17]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[18]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[19]}]
set_property IOSTANDARD SSTL15 [get_ports DQS2_P]
set_property IOSTANDARD SSTL15 [get_ports DM2]
set_property IOSTANDARD SSTL15 [get_ports {DQ[20]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[21]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[22]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[23]}]
set_property IOSTANDARD SSTL15 [get_ports DM3]
set_property IOSTANDARD SSTL15 [get_ports {DQ[24]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[25]}]
set_property IOSTANDARD SSTL15 [get_ports DQS3_P]
set_property IOSTANDARD SSTL15 [get_ports {DQ[26]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[27]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[28]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[29]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[30]}]
set_property IOSTANDARD SSTL15 [get_ports {DQ[31]}]
set_property IOSTANDARD LVCMOS15 [get_ports {A[14]}]
set_property IOSTANDARD LVCMOS15 [get_ports {A[12]}]
set_property IOSTANDARD LVCMOS15 [get_ports {A[13]}]
set_property IOSTANDARD LVCMOS15 [get_ports {A[11]}]
set_property IOSTANDARD LVCMOS15 [get_ports CK_N]
set_property IOSTANDARD LVCMOS15 [get_ports {A[9]}]
set_property IOSTANDARD LVCMOS15 [get_ports CK_P]
set_property IOSTANDARD LVCMOS15 [get_ports {A[5]}]
set_property IOSTANDARD LVCMOS15 [get_ports {A[10]}]
set_property IOSTANDARD LVCMOS15 [get_ports {A[4]}]
set_property IOSTANDARD LVCMOS15 [get_ports {A[8]}]
set_property IOSTANDARD LVCMOS15 [get_ports {A[6]}]
set_property IOSTANDARD LVCMOS15 [get_ports {A[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports {A[7]}]
set_property IOSTANDARD LVCMOS15 [get_ports {A[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {A[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {BA[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {A[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {BA[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports CAS_N]
set_property IOSTANDARD LVCMOS15 [get_ports {BA[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports CS_N]
set_property IOSTANDARD LVCMOS15 [get_ports WE_N]
set_property IOSTANDARD LVCMOS15 [get_ports RAS_N]
set_property IOSTANDARD LVCMOS15 [get_ports ODT]
set_property IOSTANDARD LVCMOS15 [get_ports CKE]
set_property IOSTANDARD LVDS_25 [get_ports CLK27MHZ_REFCLK_N]
set_property IOSTANDARD LVDS_25 [get_ports CLK27MHZ_REFCLK_P]
set_property IOSTANDARD LVCMOS33 [get_ports {RX_SELECT[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RX_SELECT[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FOUT[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports NO_REF1]
set_property IOSTANDARD LVCMOS33 [get_ports NO_ALIGN1]
set_property IOSTANDARD LVCMOS33 [get_ports NO_LOCK1]
set_property IOSTANDARD LVCMOS33 [get_ports {FOUT[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FOUT[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FOUT[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports UART1_RXD]
set_property IOSTANDARD LVCMOS33 [get_ports UART1_TXD]
set_property IOSTANDARD LVCMOS33 [get_ports CH1_CARRIER_DETECT]
set_property IOSTANDARD LVCMOS33 [get_ports CH1_GAIN_SEL]
set_property IOSTANDARD LVCMOS33 [get_ports CH1_DISn]
set_property IOSTANDARD LVCMOS33 [get_ports CH1_SD_HDn]
set_property IOSTANDARD LVCMOS33 [get_ports CH1_EQ_ENn]
set_property IOSTANDARD LVCMOS33 [get_ports SW_GPIOB1]
set_property IOSTANDARD LVCMOS33 [get_ports SW_GPIOB2]
set_property IOSTANDARD LVCMOS33 [get_ports SW_GPIOB3]
set_property IOSTANDARD LVCMOS33 [get_ports LED_ACT]
set_property IOSTANDARD LVCMOS33 [get_ports LED_SDI]
set_property IOSTANDARD LVCMOS33 [get_ports LED_LINK]
set_property IOSTANDARD LVCMOS33 [get_ports LED_POWER]
set_property IOSTANDARD LVCMOS33 [get_ports {RMII_TXD[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RMII_TXD[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RMII_TXD[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports SFP_FAULT]
set_property IOSTANDARD LVCMOS33 [get_ports ETH_RSTN]
set_property IOSTANDARD LVCMOS33 [get_ports RMII_RXCTL]
set_property IOSTANDARD LVCMOS33 [get_ports {RMII_RXD[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RMII_RXD[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RMII_RXD[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RMII_RXD[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports RMII_COL]
set_property IOSTANDARD LVCMOS33 [get_ports RMII_CRS]
set_property IOSTANDARD LVCMOS33 [get_ports RMII_TXCTL]
set_property IOSTANDARD LVCMOS33 [get_ports {RMII_TXD[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports SFP_RX_LOS]
set_property IOSTANDARD LVCMOS33 [get_ports SFP_RS1]
set_property IOSTANDARD LVCMOS33 [get_ports SFP_RS0]
set_property IOSTANDARD LVCMOS33 [get_ports SFP_ABS]
set_property IOSTANDARD LVCMOS33 [get_ports SFP_DIS]
set_property IOSTANDARD LVCMOS33 [get_ports AUDIO_REFCLK_N]


set_property IOSTANDARD SSTL15 [get_ports DQS2_N]
set_property IOSTANDARD SSTL15 [get_ports DQS1_P]
set_property IOSTANDARD SSTL15 [get_ports DQS1_N]
set_property IOSTANDARD SSTL15 [get_ports DQS3_N]

set_property PACKAGE_PIN K21 [get_ports CLK27MHZ_REFCLK_N]

set_property PACKAGE_PIN AD12 [get_ports XAUI_IN0_N]
set_property PACKAGE_PIN AC12 [get_ports XAUI_IN0_P]
set_property PACKAGE_PIN AD10 [get_ports XAUI_OUT0_N]
set_property PACKAGE_PIN AC10 [get_ports XAUI_OUT0_P]
set_property PACKAGE_PIN AF13 [get_ports XAUI_IN1_N]
set_property PACKAGE_PIN AE13 [get_ports XAUI_IN1_P]
set_property PACKAGE_PIN AF9 [get_ports XAUI_OUT1_N]
set_property PACKAGE_PIN AE9 [get_ports XAUI_OUT1_P]
set_property PACKAGE_PIN AD14 [get_ports XAUI_IN2_N]
set_property PACKAGE_PIN AC14 [get_ports XAUI_IN2_P]
set_property PACKAGE_PIN AD8 [get_ports XAUI_OUT2_N]
set_property PACKAGE_PIN AC8 [get_ports XAUI_OUT2_P]
set_property PACKAGE_PIN AF11 [get_ports XAUI_IN3_N]
set_property PACKAGE_PIN AE11 [get_ports XAUI_IN3_P]
set_property PACKAGE_PIN AF7 [get_ports XAUI_OUT3_N]
set_property PACKAGE_PIN AE7 [get_ports XAUI_OUT3_P]

set_property PACKAGE_PIN B11 [get_ports CH1_SDIi_N]
set_property PACKAGE_PIN H22 [get_ports AUDIO_REFCLK_N]

set_property PULLUP true [get_ports uC_SPICSn]
set_property PULLUP true [get_ports uC_MOSI]

## not used FLASH_CLK. This pin is connected in primitive of STARTUPE2
# added for SPI Flash 
# set_property PACKAGE_PIN H13 [get_ports FLASH_CLK]
# set_property IOSTANDARD LVCMOS33 [get_ports FLASH_CLK]

# set_max_delay -from uC_cs_n -to flash_cs_n 12.000
# set_max_delay -from uC_clk   -to flash_clk  12.00
# set_max_delay -from uC_mosi -to flash_mosi 12.000
# set_max_delay -from flash_miso -to uC_miso 12.000
