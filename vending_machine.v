`timescale 1ns / 1ps

module vending_machine(
    input clk,
    input reset_n,
    input [3:0] moneyin,       // 동전 입력 (1000[3], 500[2], 200[1], 100[0])
    input [3:0] buy,       // 음료 구매 버튼 (900[3], 700[2], 500[1], 300[0])
    input refund,          // 반환 버튼
    output [6:0] seg_1000,    // 7-segment: 1000자리
    output [6:0] seg_100,    // 7-segment: 100자리
    output [6:0] seg_10,    // 7-segment: 10자리
    output [6:0] seg_1, // 7-segment: 1자리
    output refund_led, //반환 확인용 led
    output [3:0] buy_available_led, // 구매 가능한 물건 표시 led (900[3], 700[2], 500[1], 300[0])
    output moneyin_led, //돈 투입 성공 led
    output buy_success_led, //음료수 판매 성공 led
    output buy_fail_led //음료수 판매 실패 led
    );
    
    wire tA,tB,tC,tD;
    wire qA, qA_, qB, qB_, qC, qC_, qD, qD_;
    //7 segment 처리용 wire
    wire is_1010;
    wire [3:0] digit_1000;
    wire [3:0] state;
    
    ////-----------------------------output settings------------------------------------------------------------------------------------------------
    assign is_1010 = qA & qB_ & qC & qD_;
    assign digit_1000 = {3'b000, is_1010};
    assign state = {qA, qB, qC, qD};
    decoder dec0 (.hex(digit_1000), .seg(seg_1000));
    decoder dec1 (.hex(state), .seg(seg_100));
    decoder dec2 (.hex(4'h0), .seg(seg_10));
    decoder dec3 (.hex(4'h0), .seg(seg_1));
    
    assign buy_available_led = {qA&qB_&qC_&qD, qA_&qB&qC&qD, qA_&qB&qC_&qD, qA_&qB_&qC&qD}; //gfdfd
    
    
    //돈 투입 성공 출력
    assign moneyin_led = (
    qA_&qB_&qC_&qD_&(moneyin[0] | moneyin[1] | moneyin[2] | moneyin[3])| //0
    qA_&qB_&qC_&qD &(moneyin[0] | moneyin[1] | moneyin[2])| //100
    qA_&qB_&qC &qD_&(moneyin[0] | moneyin[1] | moneyin[2])| //200
    qA_&qB_&qC &qD &(moneyin[0] | moneyin[1] | moneyin[2])| //300
    qA_&qB &qC_&qD_&(moneyin[0] | moneyin[1] | moneyin[2])| //400
    qA_&qB &qC_&qD &(moneyin[0] | moneyin[1] | moneyin[2])| //500
    qA_&qB &qC &qD_&(moneyin[0] | moneyin[1])| //600
    qA_&qB &qC &qD &(moneyin[0] | moneyin[1])| //700
    qA &qB_&qC_&qD_&(moneyin[0] | moneyin[1])| //800
    qA &qB_&qC_&qD &(moneyin[0])| //900
    qA &qB_&qC &qD_&(1'b0) //1000
    );
    
    //반환 출력
    assign refund_led = refund|(
    qA_&qB_&qC_&qD_&(1'b0)| //0
    qA_&qB_&qC_&qD &(moneyin[3])| //100
    qA_&qB_&qC &qD_&(moneyin[3])| //200
    qA_&qB_&qC &qD &(moneyin[3])| //300
    qA_&qB &qC_&qD_&(moneyin[3])| //400
    qA_&qB &qC_&qD &(moneyin[3])| //500
    qA_&qB &qC &qD_&(moneyin[2] | moneyin[3])| //600
    qA_&qB &qC &qD &(moneyin[2] | moneyin[3])| //700
    qA &qB_&qC_&qD_&(moneyin[2] | moneyin[3])| //800
    qA &qB_&qC_&qD &(moneyin[1] | moneyin[2] | moneyin[3])| //900
    qA &qB_&qC &qD_&(moneyin[0] | moneyin[1] | moneyin[2] | moneyin[3]) //1000
    );
    
    //음료수 판매 성공 출력
    assign buy_success_led = (
    qA_&qB_&qC_&qD_&(1'b0)| //0
    qA_&qB_&qC_&qD &(1'b0)| //100
    qA_&qB_&qC &qD_&(1'b0)| //200
    qA_&qB_&qC &qD &(buy[0])| //300
    qA_&qB &qC_&qD_&(buy[0])| //400
    qA_&qB &qC_&qD &(buy[0] | buy[1])| //500
    qA_&qB &qC &qD_&(buy[0] | buy[1])| //600
    qA_&qB &qC &qD &(buy[0] | buy[1] | buy[2])| //700
    qA &qB_&qC_&qD_&(buy[0] | buy[1] | buy[2])| //800
    qA &qB_&qC_&qD &(buy[0] | buy[1] | buy[2] | buy[3])| //900
    qA &qB_&qC &qD_&(buy[0] | buy[1] | buy[2] | buy[3]) //1000
    );
    
    //음료수 판매 실패 출력
    assign buy_fail_led = (
    qA_&qB_&qC_&qD_&(buy[0] | buy[1] | buy[2] | buy[3])| //0
    qA_&qB_&qC_&qD &(buy[0] | buy[1] | buy[2] | buy[3])| //100
    qA_&qB_&qC &qD_&(buy[0] | buy[1] | buy[2] | buy[3])| //200
    qA_&qB_&qC &qD &(buy[1] | buy[2] | buy[3])| //300
    qA_&qB &qC_&qD_&(buy[1] | buy[2] | buy[3])| //400
    qA_&qB &qC_&qD &(buy[2] | buy[3])| //500
    qA_&qB &qC &qD_&(buy[2] | buy[3])| //600
    qA_&qB &qC &qD &(buy[3])| //700
    qA &qB_&qC_&qD_&(buy[3])| //800
    qA &qB_&qC_&qD &(1'b0)| //900
    qA &qB_&qC &qD_&(1'b0) //1000
    );

    //-----------------------------flip-flop settings------------------------------------------------------------------------------------------------
    
    //A의 T flip-flop 입력
    assign tA = (
    qA_&qB_&qC_&qD_&(moneyin[3])|
    qA_&qB_&qC_&qD &(1'b0)|
    qA_&qB_&qC &qD_&(1'b0)|
    qA_&qB_&qC &qD &(moneyin[2])|
    qA_&qB &qC_&qD_&(moneyin[2])|
    qA_&qB &qC_&qD &(moneyin[2])|
    qA_&qB &qC &qD_&(moneyin[1])|
    qA_&qB &qC &qD &(moneyin[1] | moneyin[0])|
    qA &qB_&qC_&qD_&(refund | moneyin[3] | moneyin[2] | buy[2] | buy[1] | buy[0])|
    qA &qB_&qC_&qD &(refund | moneyin[3] | moneyin[2] | moneyin[1] | buy[3] | buy[2] | buy[1] | buy[0])|
    qA &qB_&qC &qD_&(refund | moneyin[3] | moneyin[2] | moneyin[1] | moneyin[0] | buy[3] | buy[2] | buy[1] | buy[0])
    );
   
    
    //B의 T flip-flop 입력
    assign tB = (
    qA_&qB_&qC_&qD_&(moneyin[2])|
    qA_&qB_&qC_&qD &(moneyin[2])|
    qA_&qB_&qC &qD_&(moneyin[2] | moneyin[1])|
    qA_&qB_&qC &qD &(moneyin[1] | moneyin[0])|
    qA_&qB &qC_&qD_&(refund | moneyin[3] | moneyin[2] | buy[0])|
    qA_&qB &qC_&qD &(refund | moneyin[3] | moneyin[2] | buy[1] | buy[0])|
    qA_&qB &qC &qD_&(refund | moneyin[3] | moneyin[2] | moneyin[1] | buy[1] | buy[0])|
    qA_&qB &qC &qD &(refund | moneyin[3] | moneyin[2] | moneyin[1] | moneyin[0] | buy[2] | buy[1])|
    qA &qB_&qC_&qD_&(buy[0])|
    qA &qB_&qC_&qD &(buy[1] | buy[0])|
    qA &qB_&qC &qD_&(buy[1] | buy[0])
    );


    //C의 T flip-flop 입력
    assign tC = (
    qA_&qB_&qC_&qD_&(moneyin[3] | moneyin[1])|
    qA_&qB_&qC_&qD &(moneyin[2] | moneyin[1] | moneyin[0])|
    qA_&qB_&qC &qD_&(refund | moneyin[3] | moneyin[1])|
    qA_&qB_&qC &qD &(refund | moneyin[3] | moneyin[2] | moneyin[1] | moneyin[0] | buy[0])|
    qA_&qB &qC_&qD_&(moneyin[1])|
    qA_&qB &qC_&qD &(moneyin[2] | moneyin[1] | moneyin[0] | buy[0])|
    qA_&qB &qC &qD_&(refund | moneyin[3] | moneyin[2] | moneyin[1] | buy[1])|
    qA_&qB &qC &qD &(refund | moneyin[3] | moneyin[2] | moneyin[1] | moneyin[0] | buy[2] | buy[0])|
    qA &qB_&qC_&qD_&(moneyin[1] | buy[1])|
    qA &qB_&qC_&qD &(moneyin[0] | buy[2] | buy[0])|
    qA &qB_&qC &qD_&(refund | moneyin[3] | moneyin[2] | moneyin[1] | moneyin[0] | buy[3] | buy[1])
    );
    
    
    //D의 T flip-flop 입력
    assign tD = (
    qA_&qB_&qC_&qD_&()|
    qA_&qB_&qC_&qD &(refund)|
    qA_&qB_&qC &qD_&()|
    qA_&qB_&qC &qD &(refund)|
    qA_&qB &qC_&qD_&()|
    qA_&qB &qC_&qD &(refund)|
    qA_&qB &qC &qD_&()|
    qA_&qB &qC &qD &(refund)|
    qA &qB_&qC_&qD_&()|
    qA &qB_&qC_&qD &(refund)|
    qA &qB_&qC &qD_&()
    );
    
    
    //T FF settings
   edge_trigger_T_FF ffA (
        .reset_n(reset_n),
        .t(tA),
        .clk(clk),
        .q(qA),
        .q_(qA_)
    );
    
    edge_trigger_T_FF ffB (
        .reset_n(reset_n),
        .t(tB),
        .clk(clk),
        .q(qB),
        .q_(qB_)
    );
    
    edge_trigger_T_FF ffC (
        .reset_n(reset_n),
        .t(tC),
        .clk(clk),
        .q(qC),
        .q_(qC_)
    );
    
    edge_trigger_T_FF ffD (
        .reset_n(reset_n),
        .t(tD),
        .clk(clk),
        .q(qD),
        .q_(qD_)
    );
    
endmodule
