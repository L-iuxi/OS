#include "../include/device/time.h"
#include "../include/kernel/init.h"
#include "../include/lib/print.h"
#include "../include/kernel/interrupt.h"
#include "../include/kernel/memory.h"
#include "../include/thread/thread.h"
#include "../include/device/console.h"
#include "../include/device/keyboard.h"

/*负责初始化所有模块 */
void init_all() {
   put_str("init_all\n");
   idt_init();   //初始化中断
   mem_init();	  // 初始化内存管理系统
   thread_init(); // 初始化线程相关结构
   timer_init();  
   console_init();
   keyboard_init();  // 键盘初始化
}
