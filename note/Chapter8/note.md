# 内存管理系统
### 文件的三种时间
（1）atime，即 access time，表示访问文件数据部分时间，每次读取文件数据部分时就会更新 atime，读取文件数据（内容）时改变 atime，比如 cat 或 less 命令查看文件就可以更新 atime，而 ls 命令则不会。
（2）ctime，即 change time，表示文件属性或数据的改变时间，每当文件的属性或数据被修改时，就会更新 ctime，也就是说 ctime 同时跟踪文件属性和文件数据变化的时间。
（3）mtime，即 modify time，表示文件数据部分的修改时间，每次文件的数据被修改时就会更新 mtime。当文件数据被修改时，mtime 和 ctime 一同更新。
### assert断言
### 位图 bitmap
*bitmap，广泛用于资源管理，是一种管理资源的方式、手段*
