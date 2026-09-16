
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	29813103          	ld	sp,664(sp) # 8000a298 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	042000ef          	jal	80000058 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000024:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | MENVCFG_STCE);
    80000028:	577d                	li	a4,-1
    8000002a:	177e                	slli	a4,a4,0x3f
    8000002c:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002e:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000032:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000036:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    8000003a:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003e:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000042:	000f4737          	lui	a4,0xf4
    80000046:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000004a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004c:	14d79073          	csrw	stimecmp,a5
}
    80000050:	60a2                	ld	ra,8(sp)
    80000052:	6402                	ld	s0,0(sp)
    80000054:	0141                	addi	sp,sp,16
    80000056:	8082                	ret

0000000080000058 <start>:
{
    80000058:	1141                	addi	sp,sp,-16
    8000005a:	e406                	sd	ra,8(sp)
    8000005c:	e022                	sd	s0,0(sp)
    8000005e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    80000060:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000064:	7779                	lui	a4,0xffffe
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb1ff>
    8000006a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000006c:	6705                	lui	a4,0x1
    8000006e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000072:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000074:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000078:	00001797          	auipc	a5,0x1
    8000007c:	de678793          	addi	a5,a5,-538 # 80000e5e <main>
    80000080:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000084:	4781                	li	a5,0
    80000086:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    8000008a:	67c1                	lui	a5,0x10
    8000008c:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008e:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    80000092:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000096:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    8000009a:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009e:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000a2:	57fd                	li	a5,-1
    800000a4:	83a9                	srli	a5,a5,0xa
    800000a6:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000aa:	47bd                	li	a5,15
    800000ac:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    800000b0:	30a027f3          	csrr	a5,0x30a
  w_menvcfg(r_menvcfg() | MENVCFG_ADUE);
    800000b4:	4705                	li	a4,1
    800000b6:	1776                	slli	a4,a4,0x3d
    800000b8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    800000ba:	30a79073          	csrw	0x30a,a5
  timerinit();
    800000be:	f5fff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000c2:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c6:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000c8:	823e                	mv	tp,a5
  asm volatile("mret");
    800000ca:	30200073          	mret
}
    800000ce:	60a2                	ld	ra,8(sp)
    800000d0:	6402                	ld	s0,0(sp)
    800000d2:	0141                	addi	sp,sp,16
    800000d4:	8082                	ret

00000000800000d6 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d6:	7119                	addi	sp,sp,-128
    800000d8:	fc86                	sd	ra,120(sp)
    800000da:	f8a2                	sd	s0,112(sp)
    800000dc:	f4a6                	sd	s1,104(sp)
    800000de:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000e0:	06c05b63          	blez	a2,80000156 <consolewrite+0x80>
    800000e4:	f0ca                	sd	s2,96(sp)
    800000e6:	ecce                	sd	s3,88(sp)
    800000e8:	e8d2                	sd	s4,80(sp)
    800000ea:	e4d6                	sd	s5,72(sp)
    800000ec:	e0da                	sd	s6,64(sp)
    800000ee:	fc5e                	sd	s7,56(sp)
    800000f0:	f862                	sd	s8,48(sp)
    800000f2:	f466                	sd	s9,40(sp)
    800000f4:	f06a                	sd	s10,32(sp)
    800000f6:	8b2a                	mv	s6,a0
    800000f8:	8bae                	mv	s7,a1
    800000fa:	8a32                	mv	s4,a2
  int i = 0;
    800000fc:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000fe:	02000c93          	li	s9,32
    80000102:	02000d13          	li	s10,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000106:	f8040a93          	addi	s5,s0,-128
    8000010a:	5c7d                	li	s8,-1
    8000010c:	a025                	j	80000134 <consolewrite+0x5e>
    if (nn > n - i)
    8000010e:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000112:	86ce                	mv	a3,s3
    80000114:	01748633          	add	a2,s1,s7
    80000118:	85da                	mv	a1,s6
    8000011a:	8556                	mv	a0,s5
    8000011c:	1de020ef          	jal	800022fa <either_copyin>
    80000120:	03850d63          	beq	a0,s8,8000015a <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000124:	85ce                	mv	a1,s3
    80000126:	8556                	mv	a0,s5
    80000128:	7c2000ef          	jal	800008ea <uartwrite>
    i += nn;
    8000012c:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    80000130:	0144d963          	bge	s1,s4,80000142 <consolewrite+0x6c>
    if (nn > n - i)
    80000134:	409a07bb          	subw	a5,s4,s1
    80000138:	893e                	mv	s2,a5
    8000013a:	fcfcdae3          	bge	s9,a5,8000010e <consolewrite+0x38>
    8000013e:	896a                	mv	s2,s10
    80000140:	b7f9                	j	8000010e <consolewrite+0x38>
    80000142:	7906                	ld	s2,96(sp)
    80000144:	69e6                	ld	s3,88(sp)
    80000146:	6a46                	ld	s4,80(sp)
    80000148:	6aa6                	ld	s5,72(sp)
    8000014a:	6b06                	ld	s6,64(sp)
    8000014c:	7be2                	ld	s7,56(sp)
    8000014e:	7c42                	ld	s8,48(sp)
    80000150:	7ca2                	ld	s9,40(sp)
    80000152:	7d02                	ld	s10,32(sp)
    80000154:	a821                	j	8000016c <consolewrite+0x96>
  int i = 0;
    80000156:	4481                	li	s1,0
    80000158:	a811                	j	8000016c <consolewrite+0x96>
    8000015a:	7906                	ld	s2,96(sp)
    8000015c:	69e6                	ld	s3,88(sp)
    8000015e:	6a46                	ld	s4,80(sp)
    80000160:	6aa6                	ld	s5,72(sp)
    80000162:	6b06                	ld	s6,64(sp)
    80000164:	7be2                	ld	s7,56(sp)
    80000166:	7c42                	ld	s8,48(sp)
    80000168:	7ca2                	ld	s9,40(sp)
    8000016a:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016c:	8526                	mv	a0,s1
    8000016e:	70e6                	ld	ra,120(sp)
    80000170:	7446                	ld	s0,112(sp)
    80000172:	74a6                	ld	s1,104(sp)
    80000174:	6109                	addi	sp,sp,128
    80000176:	8082                	ret

0000000080000178 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000178:	711d                	addi	sp,sp,-96
    8000017a:	ec86                	sd	ra,88(sp)
    8000017c:	e8a2                	sd	s0,80(sp)
    8000017e:	e4a6                	sd	s1,72(sp)
    80000180:	e0ca                	sd	s2,64(sp)
    80000182:	fc4e                	sd	s3,56(sp)
    80000184:	f852                	sd	s4,48(sp)
    80000186:	f05a                	sd	s6,32(sp)
    80000188:	ec5e                	sd	s7,24(sp)
    8000018a:	1080                	addi	s0,sp,96
    8000018c:	8b2a                	mv	s6,a0
    8000018e:	8a2e                	mv	s4,a1
    80000190:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000194:	00012517          	auipc	a0,0x12
    80000198:	14c50513          	addi	a0,a0,332 # 800122e0 <cons>
    8000019c:	24d000ef          	jal	80000be8 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	14048493          	addi	s1,s1,320 # 800122e0 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	1d090913          	addi	s2,s2,464 # 80012378 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	748010ef          	jal	80001908 <myproc>
    800001c4:	7b7010ef          	jal	8000217a <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	557010ef          	jal	80001f22 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	29f000ef          	jal	80000c70 <release>
      sleep();
    800001d6:	589010ef          	jal	80001f5e <sleep>
      acquire(&cons.lock);
    800001da:	8526                	mv	a0,s1
    800001dc:	20d000ef          	jal	80000be8 <acquire>
    while (cons.r == cons.w) {
    800001e0:	0984a783          	lw	a5,152(s1)
    800001e4:	09c4a703          	lw	a4,156(s1)
    800001e8:	fcf70ce3          	beq	a4,a5,800001c0 <consoleread+0x48>
    800001ec:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ee:	00012717          	auipc	a4,0x12
    800001f2:	0f270713          	addi	a4,a4,242 # 800122e0 <cons>
    800001f6:	0017869b          	addiw	a3,a5,1
    800001fa:	08d72c23          	sw	a3,152(a4)
    800001fe:	07f7f693          	andi	a3,a5,127
    80000202:	9736                	add	a4,a4,a3
    80000204:	01874703          	lbu	a4,24(a4)
    80000208:	00070a9b          	sext.w	s5,a4

    if (c == C('D')) { // end-of-file
    8000020c:	4691                	li	a3,4
    8000020e:	04da8663          	beq	s5,a3,8000025a <consoleread+0xe2>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000212:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000216:	4685                	li	a3,1
    80000218:	faf40613          	addi	a2,s0,-81
    8000021c:	85d2                	mv	a1,s4
    8000021e:	855a                	mv	a0,s6
    80000220:	08e020ef          	jal	800022ae <either_copyout>
    80000224:	57fd                	li	a5,-1
    80000226:	04f50663          	beq	a0,a5,80000272 <consoleread+0xfa>
      break;

    dst++;
    8000022a:	0a05                	addi	s4,s4,1
    --n;
    8000022c:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    8000022e:	47a9                	li	a5,10
    80000230:	04fa8b63          	beq	s5,a5,80000286 <consoleread+0x10e>
    80000234:	7aa2                	ld	s5,40(sp)
    80000236:	bfad                	j	800001b0 <consoleread+0x38>
        release(&cons.lock);
    80000238:	00012517          	auipc	a0,0x12
    8000023c:	0a850513          	addi	a0,a0,168 # 800122e0 <cons>
    80000240:	231000ef          	jal	80000c70 <release>
        return -1;
    80000244:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000246:	60e6                	ld	ra,88(sp)
    80000248:	6446                	ld	s0,80(sp)
    8000024a:	64a6                	ld	s1,72(sp)
    8000024c:	6906                	ld	s2,64(sp)
    8000024e:	79e2                	ld	s3,56(sp)
    80000250:	7a42                	ld	s4,48(sp)
    80000252:	7b02                	ld	s6,32(sp)
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	6125                	addi	sp,sp,96
    80000258:	8082                	ret
      if (n < target) {
    8000025a:	0179fa63          	bgeu	s3,s7,8000026e <consoleread+0xf6>
        cons.r--;
    8000025e:	00012717          	auipc	a4,0x12
    80000262:	10f72d23          	sw	a5,282(a4) # 80012378 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	06c50513          	addi	a0,a0,108 # 800122e0 <cons>
    8000027c:	1f5000ef          	jal	80000c70 <release>
  return target - n;
    80000280:	413b853b          	subw	a0,s7,s3
    80000284:	b7c9                	j	80000246 <consoleread+0xce>
    80000286:	7aa2                	ld	s5,40(sp)
    80000288:	b7f5                	j	80000274 <consoleread+0xfc>

000000008000028a <consputc>:
{
    8000028a:	1141                	addi	sp,sp,-16
    8000028c:	e406                	sd	ra,8(sp)
    8000028e:	e022                	sd	s0,0(sp)
    80000290:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000292:	10000793          	li	a5,256
    80000296:	00f50863          	beq	a0,a5,800002a6 <consputc+0x1c>
    uartputc_sync(c);
    8000029a:	6d6000ef          	jal	80000970 <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	6c8000ef          	jal	80000970 <uartputc_sync>
    uartputc_sync(' ');
    800002ac:	02000513          	li	a0,32
    800002b0:	6c0000ef          	jal	80000970 <uartputc_sync>
    uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	6ba000ef          	jal	80000970 <uartputc_sync>
    800002ba:	b7d5                	j	8000029e <consputc+0x14>

00000000800002bc <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002bc:	1101                	addi	sp,sp,-32
    800002be:	ec06                	sd	ra,24(sp)
    800002c0:	e822                	sd	s0,16(sp)
    800002c2:	e426                	sd	s1,8(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00012517          	auipc	a0,0x12
    800002cc:	01850513          	addi	a0,a0,24 # 800122e0 <cons>
    800002d0:	119000ef          	jal	80000be8 <acquire>

  switch (c) {
    800002d4:	47d5                	li	a5,21
    800002d6:	08f48d63          	beq	s1,a5,80000370 <consoleintr+0xb4>
    800002da:	0297c563          	blt	a5,s1,80000304 <consoleintr+0x48>
    800002de:	47a1                	li	a5,8
    800002e0:	0ef48263          	beq	s1,a5,800003c4 <consoleintr+0x108>
    800002e4:	47c1                	li	a5,16
    800002e6:	10f49363          	bne	s1,a5,800003ec <consoleintr+0x130>
  case C('P'): // Print process list.
    procdump();
    800002ea:	05c020ef          	jal	80002346 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	ff250513          	addi	a0,a0,-14 # 800122e0 <cons>
    800002f6:	17b000ef          	jal	80000c70 <release>
}
    800002fa:	60e2                	ld	ra,24(sp)
    800002fc:	6442                	ld	s0,16(sp)
    800002fe:	64a2                	ld	s1,8(sp)
    80000300:	6105                	addi	sp,sp,32
    80000302:	8082                	ret
  switch (c) {
    80000304:	07f00793          	li	a5,127
    80000308:	0af48e63          	beq	s1,a5,800003c4 <consoleintr+0x108>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    8000030c:	00012717          	auipc	a4,0x12
    80000310:	fd470713          	addi	a4,a4,-44 # 800122e0 <cons>
    80000314:	0a072783          	lw	a5,160(a4)
    80000318:	09872703          	lw	a4,152(a4)
    8000031c:	9f99                	subw	a5,a5,a4
    8000031e:	07f00713          	li	a4,127
    80000322:	fcf766e3          	bltu	a4,a5,800002ee <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000326:	47b5                	li	a5,13
    80000328:	0cf48563          	beq	s1,a5,800003f2 <consoleintr+0x136>
      consputc(c);
    8000032c:	8526                	mv	a0,s1
    8000032e:	f5dff0ef          	jal	8000028a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000332:	00012717          	auipc	a4,0x12
    80000336:	fae70713          	addi	a4,a4,-82 # 800122e0 <cons>
    8000033a:	0a072683          	lw	a3,160(a4)
    8000033e:	0016879b          	addiw	a5,a3,1
    80000342:	863e                	mv	a2,a5
    80000344:	0af72023          	sw	a5,160(a4)
    80000348:	07f6f693          	andi	a3,a3,127
    8000034c:	9736                	add	a4,a4,a3
    8000034e:	00970c23          	sb	s1,24(a4)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000352:	ff648713          	addi	a4,s1,-10
    80000356:	c371                	beqz	a4,8000041a <consoleintr+0x15e>
    80000358:	14f1                	addi	s1,s1,-4
    8000035a:	c0e1                	beqz	s1,8000041a <consoleintr+0x15e>
    8000035c:	00012717          	auipc	a4,0x12
    80000360:	01c72703          	lw	a4,28(a4) # 80012378 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	f6e70713          	addi	a4,a4,-146 # 800122e0 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	f5e48493          	addi	s1,s1,-162 # 800122e0 <cons>
    while (cons.e != cons.w &&
    8000038a:	4929                	li	s2,10
    8000038c:	02f70863          	beq	a4,a5,800003bc <consoleintr+0x100>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000390:	37fd                	addiw	a5,a5,-1
    80000392:	07f7f713          	andi	a4,a5,127
    80000396:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    80000398:	01874703          	lbu	a4,24(a4)
    8000039c:	03270263          	beq	a4,s2,800003c0 <consoleintr+0x104>
      cons.e--;
    800003a0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a4:	10000513          	li	a0,256
    800003a8:	ee3ff0ef          	jal	8000028a <consputc>
    while (cons.e != cons.w &&
    800003ac:	0a04a783          	lw	a5,160(s1)
    800003b0:	09c4a703          	lw	a4,156(s1)
    800003b4:	fcf71ee3          	bne	a4,a5,80000390 <consoleintr+0xd4>
    800003b8:	6902                	ld	s2,0(sp)
    800003ba:	bf15                	j	800002ee <consoleintr+0x32>
    800003bc:	6902                	ld	s2,0(sp)
    800003be:	bf05                	j	800002ee <consoleintr+0x32>
    800003c0:	6902                	ld	s2,0(sp)
    800003c2:	b735                	j	800002ee <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003c4:	00012717          	auipc	a4,0x12
    800003c8:	f1c70713          	addi	a4,a4,-228 # 800122e0 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	faf72323          	sw	a5,-90(a4) # 80012380 <cons+0xa0>
      consputc(BACKSPACE);
    800003e2:	10000513          	li	a0,256
    800003e6:	ea5ff0ef          	jal	8000028a <consputc>
    800003ea:	b711                	j	800002ee <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003ec:	f00481e3          	beqz	s1,800002ee <consoleintr+0x32>
    800003f0:	bf31                	j	8000030c <consoleintr+0x50>
      consputc(c);
    800003f2:	4529                	li	a0,10
    800003f4:	e97ff0ef          	jal	8000028a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003f8:	00012797          	auipc	a5,0x12
    800003fc:	ee878793          	addi	a5,a5,-280 # 800122e0 <cons>
    80000400:	0a07a703          	lw	a4,160(a5)
    80000404:	0017069b          	addiw	a3,a4,1
    80000408:	8636                	mv	a2,a3
    8000040a:	0ad7a023          	sw	a3,160(a5)
    8000040e:	07f77713          	andi	a4,a4,127
    80000412:	97ba                	add	a5,a5,a4
    80000414:	4729                	li	a4,10
    80000416:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000041a:	00012797          	auipc	a5,0x12
    8000041e:	f6c7a123          	sw	a2,-158(a5) # 8001237c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	f5650513          	addi	a0,a0,-170 # 80012378 <cons+0x98>
    8000042a:	365010ef          	jal	80001f8e <wakeup>
    8000042e:	b5c1                	j	800002ee <consoleintr+0x32>

0000000080000430 <consoleinit>:

void
consoleinit(void)
{
    80000430:	1141                	addi	sp,sp,-16
    80000432:	e406                	sd	ra,8(sp)
    80000434:	e022                	sd	s0,0(sp)
    80000436:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000438:	00007597          	auipc	a1,0x7
    8000043c:	bc858593          	addi	a1,a1,-1080 # 80007000 <etext>
    80000440:	00012517          	auipc	a0,0x12
    80000444:	ea050513          	addi	a0,a0,-352 # 800122e0 <cons>
    80000448:	720000ef          	jal	80000b68 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	01878793          	addi	a5,a5,24 # 80022468 <devsw>
    80000458:	00000717          	auipc	a4,0x0
    8000045c:	d2070713          	addi	a4,a4,-736 # 80000178 <consoleread>
    80000460:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000462:	00000717          	auipc	a4,0x0
    80000466:	c7470713          	addi	a4,a4,-908 # 800000d6 <consolewrite>
    8000046a:	ef98                	sd	a4,24(a5)
}
    8000046c:	60a2                	ld	ra,8(sp)
    8000046e:	6402                	ld	s0,0(sp)
    80000470:	0141                	addi	sp,sp,16
    80000472:	8082                	ret

0000000080000474 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000474:	7139                	addi	sp,sp,-64
    80000476:	fc06                	sd	ra,56(sp)
    80000478:	f822                	sd	s0,48(sp)
    8000047a:	f04a                	sd	s2,32(sp)
    8000047c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    8000047e:	c219                	beqz	a2,80000484 <printint+0x10>
    80000480:	08054163          	bltz	a0,80000502 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000484:	4301                	li	t1,0

  i = 0;
    80000486:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000048a:	86ca                	mv	a3,s2
  i = 0;
    8000048c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000048e:	00007817          	auipc	a6,0x7
    80000492:	2a280813          	addi	a6,a6,674 # 80007730 <digits>
    80000496:	88ba                	mv	a7,a4
    80000498:	0017061b          	addiw	a2,a4,1
    8000049c:	8732                	mv	a4,a2
    8000049e:	02b577b3          	remu	a5,a0,a1
    800004a2:	97c2                	add	a5,a5,a6
    800004a4:	0007c783          	lbu	a5,0(a5)
    800004a8:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
    800004ac:	87aa                	mv	a5,a0
    800004ae:	02b55533          	divu	a0,a0,a1
    800004b2:	0685                	addi	a3,a3,1
    800004b4:	feb7f1e3          	bgeu	a5,a1,80000496 <printint+0x22>

  if (sign)
    800004b8:	00030c63          	beqz	t1,800004d0 <printint+0x5c>
    buf[i++] = '-';
    800004bc:	fe060793          	addi	a5,a2,-32
    800004c0:	00878633          	add	a2,a5,s0
    800004c4:	02d00793          	li	a5,45
    800004c8:	fef60423          	sb	a5,-24(a2)
    800004cc:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
    800004d0:	02e05463          	blez	a4,800004f8 <printint+0x84>
    800004d4:	f426                	sd	s1,40(sp)
    800004d6:	377d                	addiw	a4,a4,-1
    800004d8:	00e904b3          	add	s1,s2,a4
    800004dc:	197d                	addi	s2,s2,-1
    800004de:	993a                	add	s2,s2,a4
    800004e0:	1702                	slli	a4,a4,0x20
    800004e2:	9301                	srli	a4,a4,0x20
    800004e4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004e8:	0004c503          	lbu	a0,0(s1)
    800004ec:	d9fff0ef          	jal	8000028a <consputc>
  while (--i >= 0)
    800004f0:	14fd                	addi	s1,s1,-1
    800004f2:	ff249be3          	bne	s1,s2,800004e8 <printint+0x74>
    800004f6:	74a2                	ld	s1,40(sp)
}
    800004f8:	70e2                	ld	ra,56(sp)
    800004fa:	7442                	ld	s0,48(sp)
    800004fc:	7902                	ld	s2,32(sp)
    800004fe:	6121                	addi	sp,sp,64
    80000500:	8082                	ret
    x = -xx;
    80000502:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    80000506:	4305                	li	t1,1
    x = -xx;
    80000508:	bfbd                	j	80000486 <printint+0x12>

000000008000050a <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    8000050a:	7131                	addi	sp,sp,-192
    8000050c:	fc86                	sd	ra,120(sp)
    8000050e:	f8a2                	sd	s0,112(sp)
    80000510:	f0ca                	sd	s2,96(sp)
    80000512:	0100                	addi	s0,sp,128
    80000514:	892a                	mv	s2,a0
    80000516:	e40c                	sd	a1,8(s0)
    80000518:	e810                	sd	a2,16(s0)
    8000051a:	ec14                	sd	a3,24(s0)
    8000051c:	f018                	sd	a4,32(s0)
    8000051e:	f41c                	sd	a5,40(s0)
    80000520:	03043823          	sd	a6,48(s0)
    80000524:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    80000528:	0000a797          	auipc	a5,0xa
    8000052c:	d8c7a783          	lw	a5,-628(a5) # 8000a2b4 <panicking>
    80000530:	cf9d                	beqz	a5,8000056e <printk+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000532:	00840793          	addi	a5,s0,8
    80000536:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    8000053a:	00094503          	lbu	a0,0(s2)
    8000053e:	22050663          	beqz	a0,8000076a <printk+0x260>
    80000542:	f4a6                	sd	s1,104(sp)
    80000544:	ecce                	sd	s3,88(sp)
    80000546:	e8d2                	sd	s4,80(sp)
    80000548:	e4d6                	sd	s5,72(sp)
    8000054a:	e0da                	sd	s6,64(sp)
    8000054c:	fc5e                	sd	s7,56(sp)
    8000054e:	f862                	sd	s8,48(sp)
    80000550:	f06a                	sd	s10,32(sp)
    80000552:	ec6e                	sd	s11,24(sp)
    80000554:	4a01                	li	s4,0
    if (cx != '%') {
    80000556:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    8000055a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    8000055e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    80000562:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000566:	4b29                	li	s6,10
    if (c0 == 'd') {
    80000568:	06400b93          	li	s7,100
    8000056c:	a015                	j	80000590 <printk+0x86>
    acquire(&pr.lock);
    8000056e:	00012517          	auipc	a0,0x12
    80000572:	e1a50513          	addi	a0,a0,-486 # 80012388 <pr>
    80000576:	672000ef          	jal	80000be8 <acquire>
    8000057a:	bf65                	j	80000532 <printk+0x28>
      consputc(cx);
    8000057c:	d0fff0ef          	jal	8000028a <consputc>
      continue;
    80000580:	84d2                	mv	s1,s4
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000582:	2485                	addiw	s1,s1,1
    80000584:	8a26                	mv	s4,s1
    80000586:	94ca                	add	s1,s1,s2
    80000588:	0004c503          	lbu	a0,0(s1)
    8000058c:	1c050663          	beqz	a0,80000758 <printk+0x24e>
    if (cx != '%') {
    80000590:	ff3516e3          	bne	a0,s3,8000057c <printk+0x72>
    i++;
    80000594:	001a079b          	addiw	a5,s4,1
    80000598:	84be                	mv	s1,a5
    c0 = fmt[i + 0] & 0xff;
    8000059a:	00f90733          	add	a4,s2,a5
    8000059e:	00074a83          	lbu	s5,0(a4)
    if (c0)
    800005a2:	200a8963          	beqz	s5,800007b4 <printk+0x2aa>
      c1 = fmt[i + 1] & 0xff;
    800005a6:	00174683          	lbu	a3,1(a4)
    if (c1)
    800005aa:	1e068c63          	beqz	a3,800007a2 <printk+0x298>
    if (c0 == 'd') {
    800005ae:	037a8863          	beq	s5,s7,800005de <printk+0xd4>
    } else if (c0 == 'l' && c1 == 'd') {
    800005b2:	f94a8713          	addi	a4,s5,-108
    800005b6:	00173713          	seqz	a4,a4
    800005ba:	f9c68613          	addi	a2,a3,-100
    800005be:	ee05                	bnez	a2,800005f6 <printk+0xec>
    800005c0:	cb1d                	beqz	a4,800005f6 <printk+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005c2:	f8843783          	ld	a5,-120(s0)
    800005c6:	00878713          	addi	a4,a5,8
    800005ca:	f8e43423          	sd	a4,-120(s0)
    800005ce:	4605                	li	a2,1
    800005d0:	85da                	mv	a1,s6
    800005d2:	6388                	ld	a0,0(a5)
    800005d4:	ea1ff0ef          	jal	80000474 <printint>
      i += 1;
    800005d8:	002a049b          	addiw	s1,s4,2
    800005dc:	b75d                	j	80000582 <printk+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005de:	f8843783          	ld	a5,-120(s0)
    800005e2:	00878713          	addi	a4,a5,8
    800005e6:	f8e43423          	sd	a4,-120(s0)
    800005ea:	4605                	li	a2,1
    800005ec:	85da                	mv	a1,s6
    800005ee:	4388                	lw	a0,0(a5)
    800005f0:	e85ff0ef          	jal	80000474 <printint>
    800005f4:	b779                	j	80000582 <printk+0x78>
      c2 = fmt[i + 2] & 0xff;
    800005f6:	97ca                	add	a5,a5,s2
    800005f8:	8636                	mv	a2,a3
    800005fa:	0027c683          	lbu	a3,2(a5)
    800005fe:	a2c9                	j	800007c0 <printk+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    80000600:	f8843783          	ld	a5,-120(s0)
    80000604:	00878713          	addi	a4,a5,8
    80000608:	f8e43423          	sd	a4,-120(s0)
    8000060c:	4605                	li	a2,1
    8000060e:	45a9                	li	a1,10
    80000610:	6388                	ld	a0,0(a5)
    80000612:	e63ff0ef          	jal	80000474 <printint>
      i += 2;
    80000616:	003a049b          	addiw	s1,s4,3
    8000061a:	b7a5                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000061c:	f8843783          	ld	a5,-120(s0)
    80000620:	00878713          	addi	a4,a5,8
    80000624:	f8e43423          	sd	a4,-120(s0)
    80000628:	4601                	li	a2,0
    8000062a:	85da                	mv	a1,s6
    8000062c:	0007e503          	lwu	a0,0(a5)
    80000630:	e45ff0ef          	jal	80000474 <printint>
    80000634:	b7b9                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000636:	f8843783          	ld	a5,-120(s0)
    8000063a:	00878713          	addi	a4,a5,8
    8000063e:	f8e43423          	sd	a4,-120(s0)
    80000642:	4601                	li	a2,0
    80000644:	85da                	mv	a1,s6
    80000646:	6388                	ld	a0,0(a5)
    80000648:	e2dff0ef          	jal	80000474 <printint>
      i += 1;
    8000064c:	002a049b          	addiw	s1,s4,2
    80000650:	bf0d                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000652:	f8843783          	ld	a5,-120(s0)
    80000656:	00878713          	addi	a4,a5,8
    8000065a:	f8e43423          	sd	a4,-120(s0)
    8000065e:	4601                	li	a2,0
    80000660:	45a9                	li	a1,10
    80000662:	6388                	ld	a0,0(a5)
    80000664:	e11ff0ef          	jal	80000474 <printint>
      i += 2;
    80000668:	003a049b          	addiw	s1,s4,3
    8000066c:	bf19                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000066e:	f8843783          	ld	a5,-120(s0)
    80000672:	00878713          	addi	a4,a5,8
    80000676:	f8e43423          	sd	a4,-120(s0)
    8000067a:	4601                	li	a2,0
    8000067c:	45c1                	li	a1,16
    8000067e:	0007e503          	lwu	a0,0(a5)
    80000682:	df3ff0ef          	jal	80000474 <printint>
    80000686:	bdf5                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000688:	f8843783          	ld	a5,-120(s0)
    8000068c:	00878713          	addi	a4,a5,8
    80000690:	f8e43423          	sd	a4,-120(s0)
    80000694:	45c1                	li	a1,16
    80000696:	6388                	ld	a0,0(a5)
    80000698:	dddff0ef          	jal	80000474 <printint>
      i += 1;
    8000069c:	002a049b          	addiw	s1,s4,2
    800006a0:	b5cd                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	4601                	li	a2,0
    800006b0:	45c1                	li	a1,16
    800006b2:	6388                	ld	a0,0(a5)
    800006b4:	dc1ff0ef          	jal	80000474 <printint>
      i += 2;
    800006b8:	003a049b          	addiw	s1,s4,3
    800006bc:	b5d9                	j	80000582 <printk+0x78>
    800006be:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006c0:	f8843783          	ld	a5,-120(s0)
    800006c4:	00878713          	addi	a4,a5,8
    800006c8:	f8e43423          	sd	a4,-120(s0)
    800006cc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006d0:	03000513          	li	a0,48
    800006d4:	bb7ff0ef          	jal	8000028a <consputc>
  consputc('x');
    800006d8:	07800513          	li	a0,120
    800006dc:	bafff0ef          	jal	8000028a <consputc>
    800006e0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006e2:	00007c97          	auipc	s9,0x7
    800006e6:	04ec8c93          	addi	s9,s9,78 # 80007730 <digits>
    800006ea:	03cad793          	srli	a5,s5,0x3c
    800006ee:	97e6                	add	a5,a5,s9
    800006f0:	0007c503          	lbu	a0,0(a5)
    800006f4:	b97ff0ef          	jal	8000028a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006f8:	0a92                	slli	s5,s5,0x4
    800006fa:	3a7d                	addiw	s4,s4,-1
    800006fc:	fe0a17e3          	bnez	s4,800006ea <printk+0x1e0>
    80000700:	7ca2                	ld	s9,40(sp)
    80000702:	b541                	j	80000582 <printk+0x78>
    } else if (c0 == 'c') {
      consputc(va_arg(ap, uint));
    80000704:	f8843783          	ld	a5,-120(s0)
    80000708:	00878713          	addi	a4,a5,8
    8000070c:	f8e43423          	sd	a4,-120(s0)
    80000710:	4388                	lw	a0,0(a5)
    80000712:	b79ff0ef          	jal	8000028a <consputc>
    80000716:	b5b5                	j	80000582 <printk+0x78>
    } else if (c0 == 's') {
      if ((s = va_arg(ap, char *)) == 0)
    80000718:	f8843783          	ld	a5,-120(s0)
    8000071c:	00878713          	addi	a4,a5,8
    80000720:	f8e43423          	sd	a4,-120(s0)
    80000724:	0007ba03          	ld	s4,0(a5)
    80000728:	000a0d63          	beqz	s4,80000742 <printk+0x238>
        s = "(null)";
      for (; *s; s++)
    8000072c:	000a4503          	lbu	a0,0(s4)
    80000730:	e40509e3          	beqz	a0,80000582 <printk+0x78>
        consputc(*s);
    80000734:	b57ff0ef          	jal	8000028a <consputc>
      for (; *s; s++)
    80000738:	0a05                	addi	s4,s4,1
    8000073a:	000a4503          	lbu	a0,0(s4)
    8000073e:	f97d                	bnez	a0,80000734 <printk+0x22a>
    80000740:	b589                	j	80000582 <printk+0x78>
        s = "(null)";
    80000742:	00007a17          	auipc	s4,0x7
    80000746:	8c6a0a13          	addi	s4,s4,-1850 # 80007008 <etext+0x8>
      for (; *s; s++)
    8000074a:	02800513          	li	a0,40
    8000074e:	b7dd                	j	80000734 <printk+0x22a>
    } else if (c0 == '%') {
      consputc('%');
    80000750:	8556                	mv	a0,s5
    80000752:	b39ff0ef          	jal	8000028a <consputc>
    80000756:	b535                	j	80000582 <printk+0x78>
    80000758:	74a6                	ld	s1,104(sp)
    8000075a:	69e6                	ld	s3,88(sp)
    8000075c:	6a46                	ld	s4,80(sp)
    8000075e:	6aa6                	ld	s5,72(sp)
    80000760:	6b06                	ld	s6,64(sp)
    80000762:	7be2                	ld	s7,56(sp)
    80000764:	7c42                	ld	s8,48(sp)
    80000766:	7d02                	ld	s10,32(sp)
    80000768:	6de2                	ld	s11,24(sp)
      consputc(c0);
    }
  }
  va_end(ap);

  if (panicking == 0)
    8000076a:	0000a797          	auipc	a5,0xa
    8000076e:	b4a7a783          	lw	a5,-1206(a5) # 8000a2b4 <panicking>
    80000772:	c38d                	beqz	a5,80000794 <printk+0x28a>
    release(&pr.lock);

  return 0;
}
    80000774:	4501                	li	a0,0
    80000776:	70e6                	ld	ra,120(sp)
    80000778:	7446                	ld	s0,112(sp)
    8000077a:	7906                	ld	s2,96(sp)
    8000077c:	6129                	addi	sp,sp,192
    8000077e:	8082                	ret
    80000780:	74a6                	ld	s1,104(sp)
    80000782:	69e6                	ld	s3,88(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	6aa6                	ld	s5,72(sp)
    80000788:	6b06                	ld	s6,64(sp)
    8000078a:	7be2                	ld	s7,56(sp)
    8000078c:	7c42                	ld	s8,48(sp)
    8000078e:	7d02                	ld	s10,32(sp)
    80000790:	6de2                	ld	s11,24(sp)
    80000792:	bfe1                	j	8000076a <printk+0x260>
    release(&pr.lock);
    80000794:	00012517          	auipc	a0,0x12
    80000798:	bf450513          	addi	a0,a0,-1036 # 80012388 <pr>
    8000079c:	4d4000ef          	jal	80000c70 <release>
  return 0;
    800007a0:	bfd1                	j	80000774 <printk+0x26a>
    if (c0 == 'd') {
    800007a2:	e37a8ee3          	beq	s5,s7,800005de <printk+0xd4>
    } else if (c0 == 'l' && c1 == 'd') {
    800007a6:	f94a8713          	addi	a4,s5,-108
    800007aa:	00173713          	seqz	a4,a4
    800007ae:	8636                	mv	a2,a3
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    800007b0:	4781                	li	a5,0
    800007b2:	a00d                	j	800007d4 <printk+0x2ca>
    } else if (c0 == 'l' && c1 == 'd') {
    800007b4:	f94a8713          	addi	a4,s5,-108
    800007b8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007bc:	8656                	mv	a2,s5
    800007be:	86d6                	mv	a3,s5
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    800007c0:	f9460793          	addi	a5,a2,-108
    800007c4:	0017b793          	seqz	a5,a5
    800007c8:	8ff9                	and	a5,a5,a4
    800007ca:	f9c68593          	addi	a1,a3,-100
    800007ce:	e199                	bnez	a1,800007d4 <printk+0x2ca>
    800007d0:	e20798e3          	bnez	a5,80000600 <printk+0xf6>
    } else if (c0 == 'u') {
    800007d4:	e58a84e3          	beq	s5,s8,8000061c <printk+0x112>
    } else if (c0 == 'l' && c1 == 'u') {
    800007d8:	f8b60593          	addi	a1,a2,-117
    800007dc:	e199                	bnez	a1,800007e2 <printk+0x2d8>
    800007de:	e4071ce3          	bnez	a4,80000636 <printk+0x12c>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    800007e2:	f8b68593          	addi	a1,a3,-117
    800007e6:	e199                	bnez	a1,800007ec <printk+0x2e2>
    800007e8:	e60795e3          	bnez	a5,80000652 <printk+0x148>
    } else if (c0 == 'x') {
    800007ec:	e9aa81e3          	beq	s5,s10,8000066e <printk+0x164>
    } else if (c0 == 'l' && c1 == 'x') {
    800007f0:	f8860613          	addi	a2,a2,-120
    800007f4:	e219                	bnez	a2,800007fa <printk+0x2f0>
    800007f6:	e80719e3          	bnez	a4,80000688 <printk+0x17e>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    800007fa:	f8868693          	addi	a3,a3,-120
    800007fe:	e299                	bnez	a3,80000804 <printk+0x2fa>
    80000800:	ea0791e3          	bnez	a5,800006a2 <printk+0x198>
    } else if (c0 == 'p') {
    80000804:	ebba8de3          	beq	s5,s11,800006be <printk+0x1b4>
    } else if (c0 == 'c') {
    80000808:	06300793          	li	a5,99
    8000080c:	eefa8ce3          	beq	s5,a5,80000704 <printk+0x1fa>
    } else if (c0 == 's') {
    80000810:	07300793          	li	a5,115
    80000814:	f0fa82e3          	beq	s5,a5,80000718 <printk+0x20e>
    } else if (c0 == '%') {
    80000818:	02500793          	li	a5,37
    8000081c:	f2fa8ae3          	beq	s5,a5,80000750 <printk+0x246>
    } else if (c0 == 0) {
    80000820:	f60a80e3          	beqz	s5,80000780 <printk+0x276>
      consputc('%');
    80000824:	02500513          	li	a0,37
    80000828:	a63ff0ef          	jal	8000028a <consputc>
      consputc(c0);
    8000082c:	8556                	mv	a0,s5
    8000082e:	a5dff0ef          	jal	8000028a <consputc>
    80000832:	bb81                	j	80000582 <printk+0x78>

0000000080000834 <panic>:

void
panic(char *s)
{
    80000834:	1101                	addi	sp,sp,-32
    80000836:	ec06                	sd	ra,24(sp)
    80000838:	e822                	sd	s0,16(sp)
    8000083a:	e426                	sd	s1,8(sp)
    8000083c:	e04a                	sd	s2,0(sp)
    8000083e:	1000                	addi	s0,sp,32
    80000840:	892a                	mv	s2,a0
  panicking = 1;
    80000842:	4485                	li	s1,1
    80000844:	0000a797          	auipc	a5,0xa
    80000848:	a697a823          	sw	s1,-1424(a5) # 8000a2b4 <panicking>
  printk("panic: ");
    8000084c:	00006517          	auipc	a0,0x6
    80000850:	7cc50513          	addi	a0,a0,1996 # 80007018 <etext+0x18>
    80000854:	cb7ff0ef          	jal	8000050a <printk>
  printk("%s\n", s);
    80000858:	85ca                	mv	a1,s2
    8000085a:	00006517          	auipc	a0,0x6
    8000085e:	7c650513          	addi	a0,a0,1990 # 80007020 <etext+0x20>
    80000862:	ca9ff0ef          	jal	8000050a <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000866:	0000a797          	auipc	a5,0xa
    8000086a:	a497a523          	sw	s1,-1462(a5) # 8000a2b0 <panicked>
  for (;;)
    8000086e:	a001                	j	8000086e <panic+0x3a>

0000000080000870 <printkinit>:
    ;
}

void
printkinit(void)
{
    80000870:	1141                	addi	sp,sp,-16
    80000872:	e406                	sd	ra,8(sp)
    80000874:	e022                	sd	s0,0(sp)
    80000876:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000878:	00006597          	auipc	a1,0x6
    8000087c:	7b058593          	addi	a1,a1,1968 # 80007028 <etext+0x28>
    80000880:	00012517          	auipc	a0,0x12
    80000884:	b0850513          	addi	a0,a0,-1272 # 80012388 <pr>
    80000888:	2e0000ef          	jal	80000b68 <initlock>
}
    8000088c:	60a2                	ld	ra,8(sp)
    8000088e:	6402                	ld	s0,0(sp)
    80000890:	0141                	addi	sp,sp,16
    80000892:	8082                	ret

0000000080000894 <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    80000894:	1141                	addi	sp,sp,-16
    80000896:	e406                	sd	ra,8(sp)
    80000898:	e022                	sd	s0,0(sp)
    8000089a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000089c:	100007b7          	lui	a5,0x10000
    800008a0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800008a4:	10000737          	lui	a4,0x10000
    800008a8:	f8000693          	li	a3,-128
    800008ac:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008b0:	468d                	li	a3,3
    800008b2:	10000637          	lui	a2,0x10000
    800008b6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008be:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008c2:	8732                	mv	a4,a2
    800008c4:	461d                	li	a2,7
    800008c6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ca:	00d780a3          	sb	a3,1(a5)

  initsleeplock(&tx_lock, "uart");
    800008ce:	00006597          	auipc	a1,0x6
    800008d2:	76258593          	addi	a1,a1,1890 # 80007030 <etext+0x30>
    800008d6:	00012517          	auipc	a0,0x12
    800008da:	aca50513          	addi	a0,a0,-1334 # 800123a0 <tx_lock>
    800008de:	6a6030ef          	jal	80003f84 <initsleeplock>
}
    800008e2:	60a2                	ld	ra,8(sp)
    800008e4:	6402                	ld	s0,0(sp)
    800008e6:	0141                	addi	sp,sp,16
    800008e8:	8082                	ret

00000000800008ea <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008ea:	7139                	addi	sp,sp,-64
    800008ec:	fc06                	sd	ra,56(sp)
    800008ee:	f822                	sd	s0,48(sp)
    800008f0:	f04a                	sd	s2,32(sp)
    800008f2:	e456                	sd	s5,8(sp)
    800008f4:	0080                	addi	s0,sp,64
    800008f6:	8aaa                	mv	s5,a0
    800008f8:	892e                	mv	s2,a1
  acquiresleep(&tx_lock);
    800008fa:	00012517          	auipc	a0,0x12
    800008fe:	aa650513          	addi	a0,a0,-1370 # 800123a0 <tx_lock>
    80000902:	6b8030ef          	jal	80003fba <acquiresleep>

  int i = 0;
  while (i < n) {
    80000906:	05205963          	blez	s2,80000958 <uartwrite+0x6e>
    8000090a:	f426                	sd	s1,40(sp)
    8000090c:	ec4e                	sd	s3,24(sp)
    8000090e:	e852                	sd	s4,16(sp)
    80000910:	e05a                	sd	s6,0(sp)
  int i = 0;
    80000912:	4481                	li	s1,0
    sleep_prepare(&tx_chan);
    80000914:	0000aa17          	auipc	s4,0xa
    80000918:	9a4a0a13          	addi	s4,s4,-1628 # 8000a2b8 <tx_chan>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    8000091c:	100009b7          	lui	s3,0x10000
    80000920:	0995                	addi	s3,s3,5 # 10000005 <_entry-0x6ffffffb>
      WriteReg(THR, buf[i]);
    80000922:	10000b37          	lui	s6,0x10000
    80000926:	a029                	j	80000930 <uartwrite+0x46>
      i += 1;
    } else {
      sleep();
    80000928:	636010ef          	jal	80001f5e <sleep>
  while (i < n) {
    8000092c:	0324d263          	bge	s1,s2,80000950 <uartwrite+0x66>
    sleep_prepare(&tx_chan);
    80000930:	8552                	mv	a0,s4
    80000932:	5f0010ef          	jal	80001f22 <sleep_prepare>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    80000936:	0009c783          	lbu	a5,0(s3)
    8000093a:	0207f793          	andi	a5,a5,32
    8000093e:	d7ed                	beqz	a5,80000928 <uartwrite+0x3e>
      WriteReg(THR, buf[i]);
    80000940:	009a87b3          	add	a5,s5,s1
    80000944:	0007c783          	lbu	a5,0(a5)
    80000948:	00fb0023          	sb	a5,0(s6) # 10000000 <_entry-0x70000000>
      i += 1;
    8000094c:	2485                	addiw	s1,s1,1
    8000094e:	bff9                	j	8000092c <uartwrite+0x42>
    80000950:	74a2                	ld	s1,40(sp)
    80000952:	69e2                	ld	s3,24(sp)
    80000954:	6a42                	ld	s4,16(sp)
    80000956:	6b02                	ld	s6,0(sp)
    }
  }

  releasesleep(&tx_lock);
    80000958:	00012517          	auipc	a0,0x12
    8000095c:	a4850513          	addi	a0,a0,-1464 # 800123a0 <tx_lock>
    80000960:	6ae030ef          	jal	8000400e <releasesleep>
}
    80000964:	70e2                	ld	ra,56(sp)
    80000966:	7442                	ld	s0,48(sp)
    80000968:	7902                	ld	s2,32(sp)
    8000096a:	6aa2                	ld	s5,8(sp)
    8000096c:	6121                	addi	sp,sp,64
    8000096e:	8082                	ret

0000000080000970 <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000970:	1101                	addi	sp,sp,-32
    80000972:	ec06                	sd	ra,24(sp)
    80000974:	e822                	sd	s0,16(sp)
    80000976:	e426                	sd	s1,8(sp)
    80000978:	1000                	addi	s0,sp,32
    8000097a:	84aa                	mv	s1,a0
  if (panicking == 0)
    8000097c:	0000a797          	auipc	a5,0xa
    80000980:	9387a783          	lw	a5,-1736(a5) # 8000a2b4 <panicking>
    80000984:	cf95                	beqz	a5,800009c0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    80000986:	0000a797          	auipc	a5,0xa
    8000098a:	92a7a783          	lw	a5,-1750(a5) # 8000a2b0 <panicked>
    8000098e:	ef85                	bnez	a5,800009c6 <uartputc_sync+0x56>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000990:	10000737          	lui	a4,0x10000
    80000994:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	00074783          	lbu	a5,0(a4)
    8000099a:	0207f793          	andi	a5,a5,32
    8000099e:	dfe5                	beqz	a5,80000996 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    800009a0:	0ff4f513          	zext.b	a0,s1
    800009a4:	100007b7          	lui	a5,0x10000
    800009a8:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    800009ac:	0000a797          	auipc	a5,0xa
    800009b0:	9087a783          	lw	a5,-1784(a5) # 8000a2b4 <panicking>
    800009b4:	cb91                	beqz	a5,800009c8 <uartputc_sync+0x58>
    pop_off();
}
    800009b6:	60e2                	ld	ra,24(sp)
    800009b8:	6442                	ld	s0,16(sp)
    800009ba:	64a2                	ld	s1,8(sp)
    800009bc:	6105                	addi	sp,sp,32
    800009be:	8082                	ret
    push_off();
    800009c0:	1ee000ef          	jal	80000bae <push_off>
    800009c4:	b7c9                	j	80000986 <uartputc_sync+0x16>
    for (;;)
    800009c6:	a001                	j	800009c6 <uartputc_sync+0x56>
    pop_off();
    800009c8:	260000ef          	jal	80000c28 <pop_off>
}
    800009cc:	b7ed                	j	800009b6 <uartputc_sync+0x46>

00000000800009ce <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009ce:	1101                	addi	sp,sp,-32
    800009d0:	ec06                	sd	ra,24(sp)
    800009d2:	e822                	sd	s0,16(sp)
    800009d4:	e426                	sd	s1,8(sp)
    800009d6:	e04a                	sd	s2,0(sp)
    800009d8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009da:	100007b7          	lui	a5,0x10000
    800009de:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  if (ReadReg(LSR) & LSR_TX_IDLE) {
    800009e2:	100007b7          	lui	a5,0x10000
    800009e6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ea:	0207f793          	andi	a5,a5,32
    800009ee:	ef99                	bnez	a5,80000a0c <uartintr+0x3e>
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009f0:	100004b7          	lui	s1,0x10000
    800009f4:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    800009f6:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009fa:	0004c783          	lbu	a5,0(s1)
    800009fe:	8b85                	andi	a5,a5,1
    80000a00:	cf89                	beqz	a5,80000a1a <uartintr+0x4c>
    return ReadReg(RHR);
    80000a02:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    80000a06:	8b7ff0ef          	jal	800002bc <consoleintr>
  while (1) {
    80000a0a:	bfc5                	j	800009fa <uartintr+0x2c>
    wakeup(&tx_chan);
    80000a0c:	0000a517          	auipc	a0,0xa
    80000a10:	8ac50513          	addi	a0,a0,-1876 # 8000a2b8 <tx_chan>
    80000a14:	57a010ef          	jal	80001f8e <wakeup>
    80000a18:	bfe1                	j	800009f0 <uartintr+0x22>
  }
}
    80000a1a:	60e2                	ld	ra,24(sp)
    80000a1c:	6442                	ld	s0,16(sp)
    80000a1e:	64a2                	ld	s1,8(sp)
    80000a20:	6902                	ld	s2,0(sp)
    80000a22:	6105                	addi	sp,sp,32
    80000a24:	8082                	ret

0000000080000a26 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a26:	1101                	addi	sp,sp,-32
    80000a28:	ec06                	sd	ra,24(sp)
    80000a2a:	e822                	sd	s0,16(sp)
    80000a2c:	e426                	sd	s1,8(sp)
    80000a2e:	e04a                	sd	s2,0(sp)
    80000a30:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a32:	00023797          	auipc	a5,0x23
    80000a36:	bce78793          	addi	a5,a5,-1074 # 80023600 <end>
    80000a3a:	00f53733          	sltu	a4,a0,a5
    80000a3e:	47c5                	li	a5,17
    80000a40:	07ee                	slli	a5,a5,0x1b
    80000a42:	17fd                	addi	a5,a5,-1
    80000a44:	00a7b7b3          	sltu	a5,a5,a0
    80000a48:	8fd9                	or	a5,a5,a4
    80000a4a:	ef95                	bnez	a5,80000a86 <kfree+0x60>
    80000a4c:	84aa                	mv	s1,a0
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	eb95                	bnez	a5,80000a86 <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a54:	6605                	lui	a2,0x1
    80000a56:	4585                	li	a1,1
    80000a58:	250000ef          	jal	80000ca8 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a5c:	00012917          	auipc	s2,0x12
    80000a60:	97490913          	addi	s2,s2,-1676 # 800123d0 <kmem>
    80000a64:	854a                	mv	a0,s2
    80000a66:	182000ef          	jal	80000be8 <acquire>
  r->next = kmem.freelist;
    80000a6a:	01893783          	ld	a5,24(s2)
    80000a6e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a70:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a74:	854a                	mv	a0,s2
    80000a76:	1fa000ef          	jal	80000c70 <release>
}
    80000a7a:	60e2                	ld	ra,24(sp)
    80000a7c:	6442                	ld	s0,16(sp)
    80000a7e:	64a2                	ld	s1,8(sp)
    80000a80:	6902                	ld	s2,0(sp)
    80000a82:	6105                	addi	sp,sp,32
    80000a84:	8082                	ret
    panic("kfree");
    80000a86:	00006517          	auipc	a0,0x6
    80000a8a:	5b250513          	addi	a0,a0,1458 # 80007038 <etext+0x38>
    80000a8e:	da7ff0ef          	jal	80000834 <panic>

0000000080000a92 <freerange>:
{
    80000a92:	7179                	addi	sp,sp,-48
    80000a94:	f406                	sd	ra,40(sp)
    80000a96:	f022                	sd	s0,32(sp)
    80000a98:	ec26                	sd	s1,24(sp)
    80000a9a:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000a9c:	6785                	lui	a5,0x1
    80000a9e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000aa2:	00e504b3          	add	s1,a0,a4
    80000aa6:	777d                	lui	a4,0xfffff
    80000aa8:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000aaa:	94be                	add	s1,s1,a5
    80000aac:	0295e263          	bltu	a1,s1,80000ad0 <freerange+0x3e>
    80000ab0:	e84a                	sd	s2,16(sp)
    80000ab2:	e44e                	sd	s3,8(sp)
    80000ab4:	e052                	sd	s4,0(sp)
    80000ab6:	892e                	mv	s2,a1
    kfree(p);
    80000ab8:	8a3a                	mv	s4,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000aba:	89be                	mv	s3,a5
    kfree(p);
    80000abc:	01448533          	add	a0,s1,s4
    80000ac0:	f67ff0ef          	jal	80000a26 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000ac4:	94ce                	add	s1,s1,s3
    80000ac6:	fe997be3          	bgeu	s2,s1,80000abc <freerange+0x2a>
    80000aca:	6942                	ld	s2,16(sp)
    80000acc:	69a2                	ld	s3,8(sp)
    80000ace:	6a02                	ld	s4,0(sp)
}
    80000ad0:	70a2                	ld	ra,40(sp)
    80000ad2:	7402                	ld	s0,32(sp)
    80000ad4:	64e2                	ld	s1,24(sp)
    80000ad6:	6145                	addi	sp,sp,48
    80000ad8:	8082                	ret

0000000080000ada <kinit>:
{
    80000ada:	1141                	addi	sp,sp,-16
    80000adc:	e406                	sd	ra,8(sp)
    80000ade:	e022                	sd	s0,0(sp)
    80000ae0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ae2:	00006597          	auipc	a1,0x6
    80000ae6:	55e58593          	addi	a1,a1,1374 # 80007040 <etext+0x40>
    80000aea:	00012517          	auipc	a0,0x12
    80000aee:	8e650513          	addi	a0,a0,-1818 # 800123d0 <kmem>
    80000af2:	076000ef          	jal	80000b68 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000af6:	45c5                	li	a1,17
    80000af8:	05ee                	slli	a1,a1,0x1b
    80000afa:	00023517          	auipc	a0,0x23
    80000afe:	b0650513          	addi	a0,a0,-1274 # 80023600 <end>
    80000b02:	f91ff0ef          	jal	80000a92 <freerange>
}
    80000b06:	60a2                	ld	ra,8(sp)
    80000b08:	6402                	ld	s0,0(sp)
    80000b0a:	0141                	addi	sp,sp,16
    80000b0c:	8082                	ret

0000000080000b0e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b0e:	1101                	addi	sp,sp,-32
    80000b10:	ec06                	sd	ra,24(sp)
    80000b12:	e822                	sd	s0,16(sp)
    80000b14:	e426                	sd	s1,8(sp)
    80000b16:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b18:	00012517          	auipc	a0,0x12
    80000b1c:	8b850513          	addi	a0,a0,-1864 # 800123d0 <kmem>
    80000b20:	0c8000ef          	jal	80000be8 <acquire>
  r = kmem.freelist;
    80000b24:	00012497          	auipc	s1,0x12
    80000b28:	8c44b483          	ld	s1,-1852(s1) # 800123e8 <kmem+0x18>
  if (r)
    80000b2c:	c49d                	beqz	s1,80000b5a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b2e:	609c                	ld	a5,0(s1)
    80000b30:	00012717          	auipc	a4,0x12
    80000b34:	8af73c23          	sd	a5,-1864(a4) # 800123e8 <kmem+0x18>
  release(&kmem.lock);
    80000b38:	00012517          	auipc	a0,0x12
    80000b3c:	89850513          	addi	a0,a0,-1896 # 800123d0 <kmem>
    80000b40:	130000ef          	jal	80000c70 <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000b44:	6605                	lui	a2,0x1
    80000b46:	4595                	li	a1,5
    80000b48:	8526                	mv	a0,s1
    80000b4a:	15e000ef          	jal	80000ca8 <memset>
  return (void *)r;
}
    80000b4e:	8526                	mv	a0,s1
    80000b50:	60e2                	ld	ra,24(sp)
    80000b52:	6442                	ld	s0,16(sp)
    80000b54:	64a2                	ld	s1,8(sp)
    80000b56:	6105                	addi	sp,sp,32
    80000b58:	8082                	ret
  release(&kmem.lock);
    80000b5a:	00012517          	auipc	a0,0x12
    80000b5e:	87650513          	addi	a0,a0,-1930 # 800123d0 <kmem>
    80000b62:	10e000ef          	jal	80000c70 <release>
  if (r)
    80000b66:	b7e5                	j	80000b4e <kalloc+0x40>

0000000080000b68 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b68:	1141                	addi	sp,sp,-16
    80000b6a:	e406                	sd	ra,8(sp)
    80000b6c:	e022                	sd	s0,0(sp)
    80000b6e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b70:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b72:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b76:	00053823          	sd	zero,16(a0)
}
    80000b7a:	60a2                	ld	ra,8(sp)
    80000b7c:	6402                	ld	s0,0(sp)
    80000b7e:	0141                	addi	sp,sp,16
    80000b80:	8082                	ret

0000000080000b82 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b82:	411c                	lw	a5,0(a0)
    80000b84:	e399                	bnez	a5,80000b8a <holding+0x8>
    80000b86:	4501                	li	a0,0
  return r;
}
    80000b88:	8082                	ret
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b94:	691c                	ld	a5,16(a0)
    80000b96:	84be                	mv	s1,a5
    80000b98:	551000ef          	jal	800018e8 <mycpu>
    80000b9c:	40a48533          	sub	a0,s1,a0
    80000ba0:	00153513          	seqz	a0,a0
}
    80000ba4:	60e2                	ld	ra,24(sp)
    80000ba6:	6442                	ld	s0,16(sp)
    80000ba8:	64a2                	ld	s1,8(sp)
    80000baa:	6105                	addi	sp,sp,32
    80000bac:	8082                	ret

0000000080000bae <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bae:	1101                	addi	sp,sp,-32
    80000bb0:	ec06                	sd	ra,24(sp)
    80000bb2:	e822                	sd	s0,16(sp)
    80000bb4:	e426                	sd	s1,8(sp)
    80000bb6:	1000                	addi	s0,sp,32
  __asm__ __volatile__("csrrc %0, sstatus, %1" : "=r"(x) : "rK"(x) : "memory");
    80000bb8:	100177f3          	csrrci	a5,sstatus,2
    80000bbc:	84be                	mv	s1,a5
  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  uint64 flags = rc_sstatus(SSTATUS_SIE);
  int old = !!(flags & SSTATUS_SIE);

  if (mycpu()->noff == 0)
    80000bbe:	52b000ef          	jal	800018e8 <mycpu>
    80000bc2:	5d3c                	lw	a5,120(a0)
    80000bc4:	cb99                	beqz	a5,80000bda <push_off+0x2c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bc6:	523000ef          	jal	800018e8 <mycpu>
    80000bca:	5d3c                	lw	a5,120(a0)
    80000bcc:	2785                	addiw	a5,a5,1
    80000bce:	dd3c                	sw	a5,120(a0)
}
    80000bd0:	60e2                	ld	ra,24(sp)
    80000bd2:	6442                	ld	s0,16(sp)
    80000bd4:	64a2                	ld	s1,8(sp)
    80000bd6:	6105                	addi	sp,sp,32
    80000bd8:	8082                	ret
    mycpu()->intena = old;
    80000bda:	50f000ef          	jal	800018e8 <mycpu>
  int old = !!(flags & SSTATUS_SIE);
    80000bde:	0014d793          	srli	a5,s1,0x1
    80000be2:	8b85                	andi	a5,a5,1
    mycpu()->intena = old;
    80000be4:	dd7c                	sw	a5,124(a0)
    80000be6:	b7c5                	j	80000bc6 <push_off+0x18>

0000000080000be8 <acquire>:
{
    80000be8:	1101                	addi	sp,sp,-32
    80000bea:	ec06                	sd	ra,24(sp)
    80000bec:	e822                	sd	s0,16(sp)
    80000bee:	e426                	sd	s1,8(sp)
    80000bf0:	1000                	addi	s0,sp,32
    80000bf2:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bf4:	fbbff0ef          	jal	80000bae <push_off>
  if (holding(lk))
    80000bf8:	8526                	mv	a0,s1
    80000bfa:	f89ff0ef          	jal	80000b82 <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000bfe:	4705                	li	a4,1
  if (holding(lk))
    80000c00:	ed11                	bnez	a0,80000c1c <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000c02:	87ba                	mv	a5,a4
    80000c04:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c08:	2781                	sext.w	a5,a5
    80000c0a:	ffe5                	bnez	a5,80000c02 <acquire+0x1a>
  lk->cpu = mycpu();
    80000c0c:	4dd000ef          	jal	800018e8 <mycpu>
    80000c10:	e888                	sd	a0,16(s1)
}
    80000c12:	60e2                	ld	ra,24(sp)
    80000c14:	6442                	ld	s0,16(sp)
    80000c16:	64a2                	ld	s1,8(sp)
    80000c18:	6105                	addi	sp,sp,32
    80000c1a:	8082                	ret
    panic("acquire");
    80000c1c:	00006517          	auipc	a0,0x6
    80000c20:	42c50513          	addi	a0,a0,1068 # 80007048 <etext+0x48>
    80000c24:	c11ff0ef          	jal	80000834 <panic>

0000000080000c28 <pop_off>:

void
pop_off(void)
{
    80000c28:	1141                	addi	sp,sp,-16
    80000c2a:	e406                	sd	ra,8(sp)
    80000c2c:	e022                	sd	s0,0(sp)
    80000c2e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c30:	4b9000ef          	jal	800018e8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c34:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c38:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000c3a:	ef99                	bnez	a5,80000c58 <pop_off+0x30>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000c3c:	5d3c                	lw	a5,120(a0)
    80000c3e:	02f05363          	blez	a5,80000c64 <pop_off+0x3c>
    panic("pop_off");
  c->noff -= 1;
    80000c42:	37fd                	addiw	a5,a5,-1
    80000c44:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000c46:	e789                	bnez	a5,80000c50 <pop_off+0x28>
    80000c48:	5d7c                	lw	a5,124(a0)
    80000c4a:	c399                	beqz	a5,80000c50 <pop_off+0x28>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80000c4c:	10016073          	csrsi	sstatus,2
    intr_on();
}
    80000c50:	60a2                	ld	ra,8(sp)
    80000c52:	6402                	ld	s0,0(sp)
    80000c54:	0141                	addi	sp,sp,16
    80000c56:	8082                	ret
    panic("pop_off - interruptible");
    80000c58:	00006517          	auipc	a0,0x6
    80000c5c:	3f850513          	addi	a0,a0,1016 # 80007050 <etext+0x50>
    80000c60:	bd5ff0ef          	jal	80000834 <panic>
    panic("pop_off");
    80000c64:	00006517          	auipc	a0,0x6
    80000c68:	40450513          	addi	a0,a0,1028 # 80007068 <etext+0x68>
    80000c6c:	bc9ff0ef          	jal	80000834 <panic>

0000000080000c70 <release>:
{
    80000c70:	1101                	addi	sp,sp,-32
    80000c72:	ec06                	sd	ra,24(sp)
    80000c74:	e822                	sd	s0,16(sp)
    80000c76:	e426                	sd	s1,8(sp)
    80000c78:	1000                	addi	s0,sp,32
    80000c7a:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000c7c:	f07ff0ef          	jal	80000b82 <holding>
    80000c80:	cd11                	beqz	a0,80000c9c <release+0x2c>
  lk->cpu = 0;
    80000c82:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000c86:	0310000f          	fence	rw,w
    80000c8a:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c8e:	f9bff0ef          	jal	80000c28 <pop_off>
}
    80000c92:	60e2                	ld	ra,24(sp)
    80000c94:	6442                	ld	s0,16(sp)
    80000c96:	64a2                	ld	s1,8(sp)
    80000c98:	6105                	addi	sp,sp,32
    80000c9a:	8082                	ret
    panic("release");
    80000c9c:	00006517          	auipc	a0,0x6
    80000ca0:	3d450513          	addi	a0,a0,980 # 80007070 <etext+0x70>
    80000ca4:	b91ff0ef          	jal	80000834 <panic>

0000000080000ca8 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000ca8:	1141                	addi	sp,sp,-16
    80000caa:	e406                	sd	ra,8(sp)
    80000cac:	e022                	sd	s0,0(sp)
    80000cae:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000cb0:	ca19                	beqz	a2,80000cc6 <memset+0x1e>
    80000cb2:	87aa                	mv	a5,a0
    80000cb4:	1602                	slli	a2,a2,0x20
    80000cb6:	9201                	srli	a2,a2,0x20
    80000cb8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cbc:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000cc0:	0785                	addi	a5,a5,1
    80000cc2:	fee79de3          	bne	a5,a4,80000cbc <memset+0x14>
  }
  return dst;
}
    80000cc6:	60a2                	ld	ra,8(sp)
    80000cc8:	6402                	ld	s0,0(sp)
    80000cca:	0141                	addi	sp,sp,16
    80000ccc:	8082                	ret

0000000080000cce <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e406                	sd	ra,8(sp)
    80000cd2:	e022                	sd	s0,0(sp)
    80000cd4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000cd6:	c61d                	beqz	a2,80000d04 <memcmp+0x36>
    80000cd8:	1602                	slli	a2,a2,0x20
    80000cda:	9201                	srli	a2,a2,0x20
    80000cdc:	00c506b3          	add	a3,a0,a2
    if (*s1 != *s2)
    80000ce0:	00054783          	lbu	a5,0(a0)
    80000ce4:	0005c703          	lbu	a4,0(a1)
    80000ce8:	00e79863          	bne	a5,a4,80000cf8 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000cec:	0505                	addi	a0,a0,1
    80000cee:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000cf0:	fed518e3          	bne	a0,a3,80000ce0 <memcmp+0x12>
  }

  return 0;
    80000cf4:	4501                	li	a0,0
    80000cf6:	a019                	j	80000cfc <memcmp+0x2e>
      return *s1 - *s2;
    80000cf8:	40e7853b          	subw	a0,a5,a4
}
    80000cfc:	60a2                	ld	ra,8(sp)
    80000cfe:	6402                	ld	s0,0(sp)
    80000d00:	0141                	addi	sp,sp,16
    80000d02:	8082                	ret
  return 0;
    80000d04:	4501                	li	a0,0
    80000d06:	bfdd                	j	80000cfc <memcmp+0x2e>

0000000080000d08 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000d08:	1141                	addi	sp,sp,-16
    80000d0a:	e406                	sd	ra,8(sp)
    80000d0c:	e022                	sd	s0,0(sp)
    80000d0e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000d10:	c205                	beqz	a2,80000d30 <memmove+0x28>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000d12:	02a5e363          	bltu	a1,a0,80000d38 <memmove+0x30>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000d16:	1602                	slli	a2,a2,0x20
    80000d18:	9201                	srli	a2,a2,0x20
    80000d1a:	00c587b3          	add	a5,a1,a2
{
    80000d1e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d20:	0585                	addi	a1,a1,1
    80000d22:	0705                	addi	a4,a4,1
    80000d24:	fff5c683          	lbu	a3,-1(a1)
    80000d28:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000d2c:	feb79ae3          	bne	a5,a1,80000d20 <memmove+0x18>

  return dst;
}
    80000d30:	60a2                	ld	ra,8(sp)
    80000d32:	6402                	ld	s0,0(sp)
    80000d34:	0141                	addi	sp,sp,16
    80000d36:	8082                	ret
  if (s < d && s + n > d) {
    80000d38:	02061693          	slli	a3,a2,0x20
    80000d3c:	9281                	srli	a3,a3,0x20
    80000d3e:	00d58733          	add	a4,a1,a3
    80000d42:	fce57ae3          	bgeu	a0,a4,80000d16 <memmove+0xe>
    d += n;
    80000d46:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000d48:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d4c:	1782                	slli	a5,a5,0x20
    80000d4e:	9381                	srli	a5,a5,0x20
    80000d50:	fff7c793          	not	a5,a5
    80000d54:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d56:	177d                	addi	a4,a4,-1
    80000d58:	16fd                	addi	a3,a3,-1
    80000d5a:	00074603          	lbu	a2,0(a4)
    80000d5e:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000d62:	fee79ae3          	bne	a5,a4,80000d56 <memmove+0x4e>
    80000d66:	b7e9                	j	80000d30 <memmove+0x28>

0000000080000d68 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000d68:	1141                	addi	sp,sp,-16
    80000d6a:	e406                	sd	ra,8(sp)
    80000d6c:	e022                	sd	s0,0(sp)
    80000d6e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d70:	f99ff0ef          	jal	80000d08 <memmove>
}
    80000d74:	60a2                	ld	ra,8(sp)
    80000d76:	6402                	ld	s0,0(sp)
    80000d78:	0141                	addi	sp,sp,16
    80000d7a:	8082                	ret

0000000080000d7c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d7c:	1141                	addi	sp,sp,-16
    80000d7e:	e406                	sd	ra,8(sp)
    80000d80:	e022                	sd	s0,0(sp)
    80000d82:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000d84:	ce11                	beqz	a2,80000da0 <strncmp+0x24>
    80000d86:	00054783          	lbu	a5,0(a0)
    80000d8a:	cf89                	beqz	a5,80000da4 <strncmp+0x28>
    80000d8c:	0005c703          	lbu	a4,0(a1)
    80000d90:	00f71a63          	bne	a4,a5,80000da4 <strncmp+0x28>
    n--, p++, q++;
    80000d94:	367d                	addiw	a2,a2,-1
    80000d96:	0505                	addi	a0,a0,1
    80000d98:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000d9a:	f675                	bnez	a2,80000d86 <strncmp+0xa>
  if (n == 0)
    return 0;
    80000d9c:	4501                	li	a0,0
    80000d9e:	a801                	j	80000dae <strncmp+0x32>
    80000da0:	4501                	li	a0,0
    80000da2:	a031                	j	80000dae <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000da4:	00054503          	lbu	a0,0(a0)
    80000da8:	0005c783          	lbu	a5,0(a1)
    80000dac:	9d1d                	subw	a0,a0,a5
}
    80000dae:	60a2                	ld	ra,8(sp)
    80000db0:	6402                	ld	s0,0(sp)
    80000db2:	0141                	addi	sp,sp,16
    80000db4:	8082                	ret

0000000080000db6 <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000db6:	1141                	addi	sp,sp,-16
    80000db8:	e406                	sd	ra,8(sp)
    80000dba:	e022                	sd	s0,0(sp)
    80000dbc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000dbe:	87aa                	mv	a5,a0
    80000dc0:	a011                	j	80000dc4 <strncpy+0xe>
    80000dc2:	8636                	mv	a2,a3
    80000dc4:	02c05863          	blez	a2,80000df4 <strncpy+0x3e>
    80000dc8:	fff6069b          	addiw	a3,a2,-1
    80000dcc:	8836                	mv	a6,a3
    80000dce:	0785                	addi	a5,a5,1
    80000dd0:	0005c703          	lbu	a4,0(a1)
    80000dd4:	fee78fa3          	sb	a4,-1(a5)
    80000dd8:	0585                	addi	a1,a1,1
    80000dda:	f765                	bnez	a4,80000dc2 <strncpy+0xc>
    ;
  while (n-- > 0)
    80000ddc:	873e                	mv	a4,a5
    80000dde:	01005b63          	blez	a6,80000df4 <strncpy+0x3e>
    80000de2:	9fb1                	addw	a5,a5,a2
    80000de4:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000de6:	0705                	addi	a4,a4,1
    80000de8:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000dec:	40e786bb          	subw	a3,a5,a4
    80000df0:	fed04be3          	bgtz	a3,80000de6 <strncpy+0x30>
  return os;
}
    80000df4:	60a2                	ld	ra,8(sp)
    80000df6:	6402                	ld	s0,0(sp)
    80000df8:	0141                	addi	sp,sp,16
    80000dfa:	8082                	ret

0000000080000dfc <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000dfc:	1141                	addi	sp,sp,-16
    80000dfe:	e406                	sd	ra,8(sp)
    80000e00:	e022                	sd	s0,0(sp)
    80000e02:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000e04:	02c05363          	blez	a2,80000e2a <safestrcpy+0x2e>
    80000e08:	fff6069b          	addiw	a3,a2,-1
    80000e0c:	1682                	slli	a3,a3,0x20
    80000e0e:	9281                	srli	a3,a3,0x20
    80000e10:	96ae                	add	a3,a3,a1
    80000e12:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000e14:	00d58963          	beq	a1,a3,80000e26 <safestrcpy+0x2a>
    80000e18:	0585                	addi	a1,a1,1
    80000e1a:	0785                	addi	a5,a5,1
    80000e1c:	fff5c703          	lbu	a4,-1(a1)
    80000e20:	fee78fa3          	sb	a4,-1(a5)
    80000e24:	fb65                	bnez	a4,80000e14 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e26:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e2a:	60a2                	ld	ra,8(sp)
    80000e2c:	6402                	ld	s0,0(sp)
    80000e2e:	0141                	addi	sp,sp,16
    80000e30:	8082                	ret

0000000080000e32 <strlen>:

int
strlen(const char *s)
{
    80000e32:	1141                	addi	sp,sp,-16
    80000e34:	e406                	sd	ra,8(sp)
    80000e36:	e022                	sd	s0,0(sp)
    80000e38:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000e3a:	00054783          	lbu	a5,0(a0)
    80000e3e:	cf91                	beqz	a5,80000e5a <strlen+0x28>
    80000e40:	00150793          	addi	a5,a0,1
    80000e44:	86be                	mv	a3,a5
    80000e46:	0785                	addi	a5,a5,1
    80000e48:	fff7c703          	lbu	a4,-1(a5)
    80000e4c:	ff65                	bnez	a4,80000e44 <strlen+0x12>
    80000e4e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000e52:	60a2                	ld	ra,8(sp)
    80000e54:	6402                	ld	s0,0(sp)
    80000e56:	0141                	addi	sp,sp,16
    80000e58:	8082                	ret
  for (n = 0; s[n]; n++)
    80000e5a:	4501                	li	a0,0
    80000e5c:	bfdd                	j	80000e52 <strlen+0x20>

0000000080000e5e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e5e:	1141                	addi	sp,sp,-16
    80000e60:	e406                	sd	ra,8(sp)
    80000e62:	e022                	sd	s0,0(sp)
    80000e64:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000e66:	26f000ef          	jal	800018d4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e6a:	00009717          	auipc	a4,0x9
    80000e6e:	45270713          	addi	a4,a4,1106 # 8000a2bc <started>
  if (cpuid() == 0) {
    80000e72:	c51d                	beqz	a0,80000ea0 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e74:	431c                	lw	a5,0(a4)
    80000e76:	0230000f          	fence	r,rw
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dfe5                	beqz	a5,80000e74 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000e7e:	257000ef          	jal	800018d4 <cpuid>
    80000e82:	85aa                	mv	a1,a0
    80000e84:	00006517          	auipc	a0,0x6
    80000e88:	21450513          	addi	a0,a0,532 # 80007098 <etext+0x98>
    80000e8c:	e7eff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000e90:	082000ef          	jal	80000f12 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000e94:	5e4010ef          	jal	80002478 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000e98:	7a0040ef          	jal	80005638 <plicinithart>
  }

  scheduler();
    80000e9c:	6eb000ef          	jal	80001d86 <scheduler>
    consoleinit();
    80000ea0:	d90ff0ef          	jal	80000430 <consoleinit>
    printkinit();
    80000ea4:	9cdff0ef          	jal	80000870 <printkinit>
    printk("\n");
    80000ea8:	00006517          	auipc	a0,0x6
    80000eac:	1d050513          	addi	a0,a0,464 # 80007078 <etext+0x78>
    80000eb0:	e5aff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000eb4:	00006517          	auipc	a0,0x6
    80000eb8:	1cc50513          	addi	a0,a0,460 # 80007080 <etext+0x80>
    80000ebc:	e4eff0ef          	jal	8000050a <printk>
    printk("\n");
    80000ec0:	00006517          	auipc	a0,0x6
    80000ec4:	1b850513          	addi	a0,a0,440 # 80007078 <etext+0x78>
    80000ec8:	e42ff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000ecc:	c0fff0ef          	jal	80000ada <kinit>
    kvminit();          // create kernel page table
    80000ed0:	2ce000ef          	jal	8000119e <kvminit>
    kvminithart();      // turn on paging
    80000ed4:	03e000ef          	jal	80000f12 <kvminithart>
    procinit();         // process table
    80000ed8:	147000ef          	jal	8000181e <procinit>
    trapinit();         // trap vectors
    80000edc:	578010ef          	jal	80002454 <trapinit>
    trapinithart();     // install kernel trap vector
    80000ee0:	598010ef          	jal	80002478 <trapinithart>
    plicinit();         // set up interrupt controller
    80000ee4:	73a040ef          	jal	8000561e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000ee8:	750040ef          	jal	80005638 <plicinithart>
    binit();            // buffer cache
    80000eec:	42b010ef          	jal	80002b16 <binit>
    iinit();            // inode table
    80000ef0:	17c020ef          	jal	8000306c <iinit>
    fileinit();         // file table
    80000ef4:	19c030ef          	jal	80004090 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ef8:	031040ef          	jal	80005728 <virtio_disk_init>
    userinit();         // first user process
    80000efc:	4df000ef          	jal	80001bda <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f00:	00009797          	auipc	a5,0x9
    80000f04:	3bc78793          	addi	a5,a5,956 # 8000a2bc <started>
    80000f08:	4705                	li	a4,1
    80000f0a:	0310000f          	fence	rw,w
    80000f0e:	c398                	sw	a4,0(a5)
    80000f10:	b771                	j	80000e9c <main+0x3e>

0000000080000f12 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f12:	1141                	addi	sp,sp,-16
    80000f14:	e406                	sd	ra,8(sp)
    80000f16:	e022                	sd	s0,0(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00009797          	auipc	a5,0x9
    80000f22:	3a27b783          	ld	a5,930(a5) # 8000a2c0 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	60a2                	ld	ra,8(sp)
    80000f38:	6402                	ld	s0,0(sp)
    80000f3a:	0141                	addi	sp,sp,16
    80000f3c:	8082                	ret

0000000080000f3e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3e:	7139                	addi	sp,sp,-64
    80000f40:	fc06                	sd	ra,56(sp)
    80000f42:	f822                	sd	s0,48(sp)
    80000f44:	f426                	sd	s1,40(sp)
    80000f46:	f04a                	sd	s2,32(sp)
    80000f48:	ec4e                	sd	s3,24(sp)
    80000f4a:	e852                	sd	s4,16(sp)
    80000f4c:	e456                	sd	s5,8(sp)
    80000f4e:	e05a                	sd	s6,0(sp)
    80000f50:	0080                	addi	s0,sp,64
    80000f52:	84aa                	mv	s1,a0
    80000f54:	89ae                	mv	s3,a1
    80000f56:	8b32                	mv	s6,a2
  if (va >= MAXVA)
    80000f58:	57fd                	li	a5,-1
    80000f5a:	83e9                	srli	a5,a5,0x1a
    80000f5c:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000f5e:	4ab1                	li	s5,12
  if (va >= MAXVA)
    80000f60:	04b7e263          	bltu	a5,a1,80000fa4 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f64:	0149d933          	srl	s2,s3,s4
    80000f68:	1ff97913          	andi	s2,s2,511
    80000f6c:	090e                	slli	s2,s2,0x3
    80000f6e:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000f70:	00093483          	ld	s1,0(s2)
    80000f74:	0014f793          	andi	a5,s1,1
    80000f78:	cf85                	beqz	a5,80000fb0 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f7a:	80a9                	srli	s1,s1,0xa
    80000f7c:	04b2                	slli	s1,s1,0xc
  for (int level = 2; level > 0; level--) {
    80000f7e:	3a5d                	addiw	s4,s4,-9
    80000f80:	ff5a12e3          	bne	s4,s5,80000f64 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000f84:	00c9d513          	srli	a0,s3,0xc
    80000f88:	1ff57513          	andi	a0,a0,511
    80000f8c:	050e                	slli	a0,a0,0x3
    80000f8e:	9526                	add	a0,a0,s1
}
    80000f90:	70e2                	ld	ra,56(sp)
    80000f92:	7442                	ld	s0,48(sp)
    80000f94:	74a2                	ld	s1,40(sp)
    80000f96:	7902                	ld	s2,32(sp)
    80000f98:	69e2                	ld	s3,24(sp)
    80000f9a:	6a42                	ld	s4,16(sp)
    80000f9c:	6aa2                	ld	s5,8(sp)
    80000f9e:	6b02                	ld	s6,0(sp)
    80000fa0:	6121                	addi	sp,sp,64
    80000fa2:	8082                	ret
    panic("walk");
    80000fa4:	00006517          	auipc	a0,0x6
    80000fa8:	10c50513          	addi	a0,a0,268 # 800070b0 <etext+0xb0>
    80000fac:	889ff0ef          	jal	80000834 <panic>
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000fb0:	020b0263          	beqz	s6,80000fd4 <walk+0x96>
    80000fb4:	b5bff0ef          	jal	80000b0e <kalloc>
    80000fb8:	84aa                	mv	s1,a0
    80000fba:	d979                	beqz	a0,80000f90 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80000fbc:	6605                	lui	a2,0x1
    80000fbe:	4581                	li	a1,0
    80000fc0:	ce9ff0ef          	jal	80000ca8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000fc4:	00c4d793          	srli	a5,s1,0xc
    80000fc8:	07aa                	slli	a5,a5,0xa
    80000fca:	0017e793          	ori	a5,a5,1
    80000fce:	00f93023          	sd	a5,0(s2)
    80000fd2:	b775                	j	80000f7e <walk+0x40>
        return 0;
    80000fd4:	4501                	li	a0,0
    80000fd6:	bf6d                	j	80000f90 <walk+0x52>

0000000080000fd8 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80000fd8:	57fd                	li	a5,-1
    80000fda:	83e9                	srli	a5,a5,0x1a
    80000fdc:	00b7f463          	bgeu	a5,a1,80000fe4 <walkaddr+0xc>
    return 0;
    80000fe0:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe2:	8082                	ret
{
    80000fe4:	1141                	addi	sp,sp,-16
    80000fe6:	e406                	sd	ra,8(sp)
    80000fe8:	e022                	sd	s0,0(sp)
    80000fea:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fec:	4601                	li	a2,0
    80000fee:	f51ff0ef          	jal	80000f3e <walk>
  if (pte == 0)
    80000ff2:	c901                	beqz	a0,80001002 <walkaddr+0x2a>
  if ((*pte & PTE_V) == 0)
    80000ff4:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80000ff6:	0117f693          	andi	a3,a5,17
    80000ffa:	4745                	li	a4,17
    return 0;
    80000ffc:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80000ffe:	00e68663          	beq	a3,a4,8000100a <walkaddr+0x32>
}
    80001002:	60a2                	ld	ra,8(sp)
    80001004:	6402                	ld	s0,0(sp)
    80001006:	0141                	addi	sp,sp,16
    80001008:	8082                	ret
  pa = PTE2PA(*pte);
    8000100a:	83a9                	srli	a5,a5,0xa
    8000100c:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001010:	bfcd                	j	80001002 <walkaddr+0x2a>

0000000080001012 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001012:	715d                	addi	sp,sp,-80
    80001014:	e486                	sd	ra,72(sp)
    80001016:	e0a2                	sd	s0,64(sp)
    80001018:	fc26                	sd	s1,56(sp)
    8000101a:	f84a                	sd	s2,48(sp)
    8000101c:	f44e                	sd	s3,40(sp)
    8000101e:	f052                	sd	s4,32(sp)
    80001020:	ec56                	sd	s5,24(sp)
    80001022:	e85a                	sd	s6,16(sp)
    80001024:	e45e                	sd	s7,8(sp)
    80001026:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001028:	03459793          	slli	a5,a1,0x34
    8000102c:	eba1                	bnez	a5,8000107c <mappages+0x6a>
    8000102e:	8a2a                	mv	s4,a0
    80001030:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80001032:	03461793          	slli	a5,a2,0x34
    80001036:	eba9                	bnez	a5,80001088 <mappages+0x76>
    panic("mappages: size not aligned");

  if (size == 0)
    80001038:	ce31                	beqz	a2,80001094 <mappages+0x82>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    8000103a:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    8000103e:	80060613          	addi	a2,a2,-2048
    80001042:	00b60933          	add	s2,a2,a1
  a = va;
    80001046:	84ae                	mv	s1,a1
  for (;;) {
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001048:	4b05                	li	s6,1
    8000104a:	40b689b3          	sub	s3,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    8000104e:	6b85                	lui	s7,0x1
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001050:	865a                	mv	a2,s6
    80001052:	85a6                	mv	a1,s1
    80001054:	8552                	mv	a0,s4
    80001056:	ee9ff0ef          	jal	80000f3e <walk>
    8000105a:	c929                	beqz	a0,800010ac <mappages+0x9a>
    if (*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	e3a1                	bnez	a5,800010a0 <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	013487b3          	add	a5,s1,s3
    80001066:	83b1                	srli	a5,a5,0xc
    80001068:	07aa                	slli	a5,a5,0xa
    8000106a:	0157e7b3          	or	a5,a5,s5
    8000106e:	0017e793          	ori	a5,a5,1
    80001072:	e11c                	sd	a5,0(a0)
    if (a == last)
    80001074:	05248863          	beq	s1,s2,800010c4 <mappages+0xb2>
    a += PGSIZE;
    80001078:	94de                	add	s1,s1,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    8000107a:	bfd9                	j	80001050 <mappages+0x3e>
    panic("mappages: va not aligned");
    8000107c:	00006517          	auipc	a0,0x6
    80001080:	03c50513          	addi	a0,a0,60 # 800070b8 <etext+0xb8>
    80001084:	fb0ff0ef          	jal	80000834 <panic>
    panic("mappages: size not aligned");
    80001088:	00006517          	auipc	a0,0x6
    8000108c:	05050513          	addi	a0,a0,80 # 800070d8 <etext+0xd8>
    80001090:	fa4ff0ef          	jal	80000834 <panic>
    panic("mappages: size");
    80001094:	00006517          	auipc	a0,0x6
    80001098:	06450513          	addi	a0,a0,100 # 800070f8 <etext+0xf8>
    8000109c:	f98ff0ef          	jal	80000834 <panic>
      panic("mappages: remap");
    800010a0:	00006517          	auipc	a0,0x6
    800010a4:	06850513          	addi	a0,a0,104 # 80007108 <etext+0x108>
    800010a8:	f8cff0ef          	jal	80000834 <panic>
      return -1;
    800010ac:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010ae:	60a6                	ld	ra,72(sp)
    800010b0:	6406                	ld	s0,64(sp)
    800010b2:	74e2                	ld	s1,56(sp)
    800010b4:	7942                	ld	s2,48(sp)
    800010b6:	79a2                	ld	s3,40(sp)
    800010b8:	7a02                	ld	s4,32(sp)
    800010ba:	6ae2                	ld	s5,24(sp)
    800010bc:	6b42                	ld	s6,16(sp)
    800010be:	6ba2                	ld	s7,8(sp)
    800010c0:	6161                	addi	sp,sp,80
    800010c2:	8082                	ret
  return 0;
    800010c4:	4501                	li	a0,0
    800010c6:	b7e5                	j	800010ae <mappages+0x9c>

00000000800010c8 <kvmmap>:
{
    800010c8:	1141                	addi	sp,sp,-16
    800010ca:	e406                	sd	ra,8(sp)
    800010cc:	e022                	sd	s0,0(sp)
    800010ce:	0800                	addi	s0,sp,16
    800010d0:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010d2:	86b2                	mv	a3,a2
    800010d4:	863e                	mv	a2,a5
    800010d6:	f3dff0ef          	jal	80001012 <mappages>
    800010da:	e509                	bnez	a0,800010e4 <kvmmap+0x1c>
}
    800010dc:	60a2                	ld	ra,8(sp)
    800010de:	6402                	ld	s0,0(sp)
    800010e0:	0141                	addi	sp,sp,16
    800010e2:	8082                	ret
    panic("kvmmap");
    800010e4:	00006517          	auipc	a0,0x6
    800010e8:	03450513          	addi	a0,a0,52 # 80007118 <etext+0x118>
    800010ec:	f48ff0ef          	jal	80000834 <panic>

00000000800010f0 <kvmmake>:
{
    800010f0:	1101                	addi	sp,sp,-32
    800010f2:	ec06                	sd	ra,24(sp)
    800010f4:	e822                	sd	s0,16(sp)
    800010f6:	e426                	sd	s1,8(sp)
    800010f8:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    800010fa:	a15ff0ef          	jal	80000b0e <kalloc>
    800010fe:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001100:	6605                	lui	a2,0x1
    80001102:	4581                	li	a1,0
    80001104:	ba5ff0ef          	jal	80000ca8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001108:	4719                	li	a4,6
    8000110a:	6685                	lui	a3,0x1
    8000110c:	10000637          	lui	a2,0x10000
    80001110:	85b2                	mv	a1,a2
    80001112:	8526                	mv	a0,s1
    80001114:	fb5ff0ef          	jal	800010c8 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	85b2                	mv	a1,a2
    80001122:	8526                	mv	a0,s1
    80001124:	fa5ff0ef          	jal	800010c8 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001128:	4719                	li	a4,6
    8000112a:	040006b7          	lui	a3,0x4000
    8000112e:	0c000637          	lui	a2,0xc000
    80001132:	85b2                	mv	a1,a2
    80001134:	8526                	mv	a0,s1
    80001136:	f93ff0ef          	jal	800010c8 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    8000113a:	4729                	li	a4,10
    8000113c:	80006697          	auipc	a3,0x80006
    80001140:	ec468693          	addi	a3,a3,-316 # 7000 <_entry-0x7fff9000>
    80001144:	4605                	li	a2,1
    80001146:	067e                	slli	a2,a2,0x1f
    80001148:	85b2                	mv	a1,a2
    8000114a:	8526                	mv	a0,s1
    8000114c:	f7dff0ef          	jal	800010c8 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    80001150:	4719                	li	a4,6
    80001152:	00006697          	auipc	a3,0x6
    80001156:	eae68693          	addi	a3,a3,-338 # 80007000 <etext>
    8000115a:	47c5                	li	a5,17
    8000115c:	07ee                	slli	a5,a5,0x1b
    8000115e:	40d786b3          	sub	a3,a5,a3
    80001162:	00006617          	auipc	a2,0x6
    80001166:	e9e60613          	addi	a2,a2,-354 # 80007000 <etext>
    8000116a:	85b2                	mv	a1,a2
    8000116c:	8526                	mv	a0,s1
    8000116e:	f5bff0ef          	jal	800010c8 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001172:	4729                	li	a4,10
    80001174:	6685                	lui	a3,0x1
    80001176:	00005617          	auipc	a2,0x5
    8000117a:	e8a60613          	addi	a2,a2,-374 # 80006000 <_trampoline>
    8000117e:	040005b7          	lui	a1,0x4000
    80001182:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001184:	05b2                	slli	a1,a1,0xc
    80001186:	8526                	mv	a0,s1
    80001188:	f41ff0ef          	jal	800010c8 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118c:	8526                	mv	a0,s1
    8000118e:	5ec000ef          	jal	8000177a <proc_mapstacks>
}
    80001192:	8526                	mv	a0,s1
    80001194:	60e2                	ld	ra,24(sp)
    80001196:	6442                	ld	s0,16(sp)
    80001198:	64a2                	ld	s1,8(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f4bff0ef          	jal	800010f0 <kvmmake>
    800011aa:	00009797          	auipc	a5,0x9
    800011ae:	10a7bb23          	sd	a0,278(a5) # 8000a2c0 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800011ba:	1101                	addi	sp,sp,-32
    800011bc:	ec06                	sd	ra,24(sp)
    800011be:	e822                	sd	s0,16(sp)
    800011c0:	e426                	sd	s1,8(sp)
    800011c2:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    800011c4:	94bff0ef          	jal	80000b0e <kalloc>
    800011c8:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800011ca:	c509                	beqz	a0,800011d4 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011cc:	6605                	lui	a2,0x1
    800011ce:	4581                	li	a1,0
    800011d0:	ad9ff0ef          	jal	80000ca8 <memset>
  return pagetable;
}
    800011d4:	8526                	mv	a0,s1
    800011d6:	60e2                	ld	ra,24(sp)
    800011d8:	6442                	ld	s0,16(sp)
    800011da:	64a2                	ld	s1,8(sp)
    800011dc:	6105                	addi	sp,sp,32
    800011de:	8082                	ret

00000000800011e0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011e0:	7139                	addi	sp,sp,-64
    800011e2:	fc06                	sd	ra,56(sp)
    800011e4:	f822                	sd	s0,48(sp)
    800011e6:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    800011e8:	03459793          	slli	a5,a1,0x34
    800011ec:	e38d                	bnez	a5,8000120e <uvmunmap+0x2e>
    800011ee:	f04a                	sd	s2,32(sp)
    800011f0:	ec4e                	sd	s3,24(sp)
    800011f2:	e852                	sd	s4,16(sp)
    800011f4:	e456                	sd	s5,8(sp)
    800011f6:	e05a                	sd	s6,0(sp)
    800011f8:	8a2a                	mv	s4,a0
    800011fa:	892e                	mv	s2,a1
    800011fc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    800011fe:	0632                	slli	a2,a2,0xc
    80001200:	00b609b3          	add	s3,a2,a1
    80001204:	6b05                	lui	s6,0x1
    80001206:	0535f963          	bgeu	a1,s3,80001258 <uvmunmap+0x78>
    8000120a:	f426                	sd	s1,40(sp)
    8000120c:	a015                	j	80001230 <uvmunmap+0x50>
    8000120e:	f426                	sd	s1,40(sp)
    80001210:	f04a                	sd	s2,32(sp)
    80001212:	ec4e                	sd	s3,24(sp)
    80001214:	e852                	sd	s4,16(sp)
    80001216:	e456                	sd	s5,8(sp)
    80001218:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000121a:	00006517          	auipc	a0,0x6
    8000121e:	f0650513          	addi	a0,a0,-250 # 80007120 <etext+0x120>
    80001222:	e12ff0ef          	jal	80000834 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    80001226:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    8000122a:	995a                	add	s2,s2,s6
    8000122c:	03397563          	bgeu	s2,s3,80001256 <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001230:	4601                	li	a2,0
    80001232:	85ca                	mv	a1,s2
    80001234:	8552                	mv	a0,s4
    80001236:	d09ff0ef          	jal	80000f3e <walk>
    8000123a:	84aa                	mv	s1,a0
    8000123c:	d57d                	beqz	a0,8000122a <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    8000123e:	611c                	ld	a5,0(a0)
    80001240:	0017f713          	andi	a4,a5,1
    80001244:	d37d                	beqz	a4,8000122a <uvmunmap+0x4a>
    if (do_free) {
    80001246:	fe0a80e3          	beqz	s5,80001226 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    8000124a:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    8000124c:	00c79513          	slli	a0,a5,0xc
    80001250:	fd6ff0ef          	jal	80000a26 <kfree>
    80001254:	bfc9                	j	80001226 <uvmunmap+0x46>
    80001256:	74a2                	ld	s1,40(sp)
    80001258:	7902                	ld	s2,32(sp)
    8000125a:	69e2                	ld	s3,24(sp)
    8000125c:	6a42                	ld	s4,16(sp)
    8000125e:	6aa2                	ld	s5,8(sp)
    80001260:	6b02                	ld	s6,0(sp)
  }
}
    80001262:	70e2                	ld	ra,56(sp)
    80001264:	7442                	ld	s0,48(sp)
    80001266:	6121                	addi	sp,sp,64
    80001268:	8082                	ret

000000008000126a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000126a:	1101                	addi	sp,sp,-32
    8000126c:	ec06                	sd	ra,24(sp)
    8000126e:	e822                	sd	s0,16(sp)
    80001270:	e426                	sd	s1,8(sp)
    80001272:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    80001274:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80001276:	00b67d63          	bgeu	a2,a1,80001290 <uvmdealloc+0x26>
    8000127a:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    8000127c:	6785                	lui	a5,0x1
    8000127e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001280:	00f60733          	add	a4,a2,a5
    80001284:	76fd                	lui	a3,0xfffff
    80001286:	8f75                	and	a4,a4,a3
    80001288:	97ae                	add	a5,a5,a1
    8000128a:	8ff5                	and	a5,a5,a3
    8000128c:	00f76863          	bltu	a4,a5,8000129c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000129c:	8f99                	sub	a5,a5,a4
    8000129e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012a0:	4685                	li	a3,1
    800012a2:	0007861b          	sext.w	a2,a5
    800012a6:	85ba                	mv	a1,a4
    800012a8:	f39ff0ef          	jal	800011e0 <uvmunmap>
    800012ac:	b7d5                	j	80001290 <uvmdealloc+0x26>

00000000800012ae <uvmalloc>:
  if (newsz < oldsz)
    800012ae:	0ab66163          	bltu	a2,a1,80001350 <uvmalloc+0xa2>
{
    800012b2:	715d                	addi	sp,sp,-80
    800012b4:	e486                	sd	ra,72(sp)
    800012b6:	e0a2                	sd	s0,64(sp)
    800012b8:	f84a                	sd	s2,48(sp)
    800012ba:	f052                	sd	s4,32(sp)
    800012bc:	ec56                	sd	s5,24(sp)
    800012be:	e45e                	sd	s7,8(sp)
    800012c0:	0880                	addi	s0,sp,80
    800012c2:	8aaa                	mv	s5,a0
    800012c4:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800012c6:	6785                	lui	a5,0x1
    800012c8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012ca:	95be                	add	a1,a1,a5
    800012cc:	77fd                	lui	a5,0xfffff
    800012ce:	00f5f933          	and	s2,a1,a5
    800012d2:	8bca                	mv	s7,s2
  for (a = oldsz; a < newsz; a += PGSIZE) {
    800012d4:	08c97063          	bgeu	s2,a2,80001354 <uvmalloc+0xa6>
    800012d8:	fc26                	sd	s1,56(sp)
    800012da:	f44e                	sd	s3,40(sp)
    800012dc:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    800012de:	6985                	lui	s3,0x1
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    800012e0:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012e4:	82bff0ef          	jal	80000b0e <kalloc>
    800012e8:	84aa                	mv	s1,a0
    if (mem == 0) {
    800012ea:	c50d                	beqz	a0,80001314 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    800012ec:	864e                	mv	a2,s3
    800012ee:	4581                	li	a1,0
    800012f0:	9b9ff0ef          	jal	80000ca8 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    800012f4:	875a                	mv	a4,s6
    800012f6:	86a6                	mv	a3,s1
    800012f8:	864e                	mv	a2,s3
    800012fa:	85ca                	mv	a1,s2
    800012fc:	8556                	mv	a0,s5
    800012fe:	d15ff0ef          	jal	80001012 <mappages>
    80001302:	e915                	bnez	a0,80001336 <uvmalloc+0x88>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001304:	994e                	add	s2,s2,s3
    80001306:	fd496fe3          	bltu	s2,s4,800012e4 <uvmalloc+0x36>
  return newsz;
    8000130a:	8552                	mv	a0,s4
    8000130c:	74e2                	ld	s1,56(sp)
    8000130e:	79a2                	ld	s3,40(sp)
    80001310:	6b42                	ld	s6,16(sp)
    80001312:	a811                	j	80001326 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001314:	865e                	mv	a2,s7
    80001316:	85ca                	mv	a1,s2
    80001318:	8556                	mv	a0,s5
    8000131a:	f51ff0ef          	jal	8000126a <uvmdealloc>
      return 0;
    8000131e:	4501                	li	a0,0
    80001320:	74e2                	ld	s1,56(sp)
    80001322:	79a2                	ld	s3,40(sp)
    80001324:	6b42                	ld	s6,16(sp)
}
    80001326:	60a6                	ld	ra,72(sp)
    80001328:	6406                	ld	s0,64(sp)
    8000132a:	7942                	ld	s2,48(sp)
    8000132c:	7a02                	ld	s4,32(sp)
    8000132e:	6ae2                	ld	s5,24(sp)
    80001330:	6ba2                	ld	s7,8(sp)
    80001332:	6161                	addi	sp,sp,80
    80001334:	8082                	ret
      kfree(mem);
    80001336:	8526                	mv	a0,s1
    80001338:	eeeff0ef          	jal	80000a26 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000133c:	865e                	mv	a2,s7
    8000133e:	85ca                	mv	a1,s2
    80001340:	8556                	mv	a0,s5
    80001342:	f29ff0ef          	jal	8000126a <uvmdealloc>
      return 0;
    80001346:	4501                	li	a0,0
    80001348:	74e2                	ld	s1,56(sp)
    8000134a:	79a2                	ld	s3,40(sp)
    8000134c:	6b42                	ld	s6,16(sp)
    8000134e:	bfe1                	j	80001326 <uvmalloc+0x78>
    return oldsz;
    80001350:	852e                	mv	a0,a1
}
    80001352:	8082                	ret
  return newsz;
    80001354:	8532                	mv	a0,a2
    80001356:	bfc1                	j	80001326 <uvmalloc+0x78>

0000000080001358 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001358:	7179                	addi	sp,sp,-48
    8000135a:	f406                	sd	ra,40(sp)
    8000135c:	f022                	sd	s0,32(sp)
    8000135e:	ec26                	sd	s1,24(sp)
    80001360:	e84a                	sd	s2,16(sp)
    80001362:	e44e                	sd	s3,8(sp)
    80001364:	1800                	addi	s0,sp,48
    80001366:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    80001368:	84aa                	mv	s1,a0
    8000136a:	6905                	lui	s2,0x1
    8000136c:	992a                	add	s2,s2,a0
    8000136e:	a811                	j	80001382 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if (pte & PTE_V) {
      panic("freewalk: leaf");
    80001370:	00006517          	auipc	a0,0x6
    80001374:	dc850513          	addi	a0,a0,-568 # 80007138 <etext+0x138>
    80001378:	cbcff0ef          	jal	80000834 <panic>
  for (int i = 0; i < 512; i++) {
    8000137c:	04a1                	addi	s1,s1,8
    8000137e:	03248163          	beq	s1,s2,800013a0 <freewalk+0x48>
    pte_t pte = pagetable[i];
    80001382:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001384:	0017f713          	andi	a4,a5,1
    80001388:	db75                	beqz	a4,8000137c <freewalk+0x24>
    8000138a:	00e7f713          	andi	a4,a5,14
    8000138e:	f36d                	bnez	a4,80001370 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    80001390:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001392:	00c79513          	slli	a0,a5,0xc
    80001396:	fc3ff0ef          	jal	80001358 <freewalk>
      pagetable[i] = 0;
    8000139a:	0004b023          	sd	zero,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    8000139e:	bff9                	j	8000137c <freewalk+0x24>
    }
  }
  kfree((void *)pagetable);
    800013a0:	854e                	mv	a0,s3
    800013a2:	e84ff0ef          	jal	80000a26 <kfree>
}
    800013a6:	70a2                	ld	ra,40(sp)
    800013a8:	7402                	ld	s0,32(sp)
    800013aa:	64e2                	ld	s1,24(sp)
    800013ac:	6942                	ld	s2,16(sp)
    800013ae:	69a2                	ld	s3,8(sp)
    800013b0:	6145                	addi	sp,sp,48
    800013b2:	8082                	ret

00000000800013b4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013b4:	1101                	addi	sp,sp,-32
    800013b6:	ec06                	sd	ra,24(sp)
    800013b8:	e822                	sd	s0,16(sp)
    800013ba:	e426                	sd	s1,8(sp)
    800013bc:	1000                	addi	s0,sp,32
    800013be:	84aa                	mv	s1,a0
  if (sz > 0)
    800013c0:	e989                	bnez	a1,800013d2 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    800013c2:	8526                	mv	a0,s1
    800013c4:	f95ff0ef          	jal	80001358 <freewalk>
}
    800013c8:	60e2                	ld	ra,24(sp)
    800013ca:	6442                	ld	s0,16(sp)
    800013cc:	64a2                	ld	s1,8(sp)
    800013ce:	6105                	addi	sp,sp,32
    800013d0:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    800013d2:	6785                	lui	a5,0x1
    800013d4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d6:	95be                	add	a1,a1,a5
    800013d8:	4685                	li	a3,1
    800013da:	00c5d613          	srli	a2,a1,0xc
    800013de:	4581                	li	a1,0
    800013e0:	e01ff0ef          	jal	800011e0 <uvmunmap>
    800013e4:	bff9                	j	800013c2 <uvmfree+0xe>

00000000800013e6 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    800013e6:	ca59                	beqz	a2,8000147c <uvmcopy+0x96>
{
    800013e8:	715d                	addi	sp,sp,-80
    800013ea:	e486                	sd	ra,72(sp)
    800013ec:	e0a2                	sd	s0,64(sp)
    800013ee:	fc26                	sd	s1,56(sp)
    800013f0:	f84a                	sd	s2,48(sp)
    800013f2:	f44e                	sd	s3,40(sp)
    800013f4:	f052                	sd	s4,32(sp)
    800013f6:	ec56                	sd	s5,24(sp)
    800013f8:	e85a                	sd	s6,16(sp)
    800013fa:	e45e                	sd	s7,8(sp)
    800013fc:	0880                	addi	s0,sp,80
    800013fe:	8b2a                	mv	s6,a0
    80001400:	8bae                	mv	s7,a1
    80001402:	8ab2                	mv	s5,a2
  for (i = 0; i < sz; i += PGSIZE) {
    80001404:	4481                	li	s1,0
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if ((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    80001406:	6a05                	lui	s4,0x1
    80001408:	a021                	j	80001410 <uvmcopy+0x2a>
  for (i = 0; i < sz; i += PGSIZE) {
    8000140a:	94d2                	add	s1,s1,s4
    8000140c:	0554fc63          	bgeu	s1,s5,80001464 <uvmcopy+0x7e>
    if ((pte = walk(old, i, 0)) == 0)
    80001410:	4601                	li	a2,0
    80001412:	85a6                	mv	a1,s1
    80001414:	855a                	mv	a0,s6
    80001416:	b29ff0ef          	jal	80000f3e <walk>
    8000141a:	d965                	beqz	a0,8000140a <uvmcopy+0x24>
    if ((*pte & PTE_V) == 0)
    8000141c:	00053983          	ld	s3,0(a0)
    80001420:	0019f793          	andi	a5,s3,1
    80001424:	d3fd                	beqz	a5,8000140a <uvmcopy+0x24>
    if ((mem = kalloc()) == 0)
    80001426:	ee8ff0ef          	jal	80000b0e <kalloc>
    8000142a:	892a                	mv	s2,a0
    8000142c:	c11d                	beqz	a0,80001452 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000142e:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char *)pa, PGSIZE);
    80001432:	8652                	mv	a2,s4
    80001434:	05b2                	slli	a1,a1,0xc
    80001436:	8d3ff0ef          	jal	80000d08 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    8000143a:	3ff9f713          	andi	a4,s3,1023
    8000143e:	86ca                	mv	a3,s2
    80001440:	8652                	mv	a2,s4
    80001442:	85a6                	mv	a1,s1
    80001444:	855e                	mv	a0,s7
    80001446:	bcdff0ef          	jal	80001012 <mappages>
    8000144a:	d161                	beqz	a0,8000140a <uvmcopy+0x24>
      kfree(mem);
    8000144c:	854a                	mv	a0,s2
    8000144e:	dd8ff0ef          	jal	80000a26 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001452:	4685                	li	a3,1
    80001454:	00c4d613          	srli	a2,s1,0xc
    80001458:	4581                	li	a1,0
    8000145a:	855e                	mv	a0,s7
    8000145c:	d85ff0ef          	jal	800011e0 <uvmunmap>
  return -1;
    80001460:	557d                	li	a0,-1
    80001462:	a011                	j	80001466 <uvmcopy+0x80>
  return 0;
    80001464:	4501                	li	a0,0
}
    80001466:	60a6                	ld	ra,72(sp)
    80001468:	6406                	ld	s0,64(sp)
    8000146a:	74e2                	ld	s1,56(sp)
    8000146c:	7942                	ld	s2,48(sp)
    8000146e:	79a2                	ld	s3,40(sp)
    80001470:	7a02                	ld	s4,32(sp)
    80001472:	6ae2                	ld	s5,24(sp)
    80001474:	6b42                	ld	s6,16(sp)
    80001476:	6ba2                	ld	s7,8(sp)
    80001478:	6161                	addi	sp,sp,80
    8000147a:	8082                	ret
  return 0;
    8000147c:	4501                	li	a0,0
}
    8000147e:	8082                	ret

0000000080001480 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001480:	1141                	addi	sp,sp,-16
    80001482:	e406                	sd	ra,8(sp)
    80001484:	e022                	sd	s0,0(sp)
    80001486:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80001488:	4601                	li	a2,0
    8000148a:	ab5ff0ef          	jal	80000f3e <walk>
  if (pte == 0)
    8000148e:	c901                	beqz	a0,8000149e <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001490:	611c                	ld	a5,0(a0)
    80001492:	9bbd                	andi	a5,a5,-17
    80001494:	e11c                	sd	a5,0(a0)
}
    80001496:	60a2                	ld	ra,8(sp)
    80001498:	6402                	ld	s0,0(sp)
    8000149a:	0141                	addi	sp,sp,16
    8000149c:	8082                	ret
    panic("uvmclear");
    8000149e:	00006517          	auipc	a0,0x6
    800014a2:	caa50513          	addi	a0,a0,-854 # 80007148 <etext+0x148>
    800014a6:	b8eff0ef          	jal	80000834 <panic>

00000000800014aa <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800014aa:	1141                	addi	sp,sp,-16
    800014ac:	e406                	sd	ra,8(sp)
    800014ae:	e022                	sd	s0,0(sp)
    800014b0:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800014b2:	4601                	li	a2,0
    800014b4:	a8bff0ef          	jal	80000f3e <walk>
  if (pte == 0) {
    800014b8:	c119                	beqz	a0,800014be <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V) {
    800014ba:	6108                	ld	a0,0(a0)
    800014bc:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800014be:	60a2                	ld	ra,8(sp)
    800014c0:	6402                	ld	s0,0(sp)
    800014c2:	0141                	addi	sp,sp,16
    800014c4:	8082                	ret

00000000800014c6 <vmfault>:
{
    800014c6:	7179                	addi	sp,sp,-48
    800014c8:	f406                	sd	ra,40(sp)
    800014ca:	f022                	sd	s0,32(sp)
    800014cc:	e052                	sd	s4,0(sp)
    800014ce:	1800                	addi	s0,sp,48
    return 0;
    800014d0:	4a01                	li	s4,0
  if (va >= psz)
    800014d2:	00b66863          	bltu	a2,a1,800014e2 <vmfault+0x1c>
}
    800014d6:	8552                	mv	a0,s4
    800014d8:	70a2                	ld	ra,40(sp)
    800014da:	7402                	ld	s0,32(sp)
    800014dc:	6a02                	ld	s4,0(sp)
    800014de:	6145                	addi	sp,sp,48
    800014e0:	8082                	ret
    800014e2:	ec26                	sd	s1,24(sp)
    800014e4:	e44e                	sd	s3,8(sp)
    800014e6:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    800014e8:	77fd                	lui	a5,0xfffff
    800014ea:	00f679b3          	and	s3,a2,a5
  if (ismapped(pagetable, va)) {
    800014ee:	85ce                	mv	a1,s3
    800014f0:	fbbff0ef          	jal	800014aa <ismapped>
    return 0;
    800014f4:	4a01                	li	s4,0
  if (ismapped(pagetable, va)) {
    800014f6:	c501                	beqz	a0,800014fe <vmfault+0x38>
    800014f8:	64e2                	ld	s1,24(sp)
    800014fa:	69a2                	ld	s3,8(sp)
    800014fc:	bfe9                	j	800014d6 <vmfault+0x10>
    800014fe:	e84a                	sd	s2,16(sp)
  mem = (uint64)kalloc();
    80001500:	e0eff0ef          	jal	80000b0e <kalloc>
    80001504:	892a                	mv	s2,a0
  if (mem == 0)
    80001506:	c915                	beqz	a0,8000153a <vmfault+0x74>
  mem = (uint64)kalloc();
    80001508:	8a2a                	mv	s4,a0
  memset((void *)mem, 0, PGSIZE);
    8000150a:	6605                	lui	a2,0x1
    8000150c:	4581                	li	a1,0
    8000150e:	f9aff0ef          	jal	80000ca8 <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    80001512:	4759                	li	a4,22
    80001514:	86ca                	mv	a3,s2
    80001516:	6605                	lui	a2,0x1
    80001518:	85ce                	mv	a1,s3
    8000151a:	8526                	mv	a0,s1
    8000151c:	af7ff0ef          	jal	80001012 <mappages>
    80001520:	e509                	bnez	a0,8000152a <vmfault+0x64>
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	b77d                	j	800014d6 <vmfault+0x10>
    kfree((void *)mem);
    8000152a:	854a                	mv	a0,s2
    8000152c:	cfaff0ef          	jal	80000a26 <kfree>
    return 0;
    80001530:	4a01                	li	s4,0
    80001532:	64e2                	ld	s1,24(sp)
    80001534:	6942                	ld	s2,16(sp)
    80001536:	69a2                	ld	s3,8(sp)
    80001538:	bf79                	j	800014d6 <vmfault+0x10>
    8000153a:	64e2                	ld	s1,24(sp)
    8000153c:	6942                	ld	s2,16(sp)
    8000153e:	69a2                	ld	s3,8(sp)
    80001540:	bf59                	j	800014d6 <vmfault+0x10>

0000000080001542 <copyout>:
  while (len > 0) {
    80001542:	cf49                	beqz	a4,800015dc <copyout+0x9a>
{
    80001544:	7159                	addi	sp,sp,-112
    80001546:	f486                	sd	ra,104(sp)
    80001548:	f0a2                	sd	s0,96(sp)
    8000154a:	eca6                	sd	s1,88(sp)
    8000154c:	e8ca                	sd	s2,80(sp)
    8000154e:	e4ce                	sd	s3,72(sp)
    80001550:	e0d2                	sd	s4,64(sp)
    80001552:	fc56                	sd	s5,56(sp)
    80001554:	f85a                	sd	s6,48(sp)
    80001556:	f45e                	sd	s7,40(sp)
    80001558:	f062                	sd	s8,32(sp)
    8000155a:	ec66                	sd	s9,24(sp)
    8000155c:	e86a                	sd	s10,16(sp)
    8000155e:	e46e                	sd	s11,8(sp)
    80001560:	1880                	addi	s0,sp,112
    80001562:	8baa                	mv	s7,a0
    80001564:	8dae                	mv	s11,a1
    80001566:	8a32                	mv	s4,a2
    80001568:	8b36                	mv	s6,a3
    8000156a:	8aba                	mv	s5,a4
    va0 = PGROUNDDOWN(dstva);
    8000156c:	7d7d                	lui	s10,0xfffff
    if (va0 >= MAXVA)
    8000156e:	5cfd                	li	s9,-1
    80001570:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001574:	6c05                	lui	s8,0x1
    80001576:	a005                	j	80001596 <copyout+0x54>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001578:	409a0533          	sub	a0,s4,s1
    8000157c:	0009061b          	sext.w	a2,s2
    80001580:	85da                	mv	a1,s6
    80001582:	954e                	add	a0,a0,s3
    80001584:	f84ff0ef          	jal	80000d08 <memmove>
    len -= n;
    80001588:	412a8ab3          	sub	s5,s5,s2
    src += n;
    8000158c:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    8000158e:	01848a33          	add	s4,s1,s8
  while (len > 0) {
    80001592:	040a8363          	beqz	s5,800015d8 <copyout+0x96>
    va0 = PGROUNDDOWN(dstva);
    80001596:	01aa74b3          	and	s1,s4,s10
    if (va0 >= MAXVA)
    8000159a:	049ce363          	bltu	s9,s1,800015e0 <copyout+0x9e>
    pa0 = walkaddr(pagetable, va0);
    8000159e:	85a6                	mv	a1,s1
    800015a0:	855e                	mv	a0,s7
    800015a2:	a37ff0ef          	jal	80000fd8 <walkaddr>
    800015a6:	89aa                	mv	s3,a0
    if (pa0 == 0) {
    800015a8:	e909                	bnez	a0,800015ba <copyout+0x78>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    800015aa:	4681                	li	a3,0
    800015ac:	8626                	mv	a2,s1
    800015ae:	85ee                	mv	a1,s11
    800015b0:	855e                	mv	a0,s7
    800015b2:	f15ff0ef          	jal	800014c6 <vmfault>
    800015b6:	89aa                	mv	s3,a0
    800015b8:	c521                	beqz	a0,80001600 <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    800015ba:	4601                	li	a2,0
    800015bc:	85a6                	mv	a1,s1
    800015be:	855e                	mv	a0,s7
    800015c0:	97fff0ef          	jal	80000f3e <walk>
    if ((*pte & PTE_W) == 0)
    800015c4:	611c                	ld	a5,0(a0)
    800015c6:	8b91                	andi	a5,a5,4
    800015c8:	cf95                	beqz	a5,80001604 <copyout+0xc2>
    n = PGSIZE - (dstva - va0);
    800015ca:	41448933          	sub	s2,s1,s4
    800015ce:	9962                	add	s2,s2,s8
    if (n > len)
    800015d0:	fb2af4e3          	bgeu	s5,s2,80001578 <copyout+0x36>
    800015d4:	8956                	mv	s2,s5
    800015d6:	b74d                	j	80001578 <copyout+0x36>
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	a021                	j	800015e2 <copyout+0xa0>
    800015dc:	4501                	li	a0,0
}
    800015de:	8082                	ret
      return -1;
    800015e0:	557d                	li	a0,-1
}
    800015e2:	70a6                	ld	ra,104(sp)
    800015e4:	7406                	ld	s0,96(sp)
    800015e6:	64e6                	ld	s1,88(sp)
    800015e8:	6946                	ld	s2,80(sp)
    800015ea:	69a6                	ld	s3,72(sp)
    800015ec:	6a06                	ld	s4,64(sp)
    800015ee:	7ae2                	ld	s5,56(sp)
    800015f0:	7b42                	ld	s6,48(sp)
    800015f2:	7ba2                	ld	s7,40(sp)
    800015f4:	7c02                	ld	s8,32(sp)
    800015f6:	6ce2                	ld	s9,24(sp)
    800015f8:	6d42                	ld	s10,16(sp)
    800015fa:	6da2                	ld	s11,8(sp)
    800015fc:	6165                	addi	sp,sp,112
    800015fe:	8082                	ret
        return -1;
    80001600:	557d                	li	a0,-1
    80001602:	b7c5                	j	800015e2 <copyout+0xa0>
      return -1;
    80001604:	557d                	li	a0,-1
    80001606:	bff1                	j	800015e2 <copyout+0xa0>

0000000080001608 <copyin>:
  while (len > 0) {
    80001608:	cf41                	beqz	a4,800016a0 <copyin+0x98>
{
    8000160a:	711d                	addi	sp,sp,-96
    8000160c:	ec86                	sd	ra,88(sp)
    8000160e:	e8a2                	sd	s0,80(sp)
    80001610:	e4a6                	sd	s1,72(sp)
    80001612:	e0ca                	sd	s2,64(sp)
    80001614:	fc4e                	sd	s3,56(sp)
    80001616:	f852                	sd	s4,48(sp)
    80001618:	f456                	sd	s5,40(sp)
    8000161a:	f05a                	sd	s6,32(sp)
    8000161c:	ec5e                	sd	s7,24(sp)
    8000161e:	e862                	sd	s8,16(sp)
    80001620:	e466                	sd	s9,8(sp)
    80001622:	e06a                	sd	s10,0(sp)
    80001624:	1080                	addi	s0,sp,96
    80001626:	8baa                	mv	s7,a0
    80001628:	8cae                	mv	s9,a1
    8000162a:	8ab2                	mv	s5,a2
    8000162c:	8936                	mv	s2,a3
    8000162e:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    80001630:	7c7d                	lui	s8,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001632:	4d05                	li	s10,1
    n = PGSIZE - (srcva - va0);
    80001634:	6b05                	lui	s6,0x1
    80001636:	a035                	j	80001662 <copyin+0x5a>
    80001638:	412984b3          	sub	s1,s3,s2
    8000163c:	94da                	add	s1,s1,s6
    if (n > len)
    8000163e:	009a7363          	bgeu	s4,s1,80001644 <copyin+0x3c>
    80001642:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001644:	413905b3          	sub	a1,s2,s3
    80001648:	0004861b          	sext.w	a2,s1
    8000164c:	95aa                	add	a1,a1,a0
    8000164e:	8556                	mv	a0,s5
    80001650:	eb8ff0ef          	jal	80000d08 <memmove>
    len -= n;
    80001654:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001658:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000165a:	01698933          	add	s2,s3,s6
  while (len > 0) {
    8000165e:	020a0263          	beqz	s4,80001682 <copyin+0x7a>
    va0 = PGROUNDDOWN(srcva);
    80001662:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001666:	85ce                	mv	a1,s3
    80001668:	855e                	mv	a0,s7
    8000166a:	96fff0ef          	jal	80000fd8 <walkaddr>
    if (pa0 == 0) {
    8000166e:	f569                	bnez	a0,80001638 <copyin+0x30>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001670:	86ea                	mv	a3,s10
    80001672:	864e                	mv	a2,s3
    80001674:	85e6                	mv	a1,s9
    80001676:	855e                	mv	a0,s7
    80001678:	e4fff0ef          	jal	800014c6 <vmfault>
    8000167c:	fd55                	bnez	a0,80001638 <copyin+0x30>
        return -1;
    8000167e:	557d                	li	a0,-1
    80001680:	a011                	j	80001684 <copyin+0x7c>
  return 0;
    80001682:	4501                	li	a0,0
}
    80001684:	60e6                	ld	ra,88(sp)
    80001686:	6446                	ld	s0,80(sp)
    80001688:	64a6                	ld	s1,72(sp)
    8000168a:	6906                	ld	s2,64(sp)
    8000168c:	79e2                	ld	s3,56(sp)
    8000168e:	7a42                	ld	s4,48(sp)
    80001690:	7aa2                	ld	s5,40(sp)
    80001692:	7b02                	ld	s6,32(sp)
    80001694:	6be2                	ld	s7,24(sp)
    80001696:	6c42                	ld	s8,16(sp)
    80001698:	6ca2                	ld	s9,8(sp)
    8000169a:	6d02                	ld	s10,0(sp)
    8000169c:	6125                	addi	sp,sp,96
    8000169e:	8082                	ret
  return 0;
    800016a0:	4501                	li	a0,0
}
    800016a2:	8082                	ret

00000000800016a4 <copyinstr>:
  while (got_null == 0 && max > 0) {
    800016a4:	c769                	beqz	a4,8000176e <copyinstr+0xca>
{
    800016a6:	711d                	addi	sp,sp,-96
    800016a8:	ec86                	sd	ra,88(sp)
    800016aa:	e8a2                	sd	s0,80(sp)
    800016ac:	e4a6                	sd	s1,72(sp)
    800016ae:	e0ca                	sd	s2,64(sp)
    800016b0:	fc4e                	sd	s3,56(sp)
    800016b2:	f852                	sd	s4,48(sp)
    800016b4:	f456                	sd	s5,40(sp)
    800016b6:	f05a                	sd	s6,32(sp)
    800016b8:	ec5e                	sd	s7,24(sp)
    800016ba:	e862                	sd	s8,16(sp)
    800016bc:	e466                	sd	s9,8(sp)
    800016be:	1080                	addi	s0,sp,96
    800016c0:	8b2a                	mv	s6,a0
    800016c2:	8c2e                	mv	s8,a1
    800016c4:	89b2                	mv	s3,a2
    800016c6:	84b6                	mv	s1,a3
    800016c8:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    800016ca:	7bfd                	lui	s7,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800016cc:	4c85                	li	s9,1
    n = PGSIZE - (srcva - va0);
    800016ce:	6a85                	lui	s5,0x1
    800016d0:	a881                	j	80001720 <copyinstr+0x7c>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800016d2:	86e6                	mv	a3,s9
    800016d4:	864a                	mv	a2,s2
    800016d6:	85e2                	mv	a1,s8
    800016d8:	855a                	mv	a0,s6
    800016da:	dedff0ef          	jal	800014c6 <vmfault>
    800016de:	e921                	bnez	a0,8000172e <copyinstr+0x8a>
        return -1;
    800016e0:	557d                	li	a0,-1
    800016e2:	a801                	j	800016f2 <copyinstr+0x4e>
        *dst = '\0';
    800016e4:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdba00>
        got_null = 1;
    800016e8:	4785                	li	a5,1
  if (got_null) {
    800016ea:	0017c793          	xori	a5,a5,1
    800016ee:	40f0053b          	negw	a0,a5
}
    800016f2:	60e6                	ld	ra,88(sp)
    800016f4:	6446                	ld	s0,80(sp)
    800016f6:	64a6                	ld	s1,72(sp)
    800016f8:	6906                	ld	s2,64(sp)
    800016fa:	79e2                	ld	s3,56(sp)
    800016fc:	7a42                	ld	s4,48(sp)
    800016fe:	7aa2                	ld	s5,40(sp)
    80001700:	7b02                	ld	s6,32(sp)
    80001702:	6be2                	ld	s7,24(sp)
    80001704:	6c42                	ld	s8,16(sp)
    80001706:	6ca2                	ld	s9,8(sp)
    80001708:	6125                	addi	sp,sp,96
    8000170a:	8082                	ret
    8000170c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80001710:	974e                	add	a4,a4,s3
      --max;
    80001712:	40b70a33          	sub	s4,a4,a1
    srcva = va0 + PGSIZE;
    80001716:	015904b3          	add	s1,s2,s5
  while (got_null == 0 && max > 0) {
    8000171a:	04e58463          	beq	a1,a4,80001762 <copyinstr+0xbe>
{
    8000171e:	89be                	mv	s3,a5
    va0 = PGROUNDDOWN(srcva);
    80001720:	0174f933          	and	s2,s1,s7
    pa0 = walkaddr(pagetable, va0);
    80001724:	85ca                	mv	a1,s2
    80001726:	855a                	mv	a0,s6
    80001728:	8b1ff0ef          	jal	80000fd8 <walkaddr>
    if (pa0 == 0) {
    8000172c:	d15d                	beqz	a0,800016d2 <copyinstr+0x2e>
    n = PGSIZE - (srcva - va0);
    8000172e:	40990633          	sub	a2,s2,s1
    80001732:	9656                	add	a2,a2,s5
    if (n > max)
    80001734:	00ca7363          	bgeu	s4,a2,8000173a <copyinstr+0x96>
    80001738:	8652                	mv	a2,s4
    while (n > 0) {
    8000173a:	c615                	beqz	a2,80001766 <copyinstr+0xc2>
    char *p = (char *)(pa0 + (srcva - va0));
    8000173c:	412484b3          	sub	s1,s1,s2
    80001740:	94aa                	add	s1,s1,a0
    80001742:	87ce                	mv	a5,s3
      if (*p == '\0') {
    80001744:	413484b3          	sub	s1,s1,s3
    while (n > 0) {
    80001748:	964e                	add	a2,a2,s3
    8000174a:	85be                	mv	a1,a5
      if (*p == '\0') {
    8000174c:	00f48733          	add	a4,s1,a5
    80001750:	00074683          	lbu	a3,0(a4)
    80001754:	dac1                	beqz	a3,800016e4 <copyinstr+0x40>
        *dst = *p;
    80001756:	00d78023          	sb	a3,0(a5)
      dst++;
    8000175a:	0785                	addi	a5,a5,1
    while (n > 0) {
    8000175c:	fec797e3          	bne	a5,a2,8000174a <copyinstr+0xa6>
    80001760:	b775                	j	8000170c <copyinstr+0x68>
    80001762:	4781                	li	a5,0
    80001764:	b759                	j	800016ea <copyinstr+0x46>
    srcva = va0 + PGSIZE;
    80001766:	6485                	lui	s1,0x1
    80001768:	94ca                	add	s1,s1,s2
    8000176a:	87ce                	mv	a5,s3
    8000176c:	bf4d                	j	8000171e <copyinstr+0x7a>
  int got_null = 0;
    8000176e:	4781                	li	a5,0
  if (got_null) {
    80001770:	0017c793          	xori	a5,a5,1
    80001774:	40f0053b          	negw	a0,a5
}
    80001778:	8082                	ret

000000008000177a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000177a:	715d                	addi	sp,sp,-80
    8000177c:	e486                	sd	ra,72(sp)
    8000177e:	e0a2                	sd	s0,64(sp)
    80001780:	fc26                	sd	s1,56(sp)
    80001782:	f84a                	sd	s2,48(sp)
    80001784:	f44e                	sd	s3,40(sp)
    80001786:	f052                	sd	s4,32(sp)
    80001788:	ec56                	sd	s5,24(sp)
    8000178a:	e85a                	sd	s6,16(sp)
    8000178c:	e45e                	sd	s7,8(sp)
    8000178e:	e062                	sd	s8,0(sp)
    80001790:	0880                	addi	s0,sp,80
    80001792:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001794:	00011497          	auipc	s1,0x11
    80001798:	08c48493          	addi	s1,s1,140 # 80012820 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000179c:	8c26                	mv	s8,s1
    8000179e:	000a57b7          	lui	a5,0xa5
    800017a2:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800017a6:	07b2                	slli	a5,a5,0xc
    800017a8:	fa578793          	addi	a5,a5,-91
    800017ac:	4fa50937          	lui	s2,0x4fa50
    800017b0:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800017b4:	1902                	slli	s2,s2,0x20
    800017b6:	993e                	add	s2,s2,a5
    800017b8:	040009b7          	lui	s3,0x4000
    800017bc:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017be:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c0:	4b99                	li	s7,6
    800017c2:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    800017c4:	00017a97          	auipc	s5,0x17
    800017c8:	a5ca8a93          	addi	s5,s5,-1444 # 80018220 <tickslock>
    char *pa = kalloc();
    800017cc:	b42ff0ef          	jal	80000b0e <kalloc>
    800017d0:	862a                	mv	a2,a0
    if (pa == 0)
    800017d2:	c121                	beqz	a0,80001812 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    800017d4:	418485b3          	sub	a1,s1,s8
    800017d8:	858d                	srai	a1,a1,0x3
    800017da:	032585b3          	mul	a1,a1,s2
    800017de:	05b6                	slli	a1,a1,0xd
    800017e0:	6789                	lui	a5,0x2
    800017e2:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017e4:	875e                	mv	a4,s7
    800017e6:	86da                	mv	a3,s6
    800017e8:	40b985b3          	sub	a1,s3,a1
    800017ec:	8552                	mv	a0,s4
    800017ee:	8dbff0ef          	jal	800010c8 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    800017f2:	16848493          	addi	s1,s1,360
    800017f6:	fd549be3          	bne	s1,s5,800017cc <proc_mapstacks+0x52>
  }
}
    800017fa:	60a6                	ld	ra,72(sp)
    800017fc:	6406                	ld	s0,64(sp)
    800017fe:	74e2                	ld	s1,56(sp)
    80001800:	7942                	ld	s2,48(sp)
    80001802:	79a2                	ld	s3,40(sp)
    80001804:	7a02                	ld	s4,32(sp)
    80001806:	6ae2                	ld	s5,24(sp)
    80001808:	6b42                	ld	s6,16(sp)
    8000180a:	6ba2                	ld	s7,8(sp)
    8000180c:	6c02                	ld	s8,0(sp)
    8000180e:	6161                	addi	sp,sp,80
    80001810:	8082                	ret
      panic("kalloc");
    80001812:	00006517          	auipc	a0,0x6
    80001816:	94650513          	addi	a0,a0,-1722 # 80007158 <etext+0x158>
    8000181a:	81aff0ef          	jal	80000834 <panic>

000000008000181e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000181e:	7139                	addi	sp,sp,-64
    80001820:	fc06                	sd	ra,56(sp)
    80001822:	f822                	sd	s0,48(sp)
    80001824:	f426                	sd	s1,40(sp)
    80001826:	f04a                	sd	s2,32(sp)
    80001828:	ec4e                	sd	s3,24(sp)
    8000182a:	e852                	sd	s4,16(sp)
    8000182c:	e456                	sd	s5,8(sp)
    8000182e:	e05a                	sd	s6,0(sp)
    80001830:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001832:	00006597          	auipc	a1,0x6
    80001836:	92e58593          	addi	a1,a1,-1746 # 80007160 <etext+0x160>
    8000183a:	00011517          	auipc	a0,0x11
    8000183e:	bb650513          	addi	a0,a0,-1098 # 800123f0 <pid_lock>
    80001842:	b26ff0ef          	jal	80000b68 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001846:	00006597          	auipc	a1,0x6
    8000184a:	92258593          	addi	a1,a1,-1758 # 80007168 <etext+0x168>
    8000184e:	00011517          	auipc	a0,0x11
    80001852:	bba50513          	addi	a0,a0,-1094 # 80012408 <wait_lock>
    80001856:	b12ff0ef          	jal	80000b68 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000185a:	00011497          	auipc	s1,0x11
    8000185e:	fc648493          	addi	s1,s1,-58 # 80012820 <proc>
    initlock(&p->lock, "proc");
    80001862:	00006b17          	auipc	s6,0x6
    80001866:	916b0b13          	addi	s6,s6,-1770 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000186a:	8aa6                	mv	s5,s1
    8000186c:	000a57b7          	lui	a5,0xa5
    80001870:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001874:	07b2                	slli	a5,a5,0xc
    80001876:	fa578793          	addi	a5,a5,-91
    8000187a:	4fa50937          	lui	s2,0x4fa50
    8000187e:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001882:	1902                	slli	s2,s2,0x20
    80001884:	993e                	add	s2,s2,a5
    80001886:	040009b7          	lui	s3,0x4000
    8000188a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000188c:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    8000188e:	00017a17          	auipc	s4,0x17
    80001892:	992a0a13          	addi	s4,s4,-1646 # 80018220 <tickslock>
    initlock(&p->lock, "proc");
    80001896:	85da                	mv	a1,s6
    80001898:	8526                	mv	a0,s1
    8000189a:	aceff0ef          	jal	80000b68 <initlock>
    p->state = UNUSED;
    8000189e:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800018a2:	415487b3          	sub	a5,s1,s5
    800018a6:	878d                	srai	a5,a5,0x3
    800018a8:	032787b3          	mul	a5,a5,s2
    800018ac:	07b6                	slli	a5,a5,0xd
    800018ae:	6709                	lui	a4,0x2
    800018b0:	9fb9                	addw	a5,a5,a4
    800018b2:	40f987b3          	sub	a5,s3,a5
    800018b6:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    800018b8:	16848493          	addi	s1,s1,360
    800018bc:	fd449de3          	bne	s1,s4,80001896 <procinit+0x78>
  }
}
    800018c0:	70e2                	ld	ra,56(sp)
    800018c2:	7442                	ld	s0,48(sp)
    800018c4:	74a2                	ld	s1,40(sp)
    800018c6:	7902                	ld	s2,32(sp)
    800018c8:	69e2                	ld	s3,24(sp)
    800018ca:	6a42                	ld	s4,16(sp)
    800018cc:	6aa2                	ld	s5,8(sp)
    800018ce:	6b02                	ld	s6,0(sp)
    800018d0:	6121                	addi	sp,sp,64
    800018d2:	8082                	ret

00000000800018d4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018d4:	1141                	addi	sp,sp,-16
    800018d6:	e406                	sd	ra,8(sp)
    800018d8:	e022                	sd	s0,0(sp)
    800018da:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    800018dc:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018de:	2501                	sext.w	a0,a0
    800018e0:	60a2                	ld	ra,8(sp)
    800018e2:	6402                	ld	s0,0(sp)
    800018e4:	0141                	addi	sp,sp,16
    800018e6:	8082                	ret

00000000800018e8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800018e8:	1141                	addi	sp,sp,-16
    800018ea:	e406                	sd	ra,8(sp)
    800018ec:	e022                	sd	s0,0(sp)
    800018ee:	0800                	addi	s0,sp,16
    800018f0:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018f2:	2781                	sext.w	a5,a5
    800018f4:	079e                	slli	a5,a5,0x7
  return c;
}
    800018f6:	00011517          	auipc	a0,0x11
    800018fa:	b2a50513          	addi	a0,a0,-1238 # 80012420 <cpus>
    800018fe:	953e                	add	a0,a0,a5
    80001900:	60a2                	ld	ra,8(sp)
    80001902:	6402                	ld	s0,0(sp)
    80001904:	0141                	addi	sp,sp,16
    80001906:	8082                	ret

0000000080001908 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001908:	1101                	addi	sp,sp,-32
    8000190a:	ec06                	sd	ra,24(sp)
    8000190c:	e822                	sd	s0,16(sp)
    8000190e:	e426                	sd	s1,8(sp)
    80001910:	1000                	addi	s0,sp,32
  push_off();
    80001912:	a9cff0ef          	jal	80000bae <push_off>
    80001916:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001918:	2781                	sext.w	a5,a5
    8000191a:	079e                	slli	a5,a5,0x7
    8000191c:	00011717          	auipc	a4,0x11
    80001920:	ad470713          	addi	a4,a4,-1324 # 800123f0 <pid_lock>
    80001924:	97ba                	add	a5,a5,a4
    80001926:	7b9c                	ld	a5,48(a5)
    80001928:	84be                	mv	s1,a5
  pop_off();
    8000192a:	afeff0ef          	jal	80000c28 <pop_off>
  return p;
}
    8000192e:	8526                	mv	a0,s1
    80001930:	60e2                	ld	ra,24(sp)
    80001932:	6442                	ld	s0,16(sp)
    80001934:	64a2                	ld	s1,8(sp)
    80001936:	6105                	addi	sp,sp,32
    80001938:	8082                	ret

000000008000193a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000193a:	7179                	addi	sp,sp,-48
    8000193c:	f406                	sd	ra,40(sp)
    8000193e:	f022                	sd	s0,32(sp)
    80001940:	ec26                	sd	s1,24(sp)
    80001942:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001944:	fc5ff0ef          	jal	80001908 <myproc>
    80001948:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    8000194a:	b26ff0ef          	jal	80000c70 <release>

  if (__atomic_load_n(&first, __ATOMIC_ACQUIRE)) {
    8000194e:	00009797          	auipc	a5,0x9
    80001952:	93278793          	addi	a5,a5,-1742 # 8000a280 <first.1>
    80001956:	439c                	lw	a5,0(a5)
    80001958:	0230000f          	fence	r,rw
    8000195c:	2781                	sext.w	a5,a5
    8000195e:	c3a1                	beqz	a5,8000199e <forkret+0x64>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001960:	4505                	li	a0,1
    80001962:	40f010ef          	jal	80003570 <fsinit>

    // ensure other cores see first=0.
    __atomic_store_n(&first, 0, __ATOMIC_RELEASE);
    80001966:	00009797          	auipc	a5,0x9
    8000196a:	91a78793          	addi	a5,a5,-1766 # 8000a280 <first.1>
    8000196e:	0310000f          	fence	rw,w
    80001972:	0007a023          	sw	zero,0(a5)

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001976:	00006797          	auipc	a5,0x6
    8000197a:	80a78793          	addi	a5,a5,-2038 # 80007180 <etext+0x180>
    8000197e:	fcf43823          	sd	a5,-48(s0)
    80001982:	fc043c23          	sd	zero,-40(s0)
    80001986:	fd040593          	addi	a1,s0,-48
    8000198a:	853e                	mv	a0,a5
    8000198c:	667020ef          	jal	800047f2 <kexec>
    80001990:	6cbc                	ld	a5,88(s1)
    80001992:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001994:	6cbc                	ld	a5,88(s1)
    80001996:	7bb8                	ld	a4,112(a5)
    80001998:	57fd                	li	a5,-1
    8000199a:	02f70d63          	beq	a4,a5,800019d4 <forkret+0x9a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    8000199e:	2f7000ef          	jal	80002494 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019a2:	68a8                	ld	a0,80(s1)
    800019a4:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019a6:	04000737          	lui	a4,0x4000
    800019aa:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019ac:	0732                	slli	a4,a4,0xc
    800019ae:	00004797          	auipc	a5,0x4
    800019b2:	6ee78793          	addi	a5,a5,1774 # 8000609c <userret>
    800019b6:	00004697          	auipc	a3,0x4
    800019ba:	64a68693          	addi	a3,a3,1610 # 80006000 <_trampoline>
    800019be:	8f95                	sub	a5,a5,a3
    800019c0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019c2:	577d                	li	a4,-1
    800019c4:	177e                	slli	a4,a4,0x3f
    800019c6:	8d59                	or	a0,a0,a4
    800019c8:	9782                	jalr	a5
}
    800019ca:	70a2                	ld	ra,40(sp)
    800019cc:	7402                	ld	s0,32(sp)
    800019ce:	64e2                	ld	s1,24(sp)
    800019d0:	6145                	addi	sp,sp,48
    800019d2:	8082                	ret
      panic("exec");
    800019d4:	00005517          	auipc	a0,0x5
    800019d8:	7b450513          	addi	a0,a0,1972 # 80007188 <etext+0x188>
    800019dc:	e59fe0ef          	jal	80000834 <panic>

00000000800019e0 <allocpid>:
{
    800019e0:	1101                	addi	sp,sp,-32
    800019e2:	ec06                	sd	ra,24(sp)
    800019e4:	e822                	sd	s0,16(sp)
    800019e6:	e426                	sd	s1,8(sp)
    800019e8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019ea:	00011517          	auipc	a0,0x11
    800019ee:	a0650513          	addi	a0,a0,-1530 # 800123f0 <pid_lock>
    800019f2:	9f6ff0ef          	jal	80000be8 <acquire>
  pid = nextpid;
    800019f6:	00009797          	auipc	a5,0x9
    800019fa:	88e78793          	addi	a5,a5,-1906 # 8000a284 <nextpid>
    800019fe:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a00:	0014871b          	addiw	a4,s1,1
    80001a04:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a06:	00011517          	auipc	a0,0x11
    80001a0a:	9ea50513          	addi	a0,a0,-1558 # 800123f0 <pid_lock>
    80001a0e:	a62ff0ef          	jal	80000c70 <release>
}
    80001a12:	8526                	mv	a0,s1
    80001a14:	60e2                	ld	ra,24(sp)
    80001a16:	6442                	ld	s0,16(sp)
    80001a18:	64a2                	ld	s1,8(sp)
    80001a1a:	6105                	addi	sp,sp,32
    80001a1c:	8082                	ret

0000000080001a1e <proc_pagetable>:
{
    80001a1e:	1101                	addi	sp,sp,-32
    80001a20:	ec06                	sd	ra,24(sp)
    80001a22:	e822                	sd	s0,16(sp)
    80001a24:	e426                	sd	s1,8(sp)
    80001a26:	e04a                	sd	s2,0(sp)
    80001a28:	1000                	addi	s0,sp,32
    80001a2a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a2c:	f8eff0ef          	jal	800011ba <uvmcreate>
    80001a30:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a32:	cd05                	beqz	a0,80001a6a <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a34:	4729                	li	a4,10
    80001a36:	00004697          	auipc	a3,0x4
    80001a3a:	5ca68693          	addi	a3,a3,1482 # 80006000 <_trampoline>
    80001a3e:	6605                	lui	a2,0x1
    80001a40:	040005b7          	lui	a1,0x4000
    80001a44:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a46:	05b2                	slli	a1,a1,0xc
    80001a48:	dcaff0ef          	jal	80001012 <mappages>
    80001a4c:	02054663          	bltz	a0,80001a78 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001a50:	4719                	li	a4,6
    80001a52:	05893683          	ld	a3,88(s2)
    80001a56:	6605                	lui	a2,0x1
    80001a58:	020005b7          	lui	a1,0x2000
    80001a5c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a5e:	05b6                	slli	a1,a1,0xd
    80001a60:	8526                	mv	a0,s1
    80001a62:	db0ff0ef          	jal	80001012 <mappages>
    80001a66:	00054f63          	bltz	a0,80001a84 <proc_pagetable+0x66>
}
    80001a6a:	8526                	mv	a0,s1
    80001a6c:	60e2                	ld	ra,24(sp)
    80001a6e:	6442                	ld	s0,16(sp)
    80001a70:	64a2                	ld	s1,8(sp)
    80001a72:	6902                	ld	s2,0(sp)
    80001a74:	6105                	addi	sp,sp,32
    80001a76:	8082                	ret
    uvmfree(pagetable, 0);
    80001a78:	4581                	li	a1,0
    80001a7a:	8526                	mv	a0,s1
    80001a7c:	939ff0ef          	jal	800013b4 <uvmfree>
    return 0;
    80001a80:	4481                	li	s1,0
    80001a82:	b7e5                	j	80001a6a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a84:	4681                	li	a3,0
    80001a86:	4605                	li	a2,1
    80001a88:	040005b7          	lui	a1,0x4000
    80001a8c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a8e:	05b2                	slli	a1,a1,0xc
    80001a90:	8526                	mv	a0,s1
    80001a92:	f4eff0ef          	jal	800011e0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a96:	4581                	li	a1,0
    80001a98:	8526                	mv	a0,s1
    80001a9a:	91bff0ef          	jal	800013b4 <uvmfree>
    return 0;
    80001a9e:	4481                	li	s1,0
    80001aa0:	b7e9                	j	80001a6a <proc_pagetable+0x4c>

0000000080001aa2 <proc_freepagetable>:
{
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
    80001aae:	84aa                	mv	s1,a0
    80001ab0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ab2:	4681                	li	a3,0
    80001ab4:	4605                	li	a2,1
    80001ab6:	040005b7          	lui	a1,0x4000
    80001aba:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001abc:	05b2                	slli	a1,a1,0xc
    80001abe:	f22ff0ef          	jal	800011e0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ac2:	4681                	li	a3,0
    80001ac4:	4605                	li	a2,1
    80001ac6:	020005b7          	lui	a1,0x2000
    80001aca:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001acc:	05b6                	slli	a1,a1,0xd
    80001ace:	8526                	mv	a0,s1
    80001ad0:	f10ff0ef          	jal	800011e0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ad4:	85ca                	mv	a1,s2
    80001ad6:	8526                	mv	a0,s1
    80001ad8:	8ddff0ef          	jal	800013b4 <uvmfree>
}
    80001adc:	60e2                	ld	ra,24(sp)
    80001ade:	6442                	ld	s0,16(sp)
    80001ae0:	64a2                	ld	s1,8(sp)
    80001ae2:	6902                	ld	s2,0(sp)
    80001ae4:	6105                	addi	sp,sp,32
    80001ae6:	8082                	ret

0000000080001ae8 <freeproc>:
{
    80001ae8:	1101                	addi	sp,sp,-32
    80001aea:	ec06                	sd	ra,24(sp)
    80001aec:	e822                	sd	s0,16(sp)
    80001aee:	e426                	sd	s1,8(sp)
    80001af0:	1000                	addi	s0,sp,32
    80001af2:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001af4:	6d28                	ld	a0,88(a0)
    80001af6:	c119                	beqz	a0,80001afc <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001af8:	f2ffe0ef          	jal	80000a26 <kfree>
  p->trapframe = 0;
    80001afc:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b00:	68a8                	ld	a0,80(s1)
    80001b02:	c501                	beqz	a0,80001b0a <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b04:	64ac                	ld	a1,72(s1)
    80001b06:	f9dff0ef          	jal	80001aa2 <proc_freepagetable>
  p->pagetable = 0;
    80001b0a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b0e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b12:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001b16:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b1a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b1e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b22:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b26:	0004ac23          	sw	zero,24(s1)
}
    80001b2a:	60e2                	ld	ra,24(sp)
    80001b2c:	6442                	ld	s0,16(sp)
    80001b2e:	64a2                	ld	s1,8(sp)
    80001b30:	6105                	addi	sp,sp,32
    80001b32:	8082                	ret

0000000080001b34 <allocproc>:
{
    80001b34:	1101                	addi	sp,sp,-32
    80001b36:	ec06                	sd	ra,24(sp)
    80001b38:	e822                	sd	s0,16(sp)
    80001b3a:	e426                	sd	s1,8(sp)
    80001b3c:	e04a                	sd	s2,0(sp)
    80001b3e:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b40:	00011497          	auipc	s1,0x11
    80001b44:	ce048493          	addi	s1,s1,-800 # 80012820 <proc>
    80001b48:	00016917          	auipc	s2,0x16
    80001b4c:	6d890913          	addi	s2,s2,1752 # 80018220 <tickslock>
    acquire(&p->lock);
    80001b50:	8526                	mv	a0,s1
    80001b52:	896ff0ef          	jal	80000be8 <acquire>
    if (p->state == UNUSED) {
    80001b56:	4c9c                	lw	a5,24(s1)
    80001b58:	cb91                	beqz	a5,80001b6c <allocproc+0x38>
      release(&p->lock);
    80001b5a:	8526                	mv	a0,s1
    80001b5c:	914ff0ef          	jal	80000c70 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b60:	16848493          	addi	s1,s1,360
    80001b64:	ff2496e3          	bne	s1,s2,80001b50 <allocproc+0x1c>
  return 0;
    80001b68:	4481                	li	s1,0
    80001b6a:	a089                	j	80001bac <allocproc+0x78>
  p->pid = allocpid();
    80001b6c:	e75ff0ef          	jal	800019e0 <allocpid>
    80001b70:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b72:	4785                	li	a5,1
    80001b74:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001b76:	f99fe0ef          	jal	80000b0e <kalloc>
    80001b7a:	892a                	mv	s2,a0
    80001b7c:	eca8                	sd	a0,88(s1)
    80001b7e:	cd15                	beqz	a0,80001bba <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b80:	8526                	mv	a0,s1
    80001b82:	e9dff0ef          	jal	80001a1e <proc_pagetable>
    80001b86:	892a                	mv	s2,a0
    80001b88:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001b8a:	c121                	beqz	a0,80001bca <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b8c:	07000613          	li	a2,112
    80001b90:	4581                	li	a1,0
    80001b92:	06048513          	addi	a0,s1,96
    80001b96:	912ff0ef          	jal	80000ca8 <memset>
  p->context.ra = (uint64)forkret;
    80001b9a:	00000797          	auipc	a5,0x0
    80001b9e:	da078793          	addi	a5,a5,-608 # 8000193a <forkret>
    80001ba2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ba4:	60bc                	ld	a5,64(s1)
    80001ba6:	6705                	lui	a4,0x1
    80001ba8:	97ba                	add	a5,a5,a4
    80001baa:	f4bc                	sd	a5,104(s1)
}
    80001bac:	8526                	mv	a0,s1
    80001bae:	60e2                	ld	ra,24(sp)
    80001bb0:	6442                	ld	s0,16(sp)
    80001bb2:	64a2                	ld	s1,8(sp)
    80001bb4:	6902                	ld	s2,0(sp)
    80001bb6:	6105                	addi	sp,sp,32
    80001bb8:	8082                	ret
    freeproc(p);
    80001bba:	8526                	mv	a0,s1
    80001bbc:	f2dff0ef          	jal	80001ae8 <freeproc>
    release(&p->lock);
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	8aeff0ef          	jal	80000c70 <release>
    return 0;
    80001bc6:	84ca                	mv	s1,s2
    80001bc8:	b7d5                	j	80001bac <allocproc+0x78>
    freeproc(p);
    80001bca:	8526                	mv	a0,s1
    80001bcc:	f1dff0ef          	jal	80001ae8 <freeproc>
    release(&p->lock);
    80001bd0:	8526                	mv	a0,s1
    80001bd2:	89eff0ef          	jal	80000c70 <release>
    return 0;
    80001bd6:	84ca                	mv	s1,s2
    80001bd8:	bfd1                	j	80001bac <allocproc+0x78>

0000000080001bda <userinit>:
{
    80001bda:	1101                	addi	sp,sp,-32
    80001bdc:	ec06                	sd	ra,24(sp)
    80001bde:	e822                	sd	s0,16(sp)
    80001be0:	e426                	sd	s1,8(sp)
    80001be2:	1000                	addi	s0,sp,32
  p = allocproc();
    80001be4:	f51ff0ef          	jal	80001b34 <allocproc>
    80001be8:	84aa                	mv	s1,a0
  initproc = p;
    80001bea:	00008797          	auipc	a5,0x8
    80001bee:	6ca7bf23          	sd	a0,1758(a5) # 8000a2c8 <initproc>
  p->cwd = namei("/");
    80001bf2:	00005517          	auipc	a0,0x5
    80001bf6:	59e50513          	addi	a0,a0,1438 # 80007190 <etext+0x190>
    80001bfa:	6c7010ef          	jal	80003ac0 <namei>
    80001bfe:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c02:	478d                	li	a5,3
    80001c04:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c06:	8526                	mv	a0,s1
    80001c08:	868ff0ef          	jal	80000c70 <release>
}
    80001c0c:	60e2                	ld	ra,24(sp)
    80001c0e:	6442                	ld	s0,16(sp)
    80001c10:	64a2                	ld	s1,8(sp)
    80001c12:	6105                	addi	sp,sp,32
    80001c14:	8082                	ret

0000000080001c16 <growproc>:
{
    80001c16:	1101                	addi	sp,sp,-32
    80001c18:	ec06                	sd	ra,24(sp)
    80001c1a:	e822                	sd	s0,16(sp)
    80001c1c:	e426                	sd	s1,8(sp)
    80001c1e:	e04a                	sd	s2,0(sp)
    80001c20:	1000                	addi	s0,sp,32
    80001c22:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c24:	ce5ff0ef          	jal	80001908 <myproc>
    80001c28:	892a                	mv	s2,a0
  sz = p->sz;
    80001c2a:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c2c:	02905963          	blez	s1,80001c5e <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c30:	00b48633          	add	a2,s1,a1
    80001c34:	020007b7          	lui	a5,0x2000
    80001c38:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c3a:	07b6                	slli	a5,a5,0xd
    80001c3c:	02c7ea63          	bltu	a5,a2,80001c70 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c40:	4691                	li	a3,4
    80001c42:	6928                	ld	a0,80(a0)
    80001c44:	e6aff0ef          	jal	800012ae <uvmalloc>
    80001c48:	85aa                	mv	a1,a0
    80001c4a:	c50d                	beqz	a0,80001c74 <growproc+0x5e>
  p->sz = sz;
    80001c4c:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c50:	4501                	li	a0,0
}
    80001c52:	60e2                	ld	ra,24(sp)
    80001c54:	6442                	ld	s0,16(sp)
    80001c56:	64a2                	ld	s1,8(sp)
    80001c58:	6902                	ld	s2,0(sp)
    80001c5a:	6105                	addi	sp,sp,32
    80001c5c:	8082                	ret
  } else if (n < 0) {
    80001c5e:	fe04d7e3          	bgez	s1,80001c4c <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c62:	00b48633          	add	a2,s1,a1
    80001c66:	6928                	ld	a0,80(a0)
    80001c68:	e02ff0ef          	jal	8000126a <uvmdealloc>
    80001c6c:	85aa                	mv	a1,a0
    80001c6e:	bff9                	j	80001c4c <growproc+0x36>
      return -1;
    80001c70:	557d                	li	a0,-1
    80001c72:	b7c5                	j	80001c52 <growproc+0x3c>
      return -1;
    80001c74:	557d                	li	a0,-1
    80001c76:	bff1                	j	80001c52 <growproc+0x3c>

0000000080001c78 <kfork>:
{
    80001c78:	7139                	addi	sp,sp,-64
    80001c7a:	fc06                	sd	ra,56(sp)
    80001c7c:	f822                	sd	s0,48(sp)
    80001c7e:	f426                	sd	s1,40(sp)
    80001c80:	e456                	sd	s5,8(sp)
    80001c82:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c84:	c85ff0ef          	jal	80001908 <myproc>
    80001c88:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001c8a:	eabff0ef          	jal	80001b34 <allocproc>
    80001c8e:	0e050a63          	beqz	a0,80001d82 <kfork+0x10a>
    80001c92:	e852                	sd	s4,16(sp)
    80001c94:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001c96:	048ab603          	ld	a2,72(s5)
    80001c9a:	692c                	ld	a1,80(a0)
    80001c9c:	050ab503          	ld	a0,80(s5)
    80001ca0:	f46ff0ef          	jal	800013e6 <uvmcopy>
    80001ca4:	04054863          	bltz	a0,80001cf4 <kfork+0x7c>
    80001ca8:	f04a                	sd	s2,32(sp)
    80001caa:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001cac:	048ab783          	ld	a5,72(s5)
    80001cb0:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001cb4:	058ab683          	ld	a3,88(s5)
    80001cb8:	87b6                	mv	a5,a3
    80001cba:	058a3703          	ld	a4,88(s4)
    80001cbe:	12068693          	addi	a3,a3,288
    80001cc2:	6388                	ld	a0,0(a5)
    80001cc4:	678c                	ld	a1,8(a5)
    80001cc6:	6b90                	ld	a2,16(a5)
    80001cc8:	e308                	sd	a0,0(a4)
    80001cca:	e70c                	sd	a1,8(a4)
    80001ccc:	eb10                	sd	a2,16(a4)
    80001cce:	6f90                	ld	a2,24(a5)
    80001cd0:	ef10                	sd	a2,24(a4)
    80001cd2:	02078793          	addi	a5,a5,32
    80001cd6:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001cda:	fed794e3          	bne	a5,a3,80001cc2 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001cde:	058a3783          	ld	a5,88(s4)
    80001ce2:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001ce6:	0d0a8493          	addi	s1,s5,208
    80001cea:	0d0a0913          	addi	s2,s4,208
    80001cee:	150a8993          	addi	s3,s5,336
    80001cf2:	a831                	j	80001d0e <kfork+0x96>
    freeproc(np);
    80001cf4:	8552                	mv	a0,s4
    80001cf6:	df3ff0ef          	jal	80001ae8 <freeproc>
    release(&np->lock);
    80001cfa:	8552                	mv	a0,s4
    80001cfc:	f75fe0ef          	jal	80000c70 <release>
    return -1;
    80001d00:	54fd                	li	s1,-1
    80001d02:	6a42                	ld	s4,16(sp)
    80001d04:	a885                	j	80001d74 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d06:	04a1                	addi	s1,s1,8
    80001d08:	0921                	addi	s2,s2,8
    80001d0a:	01348963          	beq	s1,s3,80001d1c <kfork+0xa4>
    if (p->ofile[i])
    80001d0e:	6088                	ld	a0,0(s1)
    80001d10:	d97d                	beqz	a0,80001d06 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d12:	400020ef          	jal	80004112 <filedup>
    80001d16:	00a93023          	sd	a0,0(s2)
    80001d1a:	b7f5                	j	80001d06 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d1c:	150ab503          	ld	a0,336(s5)
    80001d20:	4de010ef          	jal	800031fe <idup>
    80001d24:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d28:	4641                	li	a2,16
    80001d2a:	158a8593          	addi	a1,s5,344
    80001d2e:	158a0513          	addi	a0,s4,344
    80001d32:	8caff0ef          	jal	80000dfc <safestrcpy>
  pid = np->pid;
    80001d36:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d3a:	8552                	mv	a0,s4
    80001d3c:	f35fe0ef          	jal	80000c70 <release>
  acquire(&wait_lock);
    80001d40:	00010517          	auipc	a0,0x10
    80001d44:	6c850513          	addi	a0,a0,1736 # 80012408 <wait_lock>
    80001d48:	ea1fe0ef          	jal	80000be8 <acquire>
  np->parent = p;
    80001d4c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d50:	00010517          	auipc	a0,0x10
    80001d54:	6b850513          	addi	a0,a0,1720 # 80012408 <wait_lock>
    80001d58:	f19fe0ef          	jal	80000c70 <release>
  acquire(&np->lock);
    80001d5c:	8552                	mv	a0,s4
    80001d5e:	e8bfe0ef          	jal	80000be8 <acquire>
  np->state = RUNNABLE;
    80001d62:	478d                	li	a5,3
    80001d64:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d68:	8552                	mv	a0,s4
    80001d6a:	f07fe0ef          	jal	80000c70 <release>
  return pid;
    80001d6e:	7902                	ld	s2,32(sp)
    80001d70:	69e2                	ld	s3,24(sp)
    80001d72:	6a42                	ld	s4,16(sp)
}
    80001d74:	8526                	mv	a0,s1
    80001d76:	70e2                	ld	ra,56(sp)
    80001d78:	7442                	ld	s0,48(sp)
    80001d7a:	74a2                	ld	s1,40(sp)
    80001d7c:	6aa2                	ld	s5,8(sp)
    80001d7e:	6121                	addi	sp,sp,64
    80001d80:	8082                	ret
    return -1;
    80001d82:	54fd                	li	s1,-1
    80001d84:	bfc5                	j	80001d74 <kfork+0xfc>

0000000080001d86 <scheduler>:
{
    80001d86:	711d                	addi	sp,sp,-96
    80001d88:	ec86                	sd	ra,88(sp)
    80001d8a:	e8a2                	sd	s0,80(sp)
    80001d8c:	e4a6                	sd	s1,72(sp)
    80001d8e:	e0ca                	sd	s2,64(sp)
    80001d90:	fc4e                	sd	s3,56(sp)
    80001d92:	f852                	sd	s4,48(sp)
    80001d94:	f456                	sd	s5,40(sp)
    80001d96:	f05a                	sd	s6,32(sp)
    80001d98:	ec5e                	sd	s7,24(sp)
    80001d9a:	e862                	sd	s8,16(sp)
    80001d9c:	e466                	sd	s9,8(sp)
    80001d9e:	1080                	addi	s0,sp,96
    80001da0:	8792                	mv	a5,tp
  int id = r_tp();
    80001da2:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001da4:	00779a93          	slli	s5,a5,0x7
    80001da8:	00010717          	auipc	a4,0x10
    80001dac:	64870713          	addi	a4,a4,1608 # 800123f0 <pid_lock>
    80001db0:	9756                	add	a4,a4,s5
    80001db2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001db6:	00010717          	auipc	a4,0x10
    80001dba:	67270713          	addi	a4,a4,1650 # 80012428 <cpus+0x8>
    80001dbe:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001dc0:	4c11                	li	s8,4
        c->proc = p;
    80001dc2:	00010b17          	auipc	s6,0x10
    80001dc6:	62eb0b13          	addi	s6,s6,1582 # 800123f0 <pid_lock>
    80001dca:	079e                	slli	a5,a5,0x7
    80001dcc:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001dd0:	4b85                	li	s7,1
    80001dd2:	a0a9                	j	80001e1c <scheduler+0x96>
      release(&p->lock);
    80001dd4:	8526                	mv	a0,s1
    80001dd6:	e9bfe0ef          	jal	80000c70 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001dda:	16848493          	addi	s1,s1,360
    80001dde:	03248b63          	beq	s1,s2,80001e14 <scheduler+0x8e>
      acquire(&p->lock);
    80001de2:	8526                	mv	a0,s1
    80001de4:	e05fe0ef          	jal	80000be8 <acquire>
      if (p->state == RUNNABLE) {
    80001de8:	4c9c                	lw	a5,24(s1)
    80001dea:	ff3795e3          	bne	a5,s3,80001dd4 <scheduler+0x4e>
        p->state = RUNNING;
    80001dee:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001df2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001df6:	06048593          	addi	a1,s1,96
    80001dfa:	8556                	mv	a0,s5
    80001dfc:	5ee000ef          	jal	800023ea <swtch>
    80001e00:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001e02:	2781                	sext.w	a5,a5
    80001e04:	079e                	slli	a5,a5,0x7
    80001e06:	97da                	add	a5,a5,s6
    80001e08:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001e0c:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e10:	8cde                	mv	s9,s7
    80001e12:	b7c9                	j	80001dd4 <scheduler+0x4e>
    if (found == 0) {
    80001e14:	000c9463          	bnez	s9,80001e1c <scheduler+0x96>
      asm volatile("wfi");
    80001e18:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001e1c:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001e20:	10017073          	csrci	sstatus,2
    int found = 0;
    80001e24:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e26:	00011497          	auipc	s1,0x11
    80001e2a:	9fa48493          	addi	s1,s1,-1542 # 80012820 <proc>
      if (p->state == RUNNABLE) {
    80001e2e:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e30:	00016917          	auipc	s2,0x16
    80001e34:	3f090913          	addi	s2,s2,1008 # 80018220 <tickslock>
    80001e38:	b76d                	j	80001de2 <scheduler+0x5c>

0000000080001e3a <sched>:
{
    80001e3a:	7179                	addi	sp,sp,-48
    80001e3c:	f406                	sd	ra,40(sp)
    80001e3e:	f022                	sd	s0,32(sp)
    80001e40:	ec26                	sd	s1,24(sp)
    80001e42:	e84a                	sd	s2,16(sp)
    80001e44:	e44e                	sd	s3,8(sp)
    80001e46:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e48:	ac1ff0ef          	jal	80001908 <myproc>
    80001e4c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001e4e:	d35fe0ef          	jal	80000b82 <holding>
    80001e52:	c935                	beqz	a0,80001ec6 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e54:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001e56:	2781                	sext.w	a5,a5
    80001e58:	079e                	slli	a5,a5,0x7
    80001e5a:	00010717          	auipc	a4,0x10
    80001e5e:	59670713          	addi	a4,a4,1430 # 800123f0 <pid_lock>
    80001e62:	97ba                	add	a5,a5,a4
    80001e64:	0a87a703          	lw	a4,168(a5)
    80001e68:	4785                	li	a5,1
    80001e6a:	06f71463          	bne	a4,a5,80001ed2 <sched+0x98>
  if (p->state == RUNNING)
    80001e6e:	4c98                	lw	a4,24(s1)
    80001e70:	4791                	li	a5,4
    80001e72:	06f70663          	beq	a4,a5,80001ede <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e76:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e7a:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001e7c:	e7bd                	bnez	a5,80001eea <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e7e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e80:	00010917          	auipc	s2,0x10
    80001e84:	57090913          	addi	s2,s2,1392 # 800123f0 <pid_lock>
    80001e88:	2781                	sext.w	a5,a5
    80001e8a:	079e                	slli	a5,a5,0x7
    80001e8c:	97ca                	add	a5,a5,s2
    80001e8e:	0ac7a983          	lw	s3,172(a5)
    80001e92:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e94:	2781                	sext.w	a5,a5
    80001e96:	079e                	slli	a5,a5,0x7
    80001e98:	07a1                	addi	a5,a5,8
    80001e9a:	00010597          	auipc	a1,0x10
    80001e9e:	58658593          	addi	a1,a1,1414 # 80012420 <cpus>
    80001ea2:	95be                	add	a1,a1,a5
    80001ea4:	06048513          	addi	a0,s1,96
    80001ea8:	542000ef          	jal	800023ea <swtch>
    80001eac:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001eae:	2781                	sext.w	a5,a5
    80001eb0:	079e                	slli	a5,a5,0x7
    80001eb2:	993e                	add	s2,s2,a5
    80001eb4:	0b392623          	sw	s3,172(s2)
}
    80001eb8:	70a2                	ld	ra,40(sp)
    80001eba:	7402                	ld	s0,32(sp)
    80001ebc:	64e2                	ld	s1,24(sp)
    80001ebe:	6942                	ld	s2,16(sp)
    80001ec0:	69a2                	ld	s3,8(sp)
    80001ec2:	6145                	addi	sp,sp,48
    80001ec4:	8082                	ret
    panic("sched p->lock");
    80001ec6:	00005517          	auipc	a0,0x5
    80001eca:	2d250513          	addi	a0,a0,722 # 80007198 <etext+0x198>
    80001ece:	967fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80001ed2:	00005517          	auipc	a0,0x5
    80001ed6:	2d650513          	addi	a0,a0,726 # 800071a8 <etext+0x1a8>
    80001eda:	95bfe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80001ede:	00005517          	auipc	a0,0x5
    80001ee2:	2da50513          	addi	a0,a0,730 # 800071b8 <etext+0x1b8>
    80001ee6:	94ffe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80001eea:	00005517          	auipc	a0,0x5
    80001eee:	2de50513          	addi	a0,a0,734 # 800071c8 <etext+0x1c8>
    80001ef2:	943fe0ef          	jal	80000834 <panic>

0000000080001ef6 <yield>:
{
    80001ef6:	1101                	addi	sp,sp,-32
    80001ef8:	ec06                	sd	ra,24(sp)
    80001efa:	e822                	sd	s0,16(sp)
    80001efc:	e426                	sd	s1,8(sp)
    80001efe:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f00:	a09ff0ef          	jal	80001908 <myproc>
    80001f04:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f06:	ce3fe0ef          	jal	80000be8 <acquire>
  p->state = RUNNABLE;
    80001f0a:	478d                	li	a5,3
    80001f0c:	cc9c                	sw	a5,24(s1)
  sched();
    80001f0e:	f2dff0ef          	jal	80001e3a <sched>
  release(&p->lock);
    80001f12:	8526                	mv	a0,s1
    80001f14:	d5dfe0ef          	jal	80000c70 <release>
}
    80001f18:	60e2                	ld	ra,24(sp)
    80001f1a:	6442                	ld	s0,16(sp)
    80001f1c:	64a2                	ld	s1,8(sp)
    80001f1e:	6105                	addi	sp,sp,32
    80001f20:	8082                	ret

0000000080001f22 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001f22:	1101                	addi	sp,sp,-32
    80001f24:	ec06                	sd	ra,24(sp)
    80001f26:	e822                	sd	s0,16(sp)
    80001f28:	e426                	sd	s1,8(sp)
    80001f2a:	e04a                	sd	s2,0(sp)
    80001f2c:	1000                	addi	s0,sp,32
    80001f2e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f30:	9d9ff0ef          	jal	80001908 <myproc>
    80001f34:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001f36:	cb3fe0ef          	jal	80000be8 <acquire>
  if (chan == 0)
    80001f3a:	cc81                	beqz	s1,80001f52 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001f3c:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001f40:	854a                	mv	a0,s2
    80001f42:	d2ffe0ef          	jal	80000c70 <release>
}
    80001f46:	60e2                	ld	ra,24(sp)
    80001f48:	6442                	ld	s0,16(sp)
    80001f4a:	64a2                	ld	s1,8(sp)
    80001f4c:	6902                	ld	s2,0(sp)
    80001f4e:	6105                	addi	sp,sp,32
    80001f50:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001f52:	00005517          	auipc	a0,0x5
    80001f56:	28e50513          	addi	a0,a0,654 # 800071e0 <etext+0x1e0>
    80001f5a:	8dbfe0ef          	jal	80000834 <panic>

0000000080001f5e <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80001f5e:	1101                	addi	sp,sp,-32
    80001f60:	ec06                	sd	ra,24(sp)
    80001f62:	e822                	sd	s0,16(sp)
    80001f64:	e426                	sd	s1,8(sp)
    80001f66:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f68:	9a1ff0ef          	jal	80001908 <myproc>
    80001f6c:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80001f6e:	c7bfe0ef          	jal	80000be8 <acquire>
  if (p->chan != 0) {
    80001f72:	709c                	ld	a5,32(s1)
    80001f74:	c789                	beqz	a5,80001f7e <sleep+0x20>
    p->state = SLEEPING;
    80001f76:	4789                	li	a5,2
    80001f78:	cc9c                	sw	a5,24(s1)
    sched();
    80001f7a:	ec1ff0ef          	jal	80001e3a <sched>
  }
  release(&p->lock);
    80001f7e:	8526                	mv	a0,s1
    80001f80:	cf1fe0ef          	jal	80000c70 <release>
}
    80001f84:	60e2                	ld	ra,24(sp)
    80001f86:	6442                	ld	s0,16(sp)
    80001f88:	64a2                	ld	s1,8(sp)
    80001f8a:	6105                	addi	sp,sp,32
    80001f8c:	8082                	ret

0000000080001f8e <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80001f8e:	7139                	addi	sp,sp,-64
    80001f90:	fc06                	sd	ra,56(sp)
    80001f92:	f822                	sd	s0,48(sp)
    80001f94:	f426                	sd	s1,40(sp)
    80001f96:	f04a                	sd	s2,32(sp)
    80001f98:	ec4e                	sd	s3,24(sp)
    80001f9a:	e852                	sd	s4,16(sp)
    80001f9c:	e456                	sd	s5,8(sp)
    80001f9e:	0080                	addi	s0,sp,64
    80001fa0:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001fa2:	00011497          	auipc	s1,0x11
    80001fa6:	87e48493          	addi	s1,s1,-1922 # 80012820 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80001faa:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80001fac:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001fae:	00016997          	auipc	s3,0x16
    80001fb2:	27298993          	addi	s3,s3,626 # 80018220 <tickslock>
    80001fb6:	a801                	j	80001fc6 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80001fb8:	8526                	mv	a0,s1
    80001fba:	cb7fe0ef          	jal	80000c70 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001fbe:	16848493          	addi	s1,s1,360
    80001fc2:	03348063          	beq	s1,s3,80001fe2 <wakeup+0x54>
    acquire(&p->lock);
    80001fc6:	8526                	mv	a0,s1
    80001fc8:	c21fe0ef          	jal	80000be8 <acquire>
    if (p->chan == chan) {
    80001fcc:	709c                	ld	a5,32(s1)
    80001fce:	ff2795e3          	bne	a5,s2,80001fb8 <wakeup+0x2a>
      p->chan = 0;
    80001fd2:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80001fd6:	4c9c                	lw	a5,24(s1)
    80001fd8:	ff4790e3          	bne	a5,s4,80001fb8 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001fdc:	0154ac23          	sw	s5,24(s1)
    80001fe0:	bfe1                	j	80001fb8 <wakeup+0x2a>
  }
}
    80001fe2:	70e2                	ld	ra,56(sp)
    80001fe4:	7442                	ld	s0,48(sp)
    80001fe6:	74a2                	ld	s1,40(sp)
    80001fe8:	7902                	ld	s2,32(sp)
    80001fea:	69e2                	ld	s3,24(sp)
    80001fec:	6a42                	ld	s4,16(sp)
    80001fee:	6aa2                	ld	s5,8(sp)
    80001ff0:	6121                	addi	sp,sp,64
    80001ff2:	8082                	ret

0000000080001ff4 <reparent>:
{
    80001ff4:	7179                	addi	sp,sp,-48
    80001ff6:	f406                	sd	ra,40(sp)
    80001ff8:	f022                	sd	s0,32(sp)
    80001ffa:	ec26                	sd	s1,24(sp)
    80001ffc:	e84a                	sd	s2,16(sp)
    80001ffe:	e44e                	sd	s3,8(sp)
    80002000:	e052                	sd	s4,0(sp)
    80002002:	1800                	addi	s0,sp,48
    80002004:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002006:	00011497          	auipc	s1,0x11
    8000200a:	81a48493          	addi	s1,s1,-2022 # 80012820 <proc>
      pp->parent = initproc;
    8000200e:	00008a17          	auipc	s4,0x8
    80002012:	2baa0a13          	addi	s4,s4,698 # 8000a2c8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002016:	00016997          	auipc	s3,0x16
    8000201a:	20a98993          	addi	s3,s3,522 # 80018220 <tickslock>
    8000201e:	a029                	j	80002028 <reparent+0x34>
    80002020:	16848493          	addi	s1,s1,360
    80002024:	01348b63          	beq	s1,s3,8000203a <reparent+0x46>
    if (pp->parent == p) {
    80002028:	7c9c                	ld	a5,56(s1)
    8000202a:	ff279be3          	bne	a5,s2,80002020 <reparent+0x2c>
      pp->parent = initproc;
    8000202e:	000a3503          	ld	a0,0(s4)
    80002032:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002034:	f5bff0ef          	jal	80001f8e <wakeup>
    80002038:	b7e5                	j	80002020 <reparent+0x2c>
}
    8000203a:	70a2                	ld	ra,40(sp)
    8000203c:	7402                	ld	s0,32(sp)
    8000203e:	64e2                	ld	s1,24(sp)
    80002040:	6942                	ld	s2,16(sp)
    80002042:	69a2                	ld	s3,8(sp)
    80002044:	6a02                	ld	s4,0(sp)
    80002046:	6145                	addi	sp,sp,48
    80002048:	8082                	ret

000000008000204a <kexit>:
{
    8000204a:	7179                	addi	sp,sp,-48
    8000204c:	f406                	sd	ra,40(sp)
    8000204e:	f022                	sd	s0,32(sp)
    80002050:	ec26                	sd	s1,24(sp)
    80002052:	e84a                	sd	s2,16(sp)
    80002054:	e44e                	sd	s3,8(sp)
    80002056:	e052                	sd	s4,0(sp)
    80002058:	1800                	addi	s0,sp,48
    8000205a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000205c:	8adff0ef          	jal	80001908 <myproc>
    80002060:	89aa                	mv	s3,a0
  if (p == initproc)
    80002062:	00008797          	auipc	a5,0x8
    80002066:	2667b783          	ld	a5,614(a5) # 8000a2c8 <initproc>
    8000206a:	0d050493          	addi	s1,a0,208
    8000206e:	15050913          	addi	s2,a0,336
    80002072:	00a79b63          	bne	a5,a0,80002088 <kexit+0x3e>
    panic("init exiting");
    80002076:	00005517          	auipc	a0,0x5
    8000207a:	18a50513          	addi	a0,a0,394 # 80007200 <etext+0x200>
    8000207e:	fb6fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002082:	04a1                	addi	s1,s1,8
    80002084:	01248963          	beq	s1,s2,80002096 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002088:	6088                	ld	a0,0(s1)
    8000208a:	dd65                	beqz	a0,80002082 <kexit+0x38>
      fileclose(f);
    8000208c:	0cc020ef          	jal	80004158 <fileclose>
      p->ofile[fd] = 0;
    80002090:	0004b023          	sd	zero,0(s1)
    80002094:	b7fd                	j	80002082 <kexit+0x38>
  begin_op();
    80002096:	409010ef          	jal	80003c9e <begin_op>
  iput(p->cwd);
    8000209a:	1509b503          	ld	a0,336(s3)
    8000209e:	318010ef          	jal	800033b6 <iput>
  end_op();
    800020a2:	489010ef          	jal	80003d2a <end_op>
  p->cwd = 0;
    800020a6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800020aa:	00010517          	auipc	a0,0x10
    800020ae:	35e50513          	addi	a0,a0,862 # 80012408 <wait_lock>
    800020b2:	b37fe0ef          	jal	80000be8 <acquire>
  reparent(p);
    800020b6:	854e                	mv	a0,s3
    800020b8:	f3dff0ef          	jal	80001ff4 <reparent>
  wakeup(p->parent);
    800020bc:	0389b503          	ld	a0,56(s3)
    800020c0:	ecfff0ef          	jal	80001f8e <wakeup>
  acquire(&p->lock);
    800020c4:	854e                	mv	a0,s3
    800020c6:	b23fe0ef          	jal	80000be8 <acquire>
  p->xstate = status;
    800020ca:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020ce:	4795                	li	a5,5
    800020d0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020d4:	00010517          	auipc	a0,0x10
    800020d8:	33450513          	addi	a0,a0,820 # 80012408 <wait_lock>
    800020dc:	b95fe0ef          	jal	80000c70 <release>
  sched();
    800020e0:	d5bff0ef          	jal	80001e3a <sched>
  panic("zombie exit");
    800020e4:	00005517          	auipc	a0,0x5
    800020e8:	12c50513          	addi	a0,a0,300 # 80007210 <etext+0x210>
    800020ec:	f48fe0ef          	jal	80000834 <panic>

00000000800020f0 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800020f0:	7179                	addi	sp,sp,-48
    800020f2:	f406                	sd	ra,40(sp)
    800020f4:	f022                	sd	s0,32(sp)
    800020f6:	ec26                	sd	s1,24(sp)
    800020f8:	e84a                	sd	s2,16(sp)
    800020fa:	e44e                	sd	s3,8(sp)
    800020fc:	1800                	addi	s0,sp,48
    800020fe:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002100:	00010497          	auipc	s1,0x10
    80002104:	72048493          	addi	s1,s1,1824 # 80012820 <proc>
    80002108:	00016997          	auipc	s3,0x16
    8000210c:	11898993          	addi	s3,s3,280 # 80018220 <tickslock>
    acquire(&p->lock);
    80002110:	8526                	mv	a0,s1
    80002112:	ad7fe0ef          	jal	80000be8 <acquire>
    if (p->pid == pid) {
    80002116:	589c                	lw	a5,48(s1)
    80002118:	01278b63          	beq	a5,s2,8000212e <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000211c:	8526                	mv	a0,s1
    8000211e:	b53fe0ef          	jal	80000c70 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002122:	16848493          	addi	s1,s1,360
    80002126:	ff3495e3          	bne	s1,s3,80002110 <kkill+0x20>
  }
  return -1;
    8000212a:	557d                	li	a0,-1
    8000212c:	a819                	j	80002142 <kkill+0x52>
      p->killed = 1;
    8000212e:	4785                	li	a5,1
    80002130:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002132:	4c98                	lw	a4,24(s1)
    80002134:	4789                	li	a5,2
    80002136:	00f70d63          	beq	a4,a5,80002150 <kkill+0x60>
      release(&p->lock);
    8000213a:	8526                	mv	a0,s1
    8000213c:	b35fe0ef          	jal	80000c70 <release>
      return 0;
    80002140:	4501                	li	a0,0
}
    80002142:	70a2                	ld	ra,40(sp)
    80002144:	7402                	ld	s0,32(sp)
    80002146:	64e2                	ld	s1,24(sp)
    80002148:	6942                	ld	s2,16(sp)
    8000214a:	69a2                	ld	s3,8(sp)
    8000214c:	6145                	addi	sp,sp,48
    8000214e:	8082                	ret
        p->state = RUNNABLE;
    80002150:	478d                	li	a5,3
    80002152:	cc9c                	sw	a5,24(s1)
    80002154:	b7dd                	j	8000213a <kkill+0x4a>

0000000080002156 <setkilled>:

void
setkilled(struct proc *p)
{
    80002156:	1101                	addi	sp,sp,-32
    80002158:	ec06                	sd	ra,24(sp)
    8000215a:	e822                	sd	s0,16(sp)
    8000215c:	e426                	sd	s1,8(sp)
    8000215e:	1000                	addi	s0,sp,32
    80002160:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002162:	a87fe0ef          	jal	80000be8 <acquire>
  p->killed = 1;
    80002166:	4785                	li	a5,1
    80002168:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000216a:	8526                	mv	a0,s1
    8000216c:	b05fe0ef          	jal	80000c70 <release>
}
    80002170:	60e2                	ld	ra,24(sp)
    80002172:	6442                	ld	s0,16(sp)
    80002174:	64a2                	ld	s1,8(sp)
    80002176:	6105                	addi	sp,sp,32
    80002178:	8082                	ret

000000008000217a <killed>:

int
killed(struct proc *p)
{
    8000217a:	1101                	addi	sp,sp,-32
    8000217c:	ec06                	sd	ra,24(sp)
    8000217e:	e822                	sd	s0,16(sp)
    80002180:	e426                	sd	s1,8(sp)
    80002182:	e04a                	sd	s2,0(sp)
    80002184:	1000                	addi	s0,sp,32
    80002186:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002188:	a61fe0ef          	jal	80000be8 <acquire>
  k = p->killed;
    8000218c:	549c                	lw	a5,40(s1)
    8000218e:	893e                	mv	s2,a5
  release(&p->lock);
    80002190:	8526                	mv	a0,s1
    80002192:	adffe0ef          	jal	80000c70 <release>
  return k;
}
    80002196:	854a                	mv	a0,s2
    80002198:	60e2                	ld	ra,24(sp)
    8000219a:	6442                	ld	s0,16(sp)
    8000219c:	64a2                	ld	s1,8(sp)
    8000219e:	6902                	ld	s2,0(sp)
    800021a0:	6105                	addi	sp,sp,32
    800021a2:	8082                	ret

00000000800021a4 <kwait>:
{
    800021a4:	715d                	addi	sp,sp,-80
    800021a6:	e486                	sd	ra,72(sp)
    800021a8:	e0a2                	sd	s0,64(sp)
    800021aa:	fc26                	sd	s1,56(sp)
    800021ac:	f84a                	sd	s2,48(sp)
    800021ae:	f44e                	sd	s3,40(sp)
    800021b0:	f052                	sd	s4,32(sp)
    800021b2:	ec56                	sd	s5,24(sp)
    800021b4:	e85a                	sd	s6,16(sp)
    800021b6:	e45e                	sd	s7,8(sp)
    800021b8:	0880                	addi	s0,sp,80
    800021ba:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800021bc:	f4cff0ef          	jal	80001908 <myproc>
    800021c0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021c2:	00010517          	auipc	a0,0x10
    800021c6:	24650513          	addi	a0,a0,582 # 80012408 <wait_lock>
    800021ca:	a1ffe0ef          	jal	80000be8 <acquire>
        if (pp->state == ZOMBIE) {
    800021ce:	4a15                	li	s4,5
        havekids = 1;
    800021d0:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021d2:	00016997          	auipc	s3,0x16
    800021d6:	04e98993          	addi	s3,s3,78 # 80018220 <tickslock>
    release(&wait_lock);
    800021da:	00010b17          	auipc	s6,0x10
    800021de:	22eb0b13          	addi	s6,s6,558 # 80012408 <wait_lock>
    800021e2:	a845                	j	80002292 <kwait+0xee>
          pid = pp->pid;
    800021e4:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    800021e8:	000b8e63          	beqz	s7,80002204 <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    800021ec:	4711                	li	a4,4
    800021ee:	02c48693          	addi	a3,s1,44
    800021f2:	865e                	mv	a2,s7
    800021f4:	04893583          	ld	a1,72(s2)
    800021f8:	05093503          	ld	a0,80(s2)
    800021fc:	b46ff0ef          	jal	80001542 <copyout>
          if (addr != 0 &&
    80002200:	02054c63          	bltz	a0,80002238 <kwait+0x94>
          pp->parent = 0;
    80002204:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    80002208:	8526                	mv	a0,s1
    8000220a:	8dfff0ef          	jal	80001ae8 <freeproc>
          release(&pp->lock);
    8000220e:	8526                	mv	a0,s1
    80002210:	a61fe0ef          	jal	80000c70 <release>
          release(&wait_lock);
    80002214:	00010517          	auipc	a0,0x10
    80002218:	1f450513          	addi	a0,a0,500 # 80012408 <wait_lock>
    8000221c:	a55fe0ef          	jal	80000c70 <release>
}
    80002220:	854e                	mv	a0,s3
    80002222:	60a6                	ld	ra,72(sp)
    80002224:	6406                	ld	s0,64(sp)
    80002226:	74e2                	ld	s1,56(sp)
    80002228:	7942                	ld	s2,48(sp)
    8000222a:	79a2                	ld	s3,40(sp)
    8000222c:	7a02                	ld	s4,32(sp)
    8000222e:	6ae2                	ld	s5,24(sp)
    80002230:	6b42                	ld	s6,16(sp)
    80002232:	6ba2                	ld	s7,8(sp)
    80002234:	6161                	addi	sp,sp,80
    80002236:	8082                	ret
            release(&pp->lock);
    80002238:	8526                	mv	a0,s1
    8000223a:	a37fe0ef          	jal	80000c70 <release>
            release(&wait_lock);
    8000223e:	00010517          	auipc	a0,0x10
    80002242:	1ca50513          	addi	a0,a0,458 # 80012408 <wait_lock>
    80002246:	a2bfe0ef          	jal	80000c70 <release>
            return -1;
    8000224a:	59fd                	li	s3,-1
    8000224c:	bfd1                	j	80002220 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000224e:	16848493          	addi	s1,s1,360
    80002252:	03348063          	beq	s1,s3,80002272 <kwait+0xce>
      if (pp->parent == p) {
    80002256:	7c9c                	ld	a5,56(s1)
    80002258:	ff279be3          	bne	a5,s2,8000224e <kwait+0xaa>
        acquire(&pp->lock);
    8000225c:	8526                	mv	a0,s1
    8000225e:	98bfe0ef          	jal	80000be8 <acquire>
        if (pp->state == ZOMBIE) {
    80002262:	4c9c                	lw	a5,24(s1)
    80002264:	f94780e3          	beq	a5,s4,800021e4 <kwait+0x40>
        release(&pp->lock);
    80002268:	8526                	mv	a0,s1
    8000226a:	a07fe0ef          	jal	80000c70 <release>
        havekids = 1;
    8000226e:	8756                	mv	a4,s5
    80002270:	bff9                	j	8000224e <kwait+0xaa>
    if (!havekids || killed(p)) {
    80002272:	c715                	beqz	a4,8000229e <kwait+0xfa>
    80002274:	854a                	mv	a0,s2
    80002276:	f05ff0ef          	jal	8000217a <killed>
    8000227a:	e115                	bnez	a0,8000229e <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    8000227c:	854a                	mv	a0,s2
    8000227e:	ca5ff0ef          	jal	80001f22 <sleep_prepare>
    release(&wait_lock);
    80002282:	855a                	mv	a0,s6
    80002284:	9edfe0ef          	jal	80000c70 <release>
    sleep();
    80002288:	cd7ff0ef          	jal	80001f5e <sleep>
    acquire(&wait_lock);
    8000228c:	855a                	mv	a0,s6
    8000228e:	95bfe0ef          	jal	80000be8 <acquire>
    havekids = 0;
    80002292:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002294:	00010497          	auipc	s1,0x10
    80002298:	58c48493          	addi	s1,s1,1420 # 80012820 <proc>
    8000229c:	bf6d                	j	80002256 <kwait+0xb2>
      release(&wait_lock);
    8000229e:	00010517          	auipc	a0,0x10
    800022a2:	16a50513          	addi	a0,a0,362 # 80012408 <wait_lock>
    800022a6:	9cbfe0ef          	jal	80000c70 <release>
      return -1;
    800022aa:	59fd                	li	s3,-1
    800022ac:	bf95                	j	80002220 <kwait+0x7c>

00000000800022ae <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800022ae:	7179                	addi	sp,sp,-48
    800022b0:	f406                	sd	ra,40(sp)
    800022b2:	f022                	sd	s0,32(sp)
    800022b4:	ec26                	sd	s1,24(sp)
    800022b6:	e84a                	sd	s2,16(sp)
    800022b8:	e44e                	sd	s3,8(sp)
    800022ba:	e052                	sd	s4,0(sp)
    800022bc:	1800                	addi	s0,sp,48
    800022be:	84aa                	mv	s1,a0
    800022c0:	8a2e                	mv	s4,a1
    800022c2:	89b2                	mv	s3,a2
    800022c4:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800022c6:	e42ff0ef          	jal	80001908 <myproc>
  if (user_dst) {
    800022ca:	c085                	beqz	s1,800022ea <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800022cc:	874a                	mv	a4,s2
    800022ce:	86ce                	mv	a3,s3
    800022d0:	8652                	mv	a2,s4
    800022d2:	652c                	ld	a1,72(a0)
    800022d4:	6928                	ld	a0,80(a0)
    800022d6:	a6cff0ef          	jal	80001542 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022da:	70a2                	ld	ra,40(sp)
    800022dc:	7402                	ld	s0,32(sp)
    800022de:	64e2                	ld	s1,24(sp)
    800022e0:	6942                	ld	s2,16(sp)
    800022e2:	69a2                	ld	s3,8(sp)
    800022e4:	6a02                	ld	s4,0(sp)
    800022e6:	6145                	addi	sp,sp,48
    800022e8:	8082                	ret
    memmove((char *)dst, src, len);
    800022ea:	0009061b          	sext.w	a2,s2
    800022ee:	85ce                	mv	a1,s3
    800022f0:	8552                	mv	a0,s4
    800022f2:	a17fe0ef          	jal	80000d08 <memmove>
    return 0;
    800022f6:	8526                	mv	a0,s1
    800022f8:	b7cd                	j	800022da <either_copyout+0x2c>

00000000800022fa <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022fa:	7179                	addi	sp,sp,-48
    800022fc:	f406                	sd	ra,40(sp)
    800022fe:	f022                	sd	s0,32(sp)
    80002300:	ec26                	sd	s1,24(sp)
    80002302:	e84a                	sd	s2,16(sp)
    80002304:	e44e                	sd	s3,8(sp)
    80002306:	e052                	sd	s4,0(sp)
    80002308:	1800                	addi	s0,sp,48
    8000230a:	8a2a                	mv	s4,a0
    8000230c:	84ae                	mv	s1,a1
    8000230e:	89b2                	mv	s3,a2
    80002310:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002312:	df6ff0ef          	jal	80001908 <myproc>
  if (user_src) {
    80002316:	c085                	beqz	s1,80002336 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    80002318:	874a                	mv	a4,s2
    8000231a:	86ce                	mv	a3,s3
    8000231c:	8652                	mv	a2,s4
    8000231e:	652c                	ld	a1,72(a0)
    80002320:	6928                	ld	a0,80(a0)
    80002322:	ae6ff0ef          	jal	80001608 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002326:	70a2                	ld	ra,40(sp)
    80002328:	7402                	ld	s0,32(sp)
    8000232a:	64e2                	ld	s1,24(sp)
    8000232c:	6942                	ld	s2,16(sp)
    8000232e:	69a2                	ld	s3,8(sp)
    80002330:	6a02                	ld	s4,0(sp)
    80002332:	6145                	addi	sp,sp,48
    80002334:	8082                	ret
    memmove(dst, (char *)src, len);
    80002336:	0009061b          	sext.w	a2,s2
    8000233a:	85ce                	mv	a1,s3
    8000233c:	8552                	mv	a0,s4
    8000233e:	9cbfe0ef          	jal	80000d08 <memmove>
    return 0;
    80002342:	8526                	mv	a0,s1
    80002344:	b7cd                	j	80002326 <either_copyin+0x2c>

0000000080002346 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002346:	715d                	addi	sp,sp,-80
    80002348:	e486                	sd	ra,72(sp)
    8000234a:	e0a2                	sd	s0,64(sp)
    8000234c:	fc26                	sd	s1,56(sp)
    8000234e:	f84a                	sd	s2,48(sp)
    80002350:	f44e                	sd	s3,40(sp)
    80002352:	f052                	sd	s4,32(sp)
    80002354:	ec56                	sd	s5,24(sp)
    80002356:	e85a                	sd	s6,16(sp)
    80002358:	e45e                	sd	s7,8(sp)
    8000235a:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    8000235c:	00005517          	auipc	a0,0x5
    80002360:	d1c50513          	addi	a0,a0,-740 # 80007078 <etext+0x78>
    80002364:	9a6fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002368:	00010497          	auipc	s1,0x10
    8000236c:	61048493          	addi	s1,s1,1552 # 80012978 <proc+0x158>
    80002370:	00016917          	auipc	s2,0x16
    80002374:	00890913          	addi	s2,s2,8 # 80018378 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002378:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000237a:	00005997          	auipc	s3,0x5
    8000237e:	ea698993          	addi	s3,s3,-346 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    80002382:	00005a97          	auipc	s5,0x5
    80002386:	ea6a8a93          	addi	s5,s5,-346 # 80007228 <etext+0x228>
    printk("\n");
    8000238a:	00005a17          	auipc	s4,0x5
    8000238e:	ceea0a13          	addi	s4,s4,-786 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002392:	00005b97          	auipc	s7,0x5
    80002396:	3b6b8b93          	addi	s7,s7,950 # 80007748 <states.0>
    8000239a:	a829                	j	800023b4 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    8000239c:	ed86a583          	lw	a1,-296(a3)
    800023a0:	8556                	mv	a0,s5
    800023a2:	968fe0ef          	jal	8000050a <printk>
    printk("\n");
    800023a6:	8552                	mv	a0,s4
    800023a8:	962fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800023ac:	16848493          	addi	s1,s1,360
    800023b0:	03248263          	beq	s1,s2,800023d4 <procdump+0x8e>
    if (p->state == UNUSED)
    800023b4:	86a6                	mv	a3,s1
    800023b6:	ec04a783          	lw	a5,-320(s1)
    800023ba:	dbed                	beqz	a5,800023ac <procdump+0x66>
      state = "???";
    800023bc:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023be:	fcfb6fe3          	bltu	s6,a5,8000239c <procdump+0x56>
    800023c2:	02079713          	slli	a4,a5,0x20
    800023c6:	01d75793          	srli	a5,a4,0x1d
    800023ca:	97de                	add	a5,a5,s7
    800023cc:	6390                	ld	a2,0(a5)
    800023ce:	f679                	bnez	a2,8000239c <procdump+0x56>
      state = "???";
    800023d0:	864e                	mv	a2,s3
    800023d2:	b7e9                	j	8000239c <procdump+0x56>
  }
}
    800023d4:	60a6                	ld	ra,72(sp)
    800023d6:	6406                	ld	s0,64(sp)
    800023d8:	74e2                	ld	s1,56(sp)
    800023da:	7942                	ld	s2,48(sp)
    800023dc:	79a2                	ld	s3,40(sp)
    800023de:	7a02                	ld	s4,32(sp)
    800023e0:	6ae2                	ld	s5,24(sp)
    800023e2:	6b42                	ld	s6,16(sp)
    800023e4:	6ba2                	ld	s7,8(sp)
    800023e6:	6161                	addi	sp,sp,80
    800023e8:	8082                	ret

00000000800023ea <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800023ea:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800023ee:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800023f2:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800023f4:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800023f6:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800023fa:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800023fe:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002402:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002406:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000240a:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000240e:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002412:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002416:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000241a:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000241e:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002422:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002426:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002428:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000242a:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000242e:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002432:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002436:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000243a:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000243e:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002442:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002446:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000244a:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000244e:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002452:	8082                	ret

0000000080002454 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002454:	1141                	addi	sp,sp,-16
    80002456:	e406                	sd	ra,8(sp)
    80002458:	e022                	sd	s0,0(sp)
    8000245a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000245c:	00005597          	auipc	a1,0x5
    80002460:	e0c58593          	addi	a1,a1,-500 # 80007268 <etext+0x268>
    80002464:	00016517          	auipc	a0,0x16
    80002468:	dbc50513          	addi	a0,a0,-580 # 80018220 <tickslock>
    8000246c:	efcfe0ef          	jal	80000b68 <initlock>
}
    80002470:	60a2                	ld	ra,8(sp)
    80002472:	6402                	ld	s0,0(sp)
    80002474:	0141                	addi	sp,sp,16
    80002476:	8082                	ret

0000000080002478 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002478:	1141                	addi	sp,sp,-16
    8000247a:	e406                	sd	ra,8(sp)
    8000247c:	e022                	sd	s0,0(sp)
    8000247e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002480:	00003797          	auipc	a5,0x3
    80002484:	14078793          	addi	a5,a5,320 # 800055c0 <kernelvec>
    80002488:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000248c:	60a2                	ld	ra,8(sp)
    8000248e:	6402                	ld	s0,0(sp)
    80002490:	0141                	addi	sp,sp,16
    80002492:	8082                	ret

0000000080002494 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002494:	1141                	addi	sp,sp,-16
    80002496:	e406                	sd	ra,8(sp)
    80002498:	e022                	sd	s0,0(sp)
    8000249a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000249c:	c6cff0ef          	jal	80001908 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    800024a0:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024a4:	04000737          	lui	a4,0x4000
    800024a8:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800024aa:	0732                	slli	a4,a4,0xc
    800024ac:	00004797          	auipc	a5,0x4
    800024b0:	b5478793          	addi	a5,a5,-1196 # 80006000 <_trampoline>
    800024b4:	00004697          	auipc	a3,0x4
    800024b8:	b4c68693          	addi	a3,a3,-1204 # 80006000 <_trampoline>
    800024bc:	8f95                	sub	a5,a5,a3
    800024be:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800024c0:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024c4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800024c6:	18002773          	csrr	a4,satp
    800024ca:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024cc:	6d38                	ld	a4,88(a0)
    800024ce:	613c                	ld	a5,64(a0)
    800024d0:	6685                	lui	a3,0x1
    800024d2:	97b6                	add	a5,a5,a3
    800024d4:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800024d6:	6d3c                	ld	a5,88(a0)
    800024d8:	00000717          	auipc	a4,0x0
    800024dc:	0fc70713          	addi	a4,a4,252 # 800025d4 <usertrap>
    800024e0:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800024e2:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    800024e4:	8712                	mv	a4,tp
    800024e6:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800024e8:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024ec:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024f0:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800024f4:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024f8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800024fa:	6f9c                	ld	a5,24(a5)
    800024fc:	14179073          	csrw	sepc,a5
}
    80002500:	60a2                	ld	ra,8(sp)
    80002502:	6402                	ld	s0,0(sp)
    80002504:	0141                	addi	sp,sp,16
    80002506:	8082                	ret

0000000080002508 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002508:	1141                	addi	sp,sp,-16
    8000250a:	e406                	sd	ra,8(sp)
    8000250c:	e022                	sd	s0,0(sp)
    8000250e:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80002510:	bc4ff0ef          	jal	800018d4 <cpuid>
    80002514:	cd11                	beqz	a0,80002530 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002516:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000251a:	000f4737          	lui	a4,0xf4
    8000251e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002522:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    80002524:	14d79073          	csrw	stimecmp,a5
}
    80002528:	60a2                	ld	ra,8(sp)
    8000252a:	6402                	ld	s0,0(sp)
    8000252c:	0141                	addi	sp,sp,16
    8000252e:	8082                	ret
    acquire(&tickslock);
    80002530:	00016517          	auipc	a0,0x16
    80002534:	cf050513          	addi	a0,a0,-784 # 80018220 <tickslock>
    80002538:	eb0fe0ef          	jal	80000be8 <acquire>
    ticks++;
    8000253c:	00008717          	auipc	a4,0x8
    80002540:	d9470713          	addi	a4,a4,-620 # 8000a2d0 <ticks>
    80002544:	431c                	lw	a5,0(a4)
    80002546:	2785                	addiw	a5,a5,1
    80002548:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    8000254a:	853a                	mv	a0,a4
    8000254c:	a43ff0ef          	jal	80001f8e <wakeup>
    release(&tickslock);
    80002550:	00016517          	auipc	a0,0x16
    80002554:	cd050513          	addi	a0,a0,-816 # 80018220 <tickslock>
    80002558:	f18fe0ef          	jal	80000c70 <release>
    8000255c:	bf6d                	j	80002516 <clockintr+0xe>

000000008000255e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000255e:	1101                	addi	sp,sp,-32
    80002560:	ec06                	sd	ra,24(sp)
    80002562:	e822                	sd	s0,16(sp)
    80002564:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    80002566:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    8000256a:	57fd                	li	a5,-1
    8000256c:	17fe                	slli	a5,a5,0x3f
    8000256e:	07a5                	addi	a5,a5,9
    80002570:	00f70c63          	beq	a4,a5,80002588 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    80002574:	57fd                	li	a5,-1
    80002576:	17fe                	slli	a5,a5,0x3f
    80002578:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000257a:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    8000257c:	04f70863          	beq	a4,a5,800025cc <devintr+0x6e>
  }
}
    80002580:	60e2                	ld	ra,24(sp)
    80002582:	6442                	ld	s0,16(sp)
    80002584:	6105                	addi	sp,sp,32
    80002586:	8082                	ret
    80002588:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000258a:	0e2030ef          	jal	8000566c <plic_claim>
    8000258e:	872a                	mv	a4,a0
    80002590:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002592:	47a9                	li	a5,10
    80002594:	00f50963          	beq	a0,a5,800025a6 <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    80002598:	4785                	li	a5,1
    8000259a:	00f50963          	beq	a0,a5,800025ac <devintr+0x4e>
    return 1;
    8000259e:	4505                	li	a0,1
    } else if (irq) {
    800025a0:	eb09                	bnez	a4,800025b2 <devintr+0x54>
    800025a2:	64a2                	ld	s1,8(sp)
    800025a4:	bff1                	j	80002580 <devintr+0x22>
      uartintr();
    800025a6:	c28fe0ef          	jal	800009ce <uartintr>
    if (irq)
    800025aa:	a819                	j	800025c0 <devintr+0x62>
      virtio_disk_intr();
    800025ac:	578030ef          	jal	80005b24 <virtio_disk_intr>
    if (irq)
    800025b0:	a801                	j	800025c0 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    800025b2:	85ba                	mv	a1,a4
    800025b4:	00005517          	auipc	a0,0x5
    800025b8:	cbc50513          	addi	a0,a0,-836 # 80007270 <etext+0x270>
    800025bc:	f4ffd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    800025c0:	8526                	mv	a0,s1
    800025c2:	0ca030ef          	jal	8000568c <plic_complete>
    return 1;
    800025c6:	4505                	li	a0,1
    800025c8:	64a2                	ld	s1,8(sp)
    800025ca:	bf5d                	j	80002580 <devintr+0x22>
    clockintr();
    800025cc:	f3dff0ef          	jal	80002508 <clockintr>
    return 2;
    800025d0:	4509                	li	a0,2
    800025d2:	b77d                	j	80002580 <devintr+0x22>

00000000800025d4 <usertrap>:
{
    800025d4:	1101                	addi	sp,sp,-32
    800025d6:	ec06                	sd	ra,24(sp)
    800025d8:	e822                	sd	s0,16(sp)
    800025da:	e426                	sd	s1,8(sp)
    800025dc:	e04a                	sd	s2,0(sp)
    800025de:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800025e0:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800025e4:	1007f793          	andi	a5,a5,256
    800025e8:	eba5                	bnez	a5,80002658 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800025ea:	00003797          	auipc	a5,0x3
    800025ee:	fd678793          	addi	a5,a5,-42 # 800055c0 <kernelvec>
    800025f2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025f6:	b12ff0ef          	jal	80001908 <myproc>
    800025fa:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025fc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800025fe:	14102773          	csrr	a4,sepc
    80002602:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    80002604:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    80002608:	47a1                	li	a5,8
    8000260a:	04f70d63          	beq	a4,a5,80002664 <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    8000260e:	f51ff0ef          	jal	8000255e <devintr>
    80002612:	892a                	mv	s2,a0
    80002614:	e54d                	bnez	a0,800026be <usertrap+0xea>
    80002616:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    8000261a:	47bd                	li	a5,15
    8000261c:	08f70463          	beq	a4,a5,800026a4 <usertrap+0xd0>
    80002620:	14202773          	csrr	a4,scause
    80002624:	47b5                	li	a5,13
    80002626:	06f70f63          	beq	a4,a5,800026a4 <usertrap+0xd0>
    8000262a:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000262e:	5890                	lw	a2,48(s1)
    80002630:	00005517          	auipc	a0,0x5
    80002634:	c8050513          	addi	a0,a0,-896 # 800072b0 <etext+0x2b0>
    80002638:	ed3fd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000263c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002640:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002644:	00005517          	auipc	a0,0x5
    80002648:	c9c50513          	addi	a0,a0,-868 # 800072e0 <etext+0x2e0>
    8000264c:	ebffd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002650:	8526                	mv	a0,s1
    80002652:	b05ff0ef          	jal	80002156 <setkilled>
    80002656:	a015                	j	8000267a <usertrap+0xa6>
    panic("usertrap: not from user mode");
    80002658:	00005517          	auipc	a0,0x5
    8000265c:	c3850513          	addi	a0,a0,-968 # 80007290 <etext+0x290>
    80002660:	9d4fe0ef          	jal	80000834 <panic>
    if (killed(p))
    80002664:	b17ff0ef          	jal	8000217a <killed>
    80002668:	e915                	bnez	a0,8000269c <usertrap+0xc8>
    p->trapframe->epc += 4;
    8000266a:	6cb8                	ld	a4,88(s1)
    8000266c:	6f1c                	ld	a5,24(a4)
    8000266e:	0791                	addi	a5,a5,4
    80002670:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002672:	10016073          	csrsi	sstatus,2
    syscall();
    80002676:	244000ef          	jal	800028ba <syscall>
  if (killed(p))
    8000267a:	8526                	mv	a0,s1
    8000267c:	affff0ef          	jal	8000217a <killed>
    80002680:	e521                	bnez	a0,800026c8 <usertrap+0xf4>
  prepare_return();
    80002682:	e13ff0ef          	jal	80002494 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002686:	68a8                	ld	a0,80(s1)
    80002688:	8131                	srli	a0,a0,0xc
    8000268a:	57fd                	li	a5,-1
    8000268c:	17fe                	slli	a5,a5,0x3f
    8000268e:	8d5d                	or	a0,a0,a5
}
    80002690:	60e2                	ld	ra,24(sp)
    80002692:	6442                	ld	s0,16(sp)
    80002694:	64a2                	ld	s1,8(sp)
    80002696:	6902                	ld	s2,0(sp)
    80002698:	6105                	addi	sp,sp,32
    8000269a:	8082                	ret
      kexit(-1);
    8000269c:	557d                	li	a0,-1
    8000269e:	9adff0ef          	jal	8000204a <kexit>
    800026a2:	b7e1                	j	8000266a <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    800026a4:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    800026a8:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    800026ac:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    800026ae:	0016b693          	seqz	a3,a3
    800026b2:	64ac                	ld	a1,72(s1)
    800026b4:	68a8                	ld	a0,80(s1)
    800026b6:	e11fe0ef          	jal	800014c6 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800026ba:	f161                	bnez	a0,8000267a <usertrap+0xa6>
    800026bc:	b7bd                	j	8000262a <usertrap+0x56>
  if (killed(p))
    800026be:	8526                	mv	a0,s1
    800026c0:	abbff0ef          	jal	8000217a <killed>
    800026c4:	c511                	beqz	a0,800026d0 <usertrap+0xfc>
    800026c6:	a011                	j	800026ca <usertrap+0xf6>
    800026c8:	4901                	li	s2,0
    kexit(-1);
    800026ca:	557d                	li	a0,-1
    800026cc:	97fff0ef          	jal	8000204a <kexit>
  if (which_dev == 2)
    800026d0:	4789                	li	a5,2
    800026d2:	faf918e3          	bne	s2,a5,80002682 <usertrap+0xae>
    yield();
    800026d6:	821ff0ef          	jal	80001ef6 <yield>
    800026da:	b765                	j	80002682 <usertrap+0xae>

00000000800026dc <kerneltrap>:
{
    800026dc:	7179                	addi	sp,sp,-48
    800026de:	f406                	sd	ra,40(sp)
    800026e0:	f022                	sd	s0,32(sp)
    800026e2:	ec26                	sd	s1,24(sp)
    800026e4:	e84a                	sd	s2,16(sp)
    800026e6:	e44e                	sd	s3,8(sp)
    800026e8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026ea:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026ee:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800026f2:	142027f3          	csrr	a5,scause
    800026f6:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    800026f8:	1004f793          	andi	a5,s1,256
    800026fc:	c795                	beqz	a5,80002728 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026fe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002702:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002704:	eb85                	bnez	a5,80002734 <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    80002706:	e59ff0ef          	jal	8000255e <devintr>
    8000270a:	c91d                	beqz	a0,80002740 <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    8000270c:	4789                	li	a5,2
    8000270e:	04f50a63          	beq	a0,a5,80002762 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002712:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002716:	10049073          	csrw	sstatus,s1
}
    8000271a:	70a2                	ld	ra,40(sp)
    8000271c:	7402                	ld	s0,32(sp)
    8000271e:	64e2                	ld	s1,24(sp)
    80002720:	6942                	ld	s2,16(sp)
    80002722:	69a2                	ld	s3,8(sp)
    80002724:	6145                	addi	sp,sp,48
    80002726:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002728:	00005517          	auipc	a0,0x5
    8000272c:	be050513          	addi	a0,a0,-1056 # 80007308 <etext+0x308>
    80002730:	904fe0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    80002734:	00005517          	auipc	a0,0x5
    80002738:	bfc50513          	addi	a0,a0,-1028 # 80007330 <etext+0x330>
    8000273c:	8f8fe0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002740:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002744:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    80002748:	85ce                	mv	a1,s3
    8000274a:	00005517          	auipc	a0,0x5
    8000274e:	c0650513          	addi	a0,a0,-1018 # 80007350 <etext+0x350>
    80002752:	db9fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    80002756:	00005517          	auipc	a0,0x5
    8000275a:	c2250513          	addi	a0,a0,-990 # 80007378 <etext+0x378>
    8000275e:	8d6fe0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    80002762:	9a6ff0ef          	jal	80001908 <myproc>
    80002766:	d555                	beqz	a0,80002712 <kerneltrap+0x36>
    yield();
    80002768:	f8eff0ef          	jal	80001ef6 <yield>
    8000276c:	b75d                	j	80002712 <kerneltrap+0x36>

000000008000276e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000276e:	1101                	addi	sp,sp,-32
    80002770:	ec06                	sd	ra,24(sp)
    80002772:	e822                	sd	s0,16(sp)
    80002774:	e426                	sd	s1,8(sp)
    80002776:	1000                	addi	s0,sp,32
    80002778:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000277a:	98eff0ef          	jal	80001908 <myproc>
  switch (n) {
    8000277e:	4795                	li	a5,5
    80002780:	0497e163          	bltu	a5,s1,800027c2 <argraw+0x54>
    80002784:	048a                	slli	s1,s1,0x2
    80002786:	00005717          	auipc	a4,0x5
    8000278a:	ff270713          	addi	a4,a4,-14 # 80007778 <states.0+0x30>
    8000278e:	94ba                	add	s1,s1,a4
    80002790:	409c                	lw	a5,0(s1)
    80002792:	97ba                	add	a5,a5,a4
    80002794:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002796:	6d3c                	ld	a5,88(a0)
    80002798:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000279a:	60e2                	ld	ra,24(sp)
    8000279c:	6442                	ld	s0,16(sp)
    8000279e:	64a2                	ld	s1,8(sp)
    800027a0:	6105                	addi	sp,sp,32
    800027a2:	8082                	ret
    return p->trapframe->a1;
    800027a4:	6d3c                	ld	a5,88(a0)
    800027a6:	7fa8                	ld	a0,120(a5)
    800027a8:	bfcd                	j	8000279a <argraw+0x2c>
    return p->trapframe->a2;
    800027aa:	6d3c                	ld	a5,88(a0)
    800027ac:	63c8                	ld	a0,128(a5)
    800027ae:	b7f5                	j	8000279a <argraw+0x2c>
    return p->trapframe->a3;
    800027b0:	6d3c                	ld	a5,88(a0)
    800027b2:	67c8                	ld	a0,136(a5)
    800027b4:	b7dd                	j	8000279a <argraw+0x2c>
    return p->trapframe->a4;
    800027b6:	6d3c                	ld	a5,88(a0)
    800027b8:	6bc8                	ld	a0,144(a5)
    800027ba:	b7c5                	j	8000279a <argraw+0x2c>
    return p->trapframe->a5;
    800027bc:	6d3c                	ld	a5,88(a0)
    800027be:	6fc8                	ld	a0,152(a5)
    800027c0:	bfe9                	j	8000279a <argraw+0x2c>
  panic("argraw");
    800027c2:	00005517          	auipc	a0,0x5
    800027c6:	bc650513          	addi	a0,a0,-1082 # 80007388 <etext+0x388>
    800027ca:	86afe0ef          	jal	80000834 <panic>

00000000800027ce <fetchaddr>:
{
    800027ce:	1101                	addi	sp,sp,-32
    800027d0:	ec06                	sd	ra,24(sp)
    800027d2:	e822                	sd	s0,16(sp)
    800027d4:	e426                	sd	s1,8(sp)
    800027d6:	e04a                	sd	s2,0(sp)
    800027d8:	1000                	addi	s0,sp,32
    800027da:	84aa                	mv	s1,a0
    800027dc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027de:	92aff0ef          	jal	80001908 <myproc>
  if (addr >= p->sz ||
    800027e2:	652c                	ld	a1,72(a0)
    800027e4:	02b4f663          	bgeu	s1,a1,80002810 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800027e8:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    800027ec:	02f5e463          	bltu	a1,a5,80002814 <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    800027f0:	4721                	li	a4,8
    800027f2:	86a6                	mv	a3,s1
    800027f4:	864a                	mv	a2,s2
    800027f6:	6928                	ld	a0,80(a0)
    800027f8:	e11fe0ef          	jal	80001608 <copyin>
    800027fc:	00a03533          	snez	a0,a0
    80002800:	40a0053b          	negw	a0,a0
}
    80002804:	60e2                	ld	ra,24(sp)
    80002806:	6442                	ld	s0,16(sp)
    80002808:	64a2                	ld	s1,8(sp)
    8000280a:	6902                	ld	s2,0(sp)
    8000280c:	6105                	addi	sp,sp,32
    8000280e:	8082                	ret
    return -1;
    80002810:	557d                	li	a0,-1
    80002812:	bfcd                	j	80002804 <fetchaddr+0x36>
    80002814:	557d                	li	a0,-1
    80002816:	b7fd                	j	80002804 <fetchaddr+0x36>

0000000080002818 <fetchstr>:
{
    80002818:	7179                	addi	sp,sp,-48
    8000281a:	f406                	sd	ra,40(sp)
    8000281c:	f022                	sd	s0,32(sp)
    8000281e:	ec26                	sd	s1,24(sp)
    80002820:	e84a                	sd	s2,16(sp)
    80002822:	e44e                	sd	s3,8(sp)
    80002824:	1800                	addi	s0,sp,48
    80002826:	89aa                	mv	s3,a0
    80002828:	84ae                	mv	s1,a1
    8000282a:	8932                	mv	s2,a2
  struct proc *p = myproc();
    8000282c:	8dcff0ef          	jal	80001908 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002830:	874a                	mv	a4,s2
    80002832:	86ce                	mv	a3,s3
    80002834:	8626                	mv	a2,s1
    80002836:	652c                	ld	a1,72(a0)
    80002838:	6928                	ld	a0,80(a0)
    8000283a:	e6bfe0ef          	jal	800016a4 <copyinstr>
    8000283e:	00054c63          	bltz	a0,80002856 <fetchstr+0x3e>
  return strlen(buf);
    80002842:	8526                	mv	a0,s1
    80002844:	deefe0ef          	jal	80000e32 <strlen>
}
    80002848:	70a2                	ld	ra,40(sp)
    8000284a:	7402                	ld	s0,32(sp)
    8000284c:	64e2                	ld	s1,24(sp)
    8000284e:	6942                	ld	s2,16(sp)
    80002850:	69a2                	ld	s3,8(sp)
    80002852:	6145                	addi	sp,sp,48
    80002854:	8082                	ret
    return -1;
    80002856:	557d                	li	a0,-1
    80002858:	bfc5                	j	80002848 <fetchstr+0x30>

000000008000285a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000285a:	1101                	addi	sp,sp,-32
    8000285c:	ec06                	sd	ra,24(sp)
    8000285e:	e822                	sd	s0,16(sp)
    80002860:	e426                	sd	s1,8(sp)
    80002862:	1000                	addi	s0,sp,32
    80002864:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002866:	f09ff0ef          	jal	8000276e <argraw>
    8000286a:	c088                	sw	a0,0(s1)
}
    8000286c:	60e2                	ld	ra,24(sp)
    8000286e:	6442                	ld	s0,16(sp)
    80002870:	64a2                	ld	s1,8(sp)
    80002872:	6105                	addi	sp,sp,32
    80002874:	8082                	ret

0000000080002876 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002876:	1101                	addi	sp,sp,-32
    80002878:	ec06                	sd	ra,24(sp)
    8000287a:	e822                	sd	s0,16(sp)
    8000287c:	e426                	sd	s1,8(sp)
    8000287e:	1000                	addi	s0,sp,32
    80002880:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002882:	eedff0ef          	jal	8000276e <argraw>
    80002886:	e088                	sd	a0,0(s1)
}
    80002888:	60e2                	ld	ra,24(sp)
    8000288a:	6442                	ld	s0,16(sp)
    8000288c:	64a2                	ld	s1,8(sp)
    8000288e:	6105                	addi	sp,sp,32
    80002890:	8082                	ret

0000000080002892 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002892:	1101                	addi	sp,sp,-32
    80002894:	ec06                	sd	ra,24(sp)
    80002896:	e822                	sd	s0,16(sp)
    80002898:	e426                	sd	s1,8(sp)
    8000289a:	e04a                	sd	s2,0(sp)
    8000289c:	1000                	addi	s0,sp,32
    8000289e:	892e                	mv	s2,a1
    800028a0:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800028a2:	ecdff0ef          	jal	8000276e <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800028a6:	8626                	mv	a2,s1
    800028a8:	85ca                	mv	a1,s2
    800028aa:	f6fff0ef          	jal	80002818 <fetchstr>
}
    800028ae:	60e2                	ld	ra,24(sp)
    800028b0:	6442                	ld	s0,16(sp)
    800028b2:	64a2                	ld	s1,8(sp)
    800028b4:	6902                	ld	s2,0(sp)
    800028b6:	6105                	addi	sp,sp,32
    800028b8:	8082                	ret

00000000800028ba <syscall>:
  // clang-format on
};

void
syscall(void)
{
    800028ba:	1101                	addi	sp,sp,-32
    800028bc:	ec06                	sd	ra,24(sp)
    800028be:	e822                	sd	s0,16(sp)
    800028c0:	e426                	sd	s1,8(sp)
    800028c2:	e04a                	sd	s2,0(sp)
    800028c4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800028c6:	842ff0ef          	jal	80001908 <myproc>
    800028ca:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800028cc:	05853903          	ld	s2,88(a0)
    800028d0:	0a893783          	ld	a5,168(s2)
    800028d4:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800028d8:	37fd                	addiw	a5,a5,-1
    800028da:	4755                	li	a4,21
    800028dc:	00f76f63          	bltu	a4,a5,800028fa <syscall+0x40>
    800028e0:	00369713          	slli	a4,a3,0x3
    800028e4:	00005797          	auipc	a5,0x5
    800028e8:	eac78793          	addi	a5,a5,-340 # 80007790 <syscalls>
    800028ec:	97ba                	add	a5,a5,a4
    800028ee:	639c                	ld	a5,0(a5)
    800028f0:	c789                	beqz	a5,800028fa <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028f2:	9782                	jalr	a5
    800028f4:	06a93823          	sd	a0,112(s2)
    800028f8:	a829                	j	80002912 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    800028fa:	15848613          	addi	a2,s1,344
    800028fe:	588c                	lw	a1,48(s1)
    80002900:	00005517          	auipc	a0,0x5
    80002904:	a9050513          	addi	a0,a0,-1392 # 80007390 <etext+0x390>
    80002908:	c03fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    8000290c:	6cbc                	ld	a5,88(s1)
    8000290e:	577d                	li	a4,-1
    80002910:	fbb8                	sd	a4,112(a5)
  }
}
    80002912:	60e2                	ld	ra,24(sp)
    80002914:	6442                	ld	s0,16(sp)
    80002916:	64a2                	ld	s1,8(sp)
    80002918:	6902                	ld	s2,0(sp)
    8000291a:	6105                	addi	sp,sp,32
    8000291c:	8082                	ret

000000008000291e <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    8000291e:	1101                	addi	sp,sp,-32
    80002920:	ec06                	sd	ra,24(sp)
    80002922:	e822                	sd	s0,16(sp)
    80002924:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002926:	fec40593          	addi	a1,s0,-20
    8000292a:	4501                	li	a0,0
    8000292c:	f2fff0ef          	jal	8000285a <argint>
  kexit(n);
    80002930:	fec42503          	lw	a0,-20(s0)
    80002934:	f16ff0ef          	jal	8000204a <kexit>
  return 0; // not reached
}
    80002938:	4501                	li	a0,0
    8000293a:	60e2                	ld	ra,24(sp)
    8000293c:	6442                	ld	s0,16(sp)
    8000293e:	6105                	addi	sp,sp,32
    80002940:	8082                	ret

0000000080002942 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002942:	1141                	addi	sp,sp,-16
    80002944:	e406                	sd	ra,8(sp)
    80002946:	e022                	sd	s0,0(sp)
    80002948:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000294a:	fbffe0ef          	jal	80001908 <myproc>
}
    8000294e:	5908                	lw	a0,48(a0)
    80002950:	60a2                	ld	ra,8(sp)
    80002952:	6402                	ld	s0,0(sp)
    80002954:	0141                	addi	sp,sp,16
    80002956:	8082                	ret

0000000080002958 <sys_fork>:

uint64
sys_fork(void)
{
    80002958:	1141                	addi	sp,sp,-16
    8000295a:	e406                	sd	ra,8(sp)
    8000295c:	e022                	sd	s0,0(sp)
    8000295e:	0800                	addi	s0,sp,16
  return kfork();
    80002960:	b18ff0ef          	jal	80001c78 <kfork>
}
    80002964:	60a2                	ld	ra,8(sp)
    80002966:	6402                	ld	s0,0(sp)
    80002968:	0141                	addi	sp,sp,16
    8000296a:	8082                	ret

000000008000296c <sys_wait>:

uint64
sys_wait(void)
{
    8000296c:	1101                	addi	sp,sp,-32
    8000296e:	ec06                	sd	ra,24(sp)
    80002970:	e822                	sd	s0,16(sp)
    80002972:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002974:	fe840593          	addi	a1,s0,-24
    80002978:	4501                	li	a0,0
    8000297a:	efdff0ef          	jal	80002876 <argaddr>
  return kwait(p);
    8000297e:	fe843503          	ld	a0,-24(s0)
    80002982:	823ff0ef          	jal	800021a4 <kwait>
}
    80002986:	60e2                	ld	ra,24(sp)
    80002988:	6442                	ld	s0,16(sp)
    8000298a:	6105                	addi	sp,sp,32
    8000298c:	8082                	ret

000000008000298e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000298e:	7179                	addi	sp,sp,-48
    80002990:	f406                	sd	ra,40(sp)
    80002992:	f022                	sd	s0,32(sp)
    80002994:	ec26                	sd	s1,24(sp)
    80002996:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002998:	fd840593          	addi	a1,s0,-40
    8000299c:	4501                	li	a0,0
    8000299e:	ebdff0ef          	jal	8000285a <argint>
  argint(1, &t);
    800029a2:	fdc40593          	addi	a1,s0,-36
    800029a6:	4505                	li	a0,1
    800029a8:	eb3ff0ef          	jal	8000285a <argint>
  addr = myproc()->sz;
    800029ac:	f5dfe0ef          	jal	80001908 <myproc>
    800029b0:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    800029b2:	fdc42703          	lw	a4,-36(s0)
    800029b6:	4785                	li	a5,1
    800029b8:	02f70763          	beq	a4,a5,800029e6 <sys_sbrk+0x58>
    800029bc:	fd842783          	lw	a5,-40(s0)
    800029c0:	0207c363          	bltz	a5,800029e6 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    800029c4:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    800029c6:	02000737          	lui	a4,0x2000
    800029ca:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    800029cc:	0736                	slli	a4,a4,0xd
    800029ce:	02f76a63          	bltu	a4,a5,80002a02 <sys_sbrk+0x74>
    800029d2:	0297e863          	bltu	a5,s1,80002a02 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    800029d6:	f33fe0ef          	jal	80001908 <myproc>
    800029da:	fd842703          	lw	a4,-40(s0)
    800029de:	653c                	ld	a5,72(a0)
    800029e0:	97ba                	add	a5,a5,a4
    800029e2:	e53c                	sd	a5,72(a0)
    800029e4:	a039                	j	800029f2 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    800029e6:	fd842503          	lw	a0,-40(s0)
    800029ea:	a2cff0ef          	jal	80001c16 <growproc>
    800029ee:	00054863          	bltz	a0,800029fe <sys_sbrk+0x70>
  }
  return addr;
}
    800029f2:	8526                	mv	a0,s1
    800029f4:	70a2                	ld	ra,40(sp)
    800029f6:	7402                	ld	s0,32(sp)
    800029f8:	64e2                	ld	s1,24(sp)
    800029fa:	6145                	addi	sp,sp,48
    800029fc:	8082                	ret
      return -1;
    800029fe:	54fd                	li	s1,-1
    80002a00:	bfcd                	j	800029f2 <sys_sbrk+0x64>
      return -1;
    80002a02:	54fd                	li	s1,-1
    80002a04:	b7fd                	j	800029f2 <sys_sbrk+0x64>

0000000080002a06 <sys_pause>:

uint64
sys_pause(void)
{
    80002a06:	7139                	addi	sp,sp,-64
    80002a08:	fc06                	sd	ra,56(sp)
    80002a0a:	f822                	sd	s0,48(sp)
    80002a0c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a0e:	fcc40593          	addi	a1,s0,-52
    80002a12:	4501                	li	a0,0
    80002a14:	e47ff0ef          	jal	8000285a <argint>
  if (n < 0)
    80002a18:	fcc42783          	lw	a5,-52(s0)
    80002a1c:	0807c063          	bltz	a5,80002a9c <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002a20:	00016517          	auipc	a0,0x16
    80002a24:	80050513          	addi	a0,a0,-2048 # 80018220 <tickslock>
    80002a28:	9c0fe0ef          	jal	80000be8 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002a2c:	fcc42783          	lw	a5,-52(s0)
    80002a30:	cbb9                	beqz	a5,80002a86 <sys_pause+0x80>
    80002a32:	f426                	sd	s1,40(sp)
    80002a34:	f04a                	sd	s2,32(sp)
    80002a36:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002a38:	00008997          	auipc	s3,0x8
    80002a3c:	8989a983          	lw	s3,-1896(s3) # 8000a2d0 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002a40:	00008917          	auipc	s2,0x8
    80002a44:	89090913          	addi	s2,s2,-1904 # 8000a2d0 <ticks>
    release(&tickslock);
    80002a48:	00015497          	auipc	s1,0x15
    80002a4c:	7d848493          	addi	s1,s1,2008 # 80018220 <tickslock>
    if (killed(myproc())) {
    80002a50:	eb9fe0ef          	jal	80001908 <myproc>
    80002a54:	f26ff0ef          	jal	8000217a <killed>
    80002a58:	e529                	bnez	a0,80002aa2 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002a5a:	854a                	mv	a0,s2
    80002a5c:	cc6ff0ef          	jal	80001f22 <sleep_prepare>
    release(&tickslock);
    80002a60:	8526                	mv	a0,s1
    80002a62:	a0efe0ef          	jal	80000c70 <release>
    sleep();
    80002a66:	cf8ff0ef          	jal	80001f5e <sleep>
    acquire(&tickslock);
    80002a6a:	8526                	mv	a0,s1
    80002a6c:	97cfe0ef          	jal	80000be8 <acquire>
  while (ticks - ticks0 < n) {
    80002a70:	00092783          	lw	a5,0(s2)
    80002a74:	413787bb          	subw	a5,a5,s3
    80002a78:	fcc42703          	lw	a4,-52(s0)
    80002a7c:	fce7eae3          	bltu	a5,a4,80002a50 <sys_pause+0x4a>
    80002a80:	74a2                	ld	s1,40(sp)
    80002a82:	7902                	ld	s2,32(sp)
    80002a84:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a86:	00015517          	auipc	a0,0x15
    80002a8a:	79a50513          	addi	a0,a0,1946 # 80018220 <tickslock>
    80002a8e:	9e2fe0ef          	jal	80000c70 <release>
  return 0;
    80002a92:	4501                	li	a0,0
}
    80002a94:	70e2                	ld	ra,56(sp)
    80002a96:	7442                	ld	s0,48(sp)
    80002a98:	6121                	addi	sp,sp,64
    80002a9a:	8082                	ret
    n = 0;
    80002a9c:	fc042623          	sw	zero,-52(s0)
    80002aa0:	b741                	j	80002a20 <sys_pause+0x1a>
      release(&tickslock);
    80002aa2:	00015517          	auipc	a0,0x15
    80002aa6:	77e50513          	addi	a0,a0,1918 # 80018220 <tickslock>
    80002aaa:	9c6fe0ef          	jal	80000c70 <release>
      return -1;
    80002aae:	557d                	li	a0,-1
    80002ab0:	74a2                	ld	s1,40(sp)
    80002ab2:	7902                	ld	s2,32(sp)
    80002ab4:	69e2                	ld	s3,24(sp)
    80002ab6:	bff9                	j	80002a94 <sys_pause+0x8e>

0000000080002ab8 <sys_kill>:

uint64
sys_kill(void)
{
    80002ab8:	1101                	addi	sp,sp,-32
    80002aba:	ec06                	sd	ra,24(sp)
    80002abc:	e822                	sd	s0,16(sp)
    80002abe:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ac0:	fec40593          	addi	a1,s0,-20
    80002ac4:	4501                	li	a0,0
    80002ac6:	d95ff0ef          	jal	8000285a <argint>
  return kkill(pid);
    80002aca:	fec42503          	lw	a0,-20(s0)
    80002ace:	e22ff0ef          	jal	800020f0 <kkill>
}
    80002ad2:	60e2                	ld	ra,24(sp)
    80002ad4:	6442                	ld	s0,16(sp)
    80002ad6:	6105                	addi	sp,sp,32
    80002ad8:	8082                	ret

0000000080002ada <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ada:	1101                	addi	sp,sp,-32
    80002adc:	ec06                	sd	ra,24(sp)
    80002ade:	e822                	sd	s0,16(sp)
    80002ae0:	e426                	sd	s1,8(sp)
    80002ae2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ae4:	00015517          	auipc	a0,0x15
    80002ae8:	73c50513          	addi	a0,a0,1852 # 80018220 <tickslock>
    80002aec:	8fcfe0ef          	jal	80000be8 <acquire>
  xticks = ticks;
    80002af0:	00007797          	auipc	a5,0x7
    80002af4:	7e07a783          	lw	a5,2016(a5) # 8000a2d0 <ticks>
    80002af8:	84be                	mv	s1,a5
  release(&tickslock);
    80002afa:	00015517          	auipc	a0,0x15
    80002afe:	72650513          	addi	a0,a0,1830 # 80018220 <tickslock>
    80002b02:	96efe0ef          	jal	80000c70 <release>
  return xticks;
}
    80002b06:	02049513          	slli	a0,s1,0x20
    80002b0a:	9101                	srli	a0,a0,0x20
    80002b0c:	60e2                	ld	ra,24(sp)
    80002b0e:	6442                	ld	s0,16(sp)
    80002b10:	64a2                	ld	s1,8(sp)
    80002b12:	6105                	addi	sp,sp,32
    80002b14:	8082                	ret

0000000080002b16 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b16:	7179                	addi	sp,sp,-48
    80002b18:	f406                	sd	ra,40(sp)
    80002b1a:	f022                	sd	s0,32(sp)
    80002b1c:	ec26                	sd	s1,24(sp)
    80002b1e:	e84a                	sd	s2,16(sp)
    80002b20:	e44e                	sd	s3,8(sp)
    80002b22:	e052                	sd	s4,0(sp)
    80002b24:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b26:	00005597          	auipc	a1,0x5
    80002b2a:	88a58593          	addi	a1,a1,-1910 # 800073b0 <etext+0x3b0>
    80002b2e:	00015517          	auipc	a0,0x15
    80002b32:	70a50513          	addi	a0,a0,1802 # 80018238 <bcache>
    80002b36:	832fe0ef          	jal	80000b68 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b3a:	0001d797          	auipc	a5,0x1d
    80002b3e:	6fe78793          	addi	a5,a5,1790 # 80020238 <bcache+0x8000>
    80002b42:	0001e717          	auipc	a4,0x1e
    80002b46:	95e70713          	addi	a4,a4,-1698 # 800204a0 <bcache+0x8268>
    80002b4a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b4e:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002b52:	00015497          	auipc	s1,0x15
    80002b56:	6fe48493          	addi	s1,s1,1790 # 80018250 <bcache+0x18>
    b->next = bcache.head.next;
    80002b5a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b5c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b5e:	00005a17          	auipc	s4,0x5
    80002b62:	85aa0a13          	addi	s4,s4,-1958 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002b66:	2b893783          	ld	a5,696(s2)
    80002b6a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b6c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b70:	85d2                	mv	a1,s4
    80002b72:	01048513          	addi	a0,s1,16
    80002b76:	40e010ef          	jal	80003f84 <initsleeplock>
    bcache.head.next->prev = b;
    80002b7a:	2b893783          	ld	a5,696(s2)
    80002b7e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b80:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002b84:	45848493          	addi	s1,s1,1112
    80002b88:	fd349fe3          	bne	s1,s3,80002b66 <binit+0x50>
  }
}
    80002b8c:	70a2                	ld	ra,40(sp)
    80002b8e:	7402                	ld	s0,32(sp)
    80002b90:	64e2                	ld	s1,24(sp)
    80002b92:	6942                	ld	s2,16(sp)
    80002b94:	69a2                	ld	s3,8(sp)
    80002b96:	6a02                	ld	s4,0(sp)
    80002b98:	6145                	addi	sp,sp,48
    80002b9a:	8082                	ret

0000000080002b9c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002b9c:	7179                	addi	sp,sp,-48
    80002b9e:	f406                	sd	ra,40(sp)
    80002ba0:	f022                	sd	s0,32(sp)
    80002ba2:	ec26                	sd	s1,24(sp)
    80002ba4:	e84a                	sd	s2,16(sp)
    80002ba6:	e44e                	sd	s3,8(sp)
    80002ba8:	1800                	addi	s0,sp,48
    80002baa:	892a                	mv	s2,a0
    80002bac:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002bae:	00015517          	auipc	a0,0x15
    80002bb2:	68a50513          	addi	a0,a0,1674 # 80018238 <bcache>
    80002bb6:	832fe0ef          	jal	80000be8 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002bba:	0001e497          	auipc	s1,0x1e
    80002bbe:	9364b483          	ld	s1,-1738(s1) # 800204f0 <bcache+0x82b8>
    80002bc2:	0001e797          	auipc	a5,0x1e
    80002bc6:	8de78793          	addi	a5,a5,-1826 # 800204a0 <bcache+0x8268>
    80002bca:	02f48b63          	beq	s1,a5,80002c00 <bread+0x64>
    80002bce:	873e                	mv	a4,a5
    80002bd0:	a021                	j	80002bd8 <bread+0x3c>
    80002bd2:	68a4                	ld	s1,80(s1)
    80002bd4:	02e48663          	beq	s1,a4,80002c00 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002bd8:	449c                	lw	a5,8(s1)
    80002bda:	ff279ce3          	bne	a5,s2,80002bd2 <bread+0x36>
    80002bde:	44dc                	lw	a5,12(s1)
    80002be0:	ff3799e3          	bne	a5,s3,80002bd2 <bread+0x36>
      b->refcnt++;
    80002be4:	40bc                	lw	a5,64(s1)
    80002be6:	2785                	addiw	a5,a5,1
    80002be8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bea:	00015517          	auipc	a0,0x15
    80002bee:	64e50513          	addi	a0,a0,1614 # 80018238 <bcache>
    80002bf2:	87efe0ef          	jal	80000c70 <release>
      acquiresleep(&b->lock);
    80002bf6:	01048513          	addi	a0,s1,16
    80002bfa:	3c0010ef          	jal	80003fba <acquiresleep>
      return b;
    80002bfe:	a889                	j	80002c50 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002c00:	0001e497          	auipc	s1,0x1e
    80002c04:	8e84b483          	ld	s1,-1816(s1) # 800204e8 <bcache+0x82b0>
    80002c08:	0001e797          	auipc	a5,0x1e
    80002c0c:	89878793          	addi	a5,a5,-1896 # 800204a0 <bcache+0x8268>
    80002c10:	00f48863          	beq	s1,a5,80002c20 <bread+0x84>
    80002c14:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002c16:	40bc                	lw	a5,64(s1)
    80002c18:	cb91                	beqz	a5,80002c2c <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002c1a:	64a4                	ld	s1,72(s1)
    80002c1c:	fee49de3          	bne	s1,a4,80002c16 <bread+0x7a>
  panic("bget: no buffers");
    80002c20:	00004517          	auipc	a0,0x4
    80002c24:	7a050513          	addi	a0,a0,1952 # 800073c0 <etext+0x3c0>
    80002c28:	c0dfd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002c2c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c30:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c34:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c38:	4785                	li	a5,1
    80002c3a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c3c:	00015517          	auipc	a0,0x15
    80002c40:	5fc50513          	addi	a0,a0,1532 # 80018238 <bcache>
    80002c44:	82cfe0ef          	jal	80000c70 <release>
      acquiresleep(&b->lock);
    80002c48:	01048513          	addi	a0,s1,16
    80002c4c:	36e010ef          	jal	80003fba <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002c50:	409c                	lw	a5,0(s1)
    80002c52:	cb89                	beqz	a5,80002c64 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c54:	8526                	mv	a0,s1
    80002c56:	70a2                	ld	ra,40(sp)
    80002c58:	7402                	ld	s0,32(sp)
    80002c5a:	64e2                	ld	s1,24(sp)
    80002c5c:	6942                	ld	s2,16(sp)
    80002c5e:	69a2                	ld	s3,8(sp)
    80002c60:	6145                	addi	sp,sp,48
    80002c62:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c64:	4581                	li	a1,0
    80002c66:	8526                	mv	a0,s1
    80002c68:	489020ef          	jal	800058f0 <virtio_disk_rw>
    b->valid = 1;
    80002c6c:	4785                	li	a5,1
    80002c6e:	c09c                	sw	a5,0(s1)
  return b;
    80002c70:	b7d5                	j	80002c54 <bread+0xb8>

0000000080002c72 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002c72:	1101                	addi	sp,sp,-32
    80002c74:	ec06                	sd	ra,24(sp)
    80002c76:	e822                	sd	s0,16(sp)
    80002c78:	e426                	sd	s1,8(sp)
    80002c7a:	1000                	addi	s0,sp,32
    80002c7c:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002c7e:	0541                	addi	a0,a0,16
    80002c80:	3c6010ef          	jal	80004046 <holdingsleep>
    80002c84:	c911                	beqz	a0,80002c98 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c86:	4585                	li	a1,1
    80002c88:	8526                	mv	a0,s1
    80002c8a:	467020ef          	jal	800058f0 <virtio_disk_rw>
}
    80002c8e:	60e2                	ld	ra,24(sp)
    80002c90:	6442                	ld	s0,16(sp)
    80002c92:	64a2                	ld	s1,8(sp)
    80002c94:	6105                	addi	sp,sp,32
    80002c96:	8082                	ret
    panic("bwrite");
    80002c98:	00004517          	auipc	a0,0x4
    80002c9c:	74050513          	addi	a0,a0,1856 # 800073d8 <etext+0x3d8>
    80002ca0:	b95fd0ef          	jal	80000834 <panic>

0000000080002ca4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ca4:	1101                	addi	sp,sp,-32
    80002ca6:	ec06                	sd	ra,24(sp)
    80002ca8:	e822                	sd	s0,16(sp)
    80002caa:	e426                	sd	s1,8(sp)
    80002cac:	e04a                	sd	s2,0(sp)
    80002cae:	1000                	addi	s0,sp,32
    80002cb0:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002cb2:	01050913          	addi	s2,a0,16
    80002cb6:	854a                	mv	a0,s2
    80002cb8:	38e010ef          	jal	80004046 <holdingsleep>
    80002cbc:	c125                	beqz	a0,80002d1c <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002cbe:	854a                	mv	a0,s2
    80002cc0:	34e010ef          	jal	8000400e <releasesleep>

  acquire(&bcache.lock);
    80002cc4:	00015517          	auipc	a0,0x15
    80002cc8:	57450513          	addi	a0,a0,1396 # 80018238 <bcache>
    80002ccc:	f1dfd0ef          	jal	80000be8 <acquire>
  b->refcnt--;
    80002cd0:	40bc                	lw	a5,64(s1)
    80002cd2:	37fd                	addiw	a5,a5,-1
    80002cd4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002cd6:	e79d                	bnez	a5,80002d04 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002cd8:	68b8                	ld	a4,80(s1)
    80002cda:	64bc                	ld	a5,72(s1)
    80002cdc:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002cde:	68b8                	ld	a4,80(s1)
    80002ce0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ce2:	0001d797          	auipc	a5,0x1d
    80002ce6:	55678793          	addi	a5,a5,1366 # 80020238 <bcache+0x8000>
    80002cea:	2b87b703          	ld	a4,696(a5)
    80002cee:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002cf0:	0001d717          	auipc	a4,0x1d
    80002cf4:	7b070713          	addi	a4,a4,1968 # 800204a0 <bcache+0x8268>
    80002cf8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002cfa:	2b87b703          	ld	a4,696(a5)
    80002cfe:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d00:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002d04:	00015517          	auipc	a0,0x15
    80002d08:	53450513          	addi	a0,a0,1332 # 80018238 <bcache>
    80002d0c:	f65fd0ef          	jal	80000c70 <release>
}
    80002d10:	60e2                	ld	ra,24(sp)
    80002d12:	6442                	ld	s0,16(sp)
    80002d14:	64a2                	ld	s1,8(sp)
    80002d16:	6902                	ld	s2,0(sp)
    80002d18:	6105                	addi	sp,sp,32
    80002d1a:	8082                	ret
    panic("brelse");
    80002d1c:	00004517          	auipc	a0,0x4
    80002d20:	6c450513          	addi	a0,a0,1732 # 800073e0 <etext+0x3e0>
    80002d24:	b11fd0ef          	jal	80000834 <panic>

0000000080002d28 <bpin>:

void
bpin(struct buf *b)
{
    80002d28:	1101                	addi	sp,sp,-32
    80002d2a:	ec06                	sd	ra,24(sp)
    80002d2c:	e822                	sd	s0,16(sp)
    80002d2e:	e426                	sd	s1,8(sp)
    80002d30:	1000                	addi	s0,sp,32
    80002d32:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d34:	00015517          	auipc	a0,0x15
    80002d38:	50450513          	addi	a0,a0,1284 # 80018238 <bcache>
    80002d3c:	eadfd0ef          	jal	80000be8 <acquire>
  b->refcnt++;
    80002d40:	40bc                	lw	a5,64(s1)
    80002d42:	2785                	addiw	a5,a5,1
    80002d44:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d46:	00015517          	auipc	a0,0x15
    80002d4a:	4f250513          	addi	a0,a0,1266 # 80018238 <bcache>
    80002d4e:	f23fd0ef          	jal	80000c70 <release>
}
    80002d52:	60e2                	ld	ra,24(sp)
    80002d54:	6442                	ld	s0,16(sp)
    80002d56:	64a2                	ld	s1,8(sp)
    80002d58:	6105                	addi	sp,sp,32
    80002d5a:	8082                	ret

0000000080002d5c <bunpin>:

void
bunpin(struct buf *b)
{
    80002d5c:	1101                	addi	sp,sp,-32
    80002d5e:	ec06                	sd	ra,24(sp)
    80002d60:	e822                	sd	s0,16(sp)
    80002d62:	e426                	sd	s1,8(sp)
    80002d64:	1000                	addi	s0,sp,32
    80002d66:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d68:	00015517          	auipc	a0,0x15
    80002d6c:	4d050513          	addi	a0,a0,1232 # 80018238 <bcache>
    80002d70:	e79fd0ef          	jal	80000be8 <acquire>
  b->refcnt--;
    80002d74:	40bc                	lw	a5,64(s1)
    80002d76:	37fd                	addiw	a5,a5,-1
    80002d78:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d7a:	00015517          	auipc	a0,0x15
    80002d7e:	4be50513          	addi	a0,a0,1214 # 80018238 <bcache>
    80002d82:	eeffd0ef          	jal	80000c70 <release>
}
    80002d86:	60e2                	ld	ra,24(sp)
    80002d88:	6442                	ld	s0,16(sp)
    80002d8a:	64a2                	ld	s1,8(sp)
    80002d8c:	6105                	addi	sp,sp,32
    80002d8e:	8082                	ret

0000000080002d90 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d90:	1101                	addi	sp,sp,-32
    80002d92:	ec06                	sd	ra,24(sp)
    80002d94:	e822                	sd	s0,16(sp)
    80002d96:	e426                	sd	s1,8(sp)
    80002d98:	e04a                	sd	s2,0(sp)
    80002d9a:	1000                	addi	s0,sp,32
    80002d9c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d9e:	00d5d79b          	srliw	a5,a1,0xd
    80002da2:	0001e597          	auipc	a1,0x1e
    80002da6:	b725a583          	lw	a1,-1166(a1) # 80020914 <sb+0x1c>
    80002daa:	9dbd                	addw	a1,a1,a5
    80002dac:	df1ff0ef          	jal	80002b9c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002db0:	0074f713          	andi	a4,s1,7
    80002db4:	4785                	li	a5,1
    80002db6:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002dba:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002dbc:	90d9                	srli	s1,s1,0x36
    80002dbe:	00950733          	add	a4,a0,s1
    80002dc2:	05874703          	lbu	a4,88(a4)
    80002dc6:	00e7f6b3          	and	a3,a5,a4
    80002dca:	c29d                	beqz	a3,80002df0 <bfree+0x60>
    80002dcc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002dce:	94aa                	add	s1,s1,a0
    80002dd0:	fff7c793          	not	a5,a5
    80002dd4:	8f7d                	and	a4,a4,a5
    80002dd6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002dda:	072010ef          	jal	80003e4c <log_write>
  brelse(bp);
    80002dde:	854a                	mv	a0,s2
    80002de0:	ec5ff0ef          	jal	80002ca4 <brelse>
}
    80002de4:	60e2                	ld	ra,24(sp)
    80002de6:	6442                	ld	s0,16(sp)
    80002de8:	64a2                	ld	s1,8(sp)
    80002dea:	6902                	ld	s2,0(sp)
    80002dec:	6105                	addi	sp,sp,32
    80002dee:	8082                	ret
    panic("freeing free block");
    80002df0:	00004517          	auipc	a0,0x4
    80002df4:	5f850513          	addi	a0,a0,1528 # 800073e8 <etext+0x3e8>
    80002df8:	a3dfd0ef          	jal	80000834 <panic>

0000000080002dfc <balloc>:
{
    80002dfc:	715d                	addi	sp,sp,-80
    80002dfe:	e486                	sd	ra,72(sp)
    80002e00:	e0a2                	sd	s0,64(sp)
    80002e02:	fc26                	sd	s1,56(sp)
    80002e04:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002e06:	0001e797          	auipc	a5,0x1e
    80002e0a:	af67a783          	lw	a5,-1290(a5) # 800208fc <sb+0x4>
    80002e0e:	0e078263          	beqz	a5,80002ef2 <balloc+0xf6>
    80002e12:	f84a                	sd	s2,48(sp)
    80002e14:	f44e                	sd	s3,40(sp)
    80002e16:	f052                	sd	s4,32(sp)
    80002e18:	ec56                	sd	s5,24(sp)
    80002e1a:	e85a                	sd	s6,16(sp)
    80002e1c:	e45e                	sd	s7,8(sp)
    80002e1e:	e062                	sd	s8,0(sp)
    80002e20:	8baa                	mv	s7,a0
    80002e22:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e24:	0001eb17          	auipc	s6,0x1e
    80002e28:	ad4b0b13          	addi	s6,s6,-1324 # 800208f8 <sb>
      m = 1 << (bi % 8);
    80002e2c:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e2e:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002e30:	6c09                	lui	s8,0x2
    80002e32:	a09d                	j	80002e98 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002e34:	97ca                	add	a5,a5,s2
    80002e36:	8e55                	or	a2,a2,a3
    80002e38:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e3c:	854a                	mv	a0,s2
    80002e3e:	00e010ef          	jal	80003e4c <log_write>
        brelse(bp);
    80002e42:	854a                	mv	a0,s2
    80002e44:	e61ff0ef          	jal	80002ca4 <brelse>
  bp = bread(dev, bno);
    80002e48:	85a6                	mv	a1,s1
    80002e4a:	855e                	mv	a0,s7
    80002e4c:	d51ff0ef          	jal	80002b9c <bread>
    80002e50:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e52:	40000613          	li	a2,1024
    80002e56:	4581                	li	a1,0
    80002e58:	05850513          	addi	a0,a0,88
    80002e5c:	e4dfd0ef          	jal	80000ca8 <memset>
  log_write(bp);
    80002e60:	854a                	mv	a0,s2
    80002e62:	7eb000ef          	jal	80003e4c <log_write>
  brelse(bp);
    80002e66:	854a                	mv	a0,s2
    80002e68:	e3dff0ef          	jal	80002ca4 <brelse>
}
    80002e6c:	7942                	ld	s2,48(sp)
    80002e6e:	79a2                	ld	s3,40(sp)
    80002e70:	7a02                	ld	s4,32(sp)
    80002e72:	6ae2                	ld	s5,24(sp)
    80002e74:	6b42                	ld	s6,16(sp)
    80002e76:	6ba2                	ld	s7,8(sp)
    80002e78:	6c02                	ld	s8,0(sp)
}
    80002e7a:	8526                	mv	a0,s1
    80002e7c:	60a6                	ld	ra,72(sp)
    80002e7e:	6406                	ld	s0,64(sp)
    80002e80:	74e2                	ld	s1,56(sp)
    80002e82:	6161                	addi	sp,sp,80
    80002e84:	8082                	ret
    brelse(bp);
    80002e86:	854a                	mv	a0,s2
    80002e88:	e1dff0ef          	jal	80002ca4 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002e8c:	015c0abb          	addw	s5,s8,s5
    80002e90:	004b2783          	lw	a5,4(s6)
    80002e94:	04faf863          	bgeu	s5,a5,80002ee4 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002e98:	40dad59b          	sraiw	a1,s5,0xd
    80002e9c:	01cb2783          	lw	a5,28(s6)
    80002ea0:	9dbd                	addw	a1,a1,a5
    80002ea2:	855e                	mv	a0,s7
    80002ea4:	cf9ff0ef          	jal	80002b9c <bread>
    80002ea8:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002eaa:	004b2503          	lw	a0,4(s6)
    80002eae:	84d6                	mv	s1,s5
    80002eb0:	4701                	li	a4,0
    80002eb2:	fca4fae3          	bgeu	s1,a0,80002e86 <balloc+0x8a>
      m = 1 << (bi % 8);
    80002eb6:	00777693          	andi	a3,a4,7
    80002eba:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002ebe:	41f7579b          	sraiw	a5,a4,0x1f
    80002ec2:	01d7d79b          	srliw	a5,a5,0x1d
    80002ec6:	9fb9                	addw	a5,a5,a4
    80002ec8:	4037d79b          	sraiw	a5,a5,0x3
    80002ecc:	00f90633          	add	a2,s2,a5
    80002ed0:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80002ed4:	00c6f5b3          	and	a1,a3,a2
    80002ed8:	ddb1                	beqz	a1,80002e34 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002eda:	2705                	addiw	a4,a4,1
    80002edc:	2485                	addiw	s1,s1,1
    80002ede:	fd471ae3          	bne	a4,s4,80002eb2 <balloc+0xb6>
    80002ee2:	b755                	j	80002e86 <balloc+0x8a>
    80002ee4:	7942                	ld	s2,48(sp)
    80002ee6:	79a2                	ld	s3,40(sp)
    80002ee8:	7a02                	ld	s4,32(sp)
    80002eea:	6ae2                	ld	s5,24(sp)
    80002eec:	6b42                	ld	s6,16(sp)
    80002eee:	6ba2                	ld	s7,8(sp)
    80002ef0:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80002ef2:	00004517          	auipc	a0,0x4
    80002ef6:	50e50513          	addi	a0,a0,1294 # 80007400 <etext+0x400>
    80002efa:	e10fd0ef          	jal	8000050a <printk>
  return 0;
    80002efe:	4481                	li	s1,0
    80002f00:	bfad                	j	80002e7a <balloc+0x7e>

0000000080002f02 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f02:	7179                	addi	sp,sp,-48
    80002f04:	f406                	sd	ra,40(sp)
    80002f06:	f022                	sd	s0,32(sp)
    80002f08:	ec26                	sd	s1,24(sp)
    80002f0a:	e84a                	sd	s2,16(sp)
    80002f0c:	e44e                	sd	s3,8(sp)
    80002f0e:	1800                	addi	s0,sp,48
    80002f10:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80002f12:	47ad                	li	a5,11
    80002f14:	02b7e363          	bltu	a5,a1,80002f3a <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80002f18:	02059793          	slli	a5,a1,0x20
    80002f1c:	01e7d593          	srli	a1,a5,0x1e
    80002f20:	00b509b3          	add	s3,a0,a1
    80002f24:	0509a483          	lw	s1,80(s3)
    80002f28:	e0b5                	bnez	s1,80002f8c <bmap+0x8a>
      addr = balloc(ip->dev);
    80002f2a:	4108                	lw	a0,0(a0)
    80002f2c:	ed1ff0ef          	jal	80002dfc <balloc>
    80002f30:	84aa                	mv	s1,a0
      if (addr == 0)
    80002f32:	cd29                	beqz	a0,80002f8c <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002f34:	04a9a823          	sw	a0,80(s3)
    80002f38:	a891                	j	80002f8c <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f3a:	ff45879b          	addiw	a5,a1,-12
    80002f3e:	873e                	mv	a4,a5
    80002f40:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    80002f42:	0ff00793          	li	a5,255
    80002f46:	06e7e763          	bltu	a5,a4,80002fb4 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80002f4a:	08052483          	lw	s1,128(a0)
    80002f4e:	e891                	bnez	s1,80002f62 <bmap+0x60>
      addr = balloc(ip->dev);
    80002f50:	4108                	lw	a0,0(a0)
    80002f52:	eabff0ef          	jal	80002dfc <balloc>
    80002f56:	84aa                	mv	s1,a0
      if (addr == 0)
    80002f58:	c915                	beqz	a0,80002f8c <bmap+0x8a>
    80002f5a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f5c:	08a92023          	sw	a0,128(s2)
    80002f60:	a011                	j	80002f64 <bmap+0x62>
    80002f62:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f64:	85a6                	mv	a1,s1
    80002f66:	00092503          	lw	a0,0(s2)
    80002f6a:	c33ff0ef          	jal	80002b9c <bread>
    80002f6e:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80002f70:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80002f74:	02099713          	slli	a4,s3,0x20
    80002f78:	01e75593          	srli	a1,a4,0x1e
    80002f7c:	97ae                	add	a5,a5,a1
    80002f7e:	89be                	mv	s3,a5
    80002f80:	4384                	lw	s1,0(a5)
    80002f82:	cc89                	beqz	s1,80002f9c <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f84:	8552                	mv	a0,s4
    80002f86:	d1fff0ef          	jal	80002ca4 <brelse>
    return addr;
    80002f8a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f8c:	8526                	mv	a0,s1
    80002f8e:	70a2                	ld	ra,40(sp)
    80002f90:	7402                	ld	s0,32(sp)
    80002f92:	64e2                	ld	s1,24(sp)
    80002f94:	6942                	ld	s2,16(sp)
    80002f96:	69a2                	ld	s3,8(sp)
    80002f98:	6145                	addi	sp,sp,48
    80002f9a:	8082                	ret
      addr = balloc(ip->dev);
    80002f9c:	00092503          	lw	a0,0(s2)
    80002fa0:	e5dff0ef          	jal	80002dfc <balloc>
    80002fa4:	84aa                	mv	s1,a0
      if (addr) {
    80002fa6:	dd79                	beqz	a0,80002f84 <bmap+0x82>
        a[bn] = addr;
    80002fa8:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80002fac:	8552                	mv	a0,s4
    80002fae:	69f000ef          	jal	80003e4c <log_write>
    80002fb2:	bfc9                	j	80002f84 <bmap+0x82>
    80002fb4:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002fb6:	00004517          	auipc	a0,0x4
    80002fba:	46250513          	addi	a0,a0,1122 # 80007418 <etext+0x418>
    80002fbe:	877fd0ef          	jal	80000834 <panic>

0000000080002fc2 <iget>:
{
    80002fc2:	7179                	addi	sp,sp,-48
    80002fc4:	f406                	sd	ra,40(sp)
    80002fc6:	f022                	sd	s0,32(sp)
    80002fc8:	ec26                	sd	s1,24(sp)
    80002fca:	e84a                	sd	s2,16(sp)
    80002fcc:	e44e                	sd	s3,8(sp)
    80002fce:	e052                	sd	s4,0(sp)
    80002fd0:	1800                	addi	s0,sp,48
    80002fd2:	892a                	mv	s2,a0
    80002fd4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002fd6:	0001e517          	auipc	a0,0x1e
    80002fda:	94250513          	addi	a0,a0,-1726 # 80020918 <itable>
    80002fde:	c0bfd0ef          	jal	80000be8 <acquire>
  empty = 0;
    80002fe2:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80002fe4:	0001e497          	auipc	s1,0x1e
    80002fe8:	94c48493          	addi	s1,s1,-1716 # 80020930 <itable+0x18>
    80002fec:	0001f697          	auipc	a3,0x1f
    80002ff0:	3d468693          	addi	a3,a3,980 # 800223c0 <log>
    80002ff4:	a809                	j	80003006 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80002ff6:	e781                	bnez	a5,80002ffe <iget+0x3c>
    80002ff8:	00099363          	bnez	s3,80002ffe <iget+0x3c>
      empty = ip;
    80002ffc:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80002ffe:	08848493          	addi	s1,s1,136
    80003002:	02d48563          	beq	s1,a3,8000302c <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80003006:	449c                	lw	a5,8(s1)
    80003008:	fef057e3          	blez	a5,80002ff6 <iget+0x34>
    8000300c:	4098                	lw	a4,0(s1)
    8000300e:	ff2718e3          	bne	a4,s2,80002ffe <iget+0x3c>
    80003012:	40d8                	lw	a4,4(s1)
    80003014:	ff4715e3          	bne	a4,s4,80002ffe <iget+0x3c>
      ip->ref++;
    80003018:	2785                	addiw	a5,a5,1
    8000301a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000301c:	0001e517          	auipc	a0,0x1e
    80003020:	8fc50513          	addi	a0,a0,-1796 # 80020918 <itable>
    80003024:	c4dfd0ef          	jal	80000c70 <release>
      return ip;
    80003028:	89a6                	mv	s3,s1
    8000302a:	a015                	j	8000304e <iget+0x8c>
  if (empty == 0)
    8000302c:	02098a63          	beqz	s3,80003060 <iget+0x9e>
  ip->dev = dev;
    80003030:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003034:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003038:	4785                	li	a5,1
    8000303a:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    8000303e:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003042:	0001e517          	auipc	a0,0x1e
    80003046:	8d650513          	addi	a0,a0,-1834 # 80020918 <itable>
    8000304a:	c27fd0ef          	jal	80000c70 <release>
}
    8000304e:	854e                	mv	a0,s3
    80003050:	70a2                	ld	ra,40(sp)
    80003052:	7402                	ld	s0,32(sp)
    80003054:	64e2                	ld	s1,24(sp)
    80003056:	6942                	ld	s2,16(sp)
    80003058:	69a2                	ld	s3,8(sp)
    8000305a:	6a02                	ld	s4,0(sp)
    8000305c:	6145                	addi	sp,sp,48
    8000305e:	8082                	ret
    panic("iget: no inodes");
    80003060:	00004517          	auipc	a0,0x4
    80003064:	3d050513          	addi	a0,a0,976 # 80007430 <etext+0x430>
    80003068:	fccfd0ef          	jal	80000834 <panic>

000000008000306c <iinit>:
{
    8000306c:	7179                	addi	sp,sp,-48
    8000306e:	f406                	sd	ra,40(sp)
    80003070:	f022                	sd	s0,32(sp)
    80003072:	ec26                	sd	s1,24(sp)
    80003074:	e84a                	sd	s2,16(sp)
    80003076:	e44e                	sd	s3,8(sp)
    80003078:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000307a:	00004597          	auipc	a1,0x4
    8000307e:	3c658593          	addi	a1,a1,966 # 80007440 <etext+0x440>
    80003082:	0001e517          	auipc	a0,0x1e
    80003086:	89650513          	addi	a0,a0,-1898 # 80020918 <itable>
    8000308a:	adffd0ef          	jal	80000b68 <initlock>
  for (i = 0; i < NINODE; i++) {
    8000308e:	0001e497          	auipc	s1,0x1e
    80003092:	8b248493          	addi	s1,s1,-1870 # 80020940 <itable+0x28>
    80003096:	0001f997          	auipc	s3,0x1f
    8000309a:	33a98993          	addi	s3,s3,826 # 800223d0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000309e:	00004917          	auipc	s2,0x4
    800030a2:	3aa90913          	addi	s2,s2,938 # 80007448 <etext+0x448>
    800030a6:	85ca                	mv	a1,s2
    800030a8:	8526                	mv	a0,s1
    800030aa:	6db000ef          	jal	80003f84 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    800030ae:	08848493          	addi	s1,s1,136
    800030b2:	ff349ae3          	bne	s1,s3,800030a6 <iinit+0x3a>
}
    800030b6:	70a2                	ld	ra,40(sp)
    800030b8:	7402                	ld	s0,32(sp)
    800030ba:	64e2                	ld	s1,24(sp)
    800030bc:	6942                	ld	s2,16(sp)
    800030be:	69a2                	ld	s3,8(sp)
    800030c0:	6145                	addi	sp,sp,48
    800030c2:	8082                	ret

00000000800030c4 <ialloc>:
{
    800030c4:	7139                	addi	sp,sp,-64
    800030c6:	fc06                	sd	ra,56(sp)
    800030c8:	f822                	sd	s0,48(sp)
    800030ca:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    800030cc:	0001e717          	auipc	a4,0x1e
    800030d0:	83872703          	lw	a4,-1992(a4) # 80020904 <sb+0xc>
    800030d4:	4785                	li	a5,1
    800030d6:	06e7f063          	bgeu	a5,a4,80003136 <ialloc+0x72>
    800030da:	f426                	sd	s1,40(sp)
    800030dc:	f04a                	sd	s2,32(sp)
    800030de:	ec4e                	sd	s3,24(sp)
    800030e0:	e852                	sd	s4,16(sp)
    800030e2:	e456                	sd	s5,8(sp)
    800030e4:	e05a                	sd	s6,0(sp)
    800030e6:	8aaa                	mv	s5,a0
    800030e8:	8b2e                	mv	s6,a1
    800030ea:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800030ec:	0001ea17          	auipc	s4,0x1e
    800030f0:	80ca0a13          	addi	s4,s4,-2036 # 800208f8 <sb>
    800030f4:	00495593          	srli	a1,s2,0x4
    800030f8:	018a2783          	lw	a5,24(s4)
    800030fc:	9dbd                	addw	a1,a1,a5
    800030fe:	8556                	mv	a0,s5
    80003100:	a9dff0ef          	jal	80002b9c <bread>
    80003104:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003106:	05850993          	addi	s3,a0,88
    8000310a:	00f97793          	andi	a5,s2,15
    8000310e:	079a                	slli	a5,a5,0x6
    80003110:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003112:	00099783          	lh	a5,0(s3)
    80003116:	cb9d                	beqz	a5,8000314c <ialloc+0x88>
    brelse(bp);
    80003118:	b8dff0ef          	jal	80002ca4 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000311c:	0905                	addi	s2,s2,1
    8000311e:	00ca2703          	lw	a4,12(s4)
    80003122:	0009079b          	sext.w	a5,s2
    80003126:	fce7e7e3          	bltu	a5,a4,800030f4 <ialloc+0x30>
    8000312a:	74a2                	ld	s1,40(sp)
    8000312c:	7902                	ld	s2,32(sp)
    8000312e:	69e2                	ld	s3,24(sp)
    80003130:	6a42                	ld	s4,16(sp)
    80003132:	6aa2                	ld	s5,8(sp)
    80003134:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    80003136:	00004517          	auipc	a0,0x4
    8000313a:	31a50513          	addi	a0,a0,794 # 80007450 <etext+0x450>
    8000313e:	bccfd0ef          	jal	8000050a <printk>
  return 0;
    80003142:	4501                	li	a0,0
}
    80003144:	70e2                	ld	ra,56(sp)
    80003146:	7442                	ld	s0,48(sp)
    80003148:	6121                	addi	sp,sp,64
    8000314a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000314c:	04000613          	li	a2,64
    80003150:	4581                	li	a1,0
    80003152:	854e                	mv	a0,s3
    80003154:	b55fd0ef          	jal	80000ca8 <memset>
      dip->type = type;
    80003158:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    8000315c:	8526                	mv	a0,s1
    8000315e:	4ef000ef          	jal	80003e4c <log_write>
      brelse(bp);
    80003162:	8526                	mv	a0,s1
    80003164:	b41ff0ef          	jal	80002ca4 <brelse>
      return iget(dev, inum);
    80003168:	0009059b          	sext.w	a1,s2
    8000316c:	8556                	mv	a0,s5
    8000316e:	e55ff0ef          	jal	80002fc2 <iget>
    80003172:	74a2                	ld	s1,40(sp)
    80003174:	7902                	ld	s2,32(sp)
    80003176:	69e2                	ld	s3,24(sp)
    80003178:	6a42                	ld	s4,16(sp)
    8000317a:	6aa2                	ld	s5,8(sp)
    8000317c:	6b02                	ld	s6,0(sp)
    8000317e:	b7d9                	j	80003144 <ialloc+0x80>

0000000080003180 <iupdate>:
{
    80003180:	1101                	addi	sp,sp,-32
    80003182:	ec06                	sd	ra,24(sp)
    80003184:	e822                	sd	s0,16(sp)
    80003186:	e426                	sd	s1,8(sp)
    80003188:	e04a                	sd	s2,0(sp)
    8000318a:	1000                	addi	s0,sp,32
    8000318c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000318e:	415c                	lw	a5,4(a0)
    80003190:	0047d79b          	srliw	a5,a5,0x4
    80003194:	0001d597          	auipc	a1,0x1d
    80003198:	77c5a583          	lw	a1,1916(a1) # 80020910 <sb+0x18>
    8000319c:	9dbd                	addw	a1,a1,a5
    8000319e:	4108                	lw	a0,0(a0)
    800031a0:	9fdff0ef          	jal	80002b9c <bread>
    800031a4:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    800031a6:	05850793          	addi	a5,a0,88
    800031aa:	40d8                	lw	a4,4(s1)
    800031ac:	8b3d                	andi	a4,a4,15
    800031ae:	071a                	slli	a4,a4,0x6
    800031b0:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800031b2:	04449703          	lh	a4,68(s1)
    800031b6:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800031ba:	04649703          	lh	a4,70(s1)
    800031be:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800031c2:	04849703          	lh	a4,72(s1)
    800031c6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800031ca:	04a49703          	lh	a4,74(s1)
    800031ce:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800031d2:	44f8                	lw	a4,76(s1)
    800031d4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800031d6:	03400613          	li	a2,52
    800031da:	05048593          	addi	a1,s1,80
    800031de:	00c78513          	addi	a0,a5,12
    800031e2:	b27fd0ef          	jal	80000d08 <memmove>
  log_write(bp);
    800031e6:	854a                	mv	a0,s2
    800031e8:	465000ef          	jal	80003e4c <log_write>
  brelse(bp);
    800031ec:	854a                	mv	a0,s2
    800031ee:	ab7ff0ef          	jal	80002ca4 <brelse>
}
    800031f2:	60e2                	ld	ra,24(sp)
    800031f4:	6442                	ld	s0,16(sp)
    800031f6:	64a2                	ld	s1,8(sp)
    800031f8:	6902                	ld	s2,0(sp)
    800031fa:	6105                	addi	sp,sp,32
    800031fc:	8082                	ret

00000000800031fe <idup>:
{
    800031fe:	1101                	addi	sp,sp,-32
    80003200:	ec06                	sd	ra,24(sp)
    80003202:	e822                	sd	s0,16(sp)
    80003204:	e426                	sd	s1,8(sp)
    80003206:	1000                	addi	s0,sp,32
    80003208:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000320a:	0001d517          	auipc	a0,0x1d
    8000320e:	70e50513          	addi	a0,a0,1806 # 80020918 <itable>
    80003212:	9d7fd0ef          	jal	80000be8 <acquire>
  ip->ref++;
    80003216:	449c                	lw	a5,8(s1)
    80003218:	2785                	addiw	a5,a5,1
    8000321a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000321c:	0001d517          	auipc	a0,0x1d
    80003220:	6fc50513          	addi	a0,a0,1788 # 80020918 <itable>
    80003224:	a4dfd0ef          	jal	80000c70 <release>
}
    80003228:	8526                	mv	a0,s1
    8000322a:	60e2                	ld	ra,24(sp)
    8000322c:	6442                	ld	s0,16(sp)
    8000322e:	64a2                	ld	s1,8(sp)
    80003230:	6105                	addi	sp,sp,32
    80003232:	8082                	ret

0000000080003234 <ilock>:
{
    80003234:	1101                	addi	sp,sp,-32
    80003236:	ec06                	sd	ra,24(sp)
    80003238:	e822                	sd	s0,16(sp)
    8000323a:	e426                	sd	s1,8(sp)
    8000323c:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    8000323e:	cd19                	beqz	a0,8000325c <ilock+0x28>
    80003240:	84aa                	mv	s1,a0
    80003242:	451c                	lw	a5,8(a0)
    80003244:	00f05c63          	blez	a5,8000325c <ilock+0x28>
  acquiresleep(&ip->lock);
    80003248:	0541                	addi	a0,a0,16
    8000324a:	571000ef          	jal	80003fba <acquiresleep>
  if (ip->valid == 0) {
    8000324e:	40bc                	lw	a5,64(s1)
    80003250:	cf89                	beqz	a5,8000326a <ilock+0x36>
}
    80003252:	60e2                	ld	ra,24(sp)
    80003254:	6442                	ld	s0,16(sp)
    80003256:	64a2                	ld	s1,8(sp)
    80003258:	6105                	addi	sp,sp,32
    8000325a:	8082                	ret
    8000325c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000325e:	00004517          	auipc	a0,0x4
    80003262:	20a50513          	addi	a0,a0,522 # 80007468 <etext+0x468>
    80003266:	dcefd0ef          	jal	80000834 <panic>
    8000326a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000326c:	40dc                	lw	a5,4(s1)
    8000326e:	0047d79b          	srliw	a5,a5,0x4
    80003272:	0001d597          	auipc	a1,0x1d
    80003276:	69e5a583          	lw	a1,1694(a1) # 80020910 <sb+0x18>
    8000327a:	9dbd                	addw	a1,a1,a5
    8000327c:	4088                	lw	a0,0(s1)
    8000327e:	91fff0ef          	jal	80002b9c <bread>
    80003282:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003284:	05850593          	addi	a1,a0,88
    80003288:	40dc                	lw	a5,4(s1)
    8000328a:	8bbd                	andi	a5,a5,15
    8000328c:	079a                	slli	a5,a5,0x6
    8000328e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003290:	00059783          	lh	a5,0(a1)
    80003294:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003298:	00259783          	lh	a5,2(a1)
    8000329c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800032a0:	00459783          	lh	a5,4(a1)
    800032a4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800032a8:	00659783          	lh	a5,6(a1)
    800032ac:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800032b0:	459c                	lw	a5,8(a1)
    800032b2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800032b4:	03400613          	li	a2,52
    800032b8:	05b1                	addi	a1,a1,12
    800032ba:	05048513          	addi	a0,s1,80
    800032be:	a4bfd0ef          	jal	80000d08 <memmove>
    brelse(bp);
    800032c2:	854a                	mv	a0,s2
    800032c4:	9e1ff0ef          	jal	80002ca4 <brelse>
    ip->valid = 1;
    800032c8:	4785                	li	a5,1
    800032ca:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    800032cc:	04449783          	lh	a5,68(s1)
    800032d0:	c399                	beqz	a5,800032d6 <ilock+0xa2>
    800032d2:	6902                	ld	s2,0(sp)
    800032d4:	bfbd                	j	80003252 <ilock+0x1e>
      panic("ilock: no type");
    800032d6:	00004517          	auipc	a0,0x4
    800032da:	19a50513          	addi	a0,a0,410 # 80007470 <etext+0x470>
    800032de:	d56fd0ef          	jal	80000834 <panic>

00000000800032e2 <iunlock>:
{
    800032e2:	1101                	addi	sp,sp,-32
    800032e4:	ec06                	sd	ra,24(sp)
    800032e6:	e822                	sd	s0,16(sp)
    800032e8:	e426                	sd	s1,8(sp)
    800032ea:	e04a                	sd	s2,0(sp)
    800032ec:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800032ee:	c505                	beqz	a0,80003316 <iunlock+0x34>
    800032f0:	84aa                	mv	s1,a0
    800032f2:	01050913          	addi	s2,a0,16
    800032f6:	854a                	mv	a0,s2
    800032f8:	54f000ef          	jal	80004046 <holdingsleep>
    800032fc:	cd09                	beqz	a0,80003316 <iunlock+0x34>
    800032fe:	449c                	lw	a5,8(s1)
    80003300:	00f05b63          	blez	a5,80003316 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003304:	854a                	mv	a0,s2
    80003306:	509000ef          	jal	8000400e <releasesleep>
}
    8000330a:	60e2                	ld	ra,24(sp)
    8000330c:	6442                	ld	s0,16(sp)
    8000330e:	64a2                	ld	s1,8(sp)
    80003310:	6902                	ld	s2,0(sp)
    80003312:	6105                	addi	sp,sp,32
    80003314:	8082                	ret
    panic("iunlock");
    80003316:	00004517          	auipc	a0,0x4
    8000331a:	16a50513          	addi	a0,a0,362 # 80007480 <etext+0x480>
    8000331e:	d16fd0ef          	jal	80000834 <panic>

0000000080003322 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003322:	7179                	addi	sp,sp,-48
    80003324:	f406                	sd	ra,40(sp)
    80003326:	f022                	sd	s0,32(sp)
    80003328:	ec26                	sd	s1,24(sp)
    8000332a:	e84a                	sd	s2,16(sp)
    8000332c:	e44e                	sd	s3,8(sp)
    8000332e:	1800                	addi	s0,sp,48
    80003330:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    80003332:	05050493          	addi	s1,a0,80
    80003336:	08050913          	addi	s2,a0,128
    8000333a:	a021                	j	80003342 <itrunc+0x20>
    8000333c:	0491                	addi	s1,s1,4
    8000333e:	01248b63          	beq	s1,s2,80003354 <itrunc+0x32>
    if (ip->addrs[i]) {
    80003342:	408c                	lw	a1,0(s1)
    80003344:	dde5                	beqz	a1,8000333c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003346:	0009a503          	lw	a0,0(s3)
    8000334a:	a47ff0ef          	jal	80002d90 <bfree>
      ip->addrs[i] = 0;
    8000334e:	0004a023          	sw	zero,0(s1)
    80003352:	b7ed                	j	8000333c <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    80003354:	0809a583          	lw	a1,128(s3)
    80003358:	ed89                	bnez	a1,80003372 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000335a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000335e:	854e                	mv	a0,s3
    80003360:	e21ff0ef          	jal	80003180 <iupdate>
}
    80003364:	70a2                	ld	ra,40(sp)
    80003366:	7402                	ld	s0,32(sp)
    80003368:	64e2                	ld	s1,24(sp)
    8000336a:	6942                	ld	s2,16(sp)
    8000336c:	69a2                	ld	s3,8(sp)
    8000336e:	6145                	addi	sp,sp,48
    80003370:	8082                	ret
    80003372:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003374:	0009a503          	lw	a0,0(s3)
    80003378:	825ff0ef          	jal	80002b9c <bread>
    8000337c:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    8000337e:	05850493          	addi	s1,a0,88
    80003382:	45850913          	addi	s2,a0,1112
    80003386:	a021                	j	8000338e <itrunc+0x6c>
    80003388:	0491                	addi	s1,s1,4
    8000338a:	01248963          	beq	s1,s2,8000339c <itrunc+0x7a>
      if (a[j])
    8000338e:	408c                	lw	a1,0(s1)
    80003390:	dde5                	beqz	a1,80003388 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003392:	0009a503          	lw	a0,0(s3)
    80003396:	9fbff0ef          	jal	80002d90 <bfree>
    8000339a:	b7fd                	j	80003388 <itrunc+0x66>
    brelse(bp);
    8000339c:	8552                	mv	a0,s4
    8000339e:	907ff0ef          	jal	80002ca4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800033a2:	0809a583          	lw	a1,128(s3)
    800033a6:	0009a503          	lw	a0,0(s3)
    800033aa:	9e7ff0ef          	jal	80002d90 <bfree>
    ip->addrs[NDIRECT] = 0;
    800033ae:	0809a023          	sw	zero,128(s3)
    800033b2:	6a02                	ld	s4,0(sp)
    800033b4:	b75d                	j	8000335a <itrunc+0x38>

00000000800033b6 <iput>:
{
    800033b6:	7179                	addi	sp,sp,-48
    800033b8:	f406                	sd	ra,40(sp)
    800033ba:	f022                	sd	s0,32(sp)
    800033bc:	ec26                	sd	s1,24(sp)
    800033be:	1800                	addi	s0,sp,48
    800033c0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033c2:	0001d517          	auipc	a0,0x1d
    800033c6:	55650513          	addi	a0,a0,1366 # 80020918 <itable>
    800033ca:	81ffd0ef          	jal	80000be8 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800033ce:	449c                	lw	a5,8(s1)
    800033d0:	4705                	li	a4,1
    800033d2:	00e78f63          	beq	a5,a4,800033f0 <iput+0x3a>
  ip->ref--;
    800033d6:	37fd                	addiw	a5,a5,-1
    800033d8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033da:	0001d517          	auipc	a0,0x1d
    800033de:	53e50513          	addi	a0,a0,1342 # 80020918 <itable>
    800033e2:	88ffd0ef          	jal	80000c70 <release>
}
    800033e6:	70a2                	ld	ra,40(sp)
    800033e8:	7402                	ld	s0,32(sp)
    800033ea:	64e2                	ld	s1,24(sp)
    800033ec:	6145                	addi	sp,sp,48
    800033ee:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800033f0:	40b8                	lw	a4,64(s1)
    800033f2:	d375                	beqz	a4,800033d6 <iput+0x20>
    800033f4:	e84a                	sd	s2,16(sp)
    800033f6:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    800033f8:	0004aa03          	lw	s4,0(s1)
    800033fc:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003400:	04a49703          	lh	a4,74(s1)
    80003404:	ef3d                	bnez	a4,80003482 <iput+0xcc>
    80003406:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003408:	01048793          	addi	a5,s1,16
    8000340c:	89be                	mv	s3,a5
    8000340e:	853e                	mv	a0,a5
    80003410:	3ab000ef          	jal	80003fba <acquiresleep>
    release(&itable.lock);
    80003414:	0001d517          	auipc	a0,0x1d
    80003418:	50450513          	addi	a0,a0,1284 # 80020918 <itable>
    8000341c:	855fd0ef          	jal	80000c70 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    80003420:	8526                	mv	a0,s1
    80003422:	f01ff0ef          	jal	80003322 <itrunc>
    ip->valid = 0;
    80003426:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000342a:	854e                	mv	a0,s3
    8000342c:	3e3000ef          	jal	8000400e <releasesleep>
    acquire(&itable.lock);
    80003430:	0001d517          	auipc	a0,0x1d
    80003434:	4e850513          	addi	a0,a0,1256 # 80020918 <itable>
    80003438:	fb0fd0ef          	jal	80000be8 <acquire>
  ip->ref--;
    8000343c:	449c                	lw	a5,8(s1)
    8000343e:	37fd                	addiw	a5,a5,-1
    80003440:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003442:	0001d517          	auipc	a0,0x1d
    80003446:	4d650513          	addi	a0,a0,1238 # 80020918 <itable>
    8000344a:	827fd0ef          	jal	80000c70 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000344e:	0049579b          	srliw	a5,s2,0x4
    80003452:	0001d597          	auipc	a1,0x1d
    80003456:	4be5a583          	lw	a1,1214(a1) # 80020910 <sb+0x18>
    8000345a:	9dbd                	addw	a1,a1,a5
    8000345c:	8552                	mv	a0,s4
    8000345e:	f3eff0ef          	jal	80002b9c <bread>
    80003462:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003464:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    80003468:	079a                	slli	a5,a5,0x6
    8000346a:	97aa                	add	a5,a5,a0
    8000346c:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    80003470:	1dd000ef          	jal	80003e4c <log_write>
  brelse(bp);
    80003474:	8526                	mv	a0,s1
    80003476:	82fff0ef          	jal	80002ca4 <brelse>
}
    8000347a:	6942                	ld	s2,16(sp)
    8000347c:	69a2                	ld	s3,8(sp)
    8000347e:	6a02                	ld	s4,0(sp)
    80003480:	b79d                	j	800033e6 <iput+0x30>
    80003482:	6942                	ld	s2,16(sp)
    80003484:	6a02                	ld	s4,0(sp)
    80003486:	bf81                	j	800033d6 <iput+0x20>

0000000080003488 <iunlockput>:
{
    80003488:	1101                	addi	sp,sp,-32
    8000348a:	ec06                	sd	ra,24(sp)
    8000348c:	e822                	sd	s0,16(sp)
    8000348e:	e426                	sd	s1,8(sp)
    80003490:	1000                	addi	s0,sp,32
    80003492:	84aa                	mv	s1,a0
  iunlock(ip);
    80003494:	e4fff0ef          	jal	800032e2 <iunlock>
  iput(ip);
    80003498:	8526                	mv	a0,s1
    8000349a:	f1dff0ef          	jal	800033b6 <iput>
}
    8000349e:	60e2                	ld	ra,24(sp)
    800034a0:	6442                	ld	s0,16(sp)
    800034a2:	64a2                	ld	s1,8(sp)
    800034a4:	6105                	addi	sp,sp,32
    800034a6:	8082                	ret

00000000800034a8 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034a8:	0001d717          	auipc	a4,0x1d
    800034ac:	45c72703          	lw	a4,1116(a4) # 80020904 <sb+0xc>
    800034b0:	4785                	li	a5,1
    800034b2:	0ae7fe63          	bgeu	a5,a4,8000356e <ireclaim+0xc6>
{
    800034b6:	7139                	addi	sp,sp,-64
    800034b8:	fc06                	sd	ra,56(sp)
    800034ba:	f822                	sd	s0,48(sp)
    800034bc:	f426                	sd	s1,40(sp)
    800034be:	f04a                	sd	s2,32(sp)
    800034c0:	ec4e                	sd	s3,24(sp)
    800034c2:	e852                	sd	s4,16(sp)
    800034c4:	e456                	sd	s5,8(sp)
    800034c6:	e05a                	sd	s6,0(sp)
    800034c8:	0080                	addi	s0,sp,64
    800034ca:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034cc:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034ce:	0001da17          	auipc	s4,0x1d
    800034d2:	42aa0a13          	addi	s4,s4,1066 # 800208f8 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    800034d6:	00004b17          	auipc	s6,0x4
    800034da:	fb2b0b13          	addi	s6,s6,-78 # 80007488 <etext+0x488>
    800034de:	a099                	j	80003524 <ireclaim+0x7c>
    800034e0:	85ce                	mv	a1,s3
    800034e2:	855a                	mv	a0,s6
    800034e4:	826fd0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    800034e8:	85ce                	mv	a1,s3
    800034ea:	8556                	mv	a0,s5
    800034ec:	ad7ff0ef          	jal	80002fc2 <iget>
    800034f0:	89aa                	mv	s3,a0
    brelse(bp);
    800034f2:	854a                	mv	a0,s2
    800034f4:	fb0ff0ef          	jal	80002ca4 <brelse>
    if (ip) {
    800034f8:	00098f63          	beqz	s3,80003516 <ireclaim+0x6e>
      begin_op();
    800034fc:	7a2000ef          	jal	80003c9e <begin_op>
      ilock(ip);
    80003500:	854e                	mv	a0,s3
    80003502:	d33ff0ef          	jal	80003234 <ilock>
      iunlock(ip);
    80003506:	854e                	mv	a0,s3
    80003508:	ddbff0ef          	jal	800032e2 <iunlock>
      iput(ip);
    8000350c:	854e                	mv	a0,s3
    8000350e:	ea9ff0ef          	jal	800033b6 <iput>
      end_op();
    80003512:	019000ef          	jal	80003d2a <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003516:	0485                	addi	s1,s1,1
    80003518:	00ca2703          	lw	a4,12(s4)
    8000351c:	0004879b          	sext.w	a5,s1
    80003520:	02e7fd63          	bgeu	a5,a4,8000355a <ireclaim+0xb2>
    80003524:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003528:	0044d593          	srli	a1,s1,0x4
    8000352c:	018a2783          	lw	a5,24(s4)
    80003530:	9dbd                	addw	a1,a1,a5
    80003532:	8556                	mv	a0,s5
    80003534:	e68ff0ef          	jal	80002b9c <bread>
    80003538:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000353a:	05850793          	addi	a5,a0,88
    8000353e:	00f9f713          	andi	a4,s3,15
    80003542:	071a                	slli	a4,a4,0x6
    80003544:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003546:	00079703          	lh	a4,0(a5)
    8000354a:	c701                	beqz	a4,80003552 <ireclaim+0xaa>
    8000354c:	00679783          	lh	a5,6(a5)
    80003550:	dbc1                	beqz	a5,800034e0 <ireclaim+0x38>
    brelse(bp);
    80003552:	854a                	mv	a0,s2
    80003554:	f50ff0ef          	jal	80002ca4 <brelse>
    if (ip) {
    80003558:	bf7d                	j	80003516 <ireclaim+0x6e>
}
    8000355a:	70e2                	ld	ra,56(sp)
    8000355c:	7442                	ld	s0,48(sp)
    8000355e:	74a2                	ld	s1,40(sp)
    80003560:	7902                	ld	s2,32(sp)
    80003562:	69e2                	ld	s3,24(sp)
    80003564:	6a42                	ld	s4,16(sp)
    80003566:	6aa2                	ld	s5,8(sp)
    80003568:	6b02                	ld	s6,0(sp)
    8000356a:	6121                	addi	sp,sp,64
    8000356c:	8082                	ret
    8000356e:	8082                	ret

0000000080003570 <fsinit>:
{
    80003570:	1101                	addi	sp,sp,-32
    80003572:	ec06                	sd	ra,24(sp)
    80003574:	e822                	sd	s0,16(sp)
    80003576:	e426                	sd	s1,8(sp)
    80003578:	e04a                	sd	s2,0(sp)
    8000357a:	1000                	addi	s0,sp,32
    8000357c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000357e:	4585                	li	a1,1
    80003580:	e1cff0ef          	jal	80002b9c <bread>
    80003584:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003586:	02000613          	li	a2,32
    8000358a:	05850593          	addi	a1,a0,88
    8000358e:	0001d517          	auipc	a0,0x1d
    80003592:	36a50513          	addi	a0,a0,874 # 800208f8 <sb>
    80003596:	f72fd0ef          	jal	80000d08 <memmove>
  brelse(bp);
    8000359a:	8526                	mv	a0,s1
    8000359c:	f08ff0ef          	jal	80002ca4 <brelse>
  if (sb.magic != FSMAGIC)
    800035a0:	0001d717          	auipc	a4,0x1d
    800035a4:	35872703          	lw	a4,856(a4) # 800208f8 <sb>
    800035a8:	102037b7          	lui	a5,0x10203
    800035ac:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035b0:	02f71263          	bne	a4,a5,800035d4 <fsinit+0x64>
  initlog(dev, &sb);
    800035b4:	0001d597          	auipc	a1,0x1d
    800035b8:	34458593          	addi	a1,a1,836 # 800208f8 <sb>
    800035bc:	854a                	mv	a0,s2
    800035be:	65e000ef          	jal	80003c1c <initlog>
  ireclaim(dev);
    800035c2:	854a                	mv	a0,s2
    800035c4:	ee5ff0ef          	jal	800034a8 <ireclaim>
}
    800035c8:	60e2                	ld	ra,24(sp)
    800035ca:	6442                	ld	s0,16(sp)
    800035cc:	64a2                	ld	s1,8(sp)
    800035ce:	6902                	ld	s2,0(sp)
    800035d0:	6105                	addi	sp,sp,32
    800035d2:	8082                	ret
    panic("invalid file system");
    800035d4:	00004517          	auipc	a0,0x4
    800035d8:	ed450513          	addi	a0,a0,-300 # 800074a8 <etext+0x4a8>
    800035dc:	a58fd0ef          	jal	80000834 <panic>

00000000800035e0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800035e0:	1141                	addi	sp,sp,-16
    800035e2:	e406                	sd	ra,8(sp)
    800035e4:	e022                	sd	s0,0(sp)
    800035e6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800035e8:	411c                	lw	a5,0(a0)
    800035ea:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800035ec:	415c                	lw	a5,4(a0)
    800035ee:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800035f0:	04451783          	lh	a5,68(a0)
    800035f4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800035f8:	04a51783          	lh	a5,74(a0)
    800035fc:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003600:	04c56783          	lwu	a5,76(a0)
    80003604:	e99c                	sd	a5,16(a1)
}
    80003606:	60a2                	ld	ra,8(sp)
    80003608:	6402                	ld	s0,0(sp)
    8000360a:	0141                	addi	sp,sp,16
    8000360c:	8082                	ret

000000008000360e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000360e:	457c                	lw	a5,76(a0)
    80003610:	0ed7e663          	bltu	a5,a3,800036fc <readi+0xee>
{
    80003614:	7159                	addi	sp,sp,-112
    80003616:	f486                	sd	ra,104(sp)
    80003618:	f0a2                	sd	s0,96(sp)
    8000361a:	eca6                	sd	s1,88(sp)
    8000361c:	e0d2                	sd	s4,64(sp)
    8000361e:	fc56                	sd	s5,56(sp)
    80003620:	f85a                	sd	s6,48(sp)
    80003622:	f45e                	sd	s7,40(sp)
    80003624:	1880                	addi	s0,sp,112
    80003626:	8b2a                	mv	s6,a0
    80003628:	8bae                	mv	s7,a1
    8000362a:	8a32                	mv	s4,a2
    8000362c:	84b6                	mv	s1,a3
    8000362e:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003630:	9f35                	addw	a4,a4,a3
    return 0;
    80003632:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003634:	0ad76b63          	bltu	a4,a3,800036ea <readi+0xdc>
    80003638:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    8000363a:	00e7f463          	bgeu	a5,a4,80003642 <readi+0x34>
    n = ip->size - off;
    8000363e:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003642:	080a8b63          	beqz	s5,800036d8 <readi+0xca>
    80003646:	e8ca                	sd	s2,80(sp)
    80003648:	f062                	sd	s8,32(sp)
    8000364a:	ec66                	sd	s9,24(sp)
    8000364c:	e86a                	sd	s10,16(sp)
    8000364e:	e46e                	sd	s11,8(sp)
    80003650:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003652:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003656:	5c7d                	li	s8,-1
    80003658:	a80d                	j	8000368a <readi+0x7c>
    8000365a:	020d1d93          	slli	s11,s10,0x20
    8000365e:	020ddd93          	srli	s11,s11,0x20
    80003662:	05890613          	addi	a2,s2,88
    80003666:	86ee                	mv	a3,s11
    80003668:	963e                	add	a2,a2,a5
    8000366a:	85d2                	mv	a1,s4
    8000366c:	855e                	mv	a0,s7
    8000366e:	c41fe0ef          	jal	800022ae <either_copyout>
    80003672:	05850363          	beq	a0,s8,800036b8 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003676:	854a                	mv	a0,s2
    80003678:	e2cff0ef          	jal	80002ca4 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000367c:	013d09bb          	addw	s3,s10,s3
    80003680:	009d04bb          	addw	s1,s10,s1
    80003684:	9a6e                	add	s4,s4,s11
    80003686:	0559f363          	bgeu	s3,s5,800036cc <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    8000368a:	00a4d59b          	srliw	a1,s1,0xa
    8000368e:	855a                	mv	a0,s6
    80003690:	873ff0ef          	jal	80002f02 <bmap>
    80003694:	85aa                	mv	a1,a0
    if (addr == 0)
    80003696:	c139                	beqz	a0,800036dc <readi+0xce>
    bp = bread(ip->dev, addr);
    80003698:	000b2503          	lw	a0,0(s6)
    8000369c:	d00ff0ef          	jal	80002b9c <bread>
    800036a0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800036a2:	3ff4f793          	andi	a5,s1,1023
    800036a6:	40fc873b          	subw	a4,s9,a5
    800036aa:	413a86bb          	subw	a3,s5,s3
    800036ae:	8d3a                	mv	s10,a4
    800036b0:	fae6f5e3          	bgeu	a3,a4,8000365a <readi+0x4c>
    800036b4:	8d36                	mv	s10,a3
    800036b6:	b755                	j	8000365a <readi+0x4c>
      brelse(bp);
    800036b8:	854a                	mv	a0,s2
    800036ba:	deaff0ef          	jal	80002ca4 <brelse>
      tot = -1;
    800036be:	59fd                	li	s3,-1
      break;
    800036c0:	6946                	ld	s2,80(sp)
    800036c2:	7c02                	ld	s8,32(sp)
    800036c4:	6ce2                	ld	s9,24(sp)
    800036c6:	6d42                	ld	s10,16(sp)
    800036c8:	6da2                	ld	s11,8(sp)
    800036ca:	a831                	j	800036e6 <readi+0xd8>
    800036cc:	6946                	ld	s2,80(sp)
    800036ce:	7c02                	ld	s8,32(sp)
    800036d0:	6ce2                	ld	s9,24(sp)
    800036d2:	6d42                	ld	s10,16(sp)
    800036d4:	6da2                	ld	s11,8(sp)
    800036d6:	a801                	j	800036e6 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800036d8:	89d6                	mv	s3,s5
    800036da:	a031                	j	800036e6 <readi+0xd8>
    800036dc:	6946                	ld	s2,80(sp)
    800036de:	7c02                	ld	s8,32(sp)
    800036e0:	6ce2                	ld	s9,24(sp)
    800036e2:	6d42                	ld	s10,16(sp)
    800036e4:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800036e6:	854e                	mv	a0,s3
    800036e8:	69a6                	ld	s3,72(sp)
}
    800036ea:	70a6                	ld	ra,104(sp)
    800036ec:	7406                	ld	s0,96(sp)
    800036ee:	64e6                	ld	s1,88(sp)
    800036f0:	6a06                	ld	s4,64(sp)
    800036f2:	7ae2                	ld	s5,56(sp)
    800036f4:	7b42                	ld	s6,48(sp)
    800036f6:	7ba2                	ld	s7,40(sp)
    800036f8:	6165                	addi	sp,sp,112
    800036fa:	8082                	ret
    return 0;
    800036fc:	4501                	li	a0,0
}
    800036fe:	8082                	ret

0000000080003700 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003700:	457c                	lw	a5,76(a0)
    80003702:	0ed7ee63          	bltu	a5,a3,800037fe <writei+0xfe>
{
    80003706:	7159                	addi	sp,sp,-112
    80003708:	f486                	sd	ra,104(sp)
    8000370a:	f0a2                	sd	s0,96(sp)
    8000370c:	e8ca                	sd	s2,80(sp)
    8000370e:	e0d2                	sd	s4,64(sp)
    80003710:	fc56                	sd	s5,56(sp)
    80003712:	f85a                	sd	s6,48(sp)
    80003714:	f45e                	sd	s7,40(sp)
    80003716:	1880                	addi	s0,sp,112
    80003718:	8aaa                	mv	s5,a0
    8000371a:	8bae                	mv	s7,a1
    8000371c:	8a32                	mv	s4,a2
    8000371e:	8936                	mv	s2,a3
    80003720:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003722:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003726:	00043737          	lui	a4,0x43
    8000372a:	0cf76c63          	bltu	a4,a5,80003802 <writei+0x102>
    8000372e:	0cd7ea63          	bltu	a5,a3,80003802 <writei+0x102>
    80003732:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003734:	0a0b0d63          	beqz	s6,800037ee <writei+0xee>
    80003738:	eca6                	sd	s1,88(sp)
    8000373a:	f062                	sd	s8,32(sp)
    8000373c:	ec66                	sd	s9,24(sp)
    8000373e:	e86a                	sd	s10,16(sp)
    80003740:	e46e                	sd	s11,8(sp)
    80003742:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003744:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003748:	5c7d                	li	s8,-1
    8000374a:	a825                	j	80003782 <writei+0x82>
    8000374c:	020d1d93          	slli	s11,s10,0x20
    80003750:	020ddd93          	srli	s11,s11,0x20
    80003754:	05848513          	addi	a0,s1,88
    80003758:	86ee                	mv	a3,s11
    8000375a:	8652                	mv	a2,s4
    8000375c:	85de                	mv	a1,s7
    8000375e:	953e                	add	a0,a0,a5
    80003760:	b9bfe0ef          	jal	800022fa <either_copyin>
    80003764:	05850663          	beq	a0,s8,800037b0 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003768:	8526                	mv	a0,s1
    8000376a:	6e2000ef          	jal	80003e4c <log_write>
    brelse(bp);
    8000376e:	8526                	mv	a0,s1
    80003770:	d34ff0ef          	jal	80002ca4 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003774:	013d09bb          	addw	s3,s10,s3
    80003778:	012d093b          	addw	s2,s10,s2
    8000377c:	9a6e                	add	s4,s4,s11
    8000377e:	0369ff63          	bgeu	s3,s6,800037bc <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    80003782:	00a9559b          	srliw	a1,s2,0xa
    80003786:	8556                	mv	a0,s5
    80003788:	f7aff0ef          	jal	80002f02 <bmap>
    8000378c:	85aa                	mv	a1,a0
    if (addr == 0)
    8000378e:	c51d                	beqz	a0,800037bc <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003790:	000aa503          	lw	a0,0(s5)
    80003794:	c08ff0ef          	jal	80002b9c <bread>
    80003798:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000379a:	3ff97793          	andi	a5,s2,1023
    8000379e:	40fc873b          	subw	a4,s9,a5
    800037a2:	413b06bb          	subw	a3,s6,s3
    800037a6:	8d3a                	mv	s10,a4
    800037a8:	fae6f2e3          	bgeu	a3,a4,8000374c <writei+0x4c>
    800037ac:	8d36                	mv	s10,a3
    800037ae:	bf79                	j	8000374c <writei+0x4c>
      log_write(bp);
    800037b0:	8526                	mv	a0,s1
    800037b2:	69a000ef          	jal	80003e4c <log_write>
      brelse(bp);
    800037b6:	8526                	mv	a0,s1
    800037b8:	cecff0ef          	jal	80002ca4 <brelse>
  }

  if (off > ip->size)
    800037bc:	04caa783          	lw	a5,76(s5)
    800037c0:	0327f963          	bgeu	a5,s2,800037f2 <writei+0xf2>
    ip->size = off;
    800037c4:	052aa623          	sw	s2,76(s5)
    800037c8:	64e6                	ld	s1,88(sp)
    800037ca:	7c02                	ld	s8,32(sp)
    800037cc:	6ce2                	ld	s9,24(sp)
    800037ce:	6d42                	ld	s10,16(sp)
    800037d0:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800037d2:	8556                	mv	a0,s5
    800037d4:	9adff0ef          	jal	80003180 <iupdate>

  return tot;
    800037d8:	854e                	mv	a0,s3
    800037da:	69a6                	ld	s3,72(sp)
}
    800037dc:	70a6                	ld	ra,104(sp)
    800037de:	7406                	ld	s0,96(sp)
    800037e0:	6946                	ld	s2,80(sp)
    800037e2:	6a06                	ld	s4,64(sp)
    800037e4:	7ae2                	ld	s5,56(sp)
    800037e6:	7b42                	ld	s6,48(sp)
    800037e8:	7ba2                	ld	s7,40(sp)
    800037ea:	6165                	addi	sp,sp,112
    800037ec:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800037ee:	89da                	mv	s3,s6
    800037f0:	b7cd                	j	800037d2 <writei+0xd2>
    800037f2:	64e6                	ld	s1,88(sp)
    800037f4:	7c02                	ld	s8,32(sp)
    800037f6:	6ce2                	ld	s9,24(sp)
    800037f8:	6d42                	ld	s10,16(sp)
    800037fa:	6da2                	ld	s11,8(sp)
    800037fc:	bfd9                	j	800037d2 <writei+0xd2>
    return -1;
    800037fe:	557d                	li	a0,-1
}
    80003800:	8082                	ret
    return -1;
    80003802:	557d                	li	a0,-1
    80003804:	bfe1                	j	800037dc <writei+0xdc>

0000000080003806 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003806:	1141                	addi	sp,sp,-16
    80003808:	e406                	sd	ra,8(sp)
    8000380a:	e022                	sd	s0,0(sp)
    8000380c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000380e:	4639                	li	a2,14
    80003810:	d6cfd0ef          	jal	80000d7c <strncmp>
}
    80003814:	60a2                	ld	ra,8(sp)
    80003816:	6402                	ld	s0,0(sp)
    80003818:	0141                	addi	sp,sp,16
    8000381a:	8082                	ret

000000008000381c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000381c:	711d                	addi	sp,sp,-96
    8000381e:	ec86                	sd	ra,88(sp)
    80003820:	e8a2                	sd	s0,80(sp)
    80003822:	e4a6                	sd	s1,72(sp)
    80003824:	e0ca                	sd	s2,64(sp)
    80003826:	fc4e                	sd	s3,56(sp)
    80003828:	f852                	sd	s4,48(sp)
    8000382a:	f456                	sd	s5,40(sp)
    8000382c:	f05a                	sd	s6,32(sp)
    8000382e:	ec5e                	sd	s7,24(sp)
    80003830:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003832:	04451703          	lh	a4,68(a0)
    80003836:	4785                	li	a5,1
    80003838:	00f71f63          	bne	a4,a5,80003856 <dirlookup+0x3a>
    8000383c:	892a                	mv	s2,a0
    8000383e:	8aae                	mv	s5,a1
    80003840:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003842:	457c                	lw	a5,76(a0)
    80003844:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003846:	fa040a13          	addi	s4,s0,-96
    8000384a:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    8000384c:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003850:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003852:	e39d                	bnez	a5,80003878 <dirlookup+0x5c>
    80003854:	a8b9                	j	800038b2 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003856:	00004517          	auipc	a0,0x4
    8000385a:	c6a50513          	addi	a0,a0,-918 # 800074c0 <etext+0x4c0>
    8000385e:	fd7fc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    80003862:	00004517          	auipc	a0,0x4
    80003866:	c7650513          	addi	a0,a0,-906 # 800074d8 <etext+0x4d8>
    8000386a:	fcbfc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000386e:	24c1                	addiw	s1,s1,16
    80003870:	04c92783          	lw	a5,76(s2)
    80003874:	02f4fe63          	bgeu	s1,a5,800038b0 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003878:	874e                	mv	a4,s3
    8000387a:	86a6                	mv	a3,s1
    8000387c:	8652                	mv	a2,s4
    8000387e:	4581                	li	a1,0
    80003880:	854a                	mv	a0,s2
    80003882:	d8dff0ef          	jal	8000360e <readi>
    80003886:	fd351ee3          	bne	a0,s3,80003862 <dirlookup+0x46>
    if (de.inum == 0)
    8000388a:	fa045783          	lhu	a5,-96(s0)
    8000388e:	d3e5                	beqz	a5,8000386e <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003890:	85da                	mv	a1,s6
    80003892:	8556                	mv	a0,s5
    80003894:	f73ff0ef          	jal	80003806 <namecmp>
    80003898:	f979                	bnez	a0,8000386e <dirlookup+0x52>
      if (poff)
    8000389a:	000b8463          	beqz	s7,800038a2 <dirlookup+0x86>
        *poff = off;
    8000389e:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800038a2:	fa045583          	lhu	a1,-96(s0)
    800038a6:	00092503          	lw	a0,0(s2)
    800038aa:	f18ff0ef          	jal	80002fc2 <iget>
    800038ae:	a011                	j	800038b2 <dirlookup+0x96>
  return 0;
    800038b0:	4501                	li	a0,0
}
    800038b2:	60e6                	ld	ra,88(sp)
    800038b4:	6446                	ld	s0,80(sp)
    800038b6:	64a6                	ld	s1,72(sp)
    800038b8:	6906                	ld	s2,64(sp)
    800038ba:	79e2                	ld	s3,56(sp)
    800038bc:	7a42                	ld	s4,48(sp)
    800038be:	7aa2                	ld	s5,40(sp)
    800038c0:	7b02                	ld	s6,32(sp)
    800038c2:	6be2                	ld	s7,24(sp)
    800038c4:	6125                	addi	sp,sp,96
    800038c6:	8082                	ret

00000000800038c8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    800038c8:	711d                	addi	sp,sp,-96
    800038ca:	ec86                	sd	ra,88(sp)
    800038cc:	e8a2                	sd	s0,80(sp)
    800038ce:	e4a6                	sd	s1,72(sp)
    800038d0:	e0ca                	sd	s2,64(sp)
    800038d2:	fc4e                	sd	s3,56(sp)
    800038d4:	f852                	sd	s4,48(sp)
    800038d6:	f456                	sd	s5,40(sp)
    800038d8:	f05a                	sd	s6,32(sp)
    800038da:	ec5e                	sd	s7,24(sp)
    800038dc:	e862                	sd	s8,16(sp)
    800038de:	e466                	sd	s9,8(sp)
    800038e0:	e06a                	sd	s10,0(sp)
    800038e2:	1080                	addi	s0,sp,96
    800038e4:	84aa                	mv	s1,a0
    800038e6:	8b2e                	mv	s6,a1
    800038e8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    800038ea:	00054703          	lbu	a4,0(a0)
    800038ee:	02f00793          	li	a5,47
    800038f2:	00f70f63          	beq	a4,a5,80003910 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800038f6:	812fe0ef          	jal	80001908 <myproc>
    800038fa:	15053503          	ld	a0,336(a0)
    800038fe:	901ff0ef          	jal	800031fe <idup>
    80003902:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003904:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003908:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    8000390a:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    8000390c:	4b85                	li	s7,1
    8000390e:	a07d                	j	800039bc <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003910:	4585                	li	a1,1
    80003912:	852e                	mv	a0,a1
    80003914:	eaeff0ef          	jal	80002fc2 <iget>
    80003918:	8a2a                	mv	s4,a0
    8000391a:	b7ed                	j	80003904 <namex+0x3c>
      iunlockput(ip);
    8000391c:	8552                	mv	a0,s4
    8000391e:	b6bff0ef          	jal	80003488 <iunlockput>
      return 0;
    80003922:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003924:	8552                	mv	a0,s4
    80003926:	60e6                	ld	ra,88(sp)
    80003928:	6446                	ld	s0,80(sp)
    8000392a:	64a6                	ld	s1,72(sp)
    8000392c:	6906                	ld	s2,64(sp)
    8000392e:	79e2                	ld	s3,56(sp)
    80003930:	7a42                	ld	s4,48(sp)
    80003932:	7aa2                	ld	s5,40(sp)
    80003934:	7b02                	ld	s6,32(sp)
    80003936:	6be2                	ld	s7,24(sp)
    80003938:	6c42                	ld	s8,16(sp)
    8000393a:	6ca2                	ld	s9,8(sp)
    8000393c:	6d02                	ld	s10,0(sp)
    8000393e:	6125                	addi	sp,sp,96
    80003940:	8082                	ret
      iunlockput(ip);
    80003942:	8552                	mv	a0,s4
    80003944:	b45ff0ef          	jal	80003488 <iunlockput>
      return 0;
    80003948:	4a01                	li	s4,0
    8000394a:	bfe9                	j	80003924 <namex+0x5c>
      iunlock(ip);
    8000394c:	8552                	mv	a0,s4
    8000394e:	995ff0ef          	jal	800032e2 <iunlock>
      return ip;
    80003952:	bfc9                	j	80003924 <namex+0x5c>
      iunlockput(ip);
    80003954:	8552                	mv	a0,s4
    80003956:	b33ff0ef          	jal	80003488 <iunlockput>
      return 0;
    8000395a:	8a4a                	mv	s4,s2
    8000395c:	b7e1                	j	80003924 <namex+0x5c>
  len = path - s;
    8000395e:	40990633          	sub	a2,s2,s1
    80003962:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003966:	09ac5763          	bge	s8,s10,800039f4 <namex+0x12c>
    memmove(name, s, DIRSIZ);
    8000396a:	8666                	mv	a2,s9
    8000396c:	85a6                	mv	a1,s1
    8000396e:	8556                	mv	a0,s5
    80003970:	b98fd0ef          	jal	80000d08 <memmove>
    80003974:	84ca                	mv	s1,s2
  while (*path == '/')
    80003976:	0004c783          	lbu	a5,0(s1)
    8000397a:	01379763          	bne	a5,s3,80003988 <namex+0xc0>
    path++;
    8000397e:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003980:	0004c783          	lbu	a5,0(s1)
    80003984:	ff378de3          	beq	a5,s3,8000397e <namex+0xb6>
    ilock(ip);
    80003988:	8552                	mv	a0,s4
    8000398a:	8abff0ef          	jal	80003234 <ilock>
    if (ip->type != T_DIR) {
    8000398e:	044a1783          	lh	a5,68(s4)
    80003992:	f97795e3          	bne	a5,s7,8000391c <namex+0x54>
    if (ip->nlink == 0) {
    80003996:	04aa1783          	lh	a5,74(s4)
    8000399a:	d7c5                	beqz	a5,80003942 <namex+0x7a>
    if (nameiparent && *path == '\0') {
    8000399c:	000b0563          	beqz	s6,800039a6 <namex+0xde>
    800039a0:	0004c783          	lbu	a5,0(s1)
    800039a4:	d7c5                	beqz	a5,8000394c <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    800039a6:	4601                	li	a2,0
    800039a8:	85d6                	mv	a1,s5
    800039aa:	8552                	mv	a0,s4
    800039ac:	e71ff0ef          	jal	8000381c <dirlookup>
    800039b0:	892a                	mv	s2,a0
    800039b2:	d14d                	beqz	a0,80003954 <namex+0x8c>
    iunlockput(ip);
    800039b4:	8552                	mv	a0,s4
    800039b6:	ad3ff0ef          	jal	80003488 <iunlockput>
    ip = next;
    800039ba:	8a4a                	mv	s4,s2
  while (*path == '/')
    800039bc:	0004c783          	lbu	a5,0(s1)
    800039c0:	01379763          	bne	a5,s3,800039ce <namex+0x106>
    path++;
    800039c4:	0485                	addi	s1,s1,1
  while (*path == '/')
    800039c6:	0004c783          	lbu	a5,0(s1)
    800039ca:	ff378de3          	beq	a5,s3,800039c4 <namex+0xfc>
  if (*path == 0)
    800039ce:	cf8d                	beqz	a5,80003a08 <namex+0x140>
  while (*path != '/' && *path != 0)
    800039d0:	0004c783          	lbu	a5,0(s1)
    800039d4:	fd178713          	addi	a4,a5,-47
    800039d8:	cb19                	beqz	a4,800039ee <namex+0x126>
    800039da:	cb91                	beqz	a5,800039ee <namex+0x126>
    800039dc:	8926                	mv	s2,s1
    path++;
    800039de:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    800039e0:	00094783          	lbu	a5,0(s2)
    800039e4:	fd178713          	addi	a4,a5,-47
    800039e8:	db3d                	beqz	a4,8000395e <namex+0x96>
    800039ea:	fbf5                	bnez	a5,800039de <namex+0x116>
    800039ec:	bf8d                	j	8000395e <namex+0x96>
    800039ee:	8926                	mv	s2,s1
  len = path - s;
    800039f0:	4d01                	li	s10,0
    800039f2:	4601                	li	a2,0
    memmove(name, s, len);
    800039f4:	2601                	sext.w	a2,a2
    800039f6:	85a6                	mv	a1,s1
    800039f8:	8556                	mv	a0,s5
    800039fa:	b0efd0ef          	jal	80000d08 <memmove>
    name[len] = 0;
    800039fe:	9d56                	add	s10,s10,s5
    80003a00:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdba00>
    80003a04:	84ca                	mv	s1,s2
    80003a06:	bf85                	j	80003976 <namex+0xae>
  if (nameiparent) {
    80003a08:	f00b0ee3          	beqz	s6,80003924 <namex+0x5c>
    iput(ip);
    80003a0c:	8552                	mv	a0,s4
    80003a0e:	9a9ff0ef          	jal	800033b6 <iput>
    return 0;
    80003a12:	4a01                	li	s4,0
    80003a14:	bf01                	j	80003924 <namex+0x5c>

0000000080003a16 <dirlink>:
{
    80003a16:	715d                	addi	sp,sp,-80
    80003a18:	e486                	sd	ra,72(sp)
    80003a1a:	e0a2                	sd	s0,64(sp)
    80003a1c:	f84a                	sd	s2,48(sp)
    80003a1e:	ec56                	sd	s5,24(sp)
    80003a20:	e85a                	sd	s6,16(sp)
    80003a22:	0880                	addi	s0,sp,80
    80003a24:	892a                	mv	s2,a0
    80003a26:	8aae                	mv	s5,a1
    80003a28:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003a2a:	4601                	li	a2,0
    80003a2c:	df1ff0ef          	jal	8000381c <dirlookup>
    80003a30:	ed1d                	bnez	a0,80003a6e <dirlink+0x58>
    80003a32:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a34:	04c92483          	lw	s1,76(s2)
    80003a38:	c4b9                	beqz	s1,80003a86 <dirlink+0x70>
    80003a3a:	f44e                	sd	s3,40(sp)
    80003a3c:	f052                	sd	s4,32(sp)
    80003a3e:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a40:	fb040a13          	addi	s4,s0,-80
    80003a44:	49c1                	li	s3,16
    80003a46:	874e                	mv	a4,s3
    80003a48:	86a6                	mv	a3,s1
    80003a4a:	8652                	mv	a2,s4
    80003a4c:	4581                	li	a1,0
    80003a4e:	854a                	mv	a0,s2
    80003a50:	bbfff0ef          	jal	8000360e <readi>
    80003a54:	03351163          	bne	a0,s3,80003a76 <dirlink+0x60>
    if (de.inum == 0)
    80003a58:	fb045783          	lhu	a5,-80(s0)
    80003a5c:	c39d                	beqz	a5,80003a82 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a5e:	24c1                	addiw	s1,s1,16
    80003a60:	04c92783          	lw	a5,76(s2)
    80003a64:	fef4e1e3          	bltu	s1,a5,80003a46 <dirlink+0x30>
    80003a68:	79a2                	ld	s3,40(sp)
    80003a6a:	7a02                	ld	s4,32(sp)
    80003a6c:	a829                	j	80003a86 <dirlink+0x70>
    iput(ip);
    80003a6e:	949ff0ef          	jal	800033b6 <iput>
    return -1;
    80003a72:	557d                	li	a0,-1
    80003a74:	a83d                	j	80003ab2 <dirlink+0x9c>
      panic("dirlink read");
    80003a76:	00004517          	auipc	a0,0x4
    80003a7a:	a7250513          	addi	a0,a0,-1422 # 800074e8 <etext+0x4e8>
    80003a7e:	db7fc0ef          	jal	80000834 <panic>
    80003a82:	79a2                	ld	s3,40(sp)
    80003a84:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003a86:	4639                	li	a2,14
    80003a88:	85d6                	mv	a1,s5
    80003a8a:	fb240513          	addi	a0,s0,-78
    80003a8e:	b28fd0ef          	jal	80000db6 <strncpy>
  de.inum = inum;
    80003a92:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a96:	4741                	li	a4,16
    80003a98:	86a6                	mv	a3,s1
    80003a9a:	fb040613          	addi	a2,s0,-80
    80003a9e:	4581                	li	a1,0
    80003aa0:	854a                	mv	a0,s2
    80003aa2:	c5fff0ef          	jal	80003700 <writei>
    80003aa6:	1541                	addi	a0,a0,-16
    80003aa8:	00a03533          	snez	a0,a0
    80003aac:	40a0053b          	negw	a0,a0
    80003ab0:	74e2                	ld	s1,56(sp)
}
    80003ab2:	60a6                	ld	ra,72(sp)
    80003ab4:	6406                	ld	s0,64(sp)
    80003ab6:	7942                	ld	s2,48(sp)
    80003ab8:	6ae2                	ld	s5,24(sp)
    80003aba:	6b42                	ld	s6,16(sp)
    80003abc:	6161                	addi	sp,sp,80
    80003abe:	8082                	ret

0000000080003ac0 <namei>:

struct inode *
namei(char *path)
{
    80003ac0:	1101                	addi	sp,sp,-32
    80003ac2:	ec06                	sd	ra,24(sp)
    80003ac4:	e822                	sd	s0,16(sp)
    80003ac6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ac8:	fe040613          	addi	a2,s0,-32
    80003acc:	4581                	li	a1,0
    80003ace:	dfbff0ef          	jal	800038c8 <namex>
}
    80003ad2:	60e2                	ld	ra,24(sp)
    80003ad4:	6442                	ld	s0,16(sp)
    80003ad6:	6105                	addi	sp,sp,32
    80003ad8:	8082                	ret

0000000080003ada <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003ada:	1141                	addi	sp,sp,-16
    80003adc:	e406                	sd	ra,8(sp)
    80003ade:	e022                	sd	s0,0(sp)
    80003ae0:	0800                	addi	s0,sp,16
    80003ae2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ae4:	4585                	li	a1,1
    80003ae6:	de3ff0ef          	jal	800038c8 <namex>
}
    80003aea:	60a2                	ld	ra,8(sp)
    80003aec:	6402                	ld	s0,0(sp)
    80003aee:	0141                	addi	sp,sp,16
    80003af0:	8082                	ret

0000000080003af2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003af2:	1101                	addi	sp,sp,-32
    80003af4:	ec06                	sd	ra,24(sp)
    80003af6:	e822                	sd	s0,16(sp)
    80003af8:	e426                	sd	s1,8(sp)
    80003afa:	e04a                	sd	s2,0(sp)
    80003afc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003afe:	0001f917          	auipc	s2,0x1f
    80003b02:	8c290913          	addi	s2,s2,-1854 # 800223c0 <log>
    80003b06:	01892583          	lw	a1,24(s2)
    80003b0a:	02492503          	lw	a0,36(s2)
    80003b0e:	88eff0ef          	jal	80002b9c <bread>
    80003b12:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003b14:	02c92603          	lw	a2,44(s2)
    80003b18:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b1a:	00c05f63          	blez	a2,80003b38 <write_head+0x46>
    80003b1e:	0001f717          	auipc	a4,0x1f
    80003b22:	8d270713          	addi	a4,a4,-1838 # 800223f0 <log+0x30>
    80003b26:	87aa                	mv	a5,a0
    80003b28:	060a                	slli	a2,a2,0x2
    80003b2a:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b2c:	4314                	lw	a3,0(a4)
    80003b2e:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b30:	0711                	addi	a4,a4,4
    80003b32:	0791                	addi	a5,a5,4
    80003b34:	fec79ce3          	bne	a5,a2,80003b2c <write_head+0x3a>
  }
  bwrite(buf);
    80003b38:	8526                	mv	a0,s1
    80003b3a:	938ff0ef          	jal	80002c72 <bwrite>
  brelse(buf);
    80003b3e:	8526                	mv	a0,s1
    80003b40:	964ff0ef          	jal	80002ca4 <brelse>
}
    80003b44:	60e2                	ld	ra,24(sp)
    80003b46:	6442                	ld	s0,16(sp)
    80003b48:	64a2                	ld	s1,8(sp)
    80003b4a:	6902                	ld	s2,0(sp)
    80003b4c:	6105                	addi	sp,sp,32
    80003b4e:	8082                	ret

0000000080003b50 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b50:	0001f797          	auipc	a5,0x1f
    80003b54:	89c7a783          	lw	a5,-1892(a5) # 800223ec <log+0x2c>
    80003b58:	0cf05163          	blez	a5,80003c1a <install_trans+0xca>
{
    80003b5c:	715d                	addi	sp,sp,-80
    80003b5e:	e486                	sd	ra,72(sp)
    80003b60:	e0a2                	sd	s0,64(sp)
    80003b62:	fc26                	sd	s1,56(sp)
    80003b64:	f84a                	sd	s2,48(sp)
    80003b66:	f44e                	sd	s3,40(sp)
    80003b68:	f052                	sd	s4,32(sp)
    80003b6a:	ec56                	sd	s5,24(sp)
    80003b6c:	e85a                	sd	s6,16(sp)
    80003b6e:	e45e                	sd	s7,8(sp)
    80003b70:	e062                	sd	s8,0(sp)
    80003b72:	0880                	addi	s0,sp,80
    80003b74:	8b2a                	mv	s6,a0
    80003b76:	0001fa97          	auipc	s5,0x1f
    80003b7a:	87aa8a93          	addi	s5,s5,-1926 # 800223f0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b7e:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b80:	00004c17          	auipc	s8,0x4
    80003b84:	978c0c13          	addi	s8,s8,-1672 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003b88:	0001fa17          	auipc	s4,0x1f
    80003b8c:	838a0a13          	addi	s4,s4,-1992 # 800223c0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003b90:	40000b93          	li	s7,1024
    80003b94:	a025                	j	80003bbc <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b96:	000aa603          	lw	a2,0(s5)
    80003b9a:	85ce                	mv	a1,s3
    80003b9c:	8562                	mv	a0,s8
    80003b9e:	96dfc0ef          	jal	8000050a <printk>
    80003ba2:	a839                	j	80003bc0 <install_trans+0x70>
    brelse(lbuf);
    80003ba4:	854a                	mv	a0,s2
    80003ba6:	8feff0ef          	jal	80002ca4 <brelse>
    brelse(dbuf);
    80003baa:	8526                	mv	a0,s1
    80003bac:	8f8ff0ef          	jal	80002ca4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bb0:	2985                	addiw	s3,s3,1
    80003bb2:	0a91                	addi	s5,s5,4
    80003bb4:	02ca2783          	lw	a5,44(s4)
    80003bb8:	04f9d563          	bge	s3,a5,80003c02 <install_trans+0xb2>
    if (recovering) {
    80003bbc:	fc0b1de3          	bnez	s6,80003b96 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003bc0:	018a2583          	lw	a1,24(s4)
    80003bc4:	013585bb          	addw	a1,a1,s3
    80003bc8:	2585                	addiw	a1,a1,1
    80003bca:	024a2503          	lw	a0,36(s4)
    80003bce:	fcffe0ef          	jal	80002b9c <bread>
    80003bd2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003bd4:	000aa583          	lw	a1,0(s5)
    80003bd8:	024a2503          	lw	a0,36(s4)
    80003bdc:	fc1fe0ef          	jal	80002b9c <bread>
    80003be0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003be2:	865e                	mv	a2,s7
    80003be4:	05890593          	addi	a1,s2,88
    80003be8:	05850513          	addi	a0,a0,88
    80003bec:	91cfd0ef          	jal	80000d08 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003bf0:	8526                	mv	a0,s1
    80003bf2:	880ff0ef          	jal	80002c72 <bwrite>
    if (recovering == 0)
    80003bf6:	fa0b17e3          	bnez	s6,80003ba4 <install_trans+0x54>
      bunpin(dbuf);
    80003bfa:	8526                	mv	a0,s1
    80003bfc:	960ff0ef          	jal	80002d5c <bunpin>
    80003c00:	b755                	j	80003ba4 <install_trans+0x54>
}
    80003c02:	60a6                	ld	ra,72(sp)
    80003c04:	6406                	ld	s0,64(sp)
    80003c06:	74e2                	ld	s1,56(sp)
    80003c08:	7942                	ld	s2,48(sp)
    80003c0a:	79a2                	ld	s3,40(sp)
    80003c0c:	7a02                	ld	s4,32(sp)
    80003c0e:	6ae2                	ld	s5,24(sp)
    80003c10:	6b42                	ld	s6,16(sp)
    80003c12:	6ba2                	ld	s7,8(sp)
    80003c14:	6c02                	ld	s8,0(sp)
    80003c16:	6161                	addi	sp,sp,80
    80003c18:	8082                	ret
    80003c1a:	8082                	ret

0000000080003c1c <initlog>:
{
    80003c1c:	7179                	addi	sp,sp,-48
    80003c1e:	f406                	sd	ra,40(sp)
    80003c20:	f022                	sd	s0,32(sp)
    80003c22:	ec26                	sd	s1,24(sp)
    80003c24:	e84a                	sd	s2,16(sp)
    80003c26:	e44e                	sd	s3,8(sp)
    80003c28:	1800                	addi	s0,sp,48
    80003c2a:	84aa                	mv	s1,a0
    80003c2c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c2e:	0001e917          	auipc	s2,0x1e
    80003c32:	79290913          	addi	s2,s2,1938 # 800223c0 <log>
    80003c36:	00004597          	auipc	a1,0x4
    80003c3a:	8e258593          	addi	a1,a1,-1822 # 80007518 <etext+0x518>
    80003c3e:	854a                	mv	a0,s2
    80003c40:	f29fc0ef          	jal	80000b68 <initlock>
  log.start = sb->logstart;
    80003c44:	0149a583          	lw	a1,20(s3)
    80003c48:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003c4c:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003c50:	8526                	mv	a0,s1
    80003c52:	f4bfe0ef          	jal	80002b9c <bread>
  log.lh.n = lh->n;
    80003c56:	4d30                	lw	a2,88(a0)
    80003c58:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003c5c:	00c05f63          	blez	a2,80003c7a <initlog+0x5e>
    80003c60:	87aa                	mv	a5,a0
    80003c62:	0001e717          	auipc	a4,0x1e
    80003c66:	78e70713          	addi	a4,a4,1934 # 800223f0 <log+0x30>
    80003c6a:	060a                	slli	a2,a2,0x2
    80003c6c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003c6e:	4ff4                	lw	a3,92(a5)
    80003c70:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c72:	0791                	addi	a5,a5,4
    80003c74:	0711                	addi	a4,a4,4
    80003c76:	fec79ce3          	bne	a5,a2,80003c6e <initlog+0x52>
  brelse(buf);
    80003c7a:	82aff0ef          	jal	80002ca4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003c7e:	4505                	li	a0,1
    80003c80:	ed1ff0ef          	jal	80003b50 <install_trans>
  log.lh.n = 0;
    80003c84:	0001e797          	auipc	a5,0x1e
    80003c88:	7607a423          	sw	zero,1896(a5) # 800223ec <log+0x2c>
  write_head(); // clear the log
    80003c8c:	e67ff0ef          	jal	80003af2 <write_head>
}
    80003c90:	70a2                	ld	ra,40(sp)
    80003c92:	7402                	ld	s0,32(sp)
    80003c94:	64e2                	ld	s1,24(sp)
    80003c96:	6942                	ld	s2,16(sp)
    80003c98:	69a2                	ld	s3,8(sp)
    80003c9a:	6145                	addi	sp,sp,48
    80003c9c:	8082                	ret

0000000080003c9e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003c9e:	1101                	addi	sp,sp,-32
    80003ca0:	ec06                	sd	ra,24(sp)
    80003ca2:	e822                	sd	s0,16(sp)
    80003ca4:	e426                	sd	s1,8(sp)
    80003ca6:	e04a                	sd	s2,0(sp)
    80003ca8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003caa:	0001e517          	auipc	a0,0x1e
    80003cae:	71650513          	addi	a0,a0,1814 # 800223c0 <log>
    80003cb2:	f37fc0ef          	jal	80000be8 <acquire>
  while (1) {
    if (log.committing) {
    80003cb6:	0001e497          	auipc	s1,0x1e
    80003cba:	70a48493          	addi	s1,s1,1802 # 800223c0 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003cbe:	4979                	li	s2,30
    80003cc0:	a821                	j	80003cd8 <begin_op+0x3a>
      sleep_prepare(&log);
    80003cc2:	8526                	mv	a0,s1
    80003cc4:	a5efe0ef          	jal	80001f22 <sleep_prepare>
      release(&log.lock);
    80003cc8:	8526                	mv	a0,s1
    80003cca:	fa7fc0ef          	jal	80000c70 <release>
      sleep();
    80003cce:	a90fe0ef          	jal	80001f5e <sleep>
      acquire(&log.lock);
    80003cd2:	8526                	mv	a0,s1
    80003cd4:	f15fc0ef          	jal	80000be8 <acquire>
    if (log.committing) {
    80003cd8:	509c                	lw	a5,32(s1)
    80003cda:	f7e5                	bnez	a5,80003cc2 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003cdc:	4cd8                	lw	a4,28(s1)
    80003cde:	2705                	addiw	a4,a4,1
    80003ce0:	0027179b          	slliw	a5,a4,0x2
    80003ce4:	9fb9                	addw	a5,a5,a4
    80003ce6:	0017979b          	slliw	a5,a5,0x1
    80003cea:	54d4                	lw	a3,44(s1)
    80003cec:	9fb5                	addw	a5,a5,a3
    80003cee:	00f95e63          	bge	s2,a5,80003d0a <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003cf2:	8526                	mv	a0,s1
    80003cf4:	a2efe0ef          	jal	80001f22 <sleep_prepare>
      release(&log.lock);
    80003cf8:	8526                	mv	a0,s1
    80003cfa:	f77fc0ef          	jal	80000c70 <release>
      sleep();
    80003cfe:	a60fe0ef          	jal	80001f5e <sleep>
      acquire(&log.lock);
    80003d02:	8526                	mv	a0,s1
    80003d04:	ee5fc0ef          	jal	80000be8 <acquire>
    80003d08:	bfc1                	j	80003cd8 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003d0a:	0001e797          	auipc	a5,0x1e
    80003d0e:	6ce7a923          	sw	a4,1746(a5) # 800223dc <log+0x1c>
      release(&log.lock);
    80003d12:	0001e517          	auipc	a0,0x1e
    80003d16:	6ae50513          	addi	a0,a0,1710 # 800223c0 <log>
    80003d1a:	f57fc0ef          	jal	80000c70 <release>
      break;
    }
  }
}
    80003d1e:	60e2                	ld	ra,24(sp)
    80003d20:	6442                	ld	s0,16(sp)
    80003d22:	64a2                	ld	s1,8(sp)
    80003d24:	6902                	ld	s2,0(sp)
    80003d26:	6105                	addi	sp,sp,32
    80003d28:	8082                	ret

0000000080003d2a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d2a:	7139                	addi	sp,sp,-64
    80003d2c:	fc06                	sd	ra,56(sp)
    80003d2e:	f822                	sd	s0,48(sp)
    80003d30:	f426                	sd	s1,40(sp)
    80003d32:	f04a                	sd	s2,32(sp)
    80003d34:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d36:	0001e497          	auipc	s1,0x1e
    80003d3a:	68a48493          	addi	s1,s1,1674 # 800223c0 <log>
    80003d3e:	8526                	mv	a0,s1
    80003d40:	ea9fc0ef          	jal	80000be8 <acquire>
  log.outstanding -= 1;
    80003d44:	4cdc                	lw	a5,28(s1)
    80003d46:	37fd                	addiw	a5,a5,-1
    80003d48:	893e                	mv	s2,a5
    80003d4a:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003d4c:	509c                	lw	a5,32(s1)
    80003d4e:	e3b1                	bnez	a5,80003d92 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003d50:	04091a63          	bnez	s2,80003da4 <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003d54:	0001e497          	auipc	s1,0x1e
    80003d58:	66c48493          	addi	s1,s1,1644 # 800223c0 <log>
    80003d5c:	4785                	li	a5,1
    80003d5e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d60:	8526                	mv	a0,s1
    80003d62:	f0ffc0ef          	jal	80000c70 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d66:	54dc                	lw	a5,44(s1)
    80003d68:	06f04063          	bgtz	a5,80003dc8 <end_op+0x9e>
    acquire(&log.lock);
    80003d6c:	0001e497          	auipc	s1,0x1e
    80003d70:	65448493          	addi	s1,s1,1620 # 800223c0 <log>
    80003d74:	8526                	mv	a0,s1
    80003d76:	e73fc0ef          	jal	80000be8 <acquire>
    log.committing = 0;
    80003d7a:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003d7e:	549c                	lw	a5,40(s1)
    80003d80:	2785                	addiw	a5,a5,1
    80003d82:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003d84:	8526                	mv	a0,s1
    80003d86:	a08fe0ef          	jal	80001f8e <wakeup>
    release(&log.lock);
    80003d8a:	8526                	mv	a0,s1
    80003d8c:	ee5fc0ef          	jal	80000c70 <release>
}
    80003d90:	a035                	j	80003dbc <end_op+0x92>
    80003d92:	ec4e                	sd	s3,24(sp)
    80003d94:	e852                	sd	s4,16(sp)
    80003d96:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003d98:	00003517          	auipc	a0,0x3
    80003d9c:	78850513          	addi	a0,a0,1928 # 80007520 <etext+0x520>
    80003da0:	a95fc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003da4:	0001e517          	auipc	a0,0x1e
    80003da8:	61c50513          	addi	a0,a0,1564 # 800223c0 <log>
    80003dac:	9e2fe0ef          	jal	80001f8e <wakeup>
  release(&log.lock);
    80003db0:	0001e517          	auipc	a0,0x1e
    80003db4:	61050513          	addi	a0,a0,1552 # 800223c0 <log>
    80003db8:	eb9fc0ef          	jal	80000c70 <release>
}
    80003dbc:	70e2                	ld	ra,56(sp)
    80003dbe:	7442                	ld	s0,48(sp)
    80003dc0:	74a2                	ld	s1,40(sp)
    80003dc2:	7902                	ld	s2,32(sp)
    80003dc4:	6121                	addi	sp,sp,64
    80003dc6:	8082                	ret
    80003dc8:	ec4e                	sd	s3,24(sp)
    80003dca:	e852                	sd	s4,16(sp)
    80003dcc:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dce:	0001ea97          	auipc	s5,0x1e
    80003dd2:	622a8a93          	addi	s5,s5,1570 # 800223f0 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003dd6:	0001ea17          	auipc	s4,0x1e
    80003dda:	5eaa0a13          	addi	s4,s4,1514 # 800223c0 <log>
    80003dde:	018a2583          	lw	a1,24(s4)
    80003de2:	012585bb          	addw	a1,a1,s2
    80003de6:	2585                	addiw	a1,a1,1
    80003de8:	024a2503          	lw	a0,36(s4)
    80003dec:	db1fe0ef          	jal	80002b9c <bread>
    80003df0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003df2:	000aa583          	lw	a1,0(s5)
    80003df6:	024a2503          	lw	a0,36(s4)
    80003dfa:	da3fe0ef          	jal	80002b9c <bread>
    80003dfe:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e00:	40000613          	li	a2,1024
    80003e04:	05850593          	addi	a1,a0,88
    80003e08:	05848513          	addi	a0,s1,88
    80003e0c:	efdfc0ef          	jal	80000d08 <memmove>
    bwrite(to); // write the log
    80003e10:	8526                	mv	a0,s1
    80003e12:	e61fe0ef          	jal	80002c72 <bwrite>
    brelse(from);
    80003e16:	854e                	mv	a0,s3
    80003e18:	e8dfe0ef          	jal	80002ca4 <brelse>
    brelse(to);
    80003e1c:	8526                	mv	a0,s1
    80003e1e:	e87fe0ef          	jal	80002ca4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e22:	2905                	addiw	s2,s2,1
    80003e24:	0a91                	addi	s5,s5,4
    80003e26:	02ca2783          	lw	a5,44(s4)
    80003e2a:	faf94ae3          	blt	s2,a5,80003dde <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003e2e:	cc5ff0ef          	jal	80003af2 <write_head>
    install_trans(0); // Now install writes to home locations
    80003e32:	4501                	li	a0,0
    80003e34:	d1dff0ef          	jal	80003b50 <install_trans>
    log.lh.n = 0;
    80003e38:	0001e797          	auipc	a5,0x1e
    80003e3c:	5a07aa23          	sw	zero,1460(a5) # 800223ec <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003e40:	cb3ff0ef          	jal	80003af2 <write_head>
    80003e44:	69e2                	ld	s3,24(sp)
    80003e46:	6a42                	ld	s4,16(sp)
    80003e48:	6aa2                	ld	s5,8(sp)
    80003e4a:	b70d                	j	80003d6c <end_op+0x42>

0000000080003e4c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e4c:	1101                	addi	sp,sp,-32
    80003e4e:	ec06                	sd	ra,24(sp)
    80003e50:	e822                	sd	s0,16(sp)
    80003e52:	e426                	sd	s1,8(sp)
    80003e54:	1000                	addi	s0,sp,32
    80003e56:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e58:	0001e517          	auipc	a0,0x1e
    80003e5c:	56850513          	addi	a0,a0,1384 # 800223c0 <log>
    80003e60:	d89fc0ef          	jal	80000be8 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003e64:	0001e617          	auipc	a2,0x1e
    80003e68:	58862603          	lw	a2,1416(a2) # 800223ec <log+0x2c>
    80003e6c:	47f5                	li	a5,29
    80003e6e:	04c7cd63          	blt	a5,a2,80003ec8 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003e72:	0001e797          	auipc	a5,0x1e
    80003e76:	56a7a783          	lw	a5,1386(a5) # 800223dc <log+0x1c>
    80003e7a:	04f05d63          	blez	a5,80003ed4 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003e7e:	4781                	li	a5,0
    80003e80:	06c05063          	blez	a2,80003ee0 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003e84:	44cc                	lw	a1,12(s1)
    80003e86:	0001e717          	auipc	a4,0x1e
    80003e8a:	56a70713          	addi	a4,a4,1386 # 800223f0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003e8e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003e90:	4314                	lw	a3,0(a4)
    80003e92:	04b68763          	beq	a3,a1,80003ee0 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003e96:	2785                	addiw	a5,a5,1
    80003e98:	0711                	addi	a4,a4,4
    80003e9a:	fef61be3          	bne	a2,a5,80003e90 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003e9e:	060a                	slli	a2,a2,0x2
    80003ea0:	02060613          	addi	a2,a2,32
    80003ea4:	0001e797          	auipc	a5,0x1e
    80003ea8:	51c78793          	addi	a5,a5,1308 # 800223c0 <log>
    80003eac:	97b2                	add	a5,a5,a2
    80003eae:	44d8                	lw	a4,12(s1)
    80003eb0:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003eb2:	8526                	mv	a0,s1
    80003eb4:	e75fe0ef          	jal	80002d28 <bpin>
    log.lh.n++;
    80003eb8:	0001e717          	auipc	a4,0x1e
    80003ebc:	50870713          	addi	a4,a4,1288 # 800223c0 <log>
    80003ec0:	575c                	lw	a5,44(a4)
    80003ec2:	2785                	addiw	a5,a5,1
    80003ec4:	d75c                	sw	a5,44(a4)
    80003ec6:	a815                	j	80003efa <log_write+0xae>
    panic("too big a transaction");
    80003ec8:	00003517          	auipc	a0,0x3
    80003ecc:	66850513          	addi	a0,a0,1640 # 80007530 <etext+0x530>
    80003ed0:	965fc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    80003ed4:	00003517          	auipc	a0,0x3
    80003ed8:	67450513          	addi	a0,a0,1652 # 80007548 <etext+0x548>
    80003edc:	959fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80003ee0:	00279693          	slli	a3,a5,0x2
    80003ee4:	02068693          	addi	a3,a3,32
    80003ee8:	0001e717          	auipc	a4,0x1e
    80003eec:	4d870713          	addi	a4,a4,1240 # 800223c0 <log>
    80003ef0:	9736                	add	a4,a4,a3
    80003ef2:	44d4                	lw	a3,12(s1)
    80003ef4:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003ef6:	faf60ee3          	beq	a2,a5,80003eb2 <log_write+0x66>
  }
  release(&log.lock);
    80003efa:	0001e517          	auipc	a0,0x1e
    80003efe:	4c650513          	addi	a0,a0,1222 # 800223c0 <log>
    80003f02:	d6ffc0ef          	jal	80000c70 <release>
}
    80003f06:	60e2                	ld	ra,24(sp)
    80003f08:	6442                	ld	s0,16(sp)
    80003f0a:	64a2                	ld	s1,8(sp)
    80003f0c:	6105                	addi	sp,sp,32
    80003f0e:	8082                	ret

0000000080003f10 <sys_sync>:

uint64
sys_sync(void)
{
    80003f10:	1101                	addi	sp,sp,-32
    80003f12:	ec06                	sd	ra,24(sp)
    80003f14:	e822                	sd	s0,16(sp)
    80003f16:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f18:	0001e517          	auipc	a0,0x1e
    80003f1c:	4a850513          	addi	a0,a0,1192 # 800223c0 <log>
    80003f20:	cc9fc0ef          	jal	80000be8 <acquire>
  if (log.committing || log.outstanding > 0) {
    80003f24:	0001e797          	auipc	a5,0x1e
    80003f28:	4bc7a783          	lw	a5,1212(a5) # 800223e0 <log+0x20>
    80003f2c:	e799                	bnez	a5,80003f3a <sys_sync+0x2a>
    80003f2e:	0001e797          	auipc	a5,0x1e
    80003f32:	4ae7a783          	lw	a5,1198(a5) # 800223dc <log+0x1c>
    80003f36:	02f05c63          	blez	a5,80003f6e <sys_sync+0x5e>
    80003f3a:	e426                	sd	s1,8(sp)
    80003f3c:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80003f3e:	0001e917          	auipc	s2,0x1e
    80003f42:	4aa92903          	lw	s2,1194(s2) # 800223e8 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80003f46:	0001e497          	auipc	s1,0x1e
    80003f4a:	47a48493          	addi	s1,s1,1146 # 800223c0 <log>
    80003f4e:	8526                	mv	a0,s1
    80003f50:	fd3fd0ef          	jal	80001f22 <sleep_prepare>
      release(&log.lock);
    80003f54:	8526                	mv	a0,s1
    80003f56:	d1bfc0ef          	jal	80000c70 <release>
      sleep();
    80003f5a:	804fe0ef          	jal	80001f5e <sleep>
      acquire(&log.lock);
    80003f5e:	8526                	mv	a0,s1
    80003f60:	c89fc0ef          	jal	80000be8 <acquire>
    while (log.ncommit < n) {
    80003f64:	549c                	lw	a5,40(s1)
    80003f66:	fef954e3          	bge	s2,a5,80003f4e <sys_sync+0x3e>
    80003f6a:	64a2                	ld	s1,8(sp)
    80003f6c:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80003f6e:	0001e517          	auipc	a0,0x1e
    80003f72:	45250513          	addi	a0,a0,1106 # 800223c0 <log>
    80003f76:	cfbfc0ef          	jal	80000c70 <release>
  return 0;
}
    80003f7a:	4501                	li	a0,0
    80003f7c:	60e2                	ld	ra,24(sp)
    80003f7e:	6442                	ld	s0,16(sp)
    80003f80:	6105                	addi	sp,sp,32
    80003f82:	8082                	ret

0000000080003f84 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003f84:	1101                	addi	sp,sp,-32
    80003f86:	ec06                	sd	ra,24(sp)
    80003f88:	e822                	sd	s0,16(sp)
    80003f8a:	e426                	sd	s1,8(sp)
    80003f8c:	e04a                	sd	s2,0(sp)
    80003f8e:	1000                	addi	s0,sp,32
    80003f90:	84aa                	mv	s1,a0
    80003f92:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f94:	00003597          	auipc	a1,0x3
    80003f98:	5d458593          	addi	a1,a1,1492 # 80007568 <etext+0x568>
    80003f9c:	0521                	addi	a0,a0,8
    80003f9e:	bcbfc0ef          	jal	80000b68 <initlock>
  lk->name = name;
    80003fa2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003fa6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003faa:	0204a423          	sw	zero,40(s1)
}
    80003fae:	60e2                	ld	ra,24(sp)
    80003fb0:	6442                	ld	s0,16(sp)
    80003fb2:	64a2                	ld	s1,8(sp)
    80003fb4:	6902                	ld	s2,0(sp)
    80003fb6:	6105                	addi	sp,sp,32
    80003fb8:	8082                	ret

0000000080003fba <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003fba:	1101                	addi	sp,sp,-32
    80003fbc:	ec06                	sd	ra,24(sp)
    80003fbe:	e822                	sd	s0,16(sp)
    80003fc0:	e426                	sd	s1,8(sp)
    80003fc2:	e04a                	sd	s2,0(sp)
    80003fc4:	1000                	addi	s0,sp,32
    80003fc6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003fc8:	00850913          	addi	s2,a0,8
    80003fcc:	854a                	mv	a0,s2
    80003fce:	c1bfc0ef          	jal	80000be8 <acquire>
  while (lk->locked) {
    80003fd2:	409c                	lw	a5,0(s1)
    80003fd4:	cf91                	beqz	a5,80003ff0 <acquiresleep+0x36>
    sleep_prepare(lk);
    80003fd6:	8526                	mv	a0,s1
    80003fd8:	f4bfd0ef          	jal	80001f22 <sleep_prepare>
    release(&lk->lk);
    80003fdc:	854a                	mv	a0,s2
    80003fde:	c93fc0ef          	jal	80000c70 <release>
    sleep();
    80003fe2:	f7dfd0ef          	jal	80001f5e <sleep>
    acquire(&lk->lk);
    80003fe6:	854a                	mv	a0,s2
    80003fe8:	c01fc0ef          	jal	80000be8 <acquire>
  while (lk->locked) {
    80003fec:	409c                	lw	a5,0(s1)
    80003fee:	f7e5                	bnez	a5,80003fd6 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003ff0:	4785                	li	a5,1
    80003ff2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003ff4:	915fd0ef          	jal	80001908 <myproc>
    80003ff8:	591c                	lw	a5,48(a0)
    80003ffa:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003ffc:	854a                	mv	a0,s2
    80003ffe:	c73fc0ef          	jal	80000c70 <release>
}
    80004002:	60e2                	ld	ra,24(sp)
    80004004:	6442                	ld	s0,16(sp)
    80004006:	64a2                	ld	s1,8(sp)
    80004008:	6902                	ld	s2,0(sp)
    8000400a:	6105                	addi	sp,sp,32
    8000400c:	8082                	ret

000000008000400e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000400e:	1101                	addi	sp,sp,-32
    80004010:	ec06                	sd	ra,24(sp)
    80004012:	e822                	sd	s0,16(sp)
    80004014:	e426                	sd	s1,8(sp)
    80004016:	e04a                	sd	s2,0(sp)
    80004018:	1000                	addi	s0,sp,32
    8000401a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000401c:	00850913          	addi	s2,a0,8
    80004020:	854a                	mv	a0,s2
    80004022:	bc7fc0ef          	jal	80000be8 <acquire>
  lk->locked = 0;
    80004026:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000402a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000402e:	8526                	mv	a0,s1
    80004030:	f5ffd0ef          	jal	80001f8e <wakeup>
  release(&lk->lk);
    80004034:	854a                	mv	a0,s2
    80004036:	c3bfc0ef          	jal	80000c70 <release>
}
    8000403a:	60e2                	ld	ra,24(sp)
    8000403c:	6442                	ld	s0,16(sp)
    8000403e:	64a2                	ld	s1,8(sp)
    80004040:	6902                	ld	s2,0(sp)
    80004042:	6105                	addi	sp,sp,32
    80004044:	8082                	ret

0000000080004046 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004046:	7179                	addi	sp,sp,-48
    80004048:	f406                	sd	ra,40(sp)
    8000404a:	f022                	sd	s0,32(sp)
    8000404c:	ec26                	sd	s1,24(sp)
    8000404e:	e84a                	sd	s2,16(sp)
    80004050:	1800                	addi	s0,sp,48
    80004052:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004054:	00850913          	addi	s2,a0,8
    80004058:	854a                	mv	a0,s2
    8000405a:	b8ffc0ef          	jal	80000be8 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000405e:	409c                	lw	a5,0(s1)
    80004060:	ef81                	bnez	a5,80004078 <holdingsleep+0x32>
    80004062:	4481                	li	s1,0
  release(&lk->lk);
    80004064:	854a                	mv	a0,s2
    80004066:	c0bfc0ef          	jal	80000c70 <release>
  return r;
}
    8000406a:	8526                	mv	a0,s1
    8000406c:	70a2                	ld	ra,40(sp)
    8000406e:	7402                	ld	s0,32(sp)
    80004070:	64e2                	ld	s1,24(sp)
    80004072:	6942                	ld	s2,16(sp)
    80004074:	6145                	addi	sp,sp,48
    80004076:	8082                	ret
    80004078:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000407a:	0284a983          	lw	s3,40(s1)
    8000407e:	88bfd0ef          	jal	80001908 <myproc>
    80004082:	5904                	lw	s1,48(a0)
    80004084:	413484b3          	sub	s1,s1,s3
    80004088:	0014b493          	seqz	s1,s1
    8000408c:	69a2                	ld	s3,8(sp)
    8000408e:	bfd9                	j	80004064 <holdingsleep+0x1e>

0000000080004090 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004090:	1141                	addi	sp,sp,-16
    80004092:	e406                	sd	ra,8(sp)
    80004094:	e022                	sd	s0,0(sp)
    80004096:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004098:	00003597          	auipc	a1,0x3
    8000409c:	4e058593          	addi	a1,a1,1248 # 80007578 <etext+0x578>
    800040a0:	0001e517          	auipc	a0,0x1e
    800040a4:	46850513          	addi	a0,a0,1128 # 80022508 <ftable>
    800040a8:	ac1fc0ef          	jal	80000b68 <initlock>
}
    800040ac:	60a2                	ld	ra,8(sp)
    800040ae:	6402                	ld	s0,0(sp)
    800040b0:	0141                	addi	sp,sp,16
    800040b2:	8082                	ret

00000000800040b4 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800040b4:	1101                	addi	sp,sp,-32
    800040b6:	ec06                	sd	ra,24(sp)
    800040b8:	e822                	sd	s0,16(sp)
    800040ba:	e426                	sd	s1,8(sp)
    800040bc:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800040be:	0001e517          	auipc	a0,0x1e
    800040c2:	44a50513          	addi	a0,a0,1098 # 80022508 <ftable>
    800040c6:	b23fc0ef          	jal	80000be8 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800040ca:	0001e497          	auipc	s1,0x1e
    800040ce:	45648493          	addi	s1,s1,1110 # 80022520 <ftable+0x18>
    800040d2:	0001f717          	auipc	a4,0x1f
    800040d6:	3ee70713          	addi	a4,a4,1006 # 800234c0 <disk>
    if (f->ref == 0) {
    800040da:	40dc                	lw	a5,4(s1)
    800040dc:	cf89                	beqz	a5,800040f6 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800040de:	02848493          	addi	s1,s1,40
    800040e2:	fee49ce3          	bne	s1,a4,800040da <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800040e6:	0001e517          	auipc	a0,0x1e
    800040ea:	42250513          	addi	a0,a0,1058 # 80022508 <ftable>
    800040ee:	b83fc0ef          	jal	80000c70 <release>
  return 0;
    800040f2:	4481                	li	s1,0
    800040f4:	a809                	j	80004106 <filealloc+0x52>
      f->ref = 1;
    800040f6:	4785                	li	a5,1
    800040f8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800040fa:	0001e517          	auipc	a0,0x1e
    800040fe:	40e50513          	addi	a0,a0,1038 # 80022508 <ftable>
    80004102:	b6ffc0ef          	jal	80000c70 <release>
}
    80004106:	8526                	mv	a0,s1
    80004108:	60e2                	ld	ra,24(sp)
    8000410a:	6442                	ld	s0,16(sp)
    8000410c:	64a2                	ld	s1,8(sp)
    8000410e:	6105                	addi	sp,sp,32
    80004110:	8082                	ret

0000000080004112 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004112:	1101                	addi	sp,sp,-32
    80004114:	ec06                	sd	ra,24(sp)
    80004116:	e822                	sd	s0,16(sp)
    80004118:	e426                	sd	s1,8(sp)
    8000411a:	1000                	addi	s0,sp,32
    8000411c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000411e:	0001e517          	auipc	a0,0x1e
    80004122:	3ea50513          	addi	a0,a0,1002 # 80022508 <ftable>
    80004126:	ac3fc0ef          	jal	80000be8 <acquire>
  if (f->ref < 1)
    8000412a:	40dc                	lw	a5,4(s1)
    8000412c:	02f05063          	blez	a5,8000414c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004130:	2785                	addiw	a5,a5,1
    80004132:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004134:	0001e517          	auipc	a0,0x1e
    80004138:	3d450513          	addi	a0,a0,980 # 80022508 <ftable>
    8000413c:	b35fc0ef          	jal	80000c70 <release>
  return f;
}
    80004140:	8526                	mv	a0,s1
    80004142:	60e2                	ld	ra,24(sp)
    80004144:	6442                	ld	s0,16(sp)
    80004146:	64a2                	ld	s1,8(sp)
    80004148:	6105                	addi	sp,sp,32
    8000414a:	8082                	ret
    panic("filedup");
    8000414c:	00003517          	auipc	a0,0x3
    80004150:	43450513          	addi	a0,a0,1076 # 80007580 <etext+0x580>
    80004154:	ee0fc0ef          	jal	80000834 <panic>

0000000080004158 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004158:	7139                	addi	sp,sp,-64
    8000415a:	fc06                	sd	ra,56(sp)
    8000415c:	f822                	sd	s0,48(sp)
    8000415e:	f426                	sd	s1,40(sp)
    80004160:	0080                	addi	s0,sp,64
    80004162:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004164:	0001e517          	auipc	a0,0x1e
    80004168:	3a450513          	addi	a0,a0,932 # 80022508 <ftable>
    8000416c:	a7dfc0ef          	jal	80000be8 <acquire>
  if (f->ref < 1)
    80004170:	40dc                	lw	a5,4(s1)
    80004172:	04f05a63          	blez	a5,800041c6 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    80004176:	37fd                	addiw	a5,a5,-1
    80004178:	c0dc                	sw	a5,4(s1)
    8000417a:	06f04063          	bgtz	a5,800041da <fileclose+0x82>
    8000417e:	f04a                	sd	s2,32(sp)
    80004180:	ec4e                	sd	s3,24(sp)
    80004182:	e852                	sd	s4,16(sp)
    80004184:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004186:	0004a903          	lw	s2,0(s1)
    8000418a:	0094c783          	lbu	a5,9(s1)
    8000418e:	89be                	mv	s3,a5
    80004190:	689c                	ld	a5,16(s1)
    80004192:	8a3e                	mv	s4,a5
    80004194:	6c9c                	ld	a5,24(s1)
    80004196:	8abe                	mv	s5,a5
  f->ref = 0;
    80004198:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000419c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800041a0:	0001e517          	auipc	a0,0x1e
    800041a4:	36850513          	addi	a0,a0,872 # 80022508 <ftable>
    800041a8:	ac9fc0ef          	jal	80000c70 <release>

  if (ff.type == FD_PIPE) {
    800041ac:	4785                	li	a5,1
    800041ae:	04f90163          	beq	s2,a5,800041f0 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    800041b2:	ffe9079b          	addiw	a5,s2,-2
    800041b6:	4705                	li	a4,1
    800041b8:	04f77563          	bgeu	a4,a5,80004202 <fileclose+0xaa>
    800041bc:	7902                	ld	s2,32(sp)
    800041be:	69e2                	ld	s3,24(sp)
    800041c0:	6a42                	ld	s4,16(sp)
    800041c2:	6aa2                	ld	s5,8(sp)
    800041c4:	a00d                	j	800041e6 <fileclose+0x8e>
    800041c6:	f04a                	sd	s2,32(sp)
    800041c8:	ec4e                	sd	s3,24(sp)
    800041ca:	e852                	sd	s4,16(sp)
    800041cc:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800041ce:	00003517          	auipc	a0,0x3
    800041d2:	3ba50513          	addi	a0,a0,954 # 80007588 <etext+0x588>
    800041d6:	e5efc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    800041da:	0001e517          	auipc	a0,0x1e
    800041de:	32e50513          	addi	a0,a0,814 # 80022508 <ftable>
    800041e2:	a8ffc0ef          	jal	80000c70 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800041e6:	70e2                	ld	ra,56(sp)
    800041e8:	7442                	ld	s0,48(sp)
    800041ea:	74a2                	ld	s1,40(sp)
    800041ec:	6121                	addi	sp,sp,64
    800041ee:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800041f0:	85ce                	mv	a1,s3
    800041f2:	8552                	mv	a0,s4
    800041f4:	360000ef          	jal	80004554 <pipeclose>
    800041f8:	7902                	ld	s2,32(sp)
    800041fa:	69e2                	ld	s3,24(sp)
    800041fc:	6a42                	ld	s4,16(sp)
    800041fe:	6aa2                	ld	s5,8(sp)
    80004200:	b7dd                	j	800041e6 <fileclose+0x8e>
    begin_op();
    80004202:	a9dff0ef          	jal	80003c9e <begin_op>
    iput(ff.ip);
    80004206:	8556                	mv	a0,s5
    80004208:	9aeff0ef          	jal	800033b6 <iput>
    end_op();
    8000420c:	b1fff0ef          	jal	80003d2a <end_op>
    80004210:	7902                	ld	s2,32(sp)
    80004212:	69e2                	ld	s3,24(sp)
    80004214:	6a42                	ld	s4,16(sp)
    80004216:	6aa2                	ld	s5,8(sp)
    80004218:	b7f9                	j	800041e6 <fileclose+0x8e>

000000008000421a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000421a:	715d                	addi	sp,sp,-80
    8000421c:	e486                	sd	ra,72(sp)
    8000421e:	e0a2                	sd	s0,64(sp)
    80004220:	fc26                	sd	s1,56(sp)
    80004222:	f052                	sd	s4,32(sp)
    80004224:	0880                	addi	s0,sp,80
    80004226:	84aa                	mv	s1,a0
    80004228:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000422a:	edefd0ef          	jal	80001908 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    8000422e:	409c                	lw	a5,0(s1)
    80004230:	37f9                	addiw	a5,a5,-2
    80004232:	4705                	li	a4,1
    80004234:	04f76463          	bltu	a4,a5,8000427c <filestat+0x62>
    80004238:	f84a                	sd	s2,48(sp)
    8000423a:	f44e                	sd	s3,40(sp)
    8000423c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000423e:	6c88                	ld	a0,24(s1)
    80004240:	ff5fe0ef          	jal	80003234 <ilock>
    stati(f->ip, &st);
    80004244:	fb840993          	addi	s3,s0,-72
    80004248:	85ce                	mv	a1,s3
    8000424a:	6c88                	ld	a0,24(s1)
    8000424c:	b94ff0ef          	jal	800035e0 <stati>
    iunlock(f->ip);
    80004250:	6c88                	ld	a0,24(s1)
    80004252:	890ff0ef          	jal	800032e2 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    80004256:	4761                	li	a4,24
    80004258:	86ce                	mv	a3,s3
    8000425a:	8652                	mv	a2,s4
    8000425c:	04893583          	ld	a1,72(s2)
    80004260:	05093503          	ld	a0,80(s2)
    80004264:	adefd0ef          	jal	80001542 <copyout>
    80004268:	41f5551b          	sraiw	a0,a0,0x1f
    8000426c:	7942                	ld	s2,48(sp)
    8000426e:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004270:	60a6                	ld	ra,72(sp)
    80004272:	6406                	ld	s0,64(sp)
    80004274:	74e2                	ld	s1,56(sp)
    80004276:	7a02                	ld	s4,32(sp)
    80004278:	6161                	addi	sp,sp,80
    8000427a:	8082                	ret
  return -1;
    8000427c:	557d                	li	a0,-1
    8000427e:	bfcd                	j	80004270 <filestat+0x56>

0000000080004280 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004280:	7179                	addi	sp,sp,-48
    80004282:	f406                	sd	ra,40(sp)
    80004284:	f022                	sd	s0,32(sp)
    80004286:	e84a                	sd	s2,16(sp)
    80004288:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    8000428a:	00854783          	lbu	a5,8(a0)
    8000428e:	c3dd                	beqz	a5,80004334 <fileread+0xb4>
    80004290:	ec26                	sd	s1,24(sp)
    80004292:	e44e                	sd	s3,8(sp)
    80004294:	84aa                	mv	s1,a0
    80004296:	892e                	mv	s2,a1
    80004298:	89b2                	mv	s3,a2
    8000429a:	01f6579b          	srliw	a5,a2,0x1f
    8000429e:	ebc9                	bnez	a5,80004330 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    800042a0:	411c                	lw	a5,0(a0)
    800042a2:	4705                	li	a4,1
    800042a4:	04e78363          	beq	a5,a4,800042ea <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800042a8:	470d                	li	a4,3
    800042aa:	04e78763          	beq	a5,a4,800042f8 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    800042ae:	4709                	li	a4,2
    800042b0:	06e79a63          	bne	a5,a4,80004324 <fileread+0xa4>
    ilock(f->ip);
    800042b4:	6d08                	ld	a0,24(a0)
    800042b6:	f7ffe0ef          	jal	80003234 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800042ba:	874e                	mv	a4,s3
    800042bc:	5094                	lw	a3,32(s1)
    800042be:	864a                	mv	a2,s2
    800042c0:	4585                	li	a1,1
    800042c2:	6c88                	ld	a0,24(s1)
    800042c4:	b4aff0ef          	jal	8000360e <readi>
    800042c8:	892a                	mv	s2,a0
    800042ca:	00a05563          	blez	a0,800042d4 <fileread+0x54>
      f->off += r;
    800042ce:	509c                	lw	a5,32(s1)
    800042d0:	9fa9                	addw	a5,a5,a0
    800042d2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800042d4:	6c88                	ld	a0,24(s1)
    800042d6:	80cff0ef          	jal	800032e2 <iunlock>
    800042da:	64e2                	ld	s1,24(sp)
    800042dc:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800042de:	854a                	mv	a0,s2
    800042e0:	70a2                	ld	ra,40(sp)
    800042e2:	7402                	ld	s0,32(sp)
    800042e4:	6942                	ld	s2,16(sp)
    800042e6:	6145                	addi	sp,sp,48
    800042e8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800042ea:	6908                	ld	a0,16(a0)
    800042ec:	3e2000ef          	jal	800046ce <piperead>
    800042f0:	892a                	mv	s2,a0
    800042f2:	64e2                	ld	s1,24(sp)
    800042f4:	69a2                	ld	s3,8(sp)
    800042f6:	b7e5                	j	800042de <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800042f8:	02451783          	lh	a5,36(a0)
    800042fc:	03079693          	slli	a3,a5,0x30
    80004300:	92c1                	srli	a3,a3,0x30
    80004302:	4725                	li	a4,9
    80004304:	02d76b63          	bltu	a4,a3,8000433a <fileread+0xba>
    80004308:	0792                	slli	a5,a5,0x4
    8000430a:	0001e717          	auipc	a4,0x1e
    8000430e:	15e70713          	addi	a4,a4,350 # 80022468 <devsw>
    80004312:	97ba                	add	a5,a5,a4
    80004314:	639c                	ld	a5,0(a5)
    80004316:	c79d                	beqz	a5,80004344 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    80004318:	4505                	li	a0,1
    8000431a:	9782                	jalr	a5
    8000431c:	892a                	mv	s2,a0
    8000431e:	64e2                	ld	s1,24(sp)
    80004320:	69a2                	ld	s3,8(sp)
    80004322:	bf75                	j	800042de <fileread+0x5e>
    panic("fileread");
    80004324:	00003517          	auipc	a0,0x3
    80004328:	27450513          	addi	a0,a0,628 # 80007598 <etext+0x598>
    8000432c:	d08fc0ef          	jal	80000834 <panic>
    80004330:	64e2                	ld	s1,24(sp)
    80004332:	69a2                	ld	s3,8(sp)
    return -1;
    80004334:	57fd                	li	a5,-1
    80004336:	893e                	mv	s2,a5
    80004338:	b75d                	j	800042de <fileread+0x5e>
      return -1;
    8000433a:	57fd                	li	a5,-1
    8000433c:	893e                	mv	s2,a5
    8000433e:	64e2                	ld	s1,24(sp)
    80004340:	69a2                	ld	s3,8(sp)
    80004342:	bf71                	j	800042de <fileread+0x5e>
    80004344:	57fd                	li	a5,-1
    80004346:	893e                	mv	s2,a5
    80004348:	64e2                	ld	s1,24(sp)
    8000434a:	69a2                	ld	s3,8(sp)
    8000434c:	bf49                	j	800042de <fileread+0x5e>

000000008000434e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    8000434e:	00954783          	lbu	a5,9(a0)
    80004352:	12078b63          	beqz	a5,80004488 <filewrite+0x13a>
{
    80004356:	711d                	addi	sp,sp,-96
    80004358:	ec86                	sd	ra,88(sp)
    8000435a:	e8a2                	sd	s0,80(sp)
    8000435c:	e0ca                	sd	s2,64(sp)
    8000435e:	f456                	sd	s5,40(sp)
    80004360:	f05a                	sd	s6,32(sp)
    80004362:	1080                	addi	s0,sp,96
    80004364:	892a                	mv	s2,a0
    80004366:	8b2e                	mv	s6,a1
    80004368:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    8000436a:	01f6579b          	srliw	a5,a2,0x1f
    8000436e:	0e079d63          	bnez	a5,80004468 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    80004372:	411c                	lw	a5,0(a0)
    80004374:	4705                	li	a4,1
    80004376:	02e78a63          	beq	a5,a4,800043aa <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000437a:	470d                	li	a4,3
    8000437c:	02e78b63          	beq	a5,a4,800043b2 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004380:	4709                	li	a4,2
    80004382:	0ce79763          	bne	a5,a4,80004450 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    80004386:	0ec05763          	blez	a2,80004474 <filewrite+0x126>
    8000438a:	e4a6                	sd	s1,72(sp)
    8000438c:	fc4e                	sd	s3,56(sp)
    8000438e:	f852                	sd	s4,48(sp)
    80004390:	ec5e                	sd	s7,24(sp)
    80004392:	e862                	sd	s8,16(sp)
    80004394:	e466                	sd	s9,8(sp)
    int i = 0;
    80004396:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    80004398:	6b85                	lui	s7,0x1
    8000439a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000439e:	6785                	lui	a5,0x1
    800043a0:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800043a4:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800043a6:	4c05                	li	s8,1
    800043a8:	a8ad                	j	80004422 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    800043aa:	6908                	ld	a0,16(a0)
    800043ac:	206000ef          	jal	800045b2 <pipewrite>
    800043b0:	a849                	j	80004442 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800043b2:	02451783          	lh	a5,36(a0)
    800043b6:	03079693          	slli	a3,a5,0x30
    800043ba:	92c1                	srli	a3,a3,0x30
    800043bc:	4725                	li	a4,9
    800043be:	0ad76763          	bltu	a4,a3,8000446c <filewrite+0x11e>
    800043c2:	0792                	slli	a5,a5,0x4
    800043c4:	0001e717          	auipc	a4,0x1e
    800043c8:	0a470713          	addi	a4,a4,164 # 80022468 <devsw>
    800043cc:	97ba                	add	a5,a5,a4
    800043ce:	679c                	ld	a5,8(a5)
    800043d0:	c3c5                	beqz	a5,80004470 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800043d2:	4505                	li	a0,1
    800043d4:	9782                	jalr	a5
    800043d6:	a0b5                	j	80004442 <filewrite+0xf4>
      if (n1 > max)
    800043d8:	2981                	sext.w	s3,s3
      begin_op();
    800043da:	8c5ff0ef          	jal	80003c9e <begin_op>
      ilock(f->ip);
    800043de:	01893503          	ld	a0,24(s2)
    800043e2:	e53fe0ef          	jal	80003234 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800043e6:	874e                	mv	a4,s3
    800043e8:	02092683          	lw	a3,32(s2)
    800043ec:	016a0633          	add	a2,s4,s6
    800043f0:	85e2                	mv	a1,s8
    800043f2:	01893503          	ld	a0,24(s2)
    800043f6:	b0aff0ef          	jal	80003700 <writei>
    800043fa:	84aa                	mv	s1,a0
    800043fc:	00a05763          	blez	a0,8000440a <filewrite+0xbc>
        f->off += r;
    80004400:	02092783          	lw	a5,32(s2)
    80004404:	9fa9                	addw	a5,a5,a0
    80004406:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000440a:	01893503          	ld	a0,24(s2)
    8000440e:	ed5fe0ef          	jal	800032e2 <iunlock>
      end_op();
    80004412:	919ff0ef          	jal	80003d2a <end_op>

      if (r != n1) {
    80004416:	00999d63          	bne	s3,s1,80004430 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    8000441a:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    8000441e:	015a5963          	bge	s4,s5,80004430 <filewrite+0xe2>
      int n1 = n - i;
    80004422:	414a87bb          	subw	a5,s5,s4
    80004426:	89be                	mv	s3,a5
      if (n1 > max)
    80004428:	fafbd8e3          	bge	s7,a5,800043d8 <filewrite+0x8a>
    8000442c:	89e6                	mv	s3,s9
    8000442e:	b76d                	j	800043d8 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    80004430:	054a9463          	bne	s5,s4,80004478 <filewrite+0x12a>
    80004434:	8556                	mv	a0,s5
    80004436:	64a6                	ld	s1,72(sp)
    80004438:	79e2                	ld	s3,56(sp)
    8000443a:	7a42                	ld	s4,48(sp)
    8000443c:	6be2                	ld	s7,24(sp)
    8000443e:	6c42                	ld	s8,16(sp)
    80004440:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004442:	60e6                	ld	ra,88(sp)
    80004444:	6446                	ld	s0,80(sp)
    80004446:	6906                	ld	s2,64(sp)
    80004448:	7aa2                	ld	s5,40(sp)
    8000444a:	7b02                	ld	s6,32(sp)
    8000444c:	6125                	addi	sp,sp,96
    8000444e:	8082                	ret
    80004450:	e4a6                	sd	s1,72(sp)
    80004452:	fc4e                	sd	s3,56(sp)
    80004454:	f852                	sd	s4,48(sp)
    80004456:	ec5e                	sd	s7,24(sp)
    80004458:	e862                	sd	s8,16(sp)
    8000445a:	e466                	sd	s9,8(sp)
    panic("filewrite");
    8000445c:	00003517          	auipc	a0,0x3
    80004460:	14c50513          	addi	a0,a0,332 # 800075a8 <etext+0x5a8>
    80004464:	bd0fc0ef          	jal	80000834 <panic>
    return -1;
    80004468:	557d                	li	a0,-1
    8000446a:	bfe1                	j	80004442 <filewrite+0xf4>
      return -1;
    8000446c:	557d                	li	a0,-1
    8000446e:	bfd1                	j	80004442 <filewrite+0xf4>
    80004470:	557d                	li	a0,-1
    80004472:	bfc1                	j	80004442 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    80004474:	8532                	mv	a0,a2
    80004476:	b7f1                	j	80004442 <filewrite+0xf4>
    80004478:	557d                	li	a0,-1
    8000447a:	64a6                	ld	s1,72(sp)
    8000447c:	79e2                	ld	s3,56(sp)
    8000447e:	7a42                	ld	s4,48(sp)
    80004480:	6be2                	ld	s7,24(sp)
    80004482:	6c42                	ld	s8,16(sp)
    80004484:	6ca2                	ld	s9,8(sp)
    80004486:	bf75                	j	80004442 <filewrite+0xf4>
    return -1;
    80004488:	557d                	li	a0,-1
}
    8000448a:	8082                	ret

000000008000448c <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000448c:	7179                	addi	sp,sp,-48
    8000448e:	f406                	sd	ra,40(sp)
    80004490:	f022                	sd	s0,32(sp)
    80004492:	ec26                	sd	s1,24(sp)
    80004494:	e052                	sd	s4,0(sp)
    80004496:	1800                	addi	s0,sp,48
    80004498:	84aa                	mv	s1,a0
    8000449a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000449c:	0005b023          	sd	zero,0(a1)
    800044a0:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800044a4:	c11ff0ef          	jal	800040b4 <filealloc>
    800044a8:	e088                	sd	a0,0(s1)
    800044aa:	c549                	beqz	a0,80004534 <pipealloc+0xa8>
    800044ac:	c09ff0ef          	jal	800040b4 <filealloc>
    800044b0:	00aa3023          	sd	a0,0(s4)
    800044b4:	cd25                	beqz	a0,8000452c <pipealloc+0xa0>
    800044b6:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    800044b8:	e56fc0ef          	jal	80000b0e <kalloc>
    800044bc:	892a                	mv	s2,a0
    800044be:	c12d                	beqz	a0,80004520 <pipealloc+0x94>
    800044c0:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800044c2:	4985                	li	s3,1
    800044c4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800044c8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800044cc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800044d0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800044d4:	00003597          	auipc	a1,0x3
    800044d8:	0e458593          	addi	a1,a1,228 # 800075b8 <etext+0x5b8>
    800044dc:	e8cfc0ef          	jal	80000b68 <initlock>
  (*f0)->type = FD_PIPE;
    800044e0:	609c                	ld	a5,0(s1)
    800044e2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800044e6:	609c                	ld	a5,0(s1)
    800044e8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800044ec:	609c                	ld	a5,0(s1)
    800044ee:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800044f2:	609c                	ld	a5,0(s1)
    800044f4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800044f8:	000a3783          	ld	a5,0(s4)
    800044fc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004500:	000a3783          	ld	a5,0(s4)
    80004504:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004508:	000a3783          	ld	a5,0(s4)
    8000450c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004510:	000a3783          	ld	a5,0(s4)
    80004514:	0127b823          	sd	s2,16(a5)
  return 0;
    80004518:	4501                	li	a0,0
    8000451a:	6942                	ld	s2,16(sp)
    8000451c:	69a2                	ld	s3,8(sp)
    8000451e:	a01d                	j	80004544 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004520:	6088                	ld	a0,0(s1)
    80004522:	c119                	beqz	a0,80004528 <pipealloc+0x9c>
    80004524:	6942                	ld	s2,16(sp)
    80004526:	a029                	j	80004530 <pipealloc+0xa4>
    80004528:	6942                	ld	s2,16(sp)
    8000452a:	a029                	j	80004534 <pipealloc+0xa8>
    8000452c:	6088                	ld	a0,0(s1)
    8000452e:	c10d                	beqz	a0,80004550 <pipealloc+0xc4>
    fileclose(*f0);
    80004530:	c29ff0ef          	jal	80004158 <fileclose>
  if (*f1)
    80004534:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004538:	557d                	li	a0,-1
  if (*f1)
    8000453a:	c789                	beqz	a5,80004544 <pipealloc+0xb8>
    fileclose(*f1);
    8000453c:	853e                	mv	a0,a5
    8000453e:	c1bff0ef          	jal	80004158 <fileclose>
  return -1;
    80004542:	557d                	li	a0,-1
}
    80004544:	70a2                	ld	ra,40(sp)
    80004546:	7402                	ld	s0,32(sp)
    80004548:	64e2                	ld	s1,24(sp)
    8000454a:	6a02                	ld	s4,0(sp)
    8000454c:	6145                	addi	sp,sp,48
    8000454e:	8082                	ret
  return -1;
    80004550:	557d                	li	a0,-1
    80004552:	bfcd                	j	80004544 <pipealloc+0xb8>

0000000080004554 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004554:	1101                	addi	sp,sp,-32
    80004556:	ec06                	sd	ra,24(sp)
    80004558:	e822                	sd	s0,16(sp)
    8000455a:	e426                	sd	s1,8(sp)
    8000455c:	e04a                	sd	s2,0(sp)
    8000455e:	1000                	addi	s0,sp,32
    80004560:	84aa                	mv	s1,a0
    80004562:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004564:	e84fc0ef          	jal	80000be8 <acquire>
  if (writable) {
    80004568:	02090763          	beqz	s2,80004596 <pipeclose+0x42>
    pi->writeopen = 0;
    8000456c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004570:	21848513          	addi	a0,s1,536
    80004574:	a1bfd0ef          	jal	80001f8e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004578:	2204a783          	lw	a5,544(s1)
    8000457c:	e781                	bnez	a5,80004584 <pipeclose+0x30>
    8000457e:	2244a783          	lw	a5,548(s1)
    80004582:	c38d                	beqz	a5,800045a4 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    80004584:	8526                	mv	a0,s1
    80004586:	eeafc0ef          	jal	80000c70 <release>
}
    8000458a:	60e2                	ld	ra,24(sp)
    8000458c:	6442                	ld	s0,16(sp)
    8000458e:	64a2                	ld	s1,8(sp)
    80004590:	6902                	ld	s2,0(sp)
    80004592:	6105                	addi	sp,sp,32
    80004594:	8082                	ret
    pi->readopen = 0;
    80004596:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000459a:	21c48513          	addi	a0,s1,540
    8000459e:	9f1fd0ef          	jal	80001f8e <wakeup>
    800045a2:	bfd9                	j	80004578 <pipeclose+0x24>
    release(&pi->lock);
    800045a4:	8526                	mv	a0,s1
    800045a6:	ecafc0ef          	jal	80000c70 <release>
    kfree((char *)pi);
    800045aa:	8526                	mv	a0,s1
    800045ac:	c7afc0ef          	jal	80000a26 <kfree>
    800045b0:	bfe9                	j	8000458a <pipeclose+0x36>

00000000800045b2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800045b2:	7159                	addi	sp,sp,-112
    800045b4:	f486                	sd	ra,104(sp)
    800045b6:	f0a2                	sd	s0,96(sp)
    800045b8:	eca6                	sd	s1,88(sp)
    800045ba:	e8ca                	sd	s2,80(sp)
    800045bc:	e4ce                	sd	s3,72(sp)
    800045be:	e0d2                	sd	s4,64(sp)
    800045c0:	fc56                	sd	s5,56(sp)
    800045c2:	1880                	addi	s0,sp,112
    800045c4:	84aa                	mv	s1,a0
    800045c6:	8aae                	mv	s5,a1
    800045c8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800045ca:	b3efd0ef          	jal	80001908 <myproc>
    800045ce:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800045d0:	8526                	mv	a0,s1
    800045d2:	e16fc0ef          	jal	80000be8 <acquire>
  while (i < n) {
    800045d6:	0f405a63          	blez	s4,800046ca <pipewrite+0x118>
    800045da:	f85a                	sd	s6,48(sp)
    800045dc:	f45e                	sd	s7,40(sp)
    800045de:	f062                	sd	s8,32(sp)
    800045e0:	ec66                	sd	s9,24(sp)
    800045e2:	e86a                	sd	s10,16(sp)
  int i = 0;
    800045e4:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800045e6:	f9f40c13          	addi	s8,s0,-97
    800045ea:	4b85                	li	s7,1
    800045ec:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800045ee:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    800045f2:	21c48c93          	addi	s9,s1,540
    800045f6:	a0a1                	j	8000463e <pipewrite+0x8c>
      release(&pi->lock);
    800045f8:	8526                	mv	a0,s1
    800045fa:	e76fc0ef          	jal	80000c70 <release>
      return -1;
    800045fe:	597d                	li	s2,-1
    80004600:	7b42                	ld	s6,48(sp)
    80004602:	7ba2                	ld	s7,40(sp)
    80004604:	7c02                	ld	s8,32(sp)
    80004606:	6ce2                	ld	s9,24(sp)
    80004608:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000460a:	854a                	mv	a0,s2
    8000460c:	70a6                	ld	ra,104(sp)
    8000460e:	7406                	ld	s0,96(sp)
    80004610:	64e6                	ld	s1,88(sp)
    80004612:	6946                	ld	s2,80(sp)
    80004614:	69a6                	ld	s3,72(sp)
    80004616:	6a06                	ld	s4,64(sp)
    80004618:	7ae2                	ld	s5,56(sp)
    8000461a:	6165                	addi	sp,sp,112
    8000461c:	8082                	ret
      wakeup(&pi->nread);
    8000461e:	856a                	mv	a0,s10
    80004620:	96ffd0ef          	jal	80001f8e <wakeup>
      sleep_prepare(&pi->nwrite);
    80004624:	8566                	mv	a0,s9
    80004626:	8fdfd0ef          	jal	80001f22 <sleep_prepare>
      release(&pi->lock);
    8000462a:	8526                	mv	a0,s1
    8000462c:	e44fc0ef          	jal	80000c70 <release>
      sleep();
    80004630:	92ffd0ef          	jal	80001f5e <sleep>
      acquire(&pi->lock);
    80004634:	8526                	mv	a0,s1
    80004636:	db2fc0ef          	jal	80000be8 <acquire>
  while (i < n) {
    8000463a:	07495b63          	bge	s2,s4,800046b0 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    8000463e:	2204a783          	lw	a5,544(s1)
    80004642:	dbdd                	beqz	a5,800045f8 <pipewrite+0x46>
    80004644:	854e                	mv	a0,s3
    80004646:	b35fd0ef          	jal	8000217a <killed>
    8000464a:	f55d                	bnez	a0,800045f8 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    8000464c:	2184a783          	lw	a5,536(s1)
    80004650:	21c4a703          	lw	a4,540(s1)
    80004654:	2007879b          	addiw	a5,a5,512
    80004658:	fcf703e3          	beq	a4,a5,8000461e <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000465c:	875e                	mv	a4,s7
    8000465e:	015906b3          	add	a3,s2,s5
    80004662:	8662                	mv	a2,s8
    80004664:	0489b583          	ld	a1,72(s3)
    80004668:	0509b503          	ld	a0,80(s3)
    8000466c:	f9dfc0ef          	jal	80001608 <copyin>
    80004670:	03650163          	beq	a0,s6,80004692 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004674:	21c4a783          	lw	a5,540(s1)
    80004678:	0017871b          	addiw	a4,a5,1
    8000467c:	20e4ae23          	sw	a4,540(s1)
    80004680:	1ff7f793          	andi	a5,a5,511
    80004684:	97a6                	add	a5,a5,s1
    80004686:	f9f44703          	lbu	a4,-97(s0)
    8000468a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000468e:	2905                	addiw	s2,s2,1
    80004690:	b76d                	j	8000463a <pipewrite+0x88>
        if (i == 0)
    80004692:	00090863          	beqz	s2,800046a2 <pipewrite+0xf0>
    80004696:	7b42                	ld	s6,48(sp)
    80004698:	7ba2                	ld	s7,40(sp)
    8000469a:	7c02                	ld	s8,32(sp)
    8000469c:	6ce2                	ld	s9,24(sp)
    8000469e:	6d42                	ld	s10,16(sp)
    800046a0:	a829                	j	800046ba <pipewrite+0x108>
          i = -1;
    800046a2:	892a                	mv	s2,a0
        break;
    800046a4:	7b42                	ld	s6,48(sp)
    800046a6:	7ba2                	ld	s7,40(sp)
    800046a8:	7c02                	ld	s8,32(sp)
    800046aa:	6ce2                	ld	s9,24(sp)
    800046ac:	6d42                	ld	s10,16(sp)
    800046ae:	a031                	j	800046ba <pipewrite+0x108>
    800046b0:	7b42                	ld	s6,48(sp)
    800046b2:	7ba2                	ld	s7,40(sp)
    800046b4:	7c02                	ld	s8,32(sp)
    800046b6:	6ce2                	ld	s9,24(sp)
    800046b8:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800046ba:	21848513          	addi	a0,s1,536
    800046be:	8d1fd0ef          	jal	80001f8e <wakeup>
  release(&pi->lock);
    800046c2:	8526                	mv	a0,s1
    800046c4:	dacfc0ef          	jal	80000c70 <release>
  return i;
    800046c8:	b789                	j	8000460a <pipewrite+0x58>
  int i = 0;
    800046ca:	4901                	li	s2,0
    800046cc:	b7fd                	j	800046ba <pipewrite+0x108>

00000000800046ce <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800046ce:	711d                	addi	sp,sp,-96
    800046d0:	ec86                	sd	ra,88(sp)
    800046d2:	e8a2                	sd	s0,80(sp)
    800046d4:	e4a6                	sd	s1,72(sp)
    800046d6:	e0ca                	sd	s2,64(sp)
    800046d8:	fc4e                	sd	s3,56(sp)
    800046da:	f852                	sd	s4,48(sp)
    800046dc:	f456                	sd	s5,40(sp)
    800046de:	1080                	addi	s0,sp,96
    800046e0:	84aa                	mv	s1,a0
    800046e2:	89ae                	mv	s3,a1
    800046e4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800046e6:	a22fd0ef          	jal	80001908 <myproc>
    800046ea:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    800046ec:	8526                	mv	a0,s1
    800046ee:	cfafc0ef          	jal	80000be8 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800046f2:	2184a703          	lw	a4,536(s1)
    800046f6:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800046fa:	21848a13          	addi	s4,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800046fe:	02f71e63          	bne	a4,a5,8000473a <piperead+0x6c>
    80004702:	2244a783          	lw	a5,548(s1)
    80004706:	c3b9                	beqz	a5,8000474c <piperead+0x7e>
    if (killed(pr)) {
    80004708:	854a                	mv	a0,s2
    8000470a:	a71fd0ef          	jal	8000217a <killed>
    8000470e:	e915                	bnez	a0,80004742 <piperead+0x74>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004710:	8552                	mv	a0,s4
    80004712:	811fd0ef          	jal	80001f22 <sleep_prepare>
    release(&pi->lock);
    80004716:	8526                	mv	a0,s1
    80004718:	d58fc0ef          	jal	80000c70 <release>
    sleep();
    8000471c:	843fd0ef          	jal	80001f5e <sleep>
    acquire(&pi->lock);
    80004720:	8526                	mv	a0,s1
    80004722:	cc6fc0ef          	jal	80000be8 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004726:	2184a703          	lw	a4,536(s1)
    8000472a:	21c4a783          	lw	a5,540(s1)
    8000472e:	fcf70ae3          	beq	a4,a5,80004702 <piperead+0x34>
    80004732:	f05a                	sd	s6,32(sp)
    80004734:	ec5e                	sd	s7,24(sp)
    80004736:	e862                	sd	s8,16(sp)
    80004738:	a829                	j	80004752 <piperead+0x84>
    8000473a:	f05a                	sd	s6,32(sp)
    8000473c:	ec5e                	sd	s7,24(sp)
    8000473e:	e862                	sd	s8,16(sp)
    80004740:	a809                	j	80004752 <piperead+0x84>
      release(&pi->lock);
    80004742:	8526                	mv	a0,s1
    80004744:	d2cfc0ef          	jal	80000c70 <release>
      return -1;
    80004748:	5a7d                	li	s4,-1
    8000474a:	a0b5                	j	800047b6 <piperead+0xe8>
    8000474c:	f05a                	sd	s6,32(sp)
    8000474e:	ec5e                	sd	s7,24(sp)
    80004750:	e862                	sd	s8,16(sp)
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004752:	4a01                	li	s4,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004754:	faf40c13          	addi	s8,s0,-81
    80004758:	4b85                	li	s7,1
    8000475a:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000475c:	05505363          	blez	s5,800047a2 <piperead+0xd4>
    if (pi->nread == pi->nwrite)
    80004760:	2184a783          	lw	a5,536(s1)
    80004764:	21c4a703          	lw	a4,540(s1)
    80004768:	02f70d63          	beq	a4,a5,800047a2 <piperead+0xd4>
    ch = pi->data[pi->nread % PIPESIZE];
    8000476c:	1ff7f793          	andi	a5,a5,511
    80004770:	97a6                	add	a5,a5,s1
    80004772:	0187c783          	lbu	a5,24(a5)
    80004776:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000477a:	875e                	mv	a4,s7
    8000477c:	86e2                	mv	a3,s8
    8000477e:	864e                	mv	a2,s3
    80004780:	04893583          	ld	a1,72(s2)
    80004784:	05093503          	ld	a0,80(s2)
    80004788:	dbbfc0ef          	jal	80001542 <copyout>
    8000478c:	03650f63          	beq	a0,s6,800047ca <piperead+0xfc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004790:	2184a783          	lw	a5,536(s1)
    80004794:	2785                	addiw	a5,a5,1
    80004796:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000479a:	2a05                	addiw	s4,s4,1
    8000479c:	0985                	addi	s3,s3,1
    8000479e:	fd4a91e3          	bne	s5,s4,80004760 <piperead+0x92>
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    800047a2:	21c48513          	addi	a0,s1,540
    800047a6:	fe8fd0ef          	jal	80001f8e <wakeup>
  release(&pi->lock);
    800047aa:	8526                	mv	a0,s1
    800047ac:	cc4fc0ef          	jal	80000c70 <release>
    800047b0:	7b02                	ld	s6,32(sp)
    800047b2:	6be2                	ld	s7,24(sp)
    800047b4:	6c42                	ld	s8,16(sp)
  return i;
}
    800047b6:	8552                	mv	a0,s4
    800047b8:	60e6                	ld	ra,88(sp)
    800047ba:	6446                	ld	s0,80(sp)
    800047bc:	64a6                	ld	s1,72(sp)
    800047be:	6906                	ld	s2,64(sp)
    800047c0:	79e2                	ld	s3,56(sp)
    800047c2:	7a42                	ld	s4,48(sp)
    800047c4:	7aa2                	ld	s5,40(sp)
    800047c6:	6125                	addi	sp,sp,96
    800047c8:	8082                	ret
      if (i == 0)
    800047ca:	fc0a1ce3          	bnez	s4,800047a2 <piperead+0xd4>
        i = -1;
    800047ce:	8a2a                	mv	s4,a0
    800047d0:	bfc9                	j	800047a2 <piperead+0xd4>

00000000800047d2 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800047d2:	1141                	addi	sp,sp,-16
    800047d4:	e406                	sd	ra,8(sp)
    800047d6:	e022                	sd	s0,0(sp)
    800047d8:	0800                	addi	s0,sp,16
    800047da:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800047dc:	0035151b          	slliw	a0,a0,0x3
    800047e0:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    800047e2:	8b89                	andi	a5,a5,2
    800047e4:	c399                	beqz	a5,800047ea <flags2perm+0x18>
    perm |= PTE_W;
    800047e6:	00456513          	ori	a0,a0,4
  return perm;
}
    800047ea:	60a2                	ld	ra,8(sp)
    800047ec:	6402                	ld	s0,0(sp)
    800047ee:	0141                	addi	sp,sp,16
    800047f0:	8082                	ret

00000000800047f2 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800047f2:	de010113          	addi	sp,sp,-544
    800047f6:	20113c23          	sd	ra,536(sp)
    800047fa:	20813823          	sd	s0,528(sp)
    800047fe:	20913423          	sd	s1,520(sp)
    80004802:	21213023          	sd	s2,512(sp)
    80004806:	1400                	addi	s0,sp,544
    80004808:	892a                	mv	s2,a0
    8000480a:	dea43823          	sd	a0,-528(s0)
    8000480e:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004812:	8f6fd0ef          	jal	80001908 <myproc>
    80004816:	84aa                	mv	s1,a0

  begin_op();
    80004818:	c86ff0ef          	jal	80003c9e <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    8000481c:	854a                	mv	a0,s2
    8000481e:	aa2ff0ef          	jal	80003ac0 <namei>
    80004822:	cd21                	beqz	a0,8000487a <kexec+0x88>
    80004824:	fbd2                	sd	s4,496(sp)
    80004826:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004828:	a0dfe0ef          	jal	80003234 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000482c:	04000713          	li	a4,64
    80004830:	4681                	li	a3,0
    80004832:	e5040613          	addi	a2,s0,-432
    80004836:	4581                	li	a1,0
    80004838:	8552                	mv	a0,s4
    8000483a:	dd5fe0ef          	jal	8000360e <readi>
    8000483e:	04000793          	li	a5,64
    80004842:	00f51a63          	bne	a0,a5,80004856 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004846:	e5042703          	lw	a4,-432(s0)
    8000484a:	464c47b7          	lui	a5,0x464c4
    8000484e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004852:	02f70863          	beq	a4,a5,80004882 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004856:	8552                	mv	a0,s4
    80004858:	c31fe0ef          	jal	80003488 <iunlockput>
    end_op();
    8000485c:	cceff0ef          	jal	80003d2a <end_op>
  }
  return -1;
    80004860:	557d                	li	a0,-1
    80004862:	7a5e                	ld	s4,496(sp)
}
    80004864:	21813083          	ld	ra,536(sp)
    80004868:	21013403          	ld	s0,528(sp)
    8000486c:	20813483          	ld	s1,520(sp)
    80004870:	20013903          	ld	s2,512(sp)
    80004874:	22010113          	addi	sp,sp,544
    80004878:	8082                	ret
    end_op();
    8000487a:	cb0ff0ef          	jal	80003d2a <end_op>
    return -1;
    8000487e:	557d                	li	a0,-1
    80004880:	b7d5                	j	80004864 <kexec+0x72>
    80004882:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004884:	8526                	mv	a0,s1
    80004886:	998fd0ef          	jal	80001a1e <proc_pagetable>
    8000488a:	8b2a                	mv	s6,a0
    8000488c:	26050e63          	beqz	a0,80004b08 <kexec+0x316>
    80004890:	ffce                	sd	s3,504(sp)
    80004892:	f7d6                	sd	s5,488(sp)
    80004894:	efde                	sd	s7,472(sp)
    80004896:	ebe2                	sd	s8,464(sp)
    80004898:	e7e6                	sd	s9,456(sp)
    8000489a:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    8000489c:	e8845783          	lhu	a5,-376(s0)
    800048a0:	14078263          	beqz	a5,800049e4 <kexec+0x1f2>
    800048a4:	ff6e                	sd	s11,440(sp)
    800048a6:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048aa:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800048ac:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800048ae:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    800048b2:	6c85                	lui	s9,0x1
    800048b4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800048b8:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    800048bc:	6a85                	lui	s5,0x1
    800048be:	a085                	j	8000491e <kexec+0x12c>
      panic("loadseg: address should exist");
    800048c0:	00003517          	auipc	a0,0x3
    800048c4:	d0050513          	addi	a0,a0,-768 # 800075c0 <etext+0x5c0>
    800048c8:	f6dfb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    800048cc:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    800048ce:	874a                	mv	a4,s2
    800048d0:	009b86bb          	addw	a3,s7,s1
    800048d4:	4581                	li	a1,0
    800048d6:	8552                	mv	a0,s4
    800048d8:	d37fe0ef          	jal	8000360e <readi>
    800048dc:	22a91a63          	bne	s2,a0,80004b10 <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    800048e0:	009a84bb          	addw	s1,s5,s1
    800048e4:	0334f263          	bgeu	s1,s3,80004908 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    800048e8:	02049593          	slli	a1,s1,0x20
    800048ec:	9181                	srli	a1,a1,0x20
    800048ee:	95e2                	add	a1,a1,s8
    800048f0:	855a                	mv	a0,s6
    800048f2:	ee6fc0ef          	jal	80000fd8 <walkaddr>
    800048f6:	862a                	mv	a2,a0
    if (pa == 0)
    800048f8:	d561                	beqz	a0,800048c0 <kexec+0xce>
    if (sz - i < PGSIZE)
    800048fa:	409987bb          	subw	a5,s3,s1
    800048fe:	893e                	mv	s2,a5
    80004900:	fcfcf6e3          	bgeu	s9,a5,800048cc <kexec+0xda>
    80004904:	8956                	mv	s2,s5
    80004906:	b7d9                	j	800048cc <kexec+0xda>
    sz = sz1;
    80004908:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    8000490c:	2d05                	addiw	s10,s10,1
    8000490e:	e0843783          	ld	a5,-504(s0)
    80004912:	0387869b          	addiw	a3,a5,56
    80004916:	e8845783          	lhu	a5,-376(s0)
    8000491a:	06fd5d63          	bge	s10,a5,80004994 <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000491e:	e0d43423          	sd	a3,-504(s0)
    80004922:	876e                	mv	a4,s11
    80004924:	e1840613          	addi	a2,s0,-488
    80004928:	4581                	li	a1,0
    8000492a:	8552                	mv	a0,s4
    8000492c:	ce3fe0ef          	jal	8000360e <readi>
    80004930:	1db51e63          	bne	a0,s11,80004b0c <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004934:	e1842783          	lw	a5,-488(s0)
    80004938:	4705                	li	a4,1
    8000493a:	fce799e3          	bne	a5,a4,8000490c <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    8000493e:	e4043483          	ld	s1,-448(s0)
    80004942:	e3843783          	ld	a5,-456(s0)
    80004946:	1ef4e363          	bltu	s1,a5,80004b2c <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    8000494a:	e2843783          	ld	a5,-472(s0)
    8000494e:	94be                	add	s1,s1,a5
    80004950:	1ef4e163          	bltu	s1,a5,80004b32 <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004954:	de843703          	ld	a4,-536(s0)
    80004958:	8ff9                	and	a5,a5,a4
    8000495a:	1c079f63          	bnez	a5,80004b38 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    8000495e:	e1c42503          	lw	a0,-484(s0)
    80004962:	e71ff0ef          	jal	800047d2 <flags2perm>
    80004966:	86aa                	mv	a3,a0
    80004968:	8626                	mv	a2,s1
    8000496a:	85ca                	mv	a1,s2
    8000496c:	855a                	mv	a0,s6
    8000496e:	941fc0ef          	jal	800012ae <uvmalloc>
    80004972:	dea43c23          	sd	a0,-520(s0)
    80004976:	1c050463          	beqz	a0,80004b3e <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000497a:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    8000497e:	00098863          	beqz	s3,8000498e <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004982:	e2843c03          	ld	s8,-472(s0)
    80004986:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    8000498a:	4481                	li	s1,0
    8000498c:	bfb1                	j	800048e8 <kexec+0xf6>
    sz = sz1;
    8000498e:	df843903          	ld	s2,-520(s0)
    80004992:	bfad                	j	8000490c <kexec+0x11a>
    80004994:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004996:	8552                	mv	a0,s4
    80004998:	af1fe0ef          	jal	80003488 <iunlockput>
  end_op();
    8000499c:	b8eff0ef          	jal	80003d2a <end_op>
  p = myproc();
    800049a0:	f69fc0ef          	jal	80001908 <myproc>
    800049a4:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    800049a6:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    800049aa:	6c05                	lui	s8,0x1
    800049ac:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    800049ae:	9c4a                	add	s8,s8,s2
    800049b0:	77fd                	lui	a5,0xfffff
    800049b2:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    800049b6:	4691                	li	a3,4
    800049b8:	6609                	lui	a2,0x2
    800049ba:	9662                	add	a2,a2,s8
    800049bc:	85e2                	mv	a1,s8
    800049be:	855a                	mv	a0,s6
    800049c0:	8effc0ef          	jal	800012ae <uvmalloc>
    800049c4:	892a                	mv	s2,a0
    800049c6:	e10d                	bnez	a0,800049e8 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    800049c8:	85e2                	mv	a1,s8
    800049ca:	855a                	mv	a0,s6
    800049cc:	8d6fd0ef          	jal	80001aa2 <proc_freepagetable>
  return -1;
    800049d0:	557d                	li	a0,-1
    800049d2:	79fe                	ld	s3,504(sp)
    800049d4:	7a5e                	ld	s4,496(sp)
    800049d6:	7abe                	ld	s5,488(sp)
    800049d8:	7b1e                	ld	s6,480(sp)
    800049da:	6bfe                	ld	s7,472(sp)
    800049dc:	6c5e                	ld	s8,464(sp)
    800049de:	6cbe                	ld	s9,456(sp)
    800049e0:	6d1e                	ld	s10,448(sp)
    800049e2:	b549                	j	80004864 <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049e4:	4901                	li	s2,0
    800049e6:	bf45                	j	80004996 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    800049e8:	75f9                	lui	a1,0xffffe
    800049ea:	95aa                	add	a1,a1,a0
    800049ec:	855a                	mv	a0,s6
    800049ee:	a93fc0ef          	jal	80001480 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    800049f2:	80090a13          	addi	s4,s2,-2048
    800049f6:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    800049fa:	e0043783          	ld	a5,-512(s0)
    800049fe:	6388                	ld	a0,0(a5)
    80004a00:	c545                	beqz	a0,80004aa8 <kexec+0x2b6>
  sp = sz;
    80004a02:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004a04:	4481                	li	s1,0
    ustack[argc] = sp;
    80004a06:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004a0a:	c28fc0ef          	jal	80000e32 <strlen>
    80004a0e:	0015079b          	addiw	a5,a0,1
    80004a12:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004a16:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004a1a:	134c6563          	bltu	s8,s4,80004b44 <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004a1e:	e0043d03          	ld	s10,-512(s0)
    80004a22:	000d3c83          	ld	s9,0(s10)
    80004a26:	8566                	mv	a0,s9
    80004a28:	c0afc0ef          	jal	80000e32 <strlen>
    80004a2c:	0015071b          	addiw	a4,a0,1
    80004a30:	86e6                	mv	a3,s9
    80004a32:	8662                	mv	a2,s8
    80004a34:	85ca                	mv	a1,s2
    80004a36:	855a                	mv	a0,s6
    80004a38:	b0bfc0ef          	jal	80001542 <copyout>
    80004a3c:	10054663          	bltz	a0,80004b48 <kexec+0x356>
    ustack[argc] = sp;
    80004a40:	00349793          	slli	a5,s1,0x3
    80004a44:	97de                	add	a5,a5,s7
    80004a46:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdba00>
  for (argc = 0; argv[argc]; argc++) {
    80004a4a:	0485                	addi	s1,s1,1
    80004a4c:	008d0793          	addi	a5,s10,8
    80004a50:	e0f43023          	sd	a5,-512(s0)
    80004a54:	008d3503          	ld	a0,8(s10)
    80004a58:	f94d                	bnez	a0,80004a0a <kexec+0x218>
  ustack[argc] = 0;
    80004a5a:	00349793          	slli	a5,s1,0x3
    80004a5e:	f9078793          	addi	a5,a5,-112
    80004a62:	97a2                	add	a5,a5,s0
    80004a64:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004a68:	00349713          	slli	a4,s1,0x3
    80004a6c:	0721                	addi	a4,a4,8
    80004a6e:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004a72:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004a76:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004a78:	f54be8e3          	bltu	s7,s4,800049c8 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004a7c:	e9040693          	addi	a3,s0,-368
    80004a80:	865e                	mv	a2,s7
    80004a82:	85ca                	mv	a1,s2
    80004a84:	855a                	mv	a0,s6
    80004a86:	abdfc0ef          	jal	80001542 <copyout>
    80004a8a:	f2054fe3          	bltz	a0,800049c8 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004a8e:	0589b783          	ld	a5,88(s3)
    80004a92:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004a96:	df043783          	ld	a5,-528(s0)
    80004a9a:	0007c703          	lbu	a4,0(a5)
    80004a9e:	c30d                	beqz	a4,80004ac0 <kexec+0x2ce>
    80004aa0:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004aa2:	02f00693          	li	a3,47
    80004aa6:	a801                	j	80004ab6 <kexec+0x2c4>
  sp = sz;
    80004aa8:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004aaa:	4481                	li	s1,0
    80004aac:	b77d                	j	80004a5a <kexec+0x268>
  for (last = s = path; *s; s++)
    80004aae:	0785                	addi	a5,a5,1
    80004ab0:	fff7c703          	lbu	a4,-1(a5)
    80004ab4:	c711                	beqz	a4,80004ac0 <kexec+0x2ce>
    if (*s == '/')
    80004ab6:	fed71ce3          	bne	a4,a3,80004aae <kexec+0x2bc>
      last = s + 1;
    80004aba:	def43823          	sd	a5,-528(s0)
    80004abe:	bfc5                	j	80004aae <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ac0:	4641                	li	a2,16
    80004ac2:	df043583          	ld	a1,-528(s0)
    80004ac6:	15898513          	addi	a0,s3,344
    80004aca:	b32fc0ef          	jal	80000dfc <safestrcpy>
  oldpagetable = p->pagetable;
    80004ace:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004ad2:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004ad6:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004ada:	0589b783          	ld	a5,88(s3)
    80004ade:	e6843703          	ld	a4,-408(s0)
    80004ae2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004ae4:	0589b783          	ld	a5,88(s3)
    80004ae8:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004aec:	85d6                	mv	a1,s5
    80004aee:	fb5fc0ef          	jal	80001aa2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004af2:	0004851b          	sext.w	a0,s1
    80004af6:	79fe                	ld	s3,504(sp)
    80004af8:	7a5e                	ld	s4,496(sp)
    80004afa:	7abe                	ld	s5,488(sp)
    80004afc:	7b1e                	ld	s6,480(sp)
    80004afe:	6bfe                	ld	s7,472(sp)
    80004b00:	6c5e                	ld	s8,464(sp)
    80004b02:	6cbe                	ld	s9,456(sp)
    80004b04:	6d1e                	ld	s10,448(sp)
    80004b06:	bbb9                	j	80004864 <kexec+0x72>
    80004b08:	7b1e                	ld	s6,480(sp)
    80004b0a:	b3b1                	j	80004856 <kexec+0x64>
    80004b0c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004b10:	df843583          	ld	a1,-520(s0)
    80004b14:	855a                	mv	a0,s6
    80004b16:	f8dfc0ef          	jal	80001aa2 <proc_freepagetable>
  if (ip) {
    80004b1a:	79fe                	ld	s3,504(sp)
    80004b1c:	7abe                	ld	s5,488(sp)
    80004b1e:	7b1e                	ld	s6,480(sp)
    80004b20:	6bfe                	ld	s7,472(sp)
    80004b22:	6c5e                	ld	s8,464(sp)
    80004b24:	6cbe                	ld	s9,456(sp)
    80004b26:	6d1e                	ld	s10,448(sp)
    80004b28:	7dfa                	ld	s11,440(sp)
    80004b2a:	b335                	j	80004856 <kexec+0x64>
    80004b2c:	df243c23          	sd	s2,-520(s0)
    80004b30:	b7c5                	j	80004b10 <kexec+0x31e>
    80004b32:	df243c23          	sd	s2,-520(s0)
    80004b36:	bfe9                	j	80004b10 <kexec+0x31e>
    80004b38:	df243c23          	sd	s2,-520(s0)
    80004b3c:	bfd1                	j	80004b10 <kexec+0x31e>
    80004b3e:	df243c23          	sd	s2,-520(s0)
    80004b42:	b7f9                	j	80004b10 <kexec+0x31e>
  sz = sz1;
    80004b44:	8c4a                	mv	s8,s2
    80004b46:	b549                	j	800049c8 <kexec+0x1d6>
    80004b48:	8c4a                	mv	s8,s2
    80004b4a:	bdbd                	j	800049c8 <kexec+0x1d6>

0000000080004b4c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004b4c:	7179                	addi	sp,sp,-48
    80004b4e:	f406                	sd	ra,40(sp)
    80004b50:	f022                	sd	s0,32(sp)
    80004b52:	ec26                	sd	s1,24(sp)
    80004b54:	e84a                	sd	s2,16(sp)
    80004b56:	1800                	addi	s0,sp,48
    80004b58:	892e                	mv	s2,a1
    80004b5a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004b5c:	fdc40593          	addi	a1,s0,-36
    80004b60:	cfbfd0ef          	jal	8000285a <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004b64:	fdc42703          	lw	a4,-36(s0)
    80004b68:	47bd                	li	a5,15
    80004b6a:	02e7ea63          	bltu	a5,a4,80004b9e <argfd+0x52>
    80004b6e:	d9bfc0ef          	jal	80001908 <myproc>
    80004b72:	fdc42703          	lw	a4,-36(s0)
    80004b76:	00371793          	slli	a5,a4,0x3
    80004b7a:	0d078793          	addi	a5,a5,208
    80004b7e:	953e                	add	a0,a0,a5
    80004b80:	611c                	ld	a5,0(a0)
    80004b82:	c385                	beqz	a5,80004ba2 <argfd+0x56>
    return -1;
  if (pfd)
    80004b84:	00090463          	beqz	s2,80004b8c <argfd+0x40>
    *pfd = fd;
    80004b88:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004b8c:	4501                	li	a0,0
  if (pf)
    80004b8e:	c091                	beqz	s1,80004b92 <argfd+0x46>
    *pf = f;
    80004b90:	e09c                	sd	a5,0(s1)
}
    80004b92:	70a2                	ld	ra,40(sp)
    80004b94:	7402                	ld	s0,32(sp)
    80004b96:	64e2                	ld	s1,24(sp)
    80004b98:	6942                	ld	s2,16(sp)
    80004b9a:	6145                	addi	sp,sp,48
    80004b9c:	8082                	ret
    return -1;
    80004b9e:	557d                	li	a0,-1
    80004ba0:	bfcd                	j	80004b92 <argfd+0x46>
    80004ba2:	557d                	li	a0,-1
    80004ba4:	b7fd                	j	80004b92 <argfd+0x46>

0000000080004ba6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004ba6:	1101                	addi	sp,sp,-32
    80004ba8:	ec06                	sd	ra,24(sp)
    80004baa:	e822                	sd	s0,16(sp)
    80004bac:	e426                	sd	s1,8(sp)
    80004bae:	1000                	addi	s0,sp,32
    80004bb0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004bb2:	d57fc0ef          	jal	80001908 <myproc>
    80004bb6:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004bb8:	0d050793          	addi	a5,a0,208
    80004bbc:	4501                	li	a0,0
    80004bbe:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004bc0:	6398                	ld	a4,0(a5)
    80004bc2:	cb19                	beqz	a4,80004bd8 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004bc4:	2505                	addiw	a0,a0,1
    80004bc6:	07a1                	addi	a5,a5,8
    80004bc8:	fed51ce3          	bne	a0,a3,80004bc0 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004bcc:	557d                	li	a0,-1
}
    80004bce:	60e2                	ld	ra,24(sp)
    80004bd0:	6442                	ld	s0,16(sp)
    80004bd2:	64a2                	ld	s1,8(sp)
    80004bd4:	6105                	addi	sp,sp,32
    80004bd6:	8082                	ret
      p->ofile[fd] = f;
    80004bd8:	00351793          	slli	a5,a0,0x3
    80004bdc:	0d078793          	addi	a5,a5,208
    80004be0:	963e                	add	a2,a2,a5
    80004be2:	e204                	sd	s1,0(a2)
      return fd;
    80004be4:	b7ed                	j	80004bce <fdalloc+0x28>

0000000080004be6 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004be6:	715d                	addi	sp,sp,-80
    80004be8:	e486                	sd	ra,72(sp)
    80004bea:	e0a2                	sd	s0,64(sp)
    80004bec:	fc26                	sd	s1,56(sp)
    80004bee:	f84a                	sd	s2,48(sp)
    80004bf0:	f052                	sd	s4,32(sp)
    80004bf2:	ec56                	sd	s5,24(sp)
    80004bf4:	e85a                	sd	s6,16(sp)
    80004bf6:	0880                	addi	s0,sp,80
    80004bf8:	8a2e                	mv	s4,a1
    80004bfa:	8ab2                	mv	s5,a2
    80004bfc:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004bfe:	fb040593          	addi	a1,s0,-80
    80004c02:	ed9fe0ef          	jal	80003ada <nameiparent>
    80004c06:	84aa                	mv	s1,a0
    80004c08:	12050f63          	beqz	a0,80004d46 <create+0x160>
    return 0;

  ilock(dp);
    80004c0c:	e28fe0ef          	jal	80003234 <ilock>

  if (dp->nlink == 0) {
    80004c10:	04a49783          	lh	a5,74(s1)
    80004c14:	cbb9                	beqz	a5,80004c6a <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004c16:	7761                	lui	a4,0xffff8
    80004c18:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4a01>
    80004c1a:	97ba                	add	a5,a5,a4
    80004c1c:	e781                	bnez	a5,80004c24 <create+0x3e>
    80004c1e:	fffa0793          	addi	a5,s4,-1
    80004c22:	cba9                	beqz	a5,80004c74 <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004c24:	4601                	li	a2,0
    80004c26:	fb040593          	addi	a1,s0,-80
    80004c2a:	8526                	mv	a0,s1
    80004c2c:	bf1fe0ef          	jal	8000381c <dirlookup>
    80004c30:	892a                	mv	s2,a0
    80004c32:	c939                	beqz	a0,80004c88 <create+0xa2>
    iunlockput(dp);
    80004c34:	8526                	mv	a0,s1
    80004c36:	853fe0ef          	jal	80003488 <iunlockput>
    ilock(ip);
    80004c3a:	854a                	mv	a0,s2
    80004c3c:	df8fe0ef          	jal	80003234 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004c40:	4789                	li	a5,2
    80004c42:	02fa1e63          	bne	s4,a5,80004c7e <create+0x98>
    80004c46:	04495783          	lhu	a5,68(s2)
    80004c4a:	37f9                	addiw	a5,a5,-2
    80004c4c:	17c2                	slli	a5,a5,0x30
    80004c4e:	93c1                	srli	a5,a5,0x30
    80004c50:	4705                	li	a4,1
    80004c52:	02f76663          	bltu	a4,a5,80004c7e <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004c56:	854a                	mv	a0,s2
    80004c58:	60a6                	ld	ra,72(sp)
    80004c5a:	6406                	ld	s0,64(sp)
    80004c5c:	74e2                	ld	s1,56(sp)
    80004c5e:	7942                	ld	s2,48(sp)
    80004c60:	7a02                	ld	s4,32(sp)
    80004c62:	6ae2                	ld	s5,24(sp)
    80004c64:	6b42                	ld	s6,16(sp)
    80004c66:	6161                	addi	sp,sp,80
    80004c68:	8082                	ret
    iunlockput(dp);
    80004c6a:	8526                	mv	a0,s1
    80004c6c:	81dfe0ef          	jal	80003488 <iunlockput>
    return 0;
    80004c70:	4901                	li	s2,0
    80004c72:	b7d5                	j	80004c56 <create+0x70>
    iunlockput(dp);
    80004c74:	8526                	mv	a0,s1
    80004c76:	813fe0ef          	jal	80003488 <iunlockput>
    return 0;
    80004c7a:	4901                	li	s2,0
    80004c7c:	bfe9                	j	80004c56 <create+0x70>
    iunlockput(ip);
    80004c7e:	854a                	mv	a0,s2
    80004c80:	809fe0ef          	jal	80003488 <iunlockput>
    return 0;
    80004c84:	4901                	li	s2,0
    80004c86:	bfc1                	j	80004c56 <create+0x70>
    80004c88:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004c8a:	85d2                	mv	a1,s4
    80004c8c:	4088                	lw	a0,0(s1)
    80004c8e:	c36fe0ef          	jal	800030c4 <ialloc>
    80004c92:	89aa                	mv	s3,a0
    80004c94:	cd1d                	beqz	a0,80004cd2 <create+0xec>
  ilock(ip);
    80004c96:	d9efe0ef          	jal	80003234 <ilock>
  ip->major = major;
    80004c9a:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004c9e:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004ca2:	4705                	li	a4,1
    80004ca4:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004ca8:	854e                	mv	a0,s3
    80004caa:	cd6fe0ef          	jal	80003180 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004cae:	4705                	li	a4,1
    80004cb0:	02ea0763          	beq	s4,a4,80004cde <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004cb4:	0049a603          	lw	a2,4(s3)
    80004cb8:	fb040593          	addi	a1,s0,-80
    80004cbc:	8526                	mv	a0,s1
    80004cbe:	d59fe0ef          	jal	80003a16 <dirlink>
    80004cc2:	06054563          	bltz	a0,80004d2c <create+0x146>
  iunlockput(dp);
    80004cc6:	8526                	mv	a0,s1
    80004cc8:	fc0fe0ef          	jal	80003488 <iunlockput>
  return ip;
    80004ccc:	894e                	mv	s2,s3
    80004cce:	79a2                	ld	s3,40(sp)
    80004cd0:	b759                	j	80004c56 <create+0x70>
    iunlockput(dp);
    80004cd2:	8526                	mv	a0,s1
    80004cd4:	fb4fe0ef          	jal	80003488 <iunlockput>
    return 0;
    80004cd8:	894e                	mv	s2,s3
    80004cda:	79a2                	ld	s3,40(sp)
    80004cdc:	bfad                	j	80004c56 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004cde:	0049a603          	lw	a2,4(s3)
    80004ce2:	00003597          	auipc	a1,0x3
    80004ce6:	8fe58593          	addi	a1,a1,-1794 # 800075e0 <etext+0x5e0>
    80004cea:	854e                	mv	a0,s3
    80004cec:	d2bfe0ef          	jal	80003a16 <dirlink>
    80004cf0:	02054e63          	bltz	a0,80004d2c <create+0x146>
    80004cf4:	40d0                	lw	a2,4(s1)
    80004cf6:	00003597          	auipc	a1,0x3
    80004cfa:	8f258593          	addi	a1,a1,-1806 # 800075e8 <etext+0x5e8>
    80004cfe:	854e                	mv	a0,s3
    80004d00:	d17fe0ef          	jal	80003a16 <dirlink>
    80004d04:	02054463          	bltz	a0,80004d2c <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004d08:	0049a603          	lw	a2,4(s3)
    80004d0c:	fb040593          	addi	a1,s0,-80
    80004d10:	8526                	mv	a0,s1
    80004d12:	d05fe0ef          	jal	80003a16 <dirlink>
    80004d16:	00054b63          	bltz	a0,80004d2c <create+0x146>
    dp->nlink++; // for ".."
    80004d1a:	04a4d783          	lhu	a5,74(s1)
    80004d1e:	2785                	addiw	a5,a5,1
    80004d20:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d24:	8526                	mv	a0,s1
    80004d26:	c5afe0ef          	jal	80003180 <iupdate>
    80004d2a:	bf71                	j	80004cc6 <create+0xe0>
  ip->nlink = 0;
    80004d2c:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004d30:	854e                	mv	a0,s3
    80004d32:	c4efe0ef          	jal	80003180 <iupdate>
  iunlockput(ip);
    80004d36:	854e                	mv	a0,s3
    80004d38:	f50fe0ef          	jal	80003488 <iunlockput>
  iunlockput(dp);
    80004d3c:	8526                	mv	a0,s1
    80004d3e:	f4afe0ef          	jal	80003488 <iunlockput>
  return 0;
    80004d42:	79a2                	ld	s3,40(sp)
    80004d44:	bf09                	j	80004c56 <create+0x70>
    return 0;
    80004d46:	892a                	mv	s2,a0
    80004d48:	b739                	j	80004c56 <create+0x70>

0000000080004d4a <sys_dup>:
{
    80004d4a:	7179                	addi	sp,sp,-48
    80004d4c:	f406                	sd	ra,40(sp)
    80004d4e:	f022                	sd	s0,32(sp)
    80004d50:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004d52:	fd840613          	addi	a2,s0,-40
    80004d56:	4581                	li	a1,0
    80004d58:	4501                	li	a0,0
    80004d5a:	df3ff0ef          	jal	80004b4c <argfd>
    return -1;
    80004d5e:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004d60:	02054363          	bltz	a0,80004d86 <sys_dup+0x3c>
    80004d64:	ec26                	sd	s1,24(sp)
    80004d66:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004d68:	fd843483          	ld	s1,-40(s0)
    80004d6c:	8526                	mv	a0,s1
    80004d6e:	e39ff0ef          	jal	80004ba6 <fdalloc>
    80004d72:	892a                	mv	s2,a0
    return -1;
    80004d74:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004d76:	00054d63          	bltz	a0,80004d90 <sys_dup+0x46>
  filedup(f);
    80004d7a:	8526                	mv	a0,s1
    80004d7c:	b96ff0ef          	jal	80004112 <filedup>
  return fd;
    80004d80:	87ca                	mv	a5,s2
    80004d82:	64e2                	ld	s1,24(sp)
    80004d84:	6942                	ld	s2,16(sp)
}
    80004d86:	853e                	mv	a0,a5
    80004d88:	70a2                	ld	ra,40(sp)
    80004d8a:	7402                	ld	s0,32(sp)
    80004d8c:	6145                	addi	sp,sp,48
    80004d8e:	8082                	ret
    80004d90:	64e2                	ld	s1,24(sp)
    80004d92:	6942                	ld	s2,16(sp)
    80004d94:	bfcd                	j	80004d86 <sys_dup+0x3c>

0000000080004d96 <sys_read>:
{
    80004d96:	7179                	addi	sp,sp,-48
    80004d98:	f406                	sd	ra,40(sp)
    80004d9a:	f022                	sd	s0,32(sp)
    80004d9c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d9e:	fd840593          	addi	a1,s0,-40
    80004da2:	4505                	li	a0,1
    80004da4:	ad3fd0ef          	jal	80002876 <argaddr>
  argint(2, &n);
    80004da8:	fe440593          	addi	a1,s0,-28
    80004dac:	4509                	li	a0,2
    80004dae:	aadfd0ef          	jal	8000285a <argint>
  if (argfd(0, 0, &f) < 0)
    80004db2:	fe840613          	addi	a2,s0,-24
    80004db6:	4581                	li	a1,0
    80004db8:	4501                	li	a0,0
    80004dba:	d93ff0ef          	jal	80004b4c <argfd>
    80004dbe:	87aa                	mv	a5,a0
    return -1;
    80004dc0:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004dc2:	0007ca63          	bltz	a5,80004dd6 <sys_read+0x40>
  return fileread(f, p, n);
    80004dc6:	fe442603          	lw	a2,-28(s0)
    80004dca:	fd843583          	ld	a1,-40(s0)
    80004dce:	fe843503          	ld	a0,-24(s0)
    80004dd2:	caeff0ef          	jal	80004280 <fileread>
}
    80004dd6:	70a2                	ld	ra,40(sp)
    80004dd8:	7402                	ld	s0,32(sp)
    80004dda:	6145                	addi	sp,sp,48
    80004ddc:	8082                	ret

0000000080004dde <sys_write>:
{
    80004dde:	7179                	addi	sp,sp,-48
    80004de0:	f406                	sd	ra,40(sp)
    80004de2:	f022                	sd	s0,32(sp)
    80004de4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004de6:	fd840593          	addi	a1,s0,-40
    80004dea:	4505                	li	a0,1
    80004dec:	a8bfd0ef          	jal	80002876 <argaddr>
  argint(2, &n);
    80004df0:	fe440593          	addi	a1,s0,-28
    80004df4:	4509                	li	a0,2
    80004df6:	a65fd0ef          	jal	8000285a <argint>
  if (argfd(0, 0, &f) < 0)
    80004dfa:	fe840613          	addi	a2,s0,-24
    80004dfe:	4581                	li	a1,0
    80004e00:	4501                	li	a0,0
    80004e02:	d4bff0ef          	jal	80004b4c <argfd>
    80004e06:	87aa                	mv	a5,a0
    return -1;
    80004e08:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e0a:	0007ca63          	bltz	a5,80004e1e <sys_write+0x40>
  return filewrite(f, p, n);
    80004e0e:	fe442603          	lw	a2,-28(s0)
    80004e12:	fd843583          	ld	a1,-40(s0)
    80004e16:	fe843503          	ld	a0,-24(s0)
    80004e1a:	d34ff0ef          	jal	8000434e <filewrite>
}
    80004e1e:	70a2                	ld	ra,40(sp)
    80004e20:	7402                	ld	s0,32(sp)
    80004e22:	6145                	addi	sp,sp,48
    80004e24:	8082                	ret

0000000080004e26 <sys_close>:
{
    80004e26:	1101                	addi	sp,sp,-32
    80004e28:	ec06                	sd	ra,24(sp)
    80004e2a:	e822                	sd	s0,16(sp)
    80004e2c:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004e2e:	fe040613          	addi	a2,s0,-32
    80004e32:	fec40593          	addi	a1,s0,-20
    80004e36:	4501                	li	a0,0
    80004e38:	d15ff0ef          	jal	80004b4c <argfd>
    return -1;
    80004e3c:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004e3e:	02054163          	bltz	a0,80004e60 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004e42:	ac7fc0ef          	jal	80001908 <myproc>
    80004e46:	fec42783          	lw	a5,-20(s0)
    80004e4a:	078e                	slli	a5,a5,0x3
    80004e4c:	0d078793          	addi	a5,a5,208
    80004e50:	953e                	add	a0,a0,a5
    80004e52:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004e56:	fe043503          	ld	a0,-32(s0)
    80004e5a:	afeff0ef          	jal	80004158 <fileclose>
  return 0;
    80004e5e:	4781                	li	a5,0
}
    80004e60:	853e                	mv	a0,a5
    80004e62:	60e2                	ld	ra,24(sp)
    80004e64:	6442                	ld	s0,16(sp)
    80004e66:	6105                	addi	sp,sp,32
    80004e68:	8082                	ret

0000000080004e6a <sys_fstat>:
{
    80004e6a:	1101                	addi	sp,sp,-32
    80004e6c:	ec06                	sd	ra,24(sp)
    80004e6e:	e822                	sd	s0,16(sp)
    80004e70:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004e72:	fe040593          	addi	a1,s0,-32
    80004e76:	4505                	li	a0,1
    80004e78:	9fffd0ef          	jal	80002876 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004e7c:	fe840613          	addi	a2,s0,-24
    80004e80:	4581                	li	a1,0
    80004e82:	4501                	li	a0,0
    80004e84:	cc9ff0ef          	jal	80004b4c <argfd>
    80004e88:	87aa                	mv	a5,a0
    return -1;
    80004e8a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e8c:	0007c863          	bltz	a5,80004e9c <sys_fstat+0x32>
  return filestat(f, st);
    80004e90:	fe043583          	ld	a1,-32(s0)
    80004e94:	fe843503          	ld	a0,-24(s0)
    80004e98:	b82ff0ef          	jal	8000421a <filestat>
}
    80004e9c:	60e2                	ld	ra,24(sp)
    80004e9e:	6442                	ld	s0,16(sp)
    80004ea0:	6105                	addi	sp,sp,32
    80004ea2:	8082                	ret

0000000080004ea4 <sys_link>:
{
    80004ea4:	7169                	addi	sp,sp,-304
    80004ea6:	f606                	sd	ra,296(sp)
    80004ea8:	f222                	sd	s0,288(sp)
    80004eaa:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004eac:	08000613          	li	a2,128
    80004eb0:	ed040593          	addi	a1,s0,-304
    80004eb4:	4501                	li	a0,0
    80004eb6:	9ddfd0ef          	jal	80002892 <argstr>
    return -1;
    80004eba:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ebc:	10054163          	bltz	a0,80004fbe <sys_link+0x11a>
    80004ec0:	08000613          	li	a2,128
    80004ec4:	f5040593          	addi	a1,s0,-176
    80004ec8:	4505                	li	a0,1
    80004eca:	9c9fd0ef          	jal	80002892 <argstr>
    return -1;
    80004ece:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ed0:	0e054763          	bltz	a0,80004fbe <sys_link+0x11a>
    80004ed4:	ee26                	sd	s1,280(sp)
  begin_op();
    80004ed6:	dc9fe0ef          	jal	80003c9e <begin_op>
  if ((ip = namei(old)) == 0) {
    80004eda:	ed040513          	addi	a0,s0,-304
    80004ede:	be3fe0ef          	jal	80003ac0 <namei>
    80004ee2:	84aa                	mv	s1,a0
    80004ee4:	cd35                	beqz	a0,80004f60 <sys_link+0xbc>
  ilock(ip);
    80004ee6:	b4efe0ef          	jal	80003234 <ilock>
  if (ip->type == T_DIR) {
    80004eea:	04449703          	lh	a4,68(s1)
    80004eee:	4785                	li	a5,1
    80004ef0:	06f70d63          	beq	a4,a5,80004f6a <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80004ef4:	04a49783          	lh	a5,74(s1)
    80004ef8:	6721                	lui	a4,0x8
    80004efa:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004efc:	06e78f63          	beq	a5,a4,80004f7a <sys_link+0xd6>
    80004f00:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004f02:	2785                	addiw	a5,a5,1
    80004f04:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f08:	8526                	mv	a0,s1
    80004f0a:	a76fe0ef          	jal	80003180 <iupdate>
  iunlock(ip);
    80004f0e:	8526                	mv	a0,s1
    80004f10:	bd2fe0ef          	jal	800032e2 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80004f14:	fd040593          	addi	a1,s0,-48
    80004f18:	f5040513          	addi	a0,s0,-176
    80004f1c:	bbffe0ef          	jal	80003ada <nameiparent>
    80004f20:	892a                	mv	s2,a0
    80004f22:	c93d                	beqz	a0,80004f98 <sys_link+0xf4>
  ilock(dp);
    80004f24:	b10fe0ef          	jal	80003234 <ilock>
  if (dp->nlink == 0) {
    80004f28:	04a91783          	lh	a5,74(s2)
    80004f2c:	cfb9                	beqz	a5,80004f8a <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80004f2e:	854a                	mv	a0,s2
    80004f30:	00092703          	lw	a4,0(s2)
    80004f34:	409c                	lw	a5,0(s1)
    80004f36:	04f71e63          	bne	a4,a5,80004f92 <sys_link+0xee>
    80004f3a:	40d0                	lw	a2,4(s1)
    80004f3c:	fd040593          	addi	a1,s0,-48
    80004f40:	ad7fe0ef          	jal	80003a16 <dirlink>
    80004f44:	04054763          	bltz	a0,80004f92 <sys_link+0xee>
  iunlockput(dp);
    80004f48:	854a                	mv	a0,s2
    80004f4a:	d3efe0ef          	jal	80003488 <iunlockput>
  iput(ip);
    80004f4e:	8526                	mv	a0,s1
    80004f50:	c66fe0ef          	jal	800033b6 <iput>
  end_op();
    80004f54:	dd7fe0ef          	jal	80003d2a <end_op>
  return 0;
    80004f58:	4781                	li	a5,0
    80004f5a:	64f2                	ld	s1,280(sp)
    80004f5c:	6952                	ld	s2,272(sp)
    80004f5e:	a085                	j	80004fbe <sys_link+0x11a>
    end_op();
    80004f60:	dcbfe0ef          	jal	80003d2a <end_op>
    return -1;
    80004f64:	57fd                	li	a5,-1
    80004f66:	64f2                	ld	s1,280(sp)
    80004f68:	a899                	j	80004fbe <sys_link+0x11a>
    iunlockput(ip);
    80004f6a:	8526                	mv	a0,s1
    80004f6c:	d1cfe0ef          	jal	80003488 <iunlockput>
    end_op();
    80004f70:	dbbfe0ef          	jal	80003d2a <end_op>
    return -1;
    80004f74:	57fd                	li	a5,-1
    80004f76:	64f2                	ld	s1,280(sp)
    80004f78:	a099                	j	80004fbe <sys_link+0x11a>
    iunlockput(ip);
    80004f7a:	8526                	mv	a0,s1
    80004f7c:	d0cfe0ef          	jal	80003488 <iunlockput>
    end_op();
    80004f80:	dabfe0ef          	jal	80003d2a <end_op>
    return -1;
    80004f84:	57fd                	li	a5,-1
    80004f86:	64f2                	ld	s1,280(sp)
    80004f88:	a81d                	j	80004fbe <sys_link+0x11a>
    iunlockput(dp);
    80004f8a:	854a                	mv	a0,s2
    80004f8c:	cfcfe0ef          	jal	80003488 <iunlockput>
    goto bad;
    80004f90:	a021                	j	80004f98 <sys_link+0xf4>
    iunlockput(dp);
    80004f92:	854a                	mv	a0,s2
    80004f94:	cf4fe0ef          	jal	80003488 <iunlockput>
  ilock(ip);
    80004f98:	8526                	mv	a0,s1
    80004f9a:	a9afe0ef          	jal	80003234 <ilock>
  ip->nlink--;
    80004f9e:	04a4d783          	lhu	a5,74(s1)
    80004fa2:	37fd                	addiw	a5,a5,-1
    80004fa4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fa8:	8526                	mv	a0,s1
    80004faa:	9d6fe0ef          	jal	80003180 <iupdate>
  iunlockput(ip);
    80004fae:	8526                	mv	a0,s1
    80004fb0:	cd8fe0ef          	jal	80003488 <iunlockput>
  end_op();
    80004fb4:	d77fe0ef          	jal	80003d2a <end_op>
  return -1;
    80004fb8:	57fd                	li	a5,-1
    80004fba:	64f2                	ld	s1,280(sp)
    80004fbc:	6952                	ld	s2,272(sp)
}
    80004fbe:	853e                	mv	a0,a5
    80004fc0:	70b2                	ld	ra,296(sp)
    80004fc2:	7412                	ld	s0,288(sp)
    80004fc4:	6155                	addi	sp,sp,304
    80004fc6:	8082                	ret

0000000080004fc8 <sys_unlink>:
{
    80004fc8:	7151                	addi	sp,sp,-240
    80004fca:	f586                	sd	ra,232(sp)
    80004fcc:	f1a2                	sd	s0,224(sp)
    80004fce:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80004fd0:	08000613          	li	a2,128
    80004fd4:	f3040593          	addi	a1,s0,-208
    80004fd8:	4501                	li	a0,0
    80004fda:	8b9fd0ef          	jal	80002892 <argstr>
    80004fde:	14054d63          	bltz	a0,80005138 <sys_unlink+0x170>
    80004fe2:	eda6                	sd	s1,216(sp)
  begin_op();
    80004fe4:	cbbfe0ef          	jal	80003c9e <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80004fe8:	fb040593          	addi	a1,s0,-80
    80004fec:	f3040513          	addi	a0,s0,-208
    80004ff0:	aebfe0ef          	jal	80003ada <nameiparent>
    80004ff4:	84aa                	mv	s1,a0
    80004ff6:	c955                	beqz	a0,800050aa <sys_unlink+0xe2>
  ilock(dp);
    80004ff8:	a3cfe0ef          	jal	80003234 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004ffc:	00002597          	auipc	a1,0x2
    80005000:	5e458593          	addi	a1,a1,1508 # 800075e0 <etext+0x5e0>
    80005004:	fb040513          	addi	a0,s0,-80
    80005008:	ffefe0ef          	jal	80003806 <namecmp>
    8000500c:	10050b63          	beqz	a0,80005122 <sys_unlink+0x15a>
    80005010:	00002597          	auipc	a1,0x2
    80005014:	5d858593          	addi	a1,a1,1496 # 800075e8 <etext+0x5e8>
    80005018:	fb040513          	addi	a0,s0,-80
    8000501c:	feafe0ef          	jal	80003806 <namecmp>
    80005020:	10050163          	beqz	a0,80005122 <sys_unlink+0x15a>
    80005024:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005026:	f2c40613          	addi	a2,s0,-212
    8000502a:	fb040593          	addi	a1,s0,-80
    8000502e:	8526                	mv	a0,s1
    80005030:	fecfe0ef          	jal	8000381c <dirlookup>
    80005034:	892a                	mv	s2,a0
    80005036:	0e050563          	beqz	a0,80005120 <sys_unlink+0x158>
    8000503a:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    8000503c:	9f8fe0ef          	jal	80003234 <ilock>
  if (ip->nlink < 1)
    80005040:	04a91783          	lh	a5,74(s2)
    80005044:	06f05863          	blez	a5,800050b4 <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80005048:	04491703          	lh	a4,68(s2)
    8000504c:	4785                	li	a5,1
    8000504e:	06f70963          	beq	a4,a5,800050c0 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005052:	fc040993          	addi	s3,s0,-64
    80005056:	4641                	li	a2,16
    80005058:	4581                	li	a1,0
    8000505a:	854e                	mv	a0,s3
    8000505c:	c4dfb0ef          	jal	80000ca8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005060:	4741                	li	a4,16
    80005062:	f2c42683          	lw	a3,-212(s0)
    80005066:	864e                	mv	a2,s3
    80005068:	4581                	li	a1,0
    8000506a:	8526                	mv	a0,s1
    8000506c:	e94fe0ef          	jal	80003700 <writei>
    80005070:	47c1                	li	a5,16
    80005072:	08f51863          	bne	a0,a5,80005102 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    80005076:	04491703          	lh	a4,68(s2)
    8000507a:	4785                	li	a5,1
    8000507c:	08f70963          	beq	a4,a5,8000510e <sys_unlink+0x146>
  iunlockput(dp);
    80005080:	8526                	mv	a0,s1
    80005082:	c06fe0ef          	jal	80003488 <iunlockput>
  ip->nlink--;
    80005086:	04a95783          	lhu	a5,74(s2)
    8000508a:	37fd                	addiw	a5,a5,-1
    8000508c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005090:	854a                	mv	a0,s2
    80005092:	8eefe0ef          	jal	80003180 <iupdate>
  iunlockput(ip);
    80005096:	854a                	mv	a0,s2
    80005098:	bf0fe0ef          	jal	80003488 <iunlockput>
  end_op();
    8000509c:	c8ffe0ef          	jal	80003d2a <end_op>
  return 0;
    800050a0:	4501                	li	a0,0
    800050a2:	64ee                	ld	s1,216(sp)
    800050a4:	694e                	ld	s2,208(sp)
    800050a6:	69ae                	ld	s3,200(sp)
    800050a8:	a061                	j	80005130 <sys_unlink+0x168>
    end_op();
    800050aa:	c81fe0ef          	jal	80003d2a <end_op>
    return -1;
    800050ae:	557d                	li	a0,-1
    800050b0:	64ee                	ld	s1,216(sp)
    800050b2:	a8bd                	j	80005130 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800050b4:	00002517          	auipc	a0,0x2
    800050b8:	53c50513          	addi	a0,a0,1340 # 800075f0 <etext+0x5f0>
    800050bc:	f78fb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800050c0:	04c92703          	lw	a4,76(s2)
    800050c4:	02000793          	li	a5,32
    800050c8:	f8e7f5e3          	bgeu	a5,a4,80005052 <sys_unlink+0x8a>
    800050cc:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050ce:	4741                	li	a4,16
    800050d0:	86ce                	mv	a3,s3
    800050d2:	f1840613          	addi	a2,s0,-232
    800050d6:	4581                	li	a1,0
    800050d8:	854a                	mv	a0,s2
    800050da:	d34fe0ef          	jal	8000360e <readi>
    800050de:	47c1                	li	a5,16
    800050e0:	00f51b63          	bne	a0,a5,800050f6 <sys_unlink+0x12e>
    if (de.inum != 0)
    800050e4:	f1845783          	lhu	a5,-232(s0)
    800050e8:	ebb1                	bnez	a5,8000513c <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800050ea:	29c1                	addiw	s3,s3,16
    800050ec:	04c92783          	lw	a5,76(s2)
    800050f0:	fcf9efe3          	bltu	s3,a5,800050ce <sys_unlink+0x106>
    800050f4:	bfb9                	j	80005052 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800050f6:	00002517          	auipc	a0,0x2
    800050fa:	51250513          	addi	a0,a0,1298 # 80007608 <etext+0x608>
    800050fe:	f36fb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    80005102:	00002517          	auipc	a0,0x2
    80005106:	51e50513          	addi	a0,a0,1310 # 80007620 <etext+0x620>
    8000510a:	f2afb0ef          	jal	80000834 <panic>
    dp->nlink--;
    8000510e:	04a4d783          	lhu	a5,74(s1)
    80005112:	37fd                	addiw	a5,a5,-1
    80005114:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005118:	8526                	mv	a0,s1
    8000511a:	866fe0ef          	jal	80003180 <iupdate>
    8000511e:	b78d                	j	80005080 <sys_unlink+0xb8>
    80005120:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005122:	8526                	mv	a0,s1
    80005124:	b64fe0ef          	jal	80003488 <iunlockput>
  end_op();
    80005128:	c03fe0ef          	jal	80003d2a <end_op>
  return -1;
    8000512c:	557d                	li	a0,-1
    8000512e:	64ee                	ld	s1,216(sp)
}
    80005130:	70ae                	ld	ra,232(sp)
    80005132:	740e                	ld	s0,224(sp)
    80005134:	616d                	addi	sp,sp,240
    80005136:	8082                	ret
    return -1;
    80005138:	557d                	li	a0,-1
    8000513a:	bfdd                	j	80005130 <sys_unlink+0x168>
    iunlockput(ip);
    8000513c:	854a                	mv	a0,s2
    8000513e:	b4afe0ef          	jal	80003488 <iunlockput>
    goto bad;
    80005142:	694e                	ld	s2,208(sp)
    80005144:	69ae                	ld	s3,200(sp)
    80005146:	bff1                	j	80005122 <sys_unlink+0x15a>

0000000080005148 <sys_open>:

uint64
sys_open(void)
{
    80005148:	7131                	addi	sp,sp,-192
    8000514a:	fd06                	sd	ra,184(sp)
    8000514c:	f922                	sd	s0,176(sp)
    8000514e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005150:	f4c40593          	addi	a1,s0,-180
    80005154:	4505                	li	a0,1
    80005156:	f04fd0ef          	jal	8000285a <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000515a:	08000613          	li	a2,128
    8000515e:	f5040593          	addi	a1,s0,-176
    80005162:	4501                	li	a0,0
    80005164:	f2efd0ef          	jal	80002892 <argstr>
    80005168:	87aa                	mv	a5,a0
    return -1;
    8000516a:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000516c:	0a07c363          	bltz	a5,80005212 <sys_open+0xca>
    80005170:	f526                	sd	s1,168(sp)

  begin_op();
    80005172:	b2dfe0ef          	jal	80003c9e <begin_op>

  if (omode & O_CREATE) {
    80005176:	f4c42783          	lw	a5,-180(s0)
    8000517a:	2007f793          	andi	a5,a5,512
    8000517e:	c3dd                	beqz	a5,80005224 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005180:	4681                	li	a3,0
    80005182:	4601                	li	a2,0
    80005184:	4589                	li	a1,2
    80005186:	f5040513          	addi	a0,s0,-176
    8000518a:	a5dff0ef          	jal	80004be6 <create>
    8000518e:	84aa                	mv	s1,a0
    if (ip == 0) {
    80005190:	c549                	beqz	a0,8000521a <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80005192:	04449703          	lh	a4,68(s1)
    80005196:	478d                	li	a5,3
    80005198:	00f71763          	bne	a4,a5,800051a6 <sys_open+0x5e>
    8000519c:	0464d703          	lhu	a4,70(s1)
    800051a0:	47a5                	li	a5,9
    800051a2:	0ae7ee63          	bltu	a5,a4,8000525e <sys_open+0x116>
    800051a6:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    800051a8:	f0dfe0ef          	jal	800040b4 <filealloc>
    800051ac:	892a                	mv	s2,a0
    800051ae:	c561                	beqz	a0,80005276 <sys_open+0x12e>
    800051b0:	ed4e                	sd	s3,152(sp)
    800051b2:	9f5ff0ef          	jal	80004ba6 <fdalloc>
    800051b6:	89aa                	mv	s3,a0
    800051b8:	0a054b63          	bltz	a0,8000526e <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    800051bc:	04449703          	lh	a4,68(s1)
    800051c0:	478d                	li	a5,3
    800051c2:	0cf70363          	beq	a4,a5,80005288 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800051c6:	4789                	li	a5,2
    800051c8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800051cc:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800051d0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800051d4:	f4c42783          	lw	a5,-180(s0)
    800051d8:	0017f713          	andi	a4,a5,1
    800051dc:	00174713          	xori	a4,a4,1
    800051e0:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800051e4:	0037f713          	andi	a4,a5,3
    800051e8:	00e03733          	snez	a4,a4
    800051ec:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    800051f0:	4007f793          	andi	a5,a5,1024
    800051f4:	c791                	beqz	a5,80005200 <sys_open+0xb8>
    800051f6:	04449703          	lh	a4,68(s1)
    800051fa:	4789                	li	a5,2
    800051fc:	08f70d63          	beq	a4,a5,80005296 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005200:	8526                	mv	a0,s1
    80005202:	8e0fe0ef          	jal	800032e2 <iunlock>
  end_op();
    80005206:	b25fe0ef          	jal	80003d2a <end_op>

  return fd;
    8000520a:	854e                	mv	a0,s3
    8000520c:	74aa                	ld	s1,168(sp)
    8000520e:	790a                	ld	s2,160(sp)
    80005210:	69ea                	ld	s3,152(sp)
}
    80005212:	70ea                	ld	ra,184(sp)
    80005214:	744a                	ld	s0,176(sp)
    80005216:	6129                	addi	sp,sp,192
    80005218:	8082                	ret
      end_op();
    8000521a:	b11fe0ef          	jal	80003d2a <end_op>
      return -1;
    8000521e:	557d                	li	a0,-1
    80005220:	74aa                	ld	s1,168(sp)
    80005222:	bfc5                	j	80005212 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    80005224:	f5040513          	addi	a0,s0,-176
    80005228:	899fe0ef          	jal	80003ac0 <namei>
    8000522c:	84aa                	mv	s1,a0
    8000522e:	c11d                	beqz	a0,80005254 <sys_open+0x10c>
    ilock(ip);
    80005230:	804fe0ef          	jal	80003234 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    80005234:	04449703          	lh	a4,68(s1)
    80005238:	4785                	li	a5,1
    8000523a:	f4f71ce3          	bne	a4,a5,80005192 <sys_open+0x4a>
    8000523e:	f4c42783          	lw	a5,-180(s0)
    80005242:	d3b5                	beqz	a5,800051a6 <sys_open+0x5e>
      iunlockput(ip);
    80005244:	8526                	mv	a0,s1
    80005246:	a42fe0ef          	jal	80003488 <iunlockput>
      end_op();
    8000524a:	ae1fe0ef          	jal	80003d2a <end_op>
      return -1;
    8000524e:	557d                	li	a0,-1
    80005250:	74aa                	ld	s1,168(sp)
    80005252:	b7c1                	j	80005212 <sys_open+0xca>
      end_op();
    80005254:	ad7fe0ef          	jal	80003d2a <end_op>
      return -1;
    80005258:	557d                	li	a0,-1
    8000525a:	74aa                	ld	s1,168(sp)
    8000525c:	bf5d                	j	80005212 <sys_open+0xca>
    iunlockput(ip);
    8000525e:	8526                	mv	a0,s1
    80005260:	a28fe0ef          	jal	80003488 <iunlockput>
    end_op();
    80005264:	ac7fe0ef          	jal	80003d2a <end_op>
    return -1;
    80005268:	557d                	li	a0,-1
    8000526a:	74aa                	ld	s1,168(sp)
    8000526c:	b75d                	j	80005212 <sys_open+0xca>
      fileclose(f);
    8000526e:	854a                	mv	a0,s2
    80005270:	ee9fe0ef          	jal	80004158 <fileclose>
    80005274:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005276:	8526                	mv	a0,s1
    80005278:	a10fe0ef          	jal	80003488 <iunlockput>
    end_op();
    8000527c:	aaffe0ef          	jal	80003d2a <end_op>
    return -1;
    80005280:	557d                	li	a0,-1
    80005282:	74aa                	ld	s1,168(sp)
    80005284:	790a                	ld	s2,160(sp)
    80005286:	b771                	j	80005212 <sys_open+0xca>
    f->type = FD_DEVICE;
    80005288:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    8000528c:	04649783          	lh	a5,70(s1)
    80005290:	02f91223          	sh	a5,36(s2)
    80005294:	bf35                	j	800051d0 <sys_open+0x88>
    itrunc(ip);
    80005296:	8526                	mv	a0,s1
    80005298:	88afe0ef          	jal	80003322 <itrunc>
    8000529c:	b795                	j	80005200 <sys_open+0xb8>

000000008000529e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000529e:	7175                	addi	sp,sp,-144
    800052a0:	e506                	sd	ra,136(sp)
    800052a2:	e122                	sd	s0,128(sp)
    800052a4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800052a6:	9f9fe0ef          	jal	80003c9e <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    800052aa:	08000613          	li	a2,128
    800052ae:	f7040593          	addi	a1,s0,-144
    800052b2:	4501                	li	a0,0
    800052b4:	ddefd0ef          	jal	80002892 <argstr>
    800052b8:	02054363          	bltz	a0,800052de <sys_mkdir+0x40>
    800052bc:	4681                	li	a3,0
    800052be:	4601                	li	a2,0
    800052c0:	4585                	li	a1,1
    800052c2:	f7040513          	addi	a0,s0,-144
    800052c6:	921ff0ef          	jal	80004be6 <create>
    800052ca:	c911                	beqz	a0,800052de <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800052cc:	9bcfe0ef          	jal	80003488 <iunlockput>
  end_op();
    800052d0:	a5bfe0ef          	jal	80003d2a <end_op>
  return 0;
    800052d4:	4501                	li	a0,0
}
    800052d6:	60aa                	ld	ra,136(sp)
    800052d8:	640a                	ld	s0,128(sp)
    800052da:	6149                	addi	sp,sp,144
    800052dc:	8082                	ret
    end_op();
    800052de:	a4dfe0ef          	jal	80003d2a <end_op>
    return -1;
    800052e2:	557d                	li	a0,-1
    800052e4:	bfcd                	j	800052d6 <sys_mkdir+0x38>

00000000800052e6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800052e6:	7135                	addi	sp,sp,-160
    800052e8:	ed06                	sd	ra,152(sp)
    800052ea:	e922                	sd	s0,144(sp)
    800052ec:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800052ee:	9b1fe0ef          	jal	80003c9e <begin_op>
  argint(1, &major);
    800052f2:	f6c40593          	addi	a1,s0,-148
    800052f6:	4505                	li	a0,1
    800052f8:	d62fd0ef          	jal	8000285a <argint>
  argint(2, &minor);
    800052fc:	f6840593          	addi	a1,s0,-152
    80005300:	4509                	li	a0,2
    80005302:	d58fd0ef          	jal	8000285a <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005306:	08000613          	li	a2,128
    8000530a:	f7040593          	addi	a1,s0,-144
    8000530e:	4501                	li	a0,0
    80005310:	d82fd0ef          	jal	80002892 <argstr>
    80005314:	02054563          	bltz	a0,8000533e <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005318:	f6841683          	lh	a3,-152(s0)
    8000531c:	f6c41603          	lh	a2,-148(s0)
    80005320:	458d                	li	a1,3
    80005322:	f7040513          	addi	a0,s0,-144
    80005326:	8c1ff0ef          	jal	80004be6 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000532a:	c911                	beqz	a0,8000533e <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000532c:	95cfe0ef          	jal	80003488 <iunlockput>
  end_op();
    80005330:	9fbfe0ef          	jal	80003d2a <end_op>
  return 0;
    80005334:	4501                	li	a0,0
}
    80005336:	60ea                	ld	ra,152(sp)
    80005338:	644a                	ld	s0,144(sp)
    8000533a:	610d                	addi	sp,sp,160
    8000533c:	8082                	ret
    end_op();
    8000533e:	9edfe0ef          	jal	80003d2a <end_op>
    return -1;
    80005342:	557d                	li	a0,-1
    80005344:	bfcd                	j	80005336 <sys_mknod+0x50>

0000000080005346 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005346:	7135                	addi	sp,sp,-160
    80005348:	ed06                	sd	ra,152(sp)
    8000534a:	e922                	sd	s0,144(sp)
    8000534c:	e14a                	sd	s2,128(sp)
    8000534e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005350:	db8fc0ef          	jal	80001908 <myproc>
    80005354:	892a                	mv	s2,a0

  begin_op();
    80005356:	949fe0ef          	jal	80003c9e <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    8000535a:	08000613          	li	a2,128
    8000535e:	f6040593          	addi	a1,s0,-160
    80005362:	4501                	li	a0,0
    80005364:	d2efd0ef          	jal	80002892 <argstr>
    80005368:	04054363          	bltz	a0,800053ae <sys_chdir+0x68>
    8000536c:	e526                	sd	s1,136(sp)
    8000536e:	f6040513          	addi	a0,s0,-160
    80005372:	f4efe0ef          	jal	80003ac0 <namei>
    80005376:	84aa                	mv	s1,a0
    80005378:	c915                	beqz	a0,800053ac <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000537a:	ebbfd0ef          	jal	80003234 <ilock>
  if (ip->type != T_DIR) {
    8000537e:	04449703          	lh	a4,68(s1)
    80005382:	4785                	li	a5,1
    80005384:	02f71963          	bne	a4,a5,800053b6 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005388:	8526                	mv	a0,s1
    8000538a:	f59fd0ef          	jal	800032e2 <iunlock>
  iput(p->cwd);
    8000538e:	15093503          	ld	a0,336(s2)
    80005392:	824fe0ef          	jal	800033b6 <iput>
  end_op();
    80005396:	995fe0ef          	jal	80003d2a <end_op>
  p->cwd = ip;
    8000539a:	14993823          	sd	s1,336(s2)
  return 0;
    8000539e:	4501                	li	a0,0
    800053a0:	64aa                	ld	s1,136(sp)
}
    800053a2:	60ea                	ld	ra,152(sp)
    800053a4:	644a                	ld	s0,144(sp)
    800053a6:	690a                	ld	s2,128(sp)
    800053a8:	610d                	addi	sp,sp,160
    800053aa:	8082                	ret
    800053ac:	64aa                	ld	s1,136(sp)
    end_op();
    800053ae:	97dfe0ef          	jal	80003d2a <end_op>
    return -1;
    800053b2:	557d                	li	a0,-1
    800053b4:	b7fd                	j	800053a2 <sys_chdir+0x5c>
    iunlockput(ip);
    800053b6:	8526                	mv	a0,s1
    800053b8:	8d0fe0ef          	jal	80003488 <iunlockput>
    end_op();
    800053bc:	96ffe0ef          	jal	80003d2a <end_op>
    return -1;
    800053c0:	557d                	li	a0,-1
    800053c2:	64aa                	ld	s1,136(sp)
    800053c4:	bff9                	j	800053a2 <sys_chdir+0x5c>

00000000800053c6 <sys_exec>:

uint64
sys_exec(void)
{
    800053c6:	7105                	addi	sp,sp,-480
    800053c8:	ef86                	sd	ra,472(sp)
    800053ca:	eba2                	sd	s0,464(sp)
    800053cc:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800053ce:	e2840593          	addi	a1,s0,-472
    800053d2:	4505                	li	a0,1
    800053d4:	ca2fd0ef          	jal	80002876 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    800053d8:	08000613          	li	a2,128
    800053dc:	f3040593          	addi	a1,s0,-208
    800053e0:	4501                	li	a0,0
    800053e2:	cb0fd0ef          	jal	80002892 <argstr>
    800053e6:	87aa                	mv	a5,a0
    return -1;
    800053e8:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    800053ea:	0e07c063          	bltz	a5,800054ca <sys_exec+0x104>
    800053ee:	e7a6                	sd	s1,456(sp)
    800053f0:	e3ca                	sd	s2,448(sp)
    800053f2:	ff4e                	sd	s3,440(sp)
    800053f4:	fb52                	sd	s4,432(sp)
    800053f6:	f756                	sd	s5,424(sp)
    800053f8:	f35a                	sd	s6,416(sp)
    800053fa:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800053fc:	e3040a13          	addi	s4,s0,-464
    80005400:	10000613          	li	a2,256
    80005404:	4581                	li	a1,0
    80005406:	8552                	mv	a0,s4
    80005408:	8a1fb0ef          	jal	80000ca8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    8000540c:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    8000540e:	89d2                	mv	s3,s4
    80005410:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005412:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005416:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    80005418:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000541c:	00391513          	slli	a0,s2,0x3
    80005420:	85d6                	mv	a1,s5
    80005422:	e2843783          	ld	a5,-472(s0)
    80005426:	953e                	add	a0,a0,a5
    80005428:	ba6fd0ef          	jal	800027ce <fetchaddr>
    8000542c:	02054663          	bltz	a0,80005458 <sys_exec+0x92>
    if (uarg == 0) {
    80005430:	e2043783          	ld	a5,-480(s0)
    80005434:	c7a1                	beqz	a5,8000547c <sys_exec+0xb6>
    argv[i] = kalloc();
    80005436:	ed8fb0ef          	jal	80000b0e <kalloc>
    8000543a:	85aa                	mv	a1,a0
    8000543c:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005440:	cd01                	beqz	a0,80005458 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005442:	865a                	mv	a2,s6
    80005444:	e2043503          	ld	a0,-480(s0)
    80005448:	bd0fd0ef          	jal	80002818 <fetchstr>
    8000544c:	00054663          	bltz	a0,80005458 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    80005450:	0905                	addi	s2,s2,1
    80005452:	09a1                	addi	s3,s3,8
    80005454:	fd7914e3          	bne	s2,s7,8000541c <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005458:	100a0a13          	addi	s4,s4,256
    8000545c:	6088                	ld	a0,0(s1)
    8000545e:	cd31                	beqz	a0,800054ba <sys_exec+0xf4>
    kfree(argv[i]);
    80005460:	dc6fb0ef          	jal	80000a26 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005464:	04a1                	addi	s1,s1,8
    80005466:	ff449be3          	bne	s1,s4,8000545c <sys_exec+0x96>
  return -1;
    8000546a:	557d                	li	a0,-1
    8000546c:	64be                	ld	s1,456(sp)
    8000546e:	691e                	ld	s2,448(sp)
    80005470:	79fa                	ld	s3,440(sp)
    80005472:	7a5a                	ld	s4,432(sp)
    80005474:	7aba                	ld	s5,424(sp)
    80005476:	7b1a                	ld	s6,416(sp)
    80005478:	6bfa                	ld	s7,408(sp)
    8000547a:	a881                	j	800054ca <sys_exec+0x104>
      argv[i] = 0;
    8000547c:	0009079b          	sext.w	a5,s2
    80005480:	e3040593          	addi	a1,s0,-464
    80005484:	078e                	slli	a5,a5,0x3
    80005486:	97ae                	add	a5,a5,a1
    80005488:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000548c:	f3040513          	addi	a0,s0,-208
    80005490:	b62ff0ef          	jal	800047f2 <kexec>
    80005494:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005496:	100a0a13          	addi	s4,s4,256
    8000549a:	6088                	ld	a0,0(s1)
    8000549c:	c511                	beqz	a0,800054a8 <sys_exec+0xe2>
    kfree(argv[i]);
    8000549e:	d88fb0ef          	jal	80000a26 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054a2:	04a1                	addi	s1,s1,8
    800054a4:	ff449be3          	bne	s1,s4,8000549a <sys_exec+0xd4>
  return ret;
    800054a8:	854a                	mv	a0,s2
    800054aa:	64be                	ld	s1,456(sp)
    800054ac:	691e                	ld	s2,448(sp)
    800054ae:	79fa                	ld	s3,440(sp)
    800054b0:	7a5a                	ld	s4,432(sp)
    800054b2:	7aba                	ld	s5,424(sp)
    800054b4:	7b1a                	ld	s6,416(sp)
    800054b6:	6bfa                	ld	s7,408(sp)
    800054b8:	a809                	j	800054ca <sys_exec+0x104>
  return -1;
    800054ba:	557d                	li	a0,-1
    800054bc:	64be                	ld	s1,456(sp)
    800054be:	691e                	ld	s2,448(sp)
    800054c0:	79fa                	ld	s3,440(sp)
    800054c2:	7a5a                	ld	s4,432(sp)
    800054c4:	7aba                	ld	s5,424(sp)
    800054c6:	7b1a                	ld	s6,416(sp)
    800054c8:	6bfa                	ld	s7,408(sp)
}
    800054ca:	60fe                	ld	ra,472(sp)
    800054cc:	645e                	ld	s0,464(sp)
    800054ce:	613d                	addi	sp,sp,480
    800054d0:	8082                	ret

00000000800054d2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800054d2:	7139                	addi	sp,sp,-64
    800054d4:	fc06                	sd	ra,56(sp)
    800054d6:	f822                	sd	s0,48(sp)
    800054d8:	f426                	sd	s1,40(sp)
    800054da:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800054dc:	c2cfc0ef          	jal	80001908 <myproc>
    800054e0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800054e2:	fd840593          	addi	a1,s0,-40
    800054e6:	4501                	li	a0,0
    800054e8:	b8efd0ef          	jal	80002876 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    800054ec:	fc840593          	addi	a1,s0,-56
    800054f0:	fd040513          	addi	a0,s0,-48
    800054f4:	f99fe0ef          	jal	8000448c <pipealloc>
    return -1;
    800054f8:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800054fa:	0a054963          	bltz	a0,800055ac <sys_pipe+0xda>
  fd0 = -1;
    800054fe:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    80005502:	fd043503          	ld	a0,-48(s0)
    80005506:	ea0ff0ef          	jal	80004ba6 <fdalloc>
    8000550a:	fca42223          	sw	a0,-60(s0)
    8000550e:	08054663          	bltz	a0,8000559a <sys_pipe+0xc8>
    80005512:	fc843503          	ld	a0,-56(s0)
    80005516:	e90ff0ef          	jal	80004ba6 <fdalloc>
    8000551a:	fca42023          	sw	a0,-64(s0)
    8000551e:	06054463          	bltz	a0,80005586 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005522:	4711                	li	a4,4
    80005524:	fc440693          	addi	a3,s0,-60
    80005528:	fd843603          	ld	a2,-40(s0)
    8000552c:	64ac                	ld	a1,72(s1)
    8000552e:	68a8                	ld	a0,80(s1)
    80005530:	812fc0ef          	jal	80001542 <copyout>
    80005534:	00054f63          	bltz	a0,80005552 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005538:	4711                	li	a4,4
    8000553a:	fc040693          	addi	a3,s0,-64
    8000553e:	fd843603          	ld	a2,-40(s0)
    80005542:	963a                	add	a2,a2,a4
    80005544:	64ac                	ld	a1,72(s1)
    80005546:	68a8                	ld	a0,80(s1)
    80005548:	ffbfb0ef          	jal	80001542 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000554c:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000554e:	04055f63          	bgez	a0,800055ac <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    80005552:	fc442783          	lw	a5,-60(s0)
    80005556:	078e                	slli	a5,a5,0x3
    80005558:	0d078793          	addi	a5,a5,208
    8000555c:	97a6                	add	a5,a5,s1
    8000555e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005562:	fc042783          	lw	a5,-64(s0)
    80005566:	078e                	slli	a5,a5,0x3
    80005568:	0d078793          	addi	a5,a5,208
    8000556c:	94be                	add	s1,s1,a5
    8000556e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005572:	fd043503          	ld	a0,-48(s0)
    80005576:	be3fe0ef          	jal	80004158 <fileclose>
    fileclose(wf);
    8000557a:	fc843503          	ld	a0,-56(s0)
    8000557e:	bdbfe0ef          	jal	80004158 <fileclose>
    return -1;
    80005582:	57fd                	li	a5,-1
    80005584:	a025                	j	800055ac <sys_pipe+0xda>
    if (fd0 >= 0)
    80005586:	fc442783          	lw	a5,-60(s0)
    8000558a:	0007c863          	bltz	a5,8000559a <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    8000558e:	078e                	slli	a5,a5,0x3
    80005590:	0d078793          	addi	a5,a5,208
    80005594:	97a6                	add	a5,a5,s1
    80005596:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000559a:	fd043503          	ld	a0,-48(s0)
    8000559e:	bbbfe0ef          	jal	80004158 <fileclose>
    fileclose(wf);
    800055a2:	fc843503          	ld	a0,-56(s0)
    800055a6:	bb3fe0ef          	jal	80004158 <fileclose>
    return -1;
    800055aa:	57fd                	li	a5,-1
}
    800055ac:	853e                	mv	a0,a5
    800055ae:	70e2                	ld	ra,56(sp)
    800055b0:	7442                	ld	s0,48(sp)
    800055b2:	74a2                	ld	s1,40(sp)
    800055b4:	6121                	addi	sp,sp,64
    800055b6:	8082                	ret
	...

00000000800055c0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800055c0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800055c2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800055c4:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    800055c6:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800055c8:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800055ca:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800055cc:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800055ce:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800055d0:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800055d2:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800055d4:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800055d6:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800055d8:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800055da:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800055dc:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800055de:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800055e0:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800055e2:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800055e4:	8f8fd0ef          	jal	800026dc <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800055e8:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800055ea:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800055ec:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800055ee:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800055f0:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800055f2:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800055f4:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800055f6:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800055f8:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800055fa:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800055fc:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800055fe:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005600:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005602:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005604:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005606:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005608:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000560a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000560c:	10200073          	sret
    80005610:	0001                	nop
    80005612:	00000013          	nop
    80005616:	00000013          	nop
    8000561a:	00000013          	nop

000000008000561e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000561e:	1141                	addi	sp,sp,-16
    80005620:	e406                	sd	ra,8(sp)
    80005622:	e022                	sd	s0,0(sp)
    80005624:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005626:	0c000737          	lui	a4,0xc000
    8000562a:	4785                	li	a5,1
    8000562c:	d71c                	sw	a5,40(a4)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000562e:	c35c                	sw	a5,4(a4)
}
    80005630:	60a2                	ld	ra,8(sp)
    80005632:	6402                	ld	s0,0(sp)
    80005634:	0141                	addi	sp,sp,16
    80005636:	8082                	ret

0000000080005638 <plicinithart>:

void
plicinithart(void)
{
    80005638:	1141                	addi	sp,sp,-16
    8000563a:	e406                	sd	ra,8(sp)
    8000563c:	e022                	sd	s0,0(sp)
    8000563e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005640:	a94fc0ef          	jal	800018d4 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005644:	0085171b          	slliw	a4,a0,0x8
    80005648:	0c0027b7          	lui	a5,0xc002
    8000564c:	97ba                	add	a5,a5,a4
    8000564e:	40200713          	li	a4,1026
    80005652:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005656:	00d5151b          	slliw	a0,a0,0xd
    8000565a:	0c2017b7          	lui	a5,0xc201
    8000565e:	97aa                	add	a5,a5,a0
    80005660:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005664:	60a2                	ld	ra,8(sp)
    80005666:	6402                	ld	s0,0(sp)
    80005668:	0141                	addi	sp,sp,16
    8000566a:	8082                	ret

000000008000566c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000566c:	1141                	addi	sp,sp,-16
    8000566e:	e406                	sd	ra,8(sp)
    80005670:	e022                	sd	s0,0(sp)
    80005672:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005674:	a60fc0ef          	jal	800018d4 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80005678:	00d5151b          	slliw	a0,a0,0xd
    8000567c:	0c2017b7          	lui	a5,0xc201
    80005680:	97aa                	add	a5,a5,a0
  return irq;
}
    80005682:	43c8                	lw	a0,4(a5)
    80005684:	60a2                	ld	ra,8(sp)
    80005686:	6402                	ld	s0,0(sp)
    80005688:	0141                	addi	sp,sp,16
    8000568a:	8082                	ret

000000008000568c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000568c:	1101                	addi	sp,sp,-32
    8000568e:	ec06                	sd	ra,24(sp)
    80005690:	e822                	sd	s0,16(sp)
    80005692:	e426                	sd	s1,8(sp)
    80005694:	1000                	addi	s0,sp,32
    80005696:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005698:	a3cfc0ef          	jal	800018d4 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    8000569c:	00d5179b          	slliw	a5,a0,0xd
    800056a0:	0c201737          	lui	a4,0xc201
    800056a4:	97ba                	add	a5,a5,a4
    800056a6:	c3c4                	sw	s1,4(a5)
}
    800056a8:	60e2                	ld	ra,24(sp)
    800056aa:	6442                	ld	s0,16(sp)
    800056ac:	64a2                	ld	s1,8(sp)
    800056ae:	6105                	addi	sp,sp,32
    800056b0:	8082                	ret

00000000800056b2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800056b2:	1141                	addi	sp,sp,-16
    800056b4:	e406                	sd	ra,8(sp)
    800056b6:	e022                	sd	s0,0(sp)
    800056b8:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800056ba:	479d                	li	a5,7
    800056bc:	04a7ca63          	blt	a5,a0,80005710 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    800056c0:	0001e797          	auipc	a5,0x1e
    800056c4:	e0078793          	addi	a5,a5,-512 # 800234c0 <disk>
    800056c8:	97aa                	add	a5,a5,a0
    800056ca:	0187c783          	lbu	a5,24(a5)
    800056ce:	e7b9                	bnez	a5,8000571c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800056d0:	00451693          	slli	a3,a0,0x4
    800056d4:	0001e797          	auipc	a5,0x1e
    800056d8:	dec78793          	addi	a5,a5,-532 # 800234c0 <disk>
    800056dc:	6398                	ld	a4,0(a5)
    800056de:	9736                	add	a4,a4,a3
    800056e0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800056e4:	6398                	ld	a4,0(a5)
    800056e6:	9736                	add	a4,a4,a3
    800056e8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800056ec:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800056f0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800056f4:	97aa                	add	a5,a5,a0
    800056f6:	4705                	li	a4,1
    800056f8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800056fc:	0001e517          	auipc	a0,0x1e
    80005700:	ddc50513          	addi	a0,a0,-548 # 800234d8 <disk+0x18>
    80005704:	88bfc0ef          	jal	80001f8e <wakeup>
}
    80005708:	60a2                	ld	ra,8(sp)
    8000570a:	6402                	ld	s0,0(sp)
    8000570c:	0141                	addi	sp,sp,16
    8000570e:	8082                	ret
    panic("free_desc 1");
    80005710:	00002517          	auipc	a0,0x2
    80005714:	f2050513          	addi	a0,a0,-224 # 80007630 <etext+0x630>
    80005718:	91cfb0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    8000571c:	00002517          	auipc	a0,0x2
    80005720:	f2450513          	addi	a0,a0,-220 # 80007640 <etext+0x640>
    80005724:	910fb0ef          	jal	80000834 <panic>

0000000080005728 <virtio_disk_init>:
{
    80005728:	1101                	addi	sp,sp,-32
    8000572a:	ec06                	sd	ra,24(sp)
    8000572c:	e822                	sd	s0,16(sp)
    8000572e:	e426                	sd	s1,8(sp)
    80005730:	e04a                	sd	s2,0(sp)
    80005732:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005734:	00002597          	auipc	a1,0x2
    80005738:	f1c58593          	addi	a1,a1,-228 # 80007650 <etext+0x650>
    8000573c:	0001e517          	auipc	a0,0x1e
    80005740:	eac50513          	addi	a0,a0,-340 # 800235e8 <disk+0x128>
    80005744:	c24fb0ef          	jal	80000b68 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005748:	100017b7          	lui	a5,0x10001
    8000574c:	4398                	lw	a4,0(a5)
    8000574e:	2701                	sext.w	a4,a4
    80005750:	747277b7          	lui	a5,0x74727
    80005754:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005758:	14f71863          	bne	a4,a5,800058a8 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000575c:	100017b7          	lui	a5,0x10001
    80005760:	43dc                	lw	a5,4(a5)
    80005762:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005764:	4709                	li	a4,2
    80005766:	14e79163          	bne	a5,a4,800058a8 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000576a:	100017b7          	lui	a5,0x10001
    8000576e:	479c                	lw	a5,8(a5)
    80005770:	2781                	sext.w	a5,a5
    80005772:	12e79b63          	bne	a5,a4,800058a8 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80005776:	100017b7          	lui	a5,0x10001
    8000577a:	47d8                	lw	a4,12(a5)
    8000577c:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000577e:	554d47b7          	lui	a5,0x554d4
    80005782:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005786:	12f71163          	bne	a4,a5,800058a8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000578a:	100017b7          	lui	a5,0x10001
    8000578e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005792:	4705                	li	a4,1
    80005794:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005796:	470d                	li	a4,3
    80005798:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000579a:	10001737          	lui	a4,0x10001
    8000579e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800057a0:	c7ffe6b7          	lui	a3,0xc7ffe
    800057a4:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdaf5f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800057a8:	8f75                	and	a4,a4,a3
    800057aa:	100016b7          	lui	a3,0x10001
    800057ae:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057b0:	472d                	li	a4,11
    800057b2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057b4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800057b8:	439c                	lw	a5,0(a5)
    800057ba:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800057be:	8ba1                	andi	a5,a5,8
    800057c0:	0e078a63          	beqz	a5,800058b4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800057c4:	100017b7          	lui	a5,0x10001
    800057c8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    800057cc:	43fc                	lw	a5,68(a5)
    800057ce:	2781                	sext.w	a5,a5
    800057d0:	0e079863          	bnez	a5,800058c0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800057d4:	100017b7          	lui	a5,0x10001
    800057d8:	5bdc                	lw	a5,52(a5)
    800057da:	2781                	sext.w	a5,a5
  if (max == 0)
    800057dc:	0e078863          	beqz	a5,800058cc <virtio_disk_init+0x1a4>
  if (max < NUM)
    800057e0:	471d                	li	a4,7
    800057e2:	0ef77b63          	bgeu	a4,a5,800058d8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800057e6:	b28fb0ef          	jal	80000b0e <kalloc>
    800057ea:	0001e497          	auipc	s1,0x1e
    800057ee:	cd648493          	addi	s1,s1,-810 # 800234c0 <disk>
    800057f2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800057f4:	b1afb0ef          	jal	80000b0e <kalloc>
    800057f8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800057fa:	b14fb0ef          	jal	80000b0e <kalloc>
    800057fe:	87aa                	mv	a5,a0
    80005800:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005802:	6088                	ld	a0,0(s1)
    80005804:	0e050063          	beqz	a0,800058e4 <virtio_disk_init+0x1bc>
    80005808:	0001e717          	auipc	a4,0x1e
    8000580c:	cc073703          	ld	a4,-832(a4) # 800234c8 <disk+0x8>
    80005810:	cb71                	beqz	a4,800058e4 <virtio_disk_init+0x1bc>
    80005812:	cbe9                	beqz	a5,800058e4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005814:	6605                	lui	a2,0x1
    80005816:	4581                	li	a1,0
    80005818:	c90fb0ef          	jal	80000ca8 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000581c:	0001e497          	auipc	s1,0x1e
    80005820:	ca448493          	addi	s1,s1,-860 # 800234c0 <disk>
    80005824:	6605                	lui	a2,0x1
    80005826:	4581                	li	a1,0
    80005828:	6488                	ld	a0,8(s1)
    8000582a:	c7efb0ef          	jal	80000ca8 <memset>
  memset(disk.used, 0, PGSIZE);
    8000582e:	6605                	lui	a2,0x1
    80005830:	4581                	li	a1,0
    80005832:	6888                	ld	a0,16(s1)
    80005834:	c74fb0ef          	jal	80000ca8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005838:	100017b7          	lui	a5,0x10001
    8000583c:	4721                	li	a4,8
    8000583e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005840:	4098                	lw	a4,0(s1)
    80005842:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005846:	40d8                	lw	a4,4(s1)
    80005848:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000584c:	649c                	ld	a5,8(s1)
    8000584e:	0007869b          	sext.w	a3,a5
    80005852:	10001737          	lui	a4,0x10001
    80005856:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000585a:	9781                	srai	a5,a5,0x20
    8000585c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005860:	689c                	ld	a5,16(s1)
    80005862:	0007869b          	sext.w	a3,a5
    80005866:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000586a:	9781                	srai	a5,a5,0x20
    8000586c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005870:	4785                	li	a5,1
    80005872:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005874:	00f48c23          	sb	a5,24(s1)
    80005878:	00f48ca3          	sb	a5,25(s1)
    8000587c:	00f48d23          	sb	a5,26(s1)
    80005880:	00f48da3          	sb	a5,27(s1)
    80005884:	00f48e23          	sb	a5,28(s1)
    80005888:	00f48ea3          	sb	a5,29(s1)
    8000588c:	00f48f23          	sb	a5,30(s1)
    80005890:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005894:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005898:	07272823          	sw	s2,112(a4)
}
    8000589c:	60e2                	ld	ra,24(sp)
    8000589e:	6442                	ld	s0,16(sp)
    800058a0:	64a2                	ld	s1,8(sp)
    800058a2:	6902                	ld	s2,0(sp)
    800058a4:	6105                	addi	sp,sp,32
    800058a6:	8082                	ret
    panic("could not find virtio disk");
    800058a8:	00002517          	auipc	a0,0x2
    800058ac:	db850513          	addi	a0,a0,-584 # 80007660 <etext+0x660>
    800058b0:	f85fa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    800058b4:	00002517          	auipc	a0,0x2
    800058b8:	dcc50513          	addi	a0,a0,-564 # 80007680 <etext+0x680>
    800058bc:	f79fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    800058c0:	00002517          	auipc	a0,0x2
    800058c4:	de050513          	addi	a0,a0,-544 # 800076a0 <etext+0x6a0>
    800058c8:	f6dfa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    800058cc:	00002517          	auipc	a0,0x2
    800058d0:	df450513          	addi	a0,a0,-524 # 800076c0 <etext+0x6c0>
    800058d4:	f61fa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    800058d8:	00002517          	auipc	a0,0x2
    800058dc:	e0850513          	addi	a0,a0,-504 # 800076e0 <etext+0x6e0>
    800058e0:	f55fa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    800058e4:	00002517          	auipc	a0,0x2
    800058e8:	e1c50513          	addi	a0,a0,-484 # 80007700 <etext+0x700>
    800058ec:	f49fa0ef          	jal	80000834 <panic>

00000000800058f0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800058f0:	711d                	addi	sp,sp,-96
    800058f2:	ec86                	sd	ra,88(sp)
    800058f4:	e8a2                	sd	s0,80(sp)
    800058f6:	e4a6                	sd	s1,72(sp)
    800058f8:	e0ca                	sd	s2,64(sp)
    800058fa:	fc4e                	sd	s3,56(sp)
    800058fc:	f852                	sd	s4,48(sp)
    800058fe:	f456                	sd	s5,40(sp)
    80005900:	f05a                	sd	s6,32(sp)
    80005902:	ec5e                	sd	s7,24(sp)
    80005904:	e862                	sd	s8,16(sp)
    80005906:	1080                	addi	s0,sp,96
    80005908:	89aa                	mv	s3,a0
    8000590a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000590c:	00c52b83          	lw	s7,12(a0)
    80005910:	001b9b9b          	slliw	s7,s7,0x1
    80005914:	1b82                	slli	s7,s7,0x20
    80005916:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    8000591a:	0001e517          	auipc	a0,0x1e
    8000591e:	cce50513          	addi	a0,a0,-818 # 800235e8 <disk+0x128>
    80005922:	ac6fb0ef          	jal	80000be8 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005926:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005928:	0001ea97          	auipc	s5,0x1e
    8000592c:	b98a8a93          	addi	s5,s5,-1128 # 800234c0 <disk>
  for (int i = 0; i < 3; i++) {
    80005930:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005932:	5c7d                	li	s8,-1
    80005934:	a8a5                	j	800059ac <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005936:	00fa8733          	add	a4,s5,a5
    8000593a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000593e:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005940:	0207c563          	bltz	a5,8000596a <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005944:	2905                	addiw	s2,s2,1
    80005946:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005948:	07490663          	beq	s2,s4,800059b4 <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    8000594c:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    8000594e:	0001e717          	auipc	a4,0x1e
    80005952:	b7270713          	addi	a4,a4,-1166 # 800234c0 <disk>
    80005956:	4781                	li	a5,0
    if (disk.free[i]) {
    80005958:	01874683          	lbu	a3,24(a4)
    8000595c:	fee9                	bnez	a3,80005936 <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    8000595e:	2785                	addiw	a5,a5,1
    80005960:	0705                	addi	a4,a4,1
    80005962:	fe979be3          	bne	a5,s1,80005958 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005966:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    8000596a:	01205d63          	blez	s2,80005984 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000596e:	fa042503          	lw	a0,-96(s0)
    80005972:	d41ff0ef          	jal	800056b2 <free_desc>
      for (int j = 0; j < i; j++)
    80005976:	4785                	li	a5,1
    80005978:	0127d663          	bge	a5,s2,80005984 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000597c:	fa442503          	lw	a0,-92(s0)
    80005980:	d33ff0ef          	jal	800056b2 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005984:	0001e517          	auipc	a0,0x1e
    80005988:	b5450513          	addi	a0,a0,-1196 # 800234d8 <disk+0x18>
    8000598c:	d96fc0ef          	jal	80001f22 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005990:	0001e517          	auipc	a0,0x1e
    80005994:	c5850513          	addi	a0,a0,-936 # 800235e8 <disk+0x128>
    80005998:	ad8fb0ef          	jal	80000c70 <release>
    sleep();
    8000599c:	dc2fc0ef          	jal	80001f5e <sleep>
    acquire(&disk.vdisk_lock);
    800059a0:	0001e517          	auipc	a0,0x1e
    800059a4:	c4850513          	addi	a0,a0,-952 # 800235e8 <disk+0x128>
    800059a8:	a40fb0ef          	jal	80000be8 <acquire>
  for (int i = 0; i < 3; i++) {
    800059ac:	fa040613          	addi	a2,s0,-96
    800059b0:	4901                	li	s2,0
    800059b2:	bf69                	j	8000594c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800059b4:	fa042503          	lw	a0,-96(s0)
    800059b8:	00451693          	slli	a3,a0,0x4

  if (write)
    800059bc:	0001e797          	auipc	a5,0x1e
    800059c0:	b0478793          	addi	a5,a5,-1276 # 800234c0 <disk>
    800059c4:	00451713          	slli	a4,a0,0x4
    800059c8:	0a070713          	addi	a4,a4,160
    800059cc:	973e                	add	a4,a4,a5
    800059ce:	01603633          	snez	a2,s6
    800059d2:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800059d4:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800059d8:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    800059dc:	6398                	ld	a4,0(a5)
    800059de:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800059e0:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    800059e4:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    800059e6:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800059e8:	6390                	ld	a2,0(a5)
    800059ea:	00d60833          	add	a6,a2,a3
    800059ee:	4741                	li	a4,16
    800059f0:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800059f4:	4585                	li	a1,1
    800059f6:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    800059fa:	fa442703          	lw	a4,-92(s0)
    800059fe:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005a02:	0712                	slli	a4,a4,0x4
    80005a04:	963a                	add	a2,a2,a4
    80005a06:	05898813          	addi	a6,s3,88
    80005a0a:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005a0e:	0007b883          	ld	a7,0(a5)
    80005a12:	9746                	add	a4,a4,a7
    80005a14:	40000613          	li	a2,1024
    80005a18:	c710                	sw	a2,8(a4)
  if (write)
    80005a1a:	001b3613          	seqz	a2,s6
    80005a1e:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005a22:	8e4d                	or	a2,a2,a1
    80005a24:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005a28:	fa842603          	lw	a2,-88(s0)
    80005a2c:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005a30:	00451813          	slli	a6,a0,0x4
    80005a34:	02080813          	addi	a6,a6,32
    80005a38:	983e                	add	a6,a6,a5
    80005a3a:	577d                	li	a4,-1
    80005a3c:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005a40:	0612                	slli	a2,a2,0x4
    80005a42:	98b2                	add	a7,a7,a2
    80005a44:	03068713          	addi	a4,a3,48
    80005a48:	973e                	add	a4,a4,a5
    80005a4a:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005a4e:	6398                	ld	a4,0(a5)
    80005a50:	9732                	add	a4,a4,a2
    80005a52:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005a54:	4689                	li	a3,2
    80005a56:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005a5a:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005a5e:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005a62:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005a66:	6794                	ld	a3,8(a5)
    80005a68:	0026d703          	lhu	a4,2(a3)
    80005a6c:	8b1d                	andi	a4,a4,7
    80005a6e:	0706                	slli	a4,a4,0x1
    80005a70:	96ba                	add	a3,a3,a4
    80005a72:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005a76:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005a7a:	6798                	ld	a4,8(a5)
    80005a7c:	00275783          	lhu	a5,2(a4)
    80005a80:	2785                	addiw	a5,a5,1
    80005a82:	00f71123          	sh	a5,2(a4)
    80005a86:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005a8a:	100017b7          	lui	a5,0x10001
    80005a8e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005a92:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005a96:	0001e497          	auipc	s1,0x1e
    80005a9a:	b5248493          	addi	s1,s1,-1198 # 800235e8 <disk+0x128>
  while (b->disk == 1) {
    80005a9e:	892e                	mv	s2,a1
    80005aa0:	02b79163          	bne	a5,a1,80005ac2 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005aa4:	854e                	mv	a0,s3
    80005aa6:	c7cfc0ef          	jal	80001f22 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005aaa:	8526                	mv	a0,s1
    80005aac:	9c4fb0ef          	jal	80000c70 <release>
    sleep();
    80005ab0:	caefc0ef          	jal	80001f5e <sleep>
    acquire(&disk.vdisk_lock);
    80005ab4:	8526                	mv	a0,s1
    80005ab6:	932fb0ef          	jal	80000be8 <acquire>
  while (b->disk == 1) {
    80005aba:	0049a783          	lw	a5,4(s3)
    80005abe:	ff2783e3          	beq	a5,s2,80005aa4 <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005ac2:	fa042903          	lw	s2,-96(s0)
    80005ac6:	00491713          	slli	a4,s2,0x4
    80005aca:	02070713          	addi	a4,a4,32
    80005ace:	0001e797          	auipc	a5,0x1e
    80005ad2:	9f278793          	addi	a5,a5,-1550 # 800234c0 <disk>
    80005ad6:	97ba                	add	a5,a5,a4
    80005ad8:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005adc:	0001e997          	auipc	s3,0x1e
    80005ae0:	9e498993          	addi	s3,s3,-1564 # 800234c0 <disk>
    80005ae4:	00491713          	slli	a4,s2,0x4
    80005ae8:	0009b783          	ld	a5,0(s3)
    80005aec:	97ba                	add	a5,a5,a4
    80005aee:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005af2:	854a                	mv	a0,s2
    80005af4:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005af8:	bbbff0ef          	jal	800056b2 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005afc:	8885                	andi	s1,s1,1
    80005afe:	f0fd                	bnez	s1,80005ae4 <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005b00:	0001e517          	auipc	a0,0x1e
    80005b04:	ae850513          	addi	a0,a0,-1304 # 800235e8 <disk+0x128>
    80005b08:	968fb0ef          	jal	80000c70 <release>
}
    80005b0c:	60e6                	ld	ra,88(sp)
    80005b0e:	6446                	ld	s0,80(sp)
    80005b10:	64a6                	ld	s1,72(sp)
    80005b12:	6906                	ld	s2,64(sp)
    80005b14:	79e2                	ld	s3,56(sp)
    80005b16:	7a42                	ld	s4,48(sp)
    80005b18:	7aa2                	ld	s5,40(sp)
    80005b1a:	7b02                	ld	s6,32(sp)
    80005b1c:	6be2                	ld	s7,24(sp)
    80005b1e:	6c42                	ld	s8,16(sp)
    80005b20:	6125                	addi	sp,sp,96
    80005b22:	8082                	ret

0000000080005b24 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005b24:	1101                	addi	sp,sp,-32
    80005b26:	ec06                	sd	ra,24(sp)
    80005b28:	e822                	sd	s0,16(sp)
    80005b2a:	e426                	sd	s1,8(sp)
    80005b2c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005b2e:	0001e497          	auipc	s1,0x1e
    80005b32:	99248493          	addi	s1,s1,-1646 # 800234c0 <disk>
    80005b36:	0001e517          	auipc	a0,0x1e
    80005b3a:	ab250513          	addi	a0,a0,-1358 # 800235e8 <disk+0x128>
    80005b3e:	8aafb0ef          	jal	80000be8 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005b42:	100017b7          	lui	a5,0x10001
    80005b46:	53bc                	lw	a5,96(a5)
    80005b48:	8b8d                	andi	a5,a5,3
    80005b4a:	10001737          	lui	a4,0x10001
    80005b4e:	d37c                	sw	a5,100(a4)
    80005b50:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005b54:	689c                	ld	a5,16(s1)
    80005b56:	0204d703          	lhu	a4,32(s1)
    80005b5a:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005b5e:	04f70863          	beq	a4,a5,80005bae <virtio_disk_intr+0x8a>
    80005b62:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005b66:	6898                	ld	a4,16(s1)
    80005b68:	0204d783          	lhu	a5,32(s1)
    80005b6c:	8b9d                	andi	a5,a5,7
    80005b6e:	078e                	slli	a5,a5,0x3
    80005b70:	97ba                	add	a5,a5,a4
    80005b72:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005b74:	00479713          	slli	a4,a5,0x4
    80005b78:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005b7c:	9726                	add	a4,a4,s1
    80005b7e:	01074703          	lbu	a4,16(a4)
    80005b82:	e329                	bnez	a4,80005bc4 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005b84:	0792                	slli	a5,a5,0x4
    80005b86:	02078793          	addi	a5,a5,32
    80005b8a:	97a6                	add	a5,a5,s1
    80005b8c:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005b8e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005b92:	bfcfc0ef          	jal	80001f8e <wakeup>

    disk.used_idx += 1;
    80005b96:	0204d783          	lhu	a5,32(s1)
    80005b9a:	2785                	addiw	a5,a5,1
    80005b9c:	17c2                	slli	a5,a5,0x30
    80005b9e:	93c1                	srli	a5,a5,0x30
    80005ba0:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005ba4:	6898                	ld	a4,16(s1)
    80005ba6:	00275703          	lhu	a4,2(a4)
    80005baa:	faf71ce3          	bne	a4,a5,80005b62 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005bae:	0001e517          	auipc	a0,0x1e
    80005bb2:	a3a50513          	addi	a0,a0,-1478 # 800235e8 <disk+0x128>
    80005bb6:	8bafb0ef          	jal	80000c70 <release>
}
    80005bba:	60e2                	ld	ra,24(sp)
    80005bbc:	6442                	ld	s0,16(sp)
    80005bbe:	64a2                	ld	s1,8(sp)
    80005bc0:	6105                	addi	sp,sp,32
    80005bc2:	8082                	ret
      panic("virtio_disk_intr status");
    80005bc4:	00002517          	auipc	a0,0x2
    80005bc8:	b5450513          	addi	a0,a0,-1196 # 80007718 <etext+0x718>
    80005bcc:	c69fa0ef          	jal	80000834 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	0000100f          	fence.i
    800060a0:	12000073          	sfence.vma
    800060a4:	18051073          	csrw	satp,a0
    800060a8:	12000073          	sfence.vma
    800060ac:	02000537          	lui	a0,0x2000
    800060b0:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060b2:	0536                	slli	a0,a0,0xd
    800060b4:	02853083          	ld	ra,40(a0)
    800060b8:	03053103          	ld	sp,48(a0)
    800060bc:	03853183          	ld	gp,56(a0)
    800060c0:	04053203          	ld	tp,64(a0)
    800060c4:	04853283          	ld	t0,72(a0)
    800060c8:	05053303          	ld	t1,80(a0)
    800060cc:	05853383          	ld	t2,88(a0)
    800060d0:	7120                	ld	s0,96(a0)
    800060d2:	7524                	ld	s1,104(a0)
    800060d4:	7d2c                	ld	a1,120(a0)
    800060d6:	6150                	ld	a2,128(a0)
    800060d8:	6554                	ld	a3,136(a0)
    800060da:	6958                	ld	a4,144(a0)
    800060dc:	6d5c                	ld	a5,152(a0)
    800060de:	0a053803          	ld	a6,160(a0)
    800060e2:	0a853883          	ld	a7,168(a0)
    800060e6:	0b053903          	ld	s2,176(a0)
    800060ea:	0b853983          	ld	s3,184(a0)
    800060ee:	0c053a03          	ld	s4,192(a0)
    800060f2:	0c853a83          	ld	s5,200(a0)
    800060f6:	0d053b03          	ld	s6,208(a0)
    800060fa:	0d853b83          	ld	s7,216(a0)
    800060fe:	0e053c03          	ld	s8,224(a0)
    80006102:	0e853c83          	ld	s9,232(a0)
    80006106:	0f053d03          	ld	s10,240(a0)
    8000610a:	0f853d83          	ld	s11,248(a0)
    8000610e:	10053e03          	ld	t3,256(a0)
    80006112:	10853e83          	ld	t4,264(a0)
    80006116:	11053f03          	ld	t5,272(a0)
    8000611a:	11853f83          	ld	t6,280(a0)
    8000611e:	7928                	ld	a0,112(a0)
    80006120:	10200073          	sret
	...
