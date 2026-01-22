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
#include "../include/userprog/fork.h"
#include "../include/user/assert.h"
#include "../include/shell/shell.h"
#include "../include/device/ide.h"
#include "../include/kernel/stdio-kernel.h"

void init(void);

int main(void)
{
    put_str("I am kernel\n");
    init_all();

    uint32_t file_size = 21816;
    uint32_t sec_cnt = DIV_ROUND_UP(file_size, 512);
    struct disk *sda = &channels[0].devices[0];
    void *prog_buf = sys_malloc(file_size);
    ide_read(sda, 300, prog_buf, sec_cnt);
    int32_t fd = sys_open("/cat", O_CREAT | O_RDWR);
    if (fd != -1)
    {
        if (sys_write(fd, prog_buf, file_size) == -1)
        {
            printk("file write error!\n");
            while (1)
                ;
        }
    }

    cls_screen();
    console_put_str("[rabbit@localhost /]$ ");
    thread_exit(running_thread(), true);
    return 0;
}

/* init进程 */
void init(void)
{
    uint32_t ret_pid = fork();
    if (ret_pid)
    { // 父进程
        int status;
        int child_pid;
        /* init在此处不停的回收僵尸进程 */
        while (1)
        {
            child_pid = wait(&status);
            printf("I`m init, My pid is 1, I recieve a child, It`s pid is %d, status is %d\n", child_pid, status);
        }
    }
    else
    { // 子进程
        my_shell();
    }
    panic("init: should not be here");
}

