# OS

## 项目简介

这是一个从零开始实现的 **x86 架构、32 位保护模式下的简易操作系统内核**，主要参考《操作系统真相还原》一书完成，目标是通过“自己动手实现”的方式，深入理解操作系统的核心机制。

当前系统已完成从  
**引导 → 内核初始化 → 中断管理 → 内存管理 → 线程调度 → 用户进程切换 → 硬盘访问**  
的完整执行链路。

---

## 项目架构
```
OS/
├── boot/                    # 启动阶段（实模式 → 保护模式）
│   ├── mbr.S                # 主引导记录（MBR）
│   └── loader.S             # 二级加载器，进入保护模式并加载内核
│
├── kernel/                  # 内核核心（Ring0）
│   ├── main.c               # 内核入口函数
│   ├── init.c               # 内核子系统初始化
│   ├── interrupt.c          # 中断管理与 IDT 初始化
│   ├── memory.c             # 内存管理（位图 / 页表）
│   ├── list.c               # 内核双向链表
│   ├── debug.c              # 调试与断言
│   ├── stdio-kernel.c       # 内核态输出支持
│   └── kernel.asm           # 中断入口与汇编支持代码
│
├── device/                  # 设备驱动
│   ├── time.c               # 时钟中断（系统节拍）
│   ├── keyboard.c           # 键盘驱动
│   ├── console.c            # 控制台输出
│   ├── ioqueue.c            # IO 队列（键盘缓冲区）
│   └── ide.c                # IDE 硬盘驱动（ATA PIO）
│
├── thread/                  # 线程与同步机制
│   ├── thread.c             # 线程管理与调度
│   ├── sync.c               # 锁 / 信号量
│   └── switch.asm           # 上下文切换
│
├── userprog/                # 用户进程支持（内核侧）
│   ├── process.c            # 用户进程创建与切换
│   ├── tss.c                # TSS 初始化
│   ├── fork.c               # fork 实现
│   ├── exec.c               # exec 实现
│   ├── wait_exit.c          # wait / exit
│   └── syscall-init.c       # 系统调用初始化
│
├── fs/                      # 文件系统
│   ├── fs.c                 # 文件系统初始化与接口
│   ├── inode.c              # inode 管理
│   ├── file.c               # 文件操作
│   └── dir.c                # 目录操作
│
├── shell/                   # Shell（用户态）
│   ├── shell.c              # Shell 主循环
│   ├── buildin_cmd.c        # 内建命令（cd / ls / pwd 等）
│   └── pipe.c               # 管道与重定向支持
│
├── lib/                     # 基础库
│   ├── bitmap.c             # 位图
│   ├── string.c             # 字符串操作
│   ├── print.asm            # 内核打印
│   └── user/                # 用户态库
│       ├── syscall.c        # 系统调用封装
│       ├── stdio.c          # 用户态 IO
│       └── assert.c         # 用户态断言
│
├── include/                 # 头文件
│   ├── kernel/
│   ├── device/
│   ├── thread/
│   ├── userprog/
│   ├── fs/
│   ├── shell/
│   ├── user/
│   └── lib/
│
├── build/                   # 编译产物
│
├── note/                    # 实现与学习笔记
├── Makefile                 # 构建脚本
└── README.md

```
---

## 快速开始
1. 获取源码
```
git clone https://github.com/L-iuxi/OS.git
```

本项目默认在 Linux 环境 下构建和运行，推荐使用 Ubuntu。

2. 安装依赖
**Bochs（x86 模拟器）**

本项目使用 Bochs 运行和调试 32 位 x86 操作系统内核。

👉 [Bochs 安装与配置](https://blog.csdn.net/kanshanxd/article/details/130689471?spm=1001.2014.3001.5502)


请确保 Bochs 编译时启用了调试器（--enable-debugger），否则将无法进行单步调试。

**GCC（32 位编译支持）**

内核使用 GCC 进行编译，需要支持 32 位目标。

👉 [GCC 4.6.1版本安装](https://blog.csdn.net/wu11zhike/article/details/83865549?utm_medium=distribute.pc_relevant.none-task-blog-2~default~BlogCommendFromMachineLearnPai2~default-4.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2~default~BlogCommendFromMachineLearnPai2~default-4.control)


请确认系统支持 -m32 编译选项，必要时需安装 32 位开发库。


3. 创建构建目录
```
mkdir -p build
```

build/ 目录用于存放编译生成的目标文件及相关产物。

4. 编译内核

在项目根目录下执行：

```
make
```

编译成功后，将生成内核镜像并写入虚拟磁盘。

5. 运行操作系统

使用 Bochs 启动系统：
```
bochs
```

或指定配置文件：
```
bochs -f bochsrc
```

启动后可在 Bochs 窗口中观察系统引导、内核初始化及 Shell 运行情况。

6. 调试（可选）

Bochs 提供内置调试器，支持单步执行、寄存器查看、中断跟踪与内存检查，
适合用于分析和验证操作系统底层行为。

---

