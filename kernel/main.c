#include "../include/lib/print.h"
#include "../include/kernel/init.h"
#include "../include/kernel/debug.h"
#include "../include/kernel/memory.h"
#include "../include/thread/thread.h"
#include "../include/kernel/interrupt.h"
#include "../include/device/console.h"
#include "../include/userprog/process.h"
#include "../include/userprog/syscall-init.h"
#include "../include/user/syscall.h"
#include "../include/user/stdio.h"
#include "../include/fs/fs.h"


int main(void)
{
    put_str("I am kernel\n");
    init_all();
    /********  测试代码  ********/
    struct stat obj_stat;
    sys_stat("/", &obj_stat);
    printf("/`s info\n   i_no:%d\n   size:%d\n   filetype:%s\n",
           obj_stat.st_ino, obj_stat.st_size,
           obj_stat.st_filetype == 2 ? "directory" : "regular");
    sys_stat("/dir1", &obj_stat);
    printf("/dir1`s info\n   i_no:%d\n   size:%d\n   filetype:%s\n",
           obj_stat.st_ino, obj_stat.st_size,
           obj_stat.st_filetype == 2 ? "directory" : "regular");
    /********  测试代码  ********/
    while (1)
        ;
    return 0;
}