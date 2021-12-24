echo "开始编译"
iverilog -o wave ./clkgen.v test_tb.v siggen.v pwm.v main.v
echo "编译完成"

echo "生成波形文件"
vvp -n wave -lxt2 
cp wave.vcd wave.lxt

echo "打开波形文件"
open -a gtkwave wave.vcd