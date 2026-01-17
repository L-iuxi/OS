#include "../include/device/time.h"
#include "../include/kernel/init.h"
#include "../include/lib/print.h"
#include "../include/kernel/interrupt.h"
#include "../include/kernel/memory.h"

/*负责初始化所有模块 */
void init_all() {
   put_str("init_all\n");
   idt_init();   //初始化中断
   timer_init();
   mem_init();	  // 初始化内存管理系统
}
